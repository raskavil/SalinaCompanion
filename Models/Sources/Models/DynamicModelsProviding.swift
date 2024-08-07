import Foundation
import SwiftUI

public protocol DynamicModelsProviding {
    var vehicles: [Vehicle] { get async throws }
    func route(for vehicle: Vehicle) async throws -> VehicleRoute
    func departures(for stop: Stop) async throws -> [Post]
    func departures(for stopId: Int) async throws -> [Post]
}

public extension EnvironmentValues {
    
    var dynamicDataProvider: DynamicModelsProviding {
        get { self[DynamicDataProviderKey.self] }
        set { self[DynamicDataProviderKey.self] = newValue }
    }
}

private struct DynamicDataProviderMock: DynamicModelsProviding {
    
    var vehicles: [Vehicle] { [] }
    func route(for vehicle: Vehicle) async throws -> VehicleRoute {
        .mock
    }
    func departures(for stop: Stop) async throws -> [Post] {
        []
    }
    func departures(for stopId: Int) async throws -> [Post] {
        []
    }
}

private struct DynamicDataProviderKey: EnvironmentKey {
    
    static let defaultValue: DynamicModelsProviding = DynamicDataProviderMock()
}
