import SwiftUI
import SwiftData
import SupportPackageViews
import MapKit
import Models

struct VehicleDetail: View {

    @Binding var vehicleRoute: VehicleRoute
    let close: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            closeButton
            
            /* map
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .clipped()
                .frame(height: proxy.size.height * 0.4)
                .matchedGeometryEffect(id: "vehicleMap", in: namespace) */
            
            vehicleHeader
            
            route
        }
    }
    
    private var closeButton: some View {
        Button(action: close) {
            Icon(.system("xmark"), size: .small)
                .bold()
                .padding(4)
        }
    }
    
    private var vehicleHeader: some View {
        HStack {
            Text(vehicleRoute.vehicle.name, size: .large, weight: .bold)
                .foregroundStyle(vehicleRoute.vehicle.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .frame(minWidth: 50)
                .background(RoundedRectangle(cornerRadius: 12).foregroundStyle(vehicleRoute.vehicle.backgroundColor))
            Text(vehicleRoute.stops.last?.name ?? "", size: .large, weight: .medium)
            Spacer()
            if vehicleRoute.vehicle.delay > 0 {
                Text("+\(vehicleRoute.vehicle.delay)'")
                    .foregroundStyle(.red)
                    .bold()
            }
        }
    }
    
    private var map: some View {
        Map(position: .init(get: { vehicleRoute.vehicle.camera }, set: { _ in })) {
            Annotation(
                coordinate: vehicleRoute.vehicle.position,
                content: {
                    Circle()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(vehicleRoute.vehicle.backgroundColor)
                        .overlay {
                            Icon(vehicleRoute.vehicle.type.icon, size: .small)
                                .foregroundStyle(vehicleRoute.vehicle.color)
                        }
                        .overlay(alignment: .center) {
                            Triangle()
                                .foregroundStyle(vehicleRoute.vehicle.backgroundColor)
                                .frame(width: 10, height: 6)
                                .padding(.bottom, 36)
                                .rotationEffect(vehicleRoute.vehicle.bearing)
                        }
                },
                label: { Text(vehicleRoute.vehicle.name) }
            )
            MapPolyline(coordinates: vehicleRoute.stops.filter(\.isServed).flatMap(\.path))
                .stroke(vehicleRoute.vehicle.backgroundColor, style: .init(
                    lineWidth: 5,
                    lineCap: .round,
                    lineJoin: .round
                ))
            MapPolyline(coordinates: vehicleRoute.stops.filter { $0.isServed == false }.flatMap(\.path))
                .stroke(vehicleRoute.vehicle.backgroundColor, style: .init(
                    lineWidth: 5,
                    lineCap: .round,
                    lineJoin: .round
                ))
        }
    }
    
    private var route: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(vehicleRoute.stops, id: \.stopID) { stop in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .padding(.trailing, 20)
                    Text(stop.name)
                    Spacer()
                    Text("\(Int(stop.time / 60)):\(stop.time % 60)", weight: .bold)
                        .foregroundStyle(Color.black)
                }
                .foregroundStyle(vehicleRoute.vehicle.backgroundColor)
                .if(!stop.isServed) { $0.bold() }
                .background(alignment: .leading) {
                    Rectangle()
                        .frame(width: 2)
                        .padding(.leading, 4)
                        .padding(.top, stop.stopID == vehicleRoute.stops.first?.stopID ? 6 : -2)
                        .padding(.bottom, stop.stopID == vehicleRoute.stops.last?.stopID ? 6 : -2)
                        .foregroundStyle(vehicleRoute.vehicle.backgroundColor)
                        .opacity(0.5)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .foregroundStyle(.white)
                .shadow(radius: 1)
        }
    }
}

extension Vehicle {
    
    var camera: MapCameraPosition {
        .camera(.init(centerCoordinate: position, distance: 1000))
    }
}

extension VehicleType {
    
    var icon: Icon.Content {
        switch self {
        case .bus:      return .system("bus")
        case .tram:     return .system("tram.fill")
        case .train:    return .system("train")
        case .boat:     return .system("boat")
        }
    }
}

struct VehicleDetailPreviews: PreviewProvider {
    
    static var dataManager: DataManager = .init()

    static var previews: some View {
        VehicleDetail(vehicleRoute: .constant(.mock), close: {}, namespace: Namespace.init().wrappedValue)
    }
}

extension View {
    
    @ViewBuilder func `if`(_ condition: Bool, content: (Self) -> some View) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}
