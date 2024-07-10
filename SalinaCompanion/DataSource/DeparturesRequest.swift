import Foundation

enum DeparturesRequest {
    
    static func send<T>(stopId: Int, _ responseParser: (PostResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/departures?stopId=\(stopId)")!)
        let session = URLSession(configuration: .default)
        return (try await JSONDecoder()
            .decode(DeparturesResponse.self, from: session.data(for: request).0))
            .PostList
            .compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct DeparturesResponse: Decodable {
        let StopID: Int
        let PostList: [FailableDecodable<PostResponse>]
    }
    
    struct PostResponse: Decodable {
        let PostID: Int
        let Name: String
        let Departures: [DepartureResponse]
    }
    
    struct DepartureResponse: Decodable {
        let LineName: String
        let LineID: Int
        let RouteID: Int
        let FinalStop: String
        let IsLowFloor: Bool
        let TimeMark: String
    }
}
