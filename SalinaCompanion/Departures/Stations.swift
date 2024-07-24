import SwiftUI
import SupportPackageViews
import Models

struct Stations: View {
    
    @Environment(\.staticDataProvider) var staticDataProvider
    @State var term = ""
    @State var displayError: Bool?
    
    var filteredStops: [Stop] {
        staticDataProvider.stops.filter {
            guard term.isEmpty == false else {
                return true
            }
            return $0.name.starts(with: term)
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Departures")
        }
        .task {
            displayError = await !staticDataProvider.isUpToDate
        }
    }
    
    @ViewBuilder private var content: some View {
        if displayError == true {
            VStack(alignment: .center, spacing: 8) {
                Text("Something went wrong", weight: .medium)
                Text("There has been a problem loading public transport stops please try again later")
                    .multilineTextAlignment(.center)
            }
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 8) {
                    ForEach(filteredStops) { stop in
                        StopCard(stop: stop, aliases: staticDataProvider.aliases)
                        if stop.id != filteredStops.last?.id {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(Color(white: 0.8))
                        }
                    }
                }
                .disabled(staticDataProvider.stops.isEmpty)
                .searchable(text: $term)
            }
        }
    }
}

struct StopCard: View {
    
    let stop: Stop
    let aliases: [Alias]
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                SwiftUI.Text(stop.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                SwiftUI.Text("\(Int(stop.position.longitude)) m away")
                    .font(.system(size: 10))
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

extension String {
    
    func lineBadge(with alias: Alias) -> Badge {
        var icon = Icon.Content.system("bus")
        if alias.lineName.starts(with: "R") || alias.lineName.starts(with: "S") {
            icon = .system("tram")
        }
        return Badge(
            text: alias.lineName,
            icon: icon,
            style: .init(
                contentColor: alias.contentColor,
                backgroundColor: alias.backgroundColor,
                borderColor: .clear
            )
        )
    }
}

import Networking

struct StationPreview: PreviewProvider {
    
    static let modelsManager = StaticModelsManager()
    
    static var previews: some View {
        Stations()
            .environment(\.staticDataProvider, modelsManager)
    }
}
