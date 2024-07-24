import SwiftUI
import SupportPackageViews

public struct Alias: Codable {
    public let id: Int
    public let lineName: String
    public var contentColor: Color { .init(hexString: contentColorHex) }
    public var backgroundColor: Color { .init(hexString: backgroundColorHex) }
    public var vehicleType: VehicleType {
        guard !lineName.starts(with: "R") && !lineName.starts(with: "S") else { return .train }
        return switch id {
        case 1...19:    .tram
        case 20...39:   .trolleybus
        case 0, 100:    .boat
        default:        .bus
        }
    }
    let contentColorHex: String
    let backgroundColorHex: String
    
    public init(id: Int, lineName: String, contentColorHex: String, backgroundColorHex: String) {
        self.id = id
        self.lineName = lineName
        self.contentColorHex = contentColorHex
        self.backgroundColorHex = backgroundColorHex
    }
}
