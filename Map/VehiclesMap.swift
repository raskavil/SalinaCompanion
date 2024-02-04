import SwiftUI
import SwiftData
import MapKit
import SupportPackageViews

struct VehiclesMap: View {
    
    @Query var aliases: [LineAlias]
    @Query var stops: [Stop]
    @State var vehicles: [MapRequest.VehicleResponse] = []
    @State var selectedItem: Int?
    @State var mapCameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            .init(
                center: .init(latitude: 49.195061, longitude: 16.606836),
                span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
    )
    
    var selectedVehicle: MapRequest.VehicleResponse? {
        selectedItem.flatMap { item in vehicles.first(where: { $0.ID == item })}
    }
    
    var body: some View {
        Map(
            position: $mapCameraPosition,
            selection: $selectedItem
        ) {
            ForEach(vehicles, id: \.ID) { vehicle in
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
        .task {
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                Task {
                    do {
                        vehicles = try await MapRequest.send { $0 }
                    } catch {
                        
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            selectedVehiclePrompt.animation(.easeInOut(duration: 0.2), value: UUID())
        }
    }
    
    @ViewBuilder private var selectedVehiclePrompt: some View {
        if let selectedVehicle {
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
                    selectedItem = nil
                }
            }))
            .padding(16)
            .transition(.move(edge: .bottom))
        }
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
