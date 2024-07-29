import SwiftUI
import SupportPackageViews
import Models

struct Departures: View {
    
    class Model: ObservableObject {

        @Published var vehicleDetail: VehicleDetail.Model?
        @Published var connectionToLoad: (routeId: Int, lineId: Int)? {
            didSet {
                task?.cancel()
                task = .init(operation: { [weak self] in
                    do {
                        let vehicles = try await self?.departuresProvider?.vehicles
                        if let vehicle = vehicles?.first(where: { 
                            $0.routeId == self?.connectionToLoad?.routeId && $0.lineId == self?.connectionToLoad?.lineId
                        }) {
                            try Task.checkCancellation()
                            DispatchQueue.main.async { [weak self] in
                                self?.vehicleDetail = .loading(vehicle)
                            }
                            self?.connectionToLoad = nil
                            Task { [weak self] in
                                let route = try await self?.departuresProvider?.route(for: vehicle)
                                if let route, route.vehicle.id == self?.vehicleDetail?.vehicle.id {
                                    DispatchQueue.main.async { [weak self] in
                                        self?.vehicleDetail = .loaded(route)
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error loading")
                    }
                })
            }
        }
        @Published var posts: [Post]?

        let stop: Stop
        var departuresProvider: DynamicModelsProviding? {
            didSet {
                startUpdating()
            }
        }
        
        private var timer: Timer?
        private var task: Task<Void, Never>?
        
        init(stop: Stop) {
            self.stop = stop
        }
        
        private func startUpdating() {
            guard let departuresProvider else { return }
            
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] timer in
                Task { [weak self] in
                    if let stop = self?.stop {
                        let posts = try await departuresProvider.departures(for: stop)
                        DispatchQueue.main.async { [weak self] in
                            self?.posts = posts
                        }
                    }
                }
                
                if let vehicleDetail = self?.vehicleDetail {
                    Task { [weak self] in
                        let vehicles = try await departuresProvider.vehicles
                        if let vehicle = vehicles.first(where: {
                            $0.id == vehicleDetail.vehicle.id && $0.routeId == vehicleDetail.vehicle.routeId
                        }) {
                            if case .loading = vehicleDetail {
                                DispatchQueue.main.async { [weak self] in
                                    self?.vehicleDetail = .loading(vehicle)
                                }
                            }
                            let route = try await departuresProvider.route(for: vehicle)
                            DispatchQueue.main.async { [weak self] in
                                self?.vehicleDetail = .loaded(route)
                            }
                        }
                    }
                }
            }
            
            timer?.fire()
        }
    }
    
    @Environment(\.dynamicDataProvider) var departuresProvider
    @StateObject private var model: Model
    
    var body: some View {
        ScrollView {
            if let posts = model.posts {
                VStack(alignment: .leading, spacing: 8) {
                    if posts.isEmpty == false {
                        ForEach(posts, content: post)
                        Spacer()
                    } else {
                        Text("departures.not_found")
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            model.departuresProvider = departuresProvider
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(model.stop.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $model.vehicleDetail) { _ in
            VehicleDetail(model: $model.vehicleDetail, displayMap: true, close: { self.model.vehicleDetail = nil })
        }
    }
    
    @ViewBuilder private func post(_ post: Post) -> some View {
        if post.id == model.posts?.first?.id {
            Rectangle()
                .foregroundStyle(Color(white: 0.8))
                .frame(height: 0.5)
        }
        VStack(alignment: .leading, spacing: 4) {
            SwiftUI.Text("departures.post.name.\(post.name)")
                .font(.system(size: 16, weight: .semibold))
                .padding(.bottom, 6)
            ForEach(Array(post.departures.enumerated()), id: \.offset) { _, departure in
                self.departure(departure)
            }
        }
        .padding(12)
        Rectangle()
            .foregroundStyle(Color(white: 0.8))
            .frame(height: 0.5)
    }
    
    private func departure(_ departure: Departure) -> some View {
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
            
            if model.connectionToLoad.map({ $0 == departure.dataForConnection }) ?? false {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 28)
            } else {
                Button(action: {
                    model.connectionToLoad = departure.dataForConnection
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
    
    init(stop: Stop) {
        self._model = .init(wrappedValue: .init(stop: stop))
    }
}

extension Departure {
    
    var dataForConnection: (routeId: Int, lineId: Int) {
        (routeId, lineId)
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
