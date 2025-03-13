import Foundation
import SupportPackage
import Models

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

    static func decode(from csv: String) -> [Post] {
        csv
            .replacing("\"", with: "")
            .split(separator: "\r\n")
            .dropFirst()
            .compactMap { line in
                var separatedValues = line.split(separator: ",").map { String($0) }
                while Int(separatedValues[4]) == nil {
                    separatedValues[1] += separatedValues.remove(at: 2)
                }
                guard separatedValues.count >= 7 else { return nil }
                return .init(
                    name: separatedValues[1],
                    id: separatedValues[0],
                    stopId: separatedValues[6],
                    departures: nil,
                    lines: nil
                )
            }
    }
}
