import SwiftUI
import SupportPackageViews
import SwiftData

struct Stations: View {
    
    @Query var stops: [Stop]
    @Query var aliases: [LineAlias]
    @State var term = ""
    @State var displayError = false
    
    var filteredStops: [Stop] {
        stops.filter {
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
    }
    
    @ViewBuilder private var content: some View {
        if displayError {
            VStack(alignment: .center, spacing: 8) {
                Text("Something went wrong", weight: .medium)
                Text("There has been a problem loading public transport stops please try again later")
                    .multilineTextAlignment(.center)
            }
        } else {
            ScrollView(.vertical) {
                LazyVStack(spacing: 8) {
                    if filteredStops.isEmpty == false {
                        ForEach(filteredStops) { stop in
                            NavigationLink(
                                destination: Departures(stop: stop)
                            ) {
                                StopCard(stop: stop, aliases: aliases)
                            }
                        }
                    } else {
                        ForEach(0...8, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 96)
                                .foregroundStyle(Color(white: 0.7))
                        }
                    }
                }
                .disabled(stops.isEmpty)
                .searchable(text: $term)
                .padding(.horizontal, 16)
            }
        }
    }
}

struct StopCard: View {
    
    let stop: Stop
    let aliases: [LineAlias]
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Icon(.system("bus"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stop.name, size: .large)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text("\(Int(stop.longitude)) m away", size: .small)
                    }
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(stop.lines.chunked(into: 5).enumerated()), id: \.offset) { _, chunk in
                        HStack(spacing: 4) {
                            ForEach(chunk, id: \.self) { line in
                                if let lineId = Int(line), let alias = aliases.first(where: { $0.id == lineId }) {
                                    line.lineBadge(with: alias)
                                        .fixedSize()
                                }
                            }
                        }
                    }
                }
            }
            Icon(.system("chevron.forward"), size: .small)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
                .shadow(radius: 2.0)
        }
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
    
    func lineBadge(with alias: LineAlias) -> Badge {
        var icon = Int(self)?.vehicleIcon
        if alias.alias.starts(with: "R") || alias.alias.starts(with: "S") {
            icon = .system("tram")
        }
        return Badge(
            text: alias.alias,
            icon: icon,
            style: .init(
                contentColor: .white,
                backgroundColor: .init(hexString: alias.colorHex),
                borderColor: .clear
            )
        )
    }
}

#Preview {
    PreviewWrapper {
        Stations()
    }
}
