import SwiftUI
import SwiftData
import Combine
import MapKit
import SupportPackageViews

struct VehiclesMap: View {
    
    @Namespace var namespace
    @Query var aliases: [LineAlias]
    @Query var stops: [Stop]
    @State private var selectedVehicle: Int?
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .region(
            .init(
                center: .init(latitude: 49.195061, longitude: 16.606836),
                span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
    )
    @StateObject private var model: Model
    private let mapPosition: PassthroughSubject<MKMapRect, Never>
    
    var body: some View {
        content
            .alert(
                Text("Something went wrong"),
                isPresented: .init(
                    get: { model.numberOfErrors >= 3 },
                    set: { value in
                        if value == false {
                            model.numberOfErrors = 0
                        }
                    }
                ),
                actions: {
                    Button("OK", action: { model.numberOfErrors = 0 })
                }
            )
    }
    
    @ViewBuilder private var content: some View {
        Map(position: $position) {
            ForEach(model.displayedVehicles, id: \.ID) { vehicle in
                Annotation(
                    coordinate: .init(latitude: vehicle.Lat, longitude: vehicle.Lng),
                    content: { annotation(for: vehicle) },
                    label: {
                        if model.displayedVehicles.count <= 30 {
                            Text(vehicle.LineName)
                        }
                    }
                )
            }
        }
        .onMapCameraChange { context in
            mapPosition.send(context.rect)
        }
        .overlay(alignment: .bottom) {
            selectedVehiclePrompt
                .animation(.easeInOut(duration: 0.2), value: selectedVehicle)
        }
        .overlay(alignment: .topTrailing) {
            if model.loading {
                HStack(spacing: 4) {
                    ProgressView()
                    Text("Loading")
                        .bold()
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder private func annotation(for vehicle: MapRequest.VehicleResponse) -> some View {
        if model.displayedVehicles.count > 30 {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundStyle(aliases.color(for: vehicle.LineName, from: \.colorHex))
        } else {
            Circle()
                .frame(width: 28, height: 28)
                .foregroundStyle(aliases.color(for: vehicle.LineName, from: \.colorHex))
                .overlay {
                    Icon(vehicle.LineName.lineIcon, size: .small)
                        .foregroundStyle(aliases.color(for: vehicle.LineName, from: \.textHex))
                }
                .overlay(alignment: .center) {
                    Triangle()
                        .foregroundStyle(aliases.color(for: vehicle.LineName, from: \.colorHex))
                        .frame(width: 10, height: 6)
                        .padding(.bottom, 36)
                        .rotationEffect(Angle(degrees: Double(vehicle.Bearing)))
                }
                .onTapGesture {
                    selectedVehicle = vehicle.ID
                }
        }
    }
    
    @ViewBuilder private var selectedVehiclePrompt: some View {
        if let selectedVehicle = model.displayedVehicles.first(where: { $0.ID == selectedVehicle }) {
            VStack {
                VehicleDetail(vehicleRoute: .constant(.mock), close: { self.selectedVehicle = nil }, namespace: namespace)
            }
            .padding(16)
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

struct MapPreviews: PreviewProvider {
    
    static var dataManager: DataManager = .init()

    static var previews: some View {
        VehiclesMap()
            .modelContainer(for: [Stop.self, Timestamp.self, LineAlias.self]) { result in
                if case .success(let container) = result {
                    Task.detached(priority: .userInitiated) {
                        await dataManager.set(container)
                    }
                }
            }
    }
}

extension String {
    
    var lineIcon: Icon.Content? {
        if let icon = Int(self)?.vehicleIcon {
            return icon
        } else if starts(with: "R") || starts(with: "S") {
            return .system("tram")
        } else {
            return .system("bus")
        }
    }
}
