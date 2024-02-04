import SwiftUI

struct ContentView: View {
    
    enum Selection: Int {
        case departures, map
    }
    
    @State private var currentSelection: Selection = .departures
    
    var body: some View {
        TabView {
            Stations()
                .tabItem {
                    Label("Departures", systemImage: "bus.fill")
                }
                .tag(Selection.departures)
            VehiclesMap()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Selection.map)
        }
    }
}
