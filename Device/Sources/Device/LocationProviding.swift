import CoreLocation
import SwiftUI

public protocol LocationProviding {
    var location: CLLocation? { get }
}

public extension EnvironmentValues {
    
    var locationProvider: LocationProviding {
        get { self[LocationProviderKey.self] }
        set { self[LocationProviderKey.self] = newValue }
    }
}

private struct LocationProviderMock: LocationProviding {
    var location: CLLocation? { nil }
}

private struct LocationProviderKey: EnvironmentKey {
    static let defaultValue: LocationProviding = LocationProviderMock()
}
