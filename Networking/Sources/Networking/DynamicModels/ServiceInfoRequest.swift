import Foundation
import SupportPackage
import Models

struct ServiceInfoRequest {
    
    let serviceId: Int
    let lineId: Int
    let routeId: Int
    
    func send<T>(_ responseParser: (RouteStopResponse) -> T?) async throws -> [T] {
        var components = URLComponents(string: "https://mapa.idsjmk.cz/api/serviceinfo")
        components?.queryItems = [
            .init(name: "serviceid", value: "\(serviceId)"),
            .init(name: "lineid", value: "\(lineId)"),
            .init(name: "routeid", value: "\(routeId)")
        ]
        let session = URLSession(configuration: .default)
        let data = try await session.data(for: URLRequest(url: components!.url!)).0
        return try JSONDecoder()
            .decode(FailableDecodable<RoutePath>.self, from: data).value?
            .Routes.first?.value?
            .Stops.compactMap { $0.value.flatMap(responseParser) } ?? []
    }
    
    struct RouteStopResponse: Decodable, Equatable {
        let StopId: Int
        let Time: Int
        let IsPublic: Bool
    }
    
    struct RouteInfoResponse: Decodable {
        let Stops: [FailableDecodable<RouteStopResponse>]
    }
    
    struct RoutePath: Decodable {
        let Routes: [FailableDecodable<RouteInfoResponse>]
    }
    
    init(vehicle: Vehicle) {
        self.lineId = vehicle.lineId
        self.routeId = vehicle.routeId
        self.serviceId = vehicle.serviceId
    }
}
