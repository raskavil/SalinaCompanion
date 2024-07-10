import SwiftUI
import MapKit
import Combine

extension VehiclesMap {
    
    class Model: ObservableObject {
        
        @Published var displayedVehicles: [MapRequest.VehicleResponse] = [] {
            didSet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.loading = false
                }
            }
        }
        @Published var selectedItem: Int?
        @Published var loading = true
        @Published var numberOfErrors: Int = 0
        
        var selectedVehicle: MapRequest.VehicleResponse? {
            selectedItem.flatMap { item in vehicles.first(where: { $0.ID == item })}
        }
        
        private var vehicles: [MapRequest.VehicleResponse] = []
        private var mapPosition: MKMapRect?
        private var timer = Timer()
        private var cancellables: Set<AnyCancellable> = []
        private var canUpdate = true
        
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
            
            updateVehicles()
        }
        
        private var filteredVehicles: [MapRequest.VehicleResponse] {
            vehicles.filter { mapPosition?.contains(.init(CLLocationCoordinate2D(latitude: $0.Lat, longitude: $0.Lng))) ?? true }
        }
        
        private func updateVehicles() {
            self.loading = true
            Task(priority: .userInitiated) { [weak self] in
                do {
                    let vehicles = try await MapRequest.send { $0 }
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
