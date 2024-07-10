import Foundation
import Networking
import Models

public class DynamicDataManager: DynamicDataProvider {
    
    private let stopsAndAliasesProvider: StaticDataProvider

    public var vehicles: [Vehicle] {
        get async throws {
            let aliases = stopsAndAliasesProvider.aliases
            return try await MapRequest.send { vehicle in
                Vehicle(
                    id: vehicle.ID,
                    name: vehicle.LineName,
                    type: vehicle.LineName.vehicleType,
                    position: .init(latitude: vehicle.Lat, longitude: vehicle.Lng),
                    bearing: vehicle.Bearing,
                    alias: aliases.first(where: { $0.lineName == vehicle.LineName }),
                    isActive: vehicle.IsActive,
                    delay: vehicle.Delay
                )
            }
        }
    }
    
    public func route(for vehicle: Vehicle) async -> VehicleRoute {
        .mock
    }
    
    public init(stopsAndAliasesProvider: StaticDataProvider) {
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

