import SwiftUI
import MapKit
import Combine
import Models
import Device

extension VehiclesMap {
    
    class Model: ObservableObject {
        
        @Published var displayedVehicles: [Vehicle] = [] {
            didSet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.loading = false
                }
            }
        }
        @Published var loading = true
        @Published var numberOfErrors: Int = 0
        @Published var displayedVehicle: VehicleDetail.Model? {
            didSet {
                if case .loading(let vehicle) = displayedVehicle {
                    guard let vehiclesProvider else { return }
                    Task {
                        let route = try await vehiclesProvider.route(for: vehicle)
                        DispatchQueue.main.async {
                            self.displayedVehicle = .loaded(route)
                        }
                    }
                }
            }
        }
        @Published var position: MapCameraPosition = .userLocation(
            fallback: .region(.init(center: .brno, span: .init(latitudeDelta: 0.03, longitudeDelta: 0.03)))
        )
        var alertPresentedBiding: Binding<Bool> {
            .init(
                get: { [weak self] in
                    self.map { $0.numberOfErrors >= 3 } ?? false
                },
                set: { [weak self] value in
                    if value == false {
                        self?.numberOfErrors = 0
                    }
                }
            )
        }
        
        private var vehicles: [Vehicle] = []
        private var mapPosition: MKMapRect?
        private var timer = Timer()
        private var cancellables: Set<AnyCancellable> = []
        private var canUpdate = true
        var vehiclesProvider: DynamicModelsProviding? {
            didSet {
                updateVehicles()
            }
        }
        
        init(mapPosition: AnyPublisher<MKMapRect, Never>) {
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in self?.updateVehicles() }
        
            mapPosition
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.canUpdate = false
                    self?.loading = true
                }
                .store(in: &cancellables)
            
            mapPosition
                .debounce(for: 2.0, scheduler: RunLoop.main)
                .sink { [weak self] mapPosition in
                    guard let self else { return }
                    self.mapPosition = mapPosition
                    self.displayedVehicles = filteredVehicles
                    self.canUpdate = true
                }
                .store(in: &cancellables)
        }
        
        func subscribe(to provider: PermissionsProviding) {
            provider.permissionsChanged
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
        
        func focusUserLocation() {
            position = .userLocation(fallback: position)
        }
        
        private var filteredVehicles: [Vehicle] {
            vehicles.filter { mapPosition?.contains(.init($0.position)) ?? true }
        }
        
        private func updateVehicles() {
            guard let vehiclesProvider else { return }
            DispatchQueue.main.async {
                self.loading = true
            }
            Task(priority: .userInitiated) { [weak self] in
                do {
                    let vehicles = try await vehiclesProvider.vehicles.filter(\.isActive)
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.numberOfErrors = 0
                        self.vehicles = vehicles
                        if self.canUpdate {
                            self.displayedVehicles = self.filteredVehicles
                        }
                    }
                } catch {
                    self?.numberOfErrors += 1
                }
            }
        }
    }
}

extension CLLocationCoordinate2D {
    
    static var brno: Self {
        .init(latitude: 49.195061, longitude: 16.606836)
    }
}
