import Foundation
import SupportPackage

enum PostsRequest {
    
    static func send<T>(_ responseParser: (PostResponse) -> T?) async throws -> [T] {
        let request = URLRequest(url: URL(string: "https://mapa.idsjmk.cz/api/posts")!)
        let session = URLSession(configuration: .default)
        return (try await JSONDecoder()
            .decode(AliasesResponse.self, from: session.data(for: request).0))
            .Posts
            .compactMap { $0.value.flatMap(responseParser) }
    }
    
    struct PostResponse: Decodable {
        let ID: Int
        let StopID: Int
        let PostID: Int
        let Name: String
        let IsPublic: Bool
        let LineList: String
    }
    
    struct AliasesResponse: Decodable {
        let Posts: [FailableDecodable<PostResponse>]
    }
}
