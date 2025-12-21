//
//  VehicleStop.swift
//  Models
//
//  Created by Vilém Raška on 21.12.2025.
//


public struct VehicleStop: Codable {
    public let id: Int
    public let name: String
    public var isServed: Bool
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
        self.id = id
        self.name = name
        self.isServed = isServed
        self.time = time
        self.location = location
        self.path = path
    }
}
