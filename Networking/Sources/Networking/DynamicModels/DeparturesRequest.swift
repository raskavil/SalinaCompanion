import Foundation
import SupportPackage

struct DeparturesRequest {
    
    let stopId: Int
    
    func send<T>(_ responseParser: (PostResponse) -> T?) async throws -> [T] {
        var components = URLComponents(string: "https://mapa.idsjmk.cz/api/routepath")
        components?.queryItems = [.init(name: "stopid", value: "\(stopId)")]
        let session = URLSession(configuration: .default)
        let data = try await session.data(for: URLRequest(url: components!.url!)).0
        return try JSONDecoder()
            .decode(DeparturesResponse.self, from: data)
            .PostList
            .compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct DepartureResponse: Decodable, Equatable {
        let LineId: Int
        let RouteId: Int
        let FinalStop: String
        let TimeMark: String
    }
    
    struct PostResponse: Decodable {
        let PostID: Int
        let Name: String
        let Departures: [FailableDecodable<DepartureResponse>]
    }
    
    struct DeparturesResponse: Decodable {
        let PostList: [FailableDecodable<PostResponse>]
    }
    
    init(stopId: Int) {
        self.stopId = stopId
    }
}
