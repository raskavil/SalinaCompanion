import SwiftUI
import SupportPackageViews
import Models

struct Departures: View {
    
    @Environment(\.dynamicDataProvider) var departuresProvider
    @State var posts: [Post] = []
    @State var routeBeingLoaded: Int?
    let stop: Stop
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(posts) { post in
                    if post.id == posts.first?.id {
                        Rectangle()
                            .foregroundStyle(Color(white: 0.8))
                            .frame(height: 0.5)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        SwiftUI.Text("Zastávka " + post.name)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.bottom, 6)
                        ForEach(Array(post.departures.enumerated()), id: \.offset) { index, departure in
                            HStack {
                                HStack(spacing: 4) {
                                    Icon(departure.alias.vehicleType.icon, size: .small)
                                        .foregroundStyle(departure.alias.contentColor)
                                    SwiftUI.Text(departure.alias.lineName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(departure.alias.contentColor)
                                }
                                .padding(4)
                                .frame(minWidth: 45, minHeight: 30, alignment: .center)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(departure.alias.backgroundColor)
                                }
                                .frame(minWidth: 55, alignment: .leading)
                                
                                SwiftUI.Text(departure.finalStopName)
                                    .font(.system(size: 14, weight: .medium))
                                    .minimumScaleFactor(0.7)
                                    .lineLimit(1)
                                Spacer()
                                
                                SwiftUI.Text(departure.time)
                                    .font(.system(size: 14, weight: .medium))
                                
                                if routeBeingLoaded == departure.routeId {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 28)
                                } else {
                                    Button(action: {
                                        routeBeingLoaded = departure.routeId
                                    }) {
                                        Circle()
                                            .frame(width: 28, height: 28)
                                            .foregroundStyle(Color(white: 0.95))
                                            .overlay {
                                                Image(systemName: "location.circle")
                                                    .foregroundStyle(departure.alias.backgroundColor)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(12)
                    Rectangle()
                        .foregroundStyle(Color(white: 0.8))
                        .frame(height: 0.5)
                }
                Spacer()
            }
        }
        .navigationTitle(stop.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                do {
                    posts = try await departuresProvider.departures(for: stop)
                    print(posts)
                } catch {
                    print(error)
                }
            }
        }
    }
}

import Networking

struct DeparturesPreviews: PreviewProvider {
    
    private struct LoadingWrapper: View {
        @Environment(\.staticDataProvider) var staticDataProvider
        @State var loaded = false
        
        var body: some View {
            VStack {
                if loaded {
                    NavigationStack {
                        Departures(
                            stop: .init(
                                id: 1146,
                                zone: 101,
                                name: "Chrlice, nádraží",
                                position: .init(),
                                lines: []
                            )
                        )
                    }
                }
            }
            .task {
                loaded = await staticDataProvider.isUpToDate
            }
        }
    }
    
    static var staticDataProvider = StaticModelsManager()
    
    static var previews: some View {
        LoadingWrapper()
            .environment(\.staticDataProvider, staticDataProvider)
            .environment(\.dynamicDataProvider, DynamicModelsManager(stopsAndAliasesProvider: staticDataProvider))
    }
    
}
