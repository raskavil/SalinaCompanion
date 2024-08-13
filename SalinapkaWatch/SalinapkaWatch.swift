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
        staticDataProvider = StaticModelsManager(saveMode: .local)
        dynamicDataProvider = DynamicModelsManager(stopsAndAliasesProvider: staticDataProvider)
        locationProvider = PermissionsManager()
        
        if locationProvider.features[.location] == .notDetermined {
            locationProvider.requestAuthorization(.location)
        }
    }
}
