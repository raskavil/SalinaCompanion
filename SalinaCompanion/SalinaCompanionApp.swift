import SwiftUI
import SwiftData
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
                vehicles
                    .tabItem {
                        Label("map.title", systemImage: "map")
                    }
                Stops()
                    .tabItem {
                        Label("departures.title", systemImage: "list.bullet.rectangle")
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
//        Font.registerDesignFonts()
//        UINavigationBar.appearance().largeTitleTextAttributes = UIFont(name: "SourceSans3-Bold", size: 34).map { [.font: $0]}
//        UITabBarItem.appearance().setTitleTextAttributes(UIFont(name: "SourceSans3-Medium", size: 12).map { [.font: $0] }, for: [])
        staticDataProvider = StaticModelsManager()
        dynamicDataProvider = DynamicModelsManager(stopsAndAliasesProvider: staticDataProvider)
        permissionsProvider = PermissionsManager()
        
        if permissionsProvider.features[.location] == .notDetermined {
            permissionsProvider.requestAuthorization(.location)
        }
    }
}
