import SwiftUI

struct ContentView: View {
    
    enum Selection: Int {
        case departures, map
    }
    
    @State private var currentSelection: Selection = .map
    
    var body: some View {
        TabView {
            VehiclesMap()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Selection.map)
        }
    }
}
