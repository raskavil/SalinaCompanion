import SwiftUI
import SupportPackageViews
import Models
import CoreLocation
import MapKit

struct Stops: View {
    
    @Environment(\.locationProvider) private var locationProvider
    @Environment(\.staticDataProvider) private var staticDataProvider
    @Environment(\.scenePhase) private var scenePhase
    @State private var term = ""
    @State private var isLoaded: Bool = false
    @State private var localStops: [Stop] = []
    @State private var location: CLLocation?
    @Binding private var deeplinkStop: Stop?
    private var filteredStops: [Stop] {
        guard term.isEmpty == false else { return localStops }
        let searchTerm = term.forSearching
        return localStops.filter { $0.searchTerm.contains(searchTerm) }
    }
    private var locationDistance: CLLocationDistance? {
        locationProvider.location.flatMap { current in location.map { $0.distance(from: current ) } }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle("departures.title")
                .onAppear() {
                    update()
                }
                .onChange(of: scenePhase) {
                    if case .active = scenePhase {
                        update()
                    }
                }
                .navigationDestination(item: $deeplinkStop, destination: Departures.init(stop:))
        }
    }
    
    @ViewBuilder private var content: some View {
        if isLoaded {
            ScrollView(.vertical) {
                LazyVStack(spacing: 8) {
                    ForEach(filteredStops) { stop in
                        NavigationLink {
                            Departures(stop: stop)
                        } label: {
                            StopCard(stop: stop, aliases: staticDataProvider.aliases)
                        }
                        .foregroundStyle(.content)
                        if stop.id != filteredStops.last?.id {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(.separe)
                        }
                    }
                }
                .disabled(staticDataProvider.stops.isEmpty)
                .searchable(text: $term)
            }
            .background {
                Color.background.ignoresSafeArea()
            }
        } else {
            Color.background.ignoresSafeArea()
                .overlay {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
        }
    }
    
    private func update() {
        guard
            localStops.isEmpty
            || location == nil && locationProvider.location != nil
            || locationDistance.map({ $0 > 500 }) == true
        else { return }
        Task {
            isLoaded = await staticDataProvider.isUpToDate
            location = locationProvider.location
            localStops = (
                locationProvider.location.map { user in
                    staticDataProvider.stops.sorted { lhs, rhs in
                        lhs.position.location.distance(from: user) < rhs.position.location.distance(from: user)
                    }
                } ?? staticDataProvider.stops
            ).filter { $0.lines.isEmpty == false }
        }
    }
    
    init(deeplinkStop: Binding<Stop?> = .constant(nil)) {
        self._deeplinkStop = deeplinkStop
    }
}

struct StopCard: View {
    
    @Environment(\.locationProvider) var locationProvider
    
    let stop: Stop
    let aliases: [Alias]
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                SwiftUI.Text(stop.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                if let location = locationProvider.location {
                    SwiftUI.Text(
                        MKDistanceFormatter().string(fromDistance: stop.position.location.distance(from: location))
                        + .init(localized: "stop.distance.away")
                    )
                    .font(.system(size: 10))
                }
                VCollection(horizontalSpacing: 4, verticalSpacing: 4) {
                    ForEach(stop.lines, id: \.self) { line in
                        if let lineId = Int(line), let alias = aliases.first(where: { $0.id == lineId }) {
                            HStack(spacing: 4) {
                                Icon(alias.vehicleType.icon, size: .small)
                                    .foregroundStyle(alias.contentColor)
                                SwiftUI.Text(alias.lineName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(alias.contentColor)
                            }
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(alias.backgroundColor)
                            }
                        }
                    }
                    
                }
            }
            Icon(.system("chevron.forward"), size: .small)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

import Networking

struct StationPreview: PreviewProvider {
    
    static let modelsManager = StaticModelsManager()
    
    static var previews: some View {
        Stops()
            .environment(\.staticDataProvider, modelsManager)
            .environment(\.dynamicDataProvider, DynamicModelsManager(stopsAndAliasesProvider: modelsManager))
    }
}
