import SwiftUI
import SwiftData
import SupportPackageViews

struct Departures: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Query var aliases: [LineAlias]
    @State var posts: [DeparturesRequest.PostResponse] = []
    let stop: Stop
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Icon(.system("chevron.backward"))
                }
                Spacer()
                Text(stop.name, size: .large, weight: .medium)
                Spacer()
            }
            .background(Color.white)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(posts, id: \.PostID) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nástupiště \(post.PostID) - " + post.Name, size: .large, weight: .medium)
                            ForEach(Array(post.Departures.enumerated()), id: \.offset) { _, departure in
                                HStack {
                                    aliases
                                        .first(where: { $0.alias == departure.LineName})
                                        .map { departure.LineName.lineBadge(with: $0) }
                                    Text(departure.FinalStop)
                                    Spacer()
                                    Text(departure.TimeMark, weight: .medium)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.white)
                                .shadow(radius: 2.0)
                        )
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            Task {
                posts = try await DeparturesRequest.send(stopId: stop.id, { $0 })
            }
        }
    }
}

extension [LineAlias] {
    
    func color(for lineName: String, from keypath: KeyPath<LineAlias, String>, fallback: Color = .primary) -> Color {
        guard let alias = first(where: { $0.alias == lineName }) else {
            return fallback
        }
        return .init(uiColor: .init(hexString: alias[keyPath: keypath]))
    }
    
}

extension Int {
    
    var vehicleIcon: Icon.Content {
        switch self {
            case 1...19:     return .system("tram.fill")
            case 20...39:    return .system("bus")
            default:         return .system("bus")
        }
    }
}

#Preview {
    Departures(
        stop: .init(
            id: 1291,
            name: "Krásného",
            longitude: 0,
            latitude: 0,
            lines: ["8", "10"]
        )
    )
}
