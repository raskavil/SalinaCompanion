import SwiftUI
import Models

struct Stops: View {
    
    enum Mode: Hashable, CustomStringConvertible {
        case nearest
        case favorite
        
        var description: String {
            return switch self {
                case .nearest:  .init(localized: "stops.nearest")
                case .favorite: .init(localized: "stops.favorite")
            }
        }
    }
    
    @Environment(\.staticDataProvider) var staticDataProvider
    @Environment(\.locationProvider) var locationProvider
    
    @State var selectedMode: Mode = .nearest
    @State var nearestStops: [Stop] = []
    @State var favoriteStops: [Stop] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if favoriteStops.isEmpty == false {
                    SegmentedControl(
                        selectedOption: $selectedMode,
                        availableOptions: [.nearest, .favorite]
                    )
                }
                switch selectedMode {
                case .nearest:
                    if nearestStops.isEmpty {
                        Text("location.not_found")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(nearestStops) { stop in
                            NavigationLink(stop.name) {
                                Departures(stop: stop)
                            }
                        }
                    }
                case .favorite:
                    if favoriteStops.isEmpty {
                        Text("stops.favorite_empty")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(favoriteStops) { stop in
                            NavigationLink(stop.name) {
                                Departures(stop: stop)
                            }
                        }
                    }
                    
                }
            }
            .task {
                if nearestStops.isEmpty || favoriteStops.isEmpty, await staticDataProvider.isUpToDate {
                    update()
                }
            }
            .onAppear {
                if nearestStops.isEmpty || favoriteStops.isEmpty {
                    update()
                }
            }
            .navigationTitle("stops.title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func update() {
        if nearestStops.isEmpty, let user = locationProvider.location {
            nearestStops = Array(
                staticDataProvider.stops.sorted { lhs, rhs in
                    lhs.position.location.distance(from: user) < rhs.position.location.distance(from: user)
                }.first(10)
            )
        }
        if favoriteStops.isEmpty {
            favoriteStops = staticDataProvider.stops.filter { stop in
                staticDataProvider.favoriteStops.contains(stop.id)
            }
        }
    }
}

struct SegmentedControl<T: Hashable & CustomStringConvertible>: View {
    
    @Namespace var namespace
    @Binding var selectedOption: T
    let availableOptions: [T]
    
    var body: some View {
        HStack {
            ForEach(availableOptions, id: \.self) { option in
                Text(option.description)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background {
                        if option == selectedOption {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(.tint)
                                .matchedGeometryEffect(id: "segmentedControl-background", in: namespace)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.1)) {
                            selectedOption = option
                        }
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension Array {
    
    func first(_ k: Int) -> ArraySlice<Element> {
        guard (count - k) >= 0 else { return dropLast(0) }
        return dropLast(count - k)
    }
}

#Preview {
    Stops()
}
