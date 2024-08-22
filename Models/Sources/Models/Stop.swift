import Foundation
import CoreLocation

public struct Stop: Codable, Identifiable, Hashable {
    public let id: Int
    public let zone: Int
    public let name: String
    public let position: CLLocationCoordinate2D
    public let lines: [String]
    public let searchTerm: String
    
    public init(id: Int, zone: Int, name: String, position: CLLocationCoordinate2D, lines: [String]) {
        self.id = id
        self.zone = zone
        self.name = name
        self.position = position
        self.lines = lines
        self.searchTerm = name.forSearching
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

    public var location: CLLocation {
        .init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(longitude)
        hasher.combine(latitude)
    }
}

extension String {
    
    /// https://stackoverflow.com/questions/29521951/how-to-remove-diacritics-from-a-string-in-swift
    public var forSearching: String {
        let simple = folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "")
    }
}
