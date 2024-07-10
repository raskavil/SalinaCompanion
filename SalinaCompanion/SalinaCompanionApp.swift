import SwiftUI
import SwiftData
import Networking
import NetworkingImplementation

@main
struct SalinaCompanionApp: App {
    
    private let staticDataProvider: StaticDataProvider
    private let dynamicDataProvider: DynamicDataProvider

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
    }
    
    init() {
        Font.registerDesignFonts()
        UINavigationBar.appearance().largeTitleTextAttributes = UIFont(name: "SourceSans3-Bold", size: 34).map { [.font: $0]}
        UITabBarItem.appearance().setTitleTextAttributes(UIFont(name: "SourceSans3-Medium", size: 12).map { [.font: $0] }, for: [])
        staticDataProvider = StaticDataManager()
        dynamicDataProvider = DynamicDataManager(stopsAndAliasesProvider: staticDataProvider)
    }
}
