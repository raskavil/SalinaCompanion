import Foundation

enum MapRequest {
    
    static func send<T>(_ responseParser: (VehicleResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/vehicles.json")!)
        let session = URLSession(configuration: .default)
        return (try await JSONDecoder().decode(MapResponse.self, from: session.data(for: request).0)).Vehicles.compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct VehicleResponse: Decodable {
        let ID: Int
        let Lat: Double
        let Lng: Double
        let Bearing: Int
        let LineName: String
        let LastStopID: Int
        let FinalStopID: Int
    }
    
    struct MapResponse: Decodable {
        let Vehicles: [FailableDecodable<VehicleResponse>]
    }
}
