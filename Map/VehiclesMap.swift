import SwiftUI
import SwiftData
import Combine
import MapKit
import SupportPackageViews

struct VehiclesMap: View {
    
    private class Model: ObservableObject {
        
        @Published var displayedVehicles: [MapRequest.VehicleResponse] = []
        @Published var selectedItem: Int?
        @Published var loading = true
        
        var selectedVehicle: MapRequest.VehicleResponse? {
            selectedItem.flatMap { item in vehicles.first(where: { $0.ID == item })}
        }
        
        private var vehicles: [MapRequest.VehicleResponse] = []
        private var mapPosition: MKMapRect?
        private var timer = Timer()
        private var cancellables: Set<AnyCancellable> = []
        private var canUpdate = true
        
        init(mapPosition: AnyPublisher<MKMapRect, Never>) {
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in self?.updateVehicles() }
        
            mapPosition
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in 
                    self?.canUpdate = false
                    self?.loading = true
                }
                .store(in: &cancellables)
            
            mapPosition
                .debounce(for: 1.0, scheduler: RunLoop.main)
                .sink { [weak self] mapPosition in
                    guard let self else { return }
                    self.mapPosition = mapPosition
                    self.displayedVehicles = filteredVehicles
                    self.canUpdate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.loading = false
                    }
                }
                .store(in: &cancellables)
            
            updateVehicles()
        }
        
        private var filteredVehicles: [MapRequest.VehicleResponse] {
            vehicles.filter { mapPosition?.contains(.init(CLLocationCoordinate2D(latitude: $0.Lat, longitude: $0.Lng))) ?? true }
        }
        
        private func updateVehicles() {
            Task(priority: .userInitiated) { [weak self] in
                do {
                    let vehicles = try await MapRequest.send { $0 }
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.vehicles = vehicles
                        if self.canUpdate {
                            self.displayedVehicles = self.filteredVehicles
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    
    @Query var aliases: [LineAlias]
    @Query var stops: [Stop]
    @StateObject private var model: Model
    private let mapPosition: PassthroughSubject<MKMapRect, Never>
    
    var body: some View {
        Map(
            initialPosition: .userLocation(
                fallback: .region(
                    .init(
                        center: .init(latitude: 49.195061, longitude: 16.606836),
                        span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                )
            )
        ) {
            ForEach(model.displayedVehicles, id: \.ID) { vehicle in
                Annotation(
                    coordinate: .init(latitude: vehicle.Lat, longitude: vehicle.Lng),
                    content: {
                        Triangle()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(aliases.color(
                                for: vehicle.LineName,
                                from: \.colorHex,
                                fallback: .blue
                            ))
                            .rotationEffect(Angle(degrees: Double(vehicle.Bearing)))
                    },
                    label: {
                        Text(vehicle.LineName)
                    }
                )
            }
        }
        .onMapCameraChange { context in
            mapPosition.send(context.rect)
        }
        .overlay(alignment: .bottom) {
            selectedVehiclePrompt.animation(.easeInOut(duration: 0.2), value: UUID())
        }
        .overlay(alignment: .topLeading) {
            if model.loading {
                HStack(spacing: 4) {
                    ProgressView()
                    Text("Loading")
                }
                .padding(10)
                .backgroundStyle(.ultraThinMaterial)
            }
        }
    }
    
    @ViewBuilder private var selectedVehiclePrompt: some View {
        if let selectedVehicle = model.selectedVehicle {
            VStack {
                HStack {
                    Text(selectedVehicle.LineName, size: .large, weight: .bold)
                        .foregroundStyle(aliases.color(for: selectedVehicle.LineName, from: \.textHex))
                    Text(
                        stops.first(where: { $0.id == selectedVehicle.FinalStopID })?.name ?? "",
                        size: .large,
                        weight: .medium
                    )
                    .foregroundStyle(aliases.color(for: selectedVehicle.LineName, from: \.textHex))
                    Spacer()
                }
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(aliases.color(for: selectedVehicle.LineName, from: \.colorHex, fallback: .blue))
                }
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
            .gesture(DragGesture(minimumDistance: 20).onEnded({ gesture in
                if gesture.translation.height > -20 {
                    model.selectedItem = nil
                }
            }))
            .padding(16)
            .transition(.move(edge: .bottom))
        }
    }
    
    init() {
        let publisher = PassthroughSubject<MKMapRect, Never>()
        mapPosition = publisher
        _model = .init(wrappedValue: .init(mapPosition: publisher.eraseToAnyPublisher()))
    }
    
}

struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: rect.minX, y: rect.maxY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        path.addLine(to: .init(x: rect.midX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VehiclesMap()
}
