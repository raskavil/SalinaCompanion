import SwiftUI
import Networking
import Models
import Device
import MapKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
  }
}

@main
struct SalinaCompanionApp: App {
    
    private let staticDataProvider: StaticModelsProviding
    private let dynamicDataProvider: DynamicModelsProviding
    private let permissionsProvider: PermissionsProviding & LocationProviding
    
    @State var staticDataReady = false
    @State var displayedStop: Stop?

    var body: some Scene {
        WindowGroup {
            TabView {
                Stops(deeplinkStop: $displayedStop)
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
                if staticDataReady == false {
                    let value = await staticDataProvider.isUpToDate
                    DispatchQueue.main.async {
                        staticDataReady = value
                    }
                }
            }
            .onOpenURL { url in
                Task {
                    guard 
                        await staticDataProvider.isUpToDate,
                        let range = url.absoluteString.range(of: "widget://")
                    else { return }
                    
                    var stopId = url.absoluteString
                    stopId.removeSubrange(range)
                    
                    displayedStop = staticDataProvider.stops.first(where: { $0.id == Int(stopId) })
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
