import SwiftUI
import Models
import MapKit
import SupportPackageViews

struct VehicleMap: View {
    
    @Binding var vehicleRoute: VehicleRoute?
    
    @ViewBuilder var body: some View {
        if let vehicleRoute {
            Map(
                initialPosition: .region(
                    .init(
                        center: vehicleRoute.vehicle.position,
                        span: .init(latitudeDelta: 0.0125, longitudeDelta: 0)
                    )
                )
            ) {
                Annotation(
                    coordinate: vehicleRoute.vehicle.position,
                    content: {
                        VehicleMarker(vehicle: vehicleRoute.vehicle)
                    },
                    label: { Text(vehicleRoute.vehicle.name) }
                )
                MapPolyline(
                    coordinates:
                        vehicleRoute.stops.filter(\.isServed).flatMap(\.path)
                        + [vehicleRoute.stops.filter { $0.isServed == false }.first?.location].compactMap { $0 }
                )
                .stroke(vehicleRoute.vehicle.alias.backgroundColor.opacity(0.5), style: .init(
                    lineWidth: 5,
                    lineCap: .round,
                    lineJoin: .round
                ))
                MapPolyline(
                    coordinates: vehicleRoute.stops.filter { $0.isServed == false }.flatMap(\.path)
                )
                .stroke(vehicleRoute.vehicle.alias.backgroundColor, style: .init(
                    lineWidth: 5,
                    lineCap: .round,
                    lineJoin: .round
                ))
            }
            .navigationTitle(vehicleRoute.vehicle.finalStopName)
        }
    }
    
    init(vehicleRoute: Binding<VehicleRoute?>) {
        self._vehicleRoute = .init(projectedValue: vehicleRoute)
    }
}

struct VehicleMarker: View {
    
    let vehicle: Vehicle
    
    var body: some View {
        Circle()
            .frame(width: 28, height: 28)
            .foregroundStyle(vehicle.alias.backgroundColor)
            .overlay {
                Icon(vehicle.alias.vehicleType.icon, size: .small)
                    .foregroundStyle(vehicle.alias.contentColor)
            }
            .overlay(alignment: .center) {
                Triangle()
                    .foregroundStyle(vehicle.alias.backgroundColor)
                    .frame(width: 10, height: 6)
                    .padding(.bottom, 36)
                    .rotationEffect(Angle(degrees: Double(vehicle.bearing)))
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
