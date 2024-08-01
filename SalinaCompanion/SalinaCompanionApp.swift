import SwiftUI
import Networking
import Models
import Device
import MapKit

@main
struct SalinaCompanionApp: App {
    
    private let staticDataProvider: StaticModelsProviding
    private let dynamicDataProvider: DynamicModelsProviding
    private let permissionsProvider: PermissionsProviding & LocationProviding
    
    @State var staticDataReady = false

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    Stops()
                }
                .tabItem {
                    Label("departures.title", systemImage: "list.bullet.rectangle")
                }
                vehicles
                    .tabItem {
                        Label("map.title", systemImage: "map")
                    }
            }
            .overlay {
                LoadingView(isHidden: $staticDataReady)
                    .ignoresSafeArea()
            }
            .task {
                let value = await staticDataProvider.isUpToDate
                DispatchQueue.main.async {
                    staticDataReady = value
                }
            }
        }
        .environment(\.dynamicDataProvider, dynamicDataProvider)
        .environment(\.staticDataProvider, staticDataProvider)
        .environment(\.permissionsProvider, permissionsProvider)
        .environment(\.locationProvider, permissionsProvider)
    }
    
    @ViewBuilder var vehicles: some View {
        if staticDataReady {
            VehiclesMap()
        }
    }
    
    init() {
        staticDataProvider = StaticModelsManager()
        dynamicDataProvider = DynamicModelsManager(stopsAndAliasesProvider: staticDataProvider)
        permissionsProvider = PermissionsManager()
        
        if permissionsProvider.features[.location] == .notDetermined {
            permissionsProvider.requestAuthorization(.location)
        }
    }
}
