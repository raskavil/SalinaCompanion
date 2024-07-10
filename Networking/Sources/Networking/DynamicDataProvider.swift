import Foundation
import Models
import SwiftUI

public protocol DynamicDataProvider {
    var vehicles: [Vehicle] { get async throws }
    func route(for vehicle: Vehicle) async throws -> VehicleRoute
}

public extension EnvironmentValues {
    
    var dynamicDataProvider: DynamicDataProvider {
        get { self[DynamicDataProviderKey.self] }
        set { self[DynamicDataProviderKey.self] = newValue }
    }
}

private struct DynamicDataProviderMock: DynamicDataProvider {
    
    var vehicles: [Vehicle] { [] }
    func route(for vehicle: Vehicle) async throws -> VehicleRoute {
        .mock
    }
}

private struct DynamicDataProviderKey: EnvironmentKey {
    
    static let defaultValue: DynamicDataProvider = DynamicDataProviderMock()
}
