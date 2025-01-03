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
            .split(separator: "\n")
            .dropFirst()
            .compactMap { line in
                let separatedValues = line.split(separator: ",").map { String($0) }
                guard separatedValues.count == 9,
                      let zone = Int(separatedValues[4]),
                      let latitude = Double(separatedValues[2]),
                      let longitude = Double(separatedValues[3]),
                      !separatedValues[6].isEmpty
                else { return nil }
                return .init(
                    name: separatedValues[1].replacing("\"", with: ""),
                    id: separatedValues[0].replacing("\"", with: ""),
                    stopId: separatedValues[6],
                    departures: nil,
                    lines: nil
                )
            }
    }
}
