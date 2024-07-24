import Foundation
import CoreLocation
import SwiftUI

public struct Vehicle: Codable {
    public let id: Int
    public let name: String
    public let type: VehicleType
    public let position: CLLocationCoordinate2D
    public let bearing: Int
    public let alias: Alias
    public let isActive: Bool
    public let delay: Int
    public let lastStopId: Int
    public let finalStopName: String
    public let lineId: Int
    public let routeId: Int
    public let serviceId: Int
    
    public init(
        id: Int,
        name: String,
        type: VehicleType,
        position: CLLocationCoordinate2D,
        bearing: Int,
        alias: Alias,
        isActive: Bool,
        delay: Int,
        lastStopId: Int,
        finalStopName: String,
        lineId: Int,
        routeId: Int,
        serviceId: Int
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.position = position
        self.bearing = bearing
        self.alias = alias
        self.isActive = isActive
        self.delay = delay
        self.lastStopId = lastStopId
        self.finalStopName = finalStopName
        self.lineId = lineId
        self.routeId = routeId
        self.serviceId = serviceId
    }
}

public enum VehicleType: Codable, Identifiable, Hashable {
    case bus, trolleybus, train, tram, boat
    
    public var id: Self { self }
}

public struct VehicleStop: Codable {
    public let name: String
    public var isServed: Bool
    public let id: Int
    public let time: Int
    public let location: CLLocationCoordinate2D
    public let path: [CLLocationCoordinate2D]
    
    public init(
        id: Int,
        name: String,
        isServed: Bool,
        time: Int,
        location: CLLocationCoordinate2D,
        path: [CLLocationCoordinate2D]
    ) {
        self.name = name
        self.isServed = isServed
        self.id = id
        self.time = time
        self.location = location
        self.path = path
    }
}

public struct VehicleRoute: Codable {
    public let vehicle: Vehicle
    public let stops: [VehicleStop]
    
    public init(vehicle: Vehicle, stops: [VehicleStop]) {
        self.vehicle = vehicle
        self.stops = stops
    }
}
