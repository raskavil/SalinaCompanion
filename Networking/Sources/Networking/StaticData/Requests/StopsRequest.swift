import Foundation
import SupportPackage
import Models

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

    static func decode(from csv: String) -> [Stop] {
        csv
            .replacing("\"", with: "")
            .split(separator: "\r\n")
            .dropFirst()
            .compactMap { line in
                var separatedValues = line.split(separator: ",").map { String($0) }
                while Int(separatedValues[4]) == nil {
                    separatedValues[1] += separatedValues.remove(at: 2)
                }
                guard let zone = Int(separatedValues[4]),
                      let latitude = Double(separatedValues[2]),
                      let longitude = Double(separatedValues[3]),
                      separatedValues.count == 7
                else { return nil }
                return .init(
                    id: separatedValues[0],
                    zone: zone,
                    name: separatedValues[1],
                    position: .init(latitude: latitude, longitude: longitude),
                    lines: []
                )
            }
    }
}
