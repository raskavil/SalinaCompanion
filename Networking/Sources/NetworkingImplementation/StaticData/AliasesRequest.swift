import Foundation
import SupportPackage

enum AliasesRequest {
    
    static func send<T>(_ responseParser: (AliasResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/linealiases")!)
        let session = URLSession(configuration: .default)
        return (try await JSONDecoder()
            .decode(AliasesResponse.self, from: session.data(for: request).0))
            .LineAliases
            .compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct AliasResponse: Decodable {
        let LineId: Int
        let LineName: String
        let Color: String
        let TextColor: String
    }
    
    struct AliasesResponse: Decodable {
        let LineAliases: [FailableDecodable<AliasResponse>]
    }
    
}
