//
//  VehicleType.swift
//  Models
//
//  Created by Vilém Raška on 21.12.2025.
//


public enum VehicleType: Codable, Identifiable, Hashable {
    case bus, trolleybus, train, tram, boat
    
    public var id: Self { self }
}

public extension VehicleType {
    
    var icon: String {
        switch self {
        case .bus, .trolleybus: return "bus"
        case .tram:             return "tram.fill"
        case .train:            return "tram"
        case .boat:             return "ferry.fill"
        }
    }
}
