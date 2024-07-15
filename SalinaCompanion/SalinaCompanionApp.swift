import SwiftUI
import SwiftData
import Networking
import Models
import Device

@main
struct SalinaCompanionApp: App {
    
    private let staticDataProvider: StaticModelsProviding
    private let dynamicDataProvider: DynamicModelsProviding
    private let permissionsProvider: PermissionsProviding
    
    @State var staticDataReady = false

    var body: some Scene {
        WindowGroup {
            if staticDataReady {
                ContentView()
            } else {
                Color.white.ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .foregroundStyle(.black)
                    }
                    .task {
                        staticDataReady = await staticDataProvider.isUpToDate
                    }
            }
        }
        .environment(\.dynamicDataProvider, dynamicDataProvider)
        .environment(\.staticDataProvider, staticDataProvider)
        .environment(\.permissionsProvider, permissionsProvider)
    }
    
    init() {
        Font.registerDesignFonts()
        UINavigationBar.appearance().largeTitleTextAttributes = UIFont(name: "SourceSans3-Bold", size: 34).map { [.font: $0]}
        UITabBarItem.appearance().setTitleTextAttributes(UIFont(name: "SourceSans3-Medium", size: 12).map { [.font: $0] }, for: [])
        staticDataProvider = StaticModelsManager()
        dynamicDataProvider = DynamicModelsManager(stopsAndAliasesProvider: staticDataProvider)
        permissionsProvider = PermissionsManager()
        
        if permissionsProvider.features[.location] == .notDetermined {
            permissionsProvider.requestAuthorization(.location)
        }
    }
}
