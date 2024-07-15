import SwiftUI
import SupportPackageViews
import MapKit
import Models

struct VehicleDetail: View {
    
    enum Model {
        case loading(Vehicle)
        case loaded(VehicleRoute)
        
        var vehicle: Vehicle {
            switch self {
                case .loaded(let route):    return route.vehicle
                case .loading(let vehicle): return vehicle
            }
        }
    }

    let model: Model
    let close: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            closeButton
            
            vehicleHeader
            
            ScrollView {
                route
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)

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
            Text(model.vehicle.name, size: .large, weight: .bold)
                .foregroundStyle(model.vehicle.alias.contentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .frame(minWidth: 50)
                .background(RoundedRectangle(cornerRadius: 12).foregroundStyle(model.vehicle.alias.backgroundColor))
            Text(model.vehicle.finalStopName, size: .large, weight: .medium)
            Spacer()
            if model.vehicle.delay > 0 {
                Text("+\(model.vehicle.delay)'")
                    .foregroundStyle(.red)
                    .bold()
            }
        }
    }
    
    @ViewBuilder private var route: some View {
        if case .loaded(let vehicleRoute) = model {
            if vehicleRoute.stops.isEmpty == false {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(vehicleRoute.stops, id: \.id) { stop in
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .padding(.trailing, 20)
                            Text(stop.name)
                            Spacer()
                            Text("\(Int(stop.time / 60)):\(stop.time % 60)", weight: .bold)
                                .foregroundStyle(Color.black)
                        }
                        .foregroundStyle(vehicleRoute.vehicle.alias.backgroundColor)
                        .if(!stop.isServed) { $0.bold() }
                        .background(alignment: .leading) {
                            Rectangle()
                                .frame(width: 2)
                                .padding(.leading, 4)
                                .padding(.top, stop.id == vehicleRoute.stops.first?.id ? 6 : -2)
                                .padding(.bottom, stop.id == vehicleRoute.stops.last?.id ? 6 : -2)
                                .foregroundStyle(vehicleRoute.vehicle.alias.backgroundColor)
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
            } else {
                VStack {
                    Text("Jízdní řád nenalezen!")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            }
            
        } else {
            ProgressView()
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
        case .train:    return .system("tram")
        case .boat:     return .system("boat")
        }
    }
}

struct VehicleDetailPreviews: PreviewProvider {
    
    static var previews: some View {
        VehicleDetail(model: .loaded(.mock), close: {})
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
