public struct VehicleRoute: Codable {
    public let vehicle: Vehicle
    
    public let stops: [VehicleStop]
    
    public init(vehicle: Vehicle, stops: [VehicleStop]) {
        self.vehicle = vehicle
        self.stops = stops
    }
}
