import SwiftUI
import Models
import SupportPackageViews

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
