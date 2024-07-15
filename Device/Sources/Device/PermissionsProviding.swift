import SwiftUI
import Combine

public enum DeviceFeature: Hashable {
    case location
}

public enum AuthorizationStatus {
    case notDetermined
    case allowed
    case denied
}

public protocol PermissionsProviding {
    
    var features: [DeviceFeature: AuthorizationStatus] { get }
    var permissionsChanged: AnyPublisher<Void, Never> { get }
    func requestAuthorization(_ feature: DeviceFeature)
}

public extension EnvironmentValues {
    
    var permissionsProvider: PermissionsProviding {
        get { self[PermissionsProviderKey.self] }
        set { self[PermissionsProviderKey.self] = newValue }
    }
}

private struct PermissionsProviderMock: PermissionsProviding {
    var features: [DeviceFeature: AuthorizationStatus] { [:] }
    var permissionsChanged = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    func requestAuthorization(_ feature: DeviceFeature) { return }

}

private struct PermissionsProviderKey: EnvironmentKey {
    
    static let defaultValue: PermissionsProviding = PermissionsProviderMock()
}
