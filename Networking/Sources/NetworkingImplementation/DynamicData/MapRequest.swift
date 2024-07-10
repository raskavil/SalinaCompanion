import Foundation
import SupportPackage

enum MapRequest {
    
    static func send<T>(_ responseParser: (VehicleResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/vehicles.json")!)
        let session = URLSession(configuration: .default)
        let data = try await session.data(for: request).0
        return try JSONDecoder().decode(MapResponse.self, from: data).Vehicles.compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct VehicleResponse: Decodable, Equatable {
        let ID: Int
        let Lat: Double
        let Lng: Double
        let Bearing: Int
        let LineName: String
        let LastStopID: Int
        let FinalStopID: Int
        let IsActive: Bool
        let Delay: Int
    }
    
    struct MapResponse: Decodable {
        let Vehicles: [FailableDecodable<VehicleResponse>]
    }
}
