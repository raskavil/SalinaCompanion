import Foundation
import Models

public class DynamicModelsManager: DynamicModelsProviding {
    
    private let stopsAndAliasesProvider: StaticModelsProviding

    public var vehicles: [Vehicle] {
        get async throws {
            let aliases = stopsAndAliasesProvider.aliases
            let vehicles = try await MapRequest.send { vehicle in
                Vehicle(
                    id: vehicle.ID,
                    name: vehicle.LineName,
                    type: vehicle.LineName.vehicleType,
                    position: .init(latitude: vehicle.Lat, longitude: vehicle.Lng),
                    bearing: vehicle.Bearing,
                    alias: aliases.first(where: { $0.lineName == vehicle.LineName })
                        ?? .init(id: 0, lineName: vehicle.LineName, contentColorHex: "#000000", backgroundColorHex: "#FFFFFF"),
                    isActive: !vehicle.IsInactive,
                    delay: vehicle.Delay,
                    lastStopId: vehicle.LastStopID,
                    finalStopName: vehicle.FinalStopName,
                    lineId: vehicle.LineID,
                    routeId: vehicle.RouteID,
                    serviceId: vehicle.ServiceId
                )
            }
            return vehicles
        }
    }
    
    public func route(for vehicle: Vehicle) async throws -> VehicleRoute {
        let stops = stopsAndAliasesProvider.stops
        
        let (route, times) = (
            try await RouteRequest(vehicle: vehicle).send { $0 },
            try await ServiceInfoRequest(vehicle: vehicle).send { $0 }
        )
        
        var vehicleStops = times.compactMap { time -> VehicleStop? in
            guard let stop = stops.first(where: { $0.id == time.StopId }) else { return nil }
            
            return VehicleStop(
                id: time.StopId,
                name: stop.name,
                isServed: false,
                time: time.Time,
                location: stop.position,
                path: route
                    .first(where: { $0.StopId == time.StopId })?.Path
                    .map { .init(latitude: $0[0], longitude: $0[1]) } ?? []
            )
        }
        
        if let index = vehicleStops.firstIndex(where: { $0.id == vehicle.lastStopId }) {
            (0...index).forEach { index in
                vehicleStops[index].isServed = true
            }
        }
        
        return .init(
            vehicle: vehicle,
            stops: vehicleStops
        )
    }
    
    public init(stopsAndAliasesProvider: StaticModelsProviding) {
        self.stopsAndAliasesProvider = stopsAndAliasesProvider
    }
}

private extension String {
    
    var vehicleType: VehicleType {
        if let lineNumber = Int(self) {
            return switch lineNumber {
                case 1...19:    .tram
                case 20...39:   .bus
                default:        .bus
            }
        } else if starts(with: "R") || starts(with: "S") {
            return .train
        } else {
            return .bus
        }
    }
}

