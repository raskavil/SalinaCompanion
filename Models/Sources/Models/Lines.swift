import SwiftUI

public struct Lines: Codable {
    public let tripId: Int
    public let lineName: String
    public let routeType: Int
    public let textColorHex: String
    public let backgroundColorHex: String
    
    public var vehicleType: VehicleType {
        switch (routeType, Int(lineName)) {
        case (0, _):                .tram
        case (2, _):                .train
        case (4, _):                .boat
        case (3, .some(20...39)):   .trolleybus
        default:                    .bus
        }
    }
    
    public init(tripId: Int, lineName: String, routeType: Int, textColorHex: String, backgroundColorHex: String) {
        self.tripId = tripId
        self.lineName = lineName
        self.routeType = routeType
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
    }
}
