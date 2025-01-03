import Foundation
import SupportPackage
import Models

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

    static func decode(from csv: String) -> [Alias] {
        csv
            .split(separator: "\n")
            .dropFirst()
            .compactMap { line in
                let separatedValues = line.split(separator: ",").map { String($0) }
                guard separatedValues.count == 7 else { return nil}
                return .init(
                    id: separatedValues[0],
                    lineName: separatedValues[2],
                    contentColorHex: separatedValues[6],
                    backgroundColorHex: separatedValues[5]
                )
            }
    }
}
