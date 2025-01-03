import SwiftUI
import Models
import Networking
import Device

@main
struct WatchApp: App {
    
    private let staticDataProvider: StaticModelsProviding
    private let dynamicDataProvider: DynamicModelsProviding
    private let locationProvider: LocationProviding & PermissionsProviding
    
    @State var staticDataReady = false

    var body: some Scene {
        WindowGroup {
            Stops()
                .task {
                    if staticDataReady == false {
                        let value = await staticDataProvider.isUpToDate
                        DispatchQueue.main.async {
                            staticDataReady = value
                        }
                    }
                }
                .overlay {
                    LoadingView(isHidden: $staticDataReady)
                        .ignoresSafeArea()
                }
        }
        .environment(\.dynamicDataProvider, dynamicDataProvider)
        .environment(\.staticDataProvider, staticDataProvider)
        .environment(\.locationProvider, locationProvider)
    }
    
    init() {
        let staticModelsManager = StaticModelsManager(saveMode: .local)
        staticDataProvider = staticModelsManager
        dynamicDataProvider = DynamicModelsManager(staticModelsManager: staticModelsManager)
        locationProvider = PermissionsManager()
        
        if locationProvider.features[.location] == .notDetermined {
            locationProvider.requestAuthorization(.location)
        }
    }
}
