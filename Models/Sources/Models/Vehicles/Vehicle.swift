import Foundation
import CoreLocation
import SwiftUI

public struct Vehicle: Codable {
    public let id: String
    public let name: String
    public let position: CLLocationCoordinate2D
    public let bearing: Int
    public let tripId: Int
    public let lineName: String
    public let routeType: Int
    public let textColorHex: String
    public let backgroundColorHex: String
    
    public init(
        id: String,
        name: String,
        position: CLLocationCoordinate2D,
        bearing: Int,
        tripId: Int,
        lineName: String,
        routeType: Int,
        textColorHex: String,
        backgroundColorHex: String
    ) {
        self.id = id
        self.name = name
        self.position = position
        self.bearing = bearing
        self.tripId = tripId
        self.lineName = lineName
        self.routeType = routeType
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
    }
    
    public var vehicleType: VehicleType {
        switch (routeType, Int(lineName)) {
        case (0, _):                .tram
        case (2, _):                .train
        case (4, _):                .boat
        case (3, .some(20...39)):   .trolleybus
        default:                    .bus
        }
    }
}

