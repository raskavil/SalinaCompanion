import Foundation

enum LineAliasesRequest {
    
    static func send<T>(_ responseParser: (LineAliasResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/linealiases")!)
        let session = URLSession(configuration: .default)
        return (try await JSONDecoder()
            .decode(LineAliasesResponse.self, from: session.data(for: request).0))
            .LineAliases
            .compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct LineAliasResponse: Decodable {
        let LineId: Int
        let LineName: String
        let Color: String
        let TextColor: String
    }
    
    struct LineAliasesResponse: Decodable {
        let LineAliases: [FailableDecodable<LineAliasResponse>]
    }
    
}
