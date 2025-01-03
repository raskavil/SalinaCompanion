import SwiftUI
import SupportPackageViews

public struct Alias: Codable {
    public let id: String
    public let lineName: String
    public var contentColor: Color { .init(hexString: contentColorHex) }
    public var backgroundColor: Color { .init(hexString: backgroundColorHex) }
    public var vehicleType: VehicleType {
        guard !lineName.starts(with: "R") && !lineName.starts(with: "S") else { return .train }
        guard !lineName.starts(with: "N") else { return .bus }
        return switch Int(lineName) {
        case .some(1...19):         .tram
        case .some(20...39):        .trolleybus
        case .some(0), .some(100):  .boat
        default:                    .bus
        }
    }
    let contentColorHex: String
    let backgroundColorHex: String
    
    public init(id: String, lineName: String, contentColorHex: String, backgroundColorHex: String) {
        self.id = id
        self.lineName = lineName
        self.contentColorHex = contentColorHex
        self.backgroundColorHex = backgroundColorHex
    }
}
