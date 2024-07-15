import Foundation
import CoreLocation

public struct Stop: Codable, Identifiable {
    public let id: Int
    public let zone: Int
    public let name: String
    public let position: CLLocationCoordinate2D
    public let lines: [String]
    
    public init(id: Int, zone: Int, name: String, position: CLLocationCoordinate2D, lines: [String]) {
        self.id = id
        self.zone = zone
        self.name = name
        self.position = position
        self.lines = lines
    }
}

extension CLLocationCoordinate2D: Codable {
    
    enum CodingKeys: CodingKey {
        case latitude, longitude
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        )
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
