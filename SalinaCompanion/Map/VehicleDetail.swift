import SwiftUI
import SupportPackageViews
import MapKit
import Models

struct VehicleDetail: View {
    
    enum Model: Identifiable {
        case loading(Vehicle)
        case loaded(VehicleRoute)
        
        var vehicle: Vehicle {
            switch self {
            case .loaded(let route):    return route.vehicle
            case .loading(let vehicle): return vehicle
            }
        }
        
        var id: Int {
            vehicle.id
        }
    }
    
    let model: Model
    let close: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                SwiftUI.Text("Detail vozidla")
                    .font(.title3)
                    .bold()
                Spacer()
                closeButton
            }
            
            vehicleHeader
            
            route
            
            Spacer()
        }
        .padding(.top, 14)
        .padding(.horizontal, 16)
    }
    
    private var closeButton: some View {
        Button(action: close) {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color(white: 0.85))
                .overlay {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .bold()
                        .foregroundStyle(Color(white: 0.45))
                }
        }
    }
    
    private var vehicleHeader: some View {
        HStack {
            HStack(alignment: .center, spacing: 4) {
                Icon(model.vehicle.type.icon, size: .small)
                SwiftUI.Text(model.vehicle.name)
                    .bold()
                    .font(.subheadline)
                
            }
            .foregroundStyle(model.vehicle.alias.contentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(minWidth: 50)
            .background(RoundedRectangle(cornerRadius: 12).foregroundStyle(model.vehicle.alias.backgroundColor))
            
            SwiftUI.Text(model.vehicle.finalStopName)
                .font(.subheadline)
                .fontWeight(.medium)
                .minimumScaleFactor(0.7)
            Spacer()
            if model.vehicle.delay > 0 {
                SwiftUI.Text("Zpoždění \(model.vehicle.delay) min")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hexString: "#E10000"))
            }
        }
    }
    
    @ViewBuilder private var route: some View {
        if case .loaded(let vehicleRoute) = model {
            
            if let firstStop = vehicleRoute.stops.first {
                VStack(alignment: .leading, spacing: 22) {
                    
                    if firstStop.isServed == true {
                        line(for: firstStop)
                            .foregroundStyle(Color.servedStop)
                            .frame(height: 14)
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 22) {
                            ForEach(vehicleRoute.stops.filter { $0.isServed == false }, id: \.id) { stop in
                                line(for: stop)
                                    .foregroundStyle(.black)
                                    .frame(height: 14)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .background(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8.0)
                            .frame(width: 16)
                            .padding(.leading, 7)
                            .foregroundStyle(model.vehicle.alias.backgroundColor)
                    }
                    .overlay {
                        VStack {
                            routeBackgroundCover
                            Spacer()
                            routeBackgroundCover
                                .rotation(.radians(.pi), anchor: .leading)
                                .padding(.leading, 16)
                        }
                        .padding(.leading, 7)
                        .foregroundStyle(Color.white)
                    }
                    .overlay {
                        VStack {
                            LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                                .frame(height: 2)
                            Spacer()
                            LinearGradient(colors: [.white, .clear], startPoint: .bottom, endPoint: .top)
                                .frame(height: 2)
                        }
                        .padding(.leading, 7 + 16)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
                .background {
                    Path { path in
                        path.move(to: .init(x: 15, y: 13))
                        path.addLine(to: .init(x: 15, y: 38))
                    }
                    .stroke(Color.servedStop, style: .init(lineWidth: 1, dash: [2]))
                }
            } else {
                VStack {
                    SwiftUI.Text("Jízdní řád nenalezen!")
                        .font(.headline)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            }
            
        } else {
            ProgressView()
        }
    }
    
    private var routeBackgroundCover: Path {
        Path { path in
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 16, y: 0))
            path.addLine(to: .init(x: 16, y: 8))
            path.addCurve(
                to: .init(x: 0, y: 8),
                control1: .init(x: 16, y: -2),
                control2: .init(x: 0, y: -2)
            )
            path.closeSubpath()
        }
    }
    
    private func line(for stop: VehicleStop) -> some View {
        HStack {
            Circle()
                .foregroundStyle(.white)
                .frame(width: 10, height: 10)
                .overlay {
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal, 10)
            SwiftUI.Text(stop.name)
                .font(.system(size: 14))
                .bold()
            Spacer()
            SwiftUI.Text(stop.time.timeText)
                .font(.system(size: 14))
                .bold()
        }
    }
}

extension Color {
    
    static var servedStop: Self {
        .init(white: 0.65)
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

extension Int {
    
    var timeText: String {
        "\(Int(self / 60)):\(self % 60)"
    }
}

struct VehicleDetailPreviews: PreviewProvider {
    
    static var previews: some View {
        Color.blue.overlay {
            GeometryReader { proxy in
                VehicleDetail(model: .loaded(.mock), close: {})
                    .background {
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 12, topTrailing: 12))
                            .foregroundStyle(.white)
                    }
                    .frame(height: proxy.size.height / 2)
                    .offset(y: proxy.size.height / 2)
                    
            }
        }
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
