import CoreLocation
import SwiftUI
import Combine

public class PermissionsManager: NSObject, PermissionsProviding, CLLocationManagerDelegate, LocationProviding {
    
    public var features: [DeviceFeature: AuthorizationStatus] {
        [.location: locationManager.authorizationStatus.authorizationStatus]
    }
    
    public var permissionsChanged: AnyPublisher<Void, Never> {
        permissionsChangedPassthrough.eraseToAnyPublisher()
    }
    
    public var location: CLLocation? {
        locationManager.location
    }

    private let permissionsChangedPassthrough = PassthroughSubject<Void, Never>()
    private let locationManager: CLLocationManager
    private var locationAuthorizationDetermined: (() -> Void)?
    
    public override init() {
        locationManager = .init()
        super.init()
        
        locationManager.delegate = self
    }
    
    public func requestAuthorization(_ feature: DeviceFeature) {
        switch feature {
            case .location: requestLocationAuthorization()
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationDetermined?()
    }
    
    private func requestLocationAuthorization() {
        guard features[.location] == .notDetermined else {
            #if os(watchOS)
            return
            #else
            Task(priority: .high) {
                guard let urlGeneral = await URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                await UIApplication.shared.open(urlGeneral)
                
            }
            return
            #endif
        }
        locationManager.requestWhenInUseAuthorization()
    }
}

extension CLAuthorizationStatus {
    
    var authorizationStatus: AuthorizationStatus {
        switch self {
            case .notDetermined:                            return .notDetermined
            case .authorizedAlways, .authorizedWhenInUse:   return .allowed
            case .denied, .restricted:                      return .denied
            @unknown default:                               return .denied
        }
    }
}
