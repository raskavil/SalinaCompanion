import Foundation
import SupportPackage

enum StopsRequest {
    
    static func send<T>(_ responseParser: (StopResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/stops")!)
        let session = URLSession(configuration: .default)
        return (try await JSONDecoder().decode(StopsResponse.self, from: session.data(for: request).0)).Stops.compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct StopResponse: Decodable {
        let StopID: Int
        let Zone: Int
        let Name: String
        let Latitude: Double
        let Longitude: Double
        let IsPublic: Bool
        let LineList: String
    }
    
    struct StopsResponse: Decodable {
        let Stops: [FailableDecodable<StopResponse>]
    }
    
}
