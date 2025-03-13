import Foundation
import Models

public class DynamicModelsManager: DynamicModelsProviding {
    
    private let staticModelsManager: StaticModelsManager

    public var vehicles: [Vehicle] {
        get async throws {

            let urlRequest = URLRequest(url: .init(string: "https://kordis-jmk.cz/gtfs/gtfsReal.dat")!)
            let response = try TransitRealtime_FeedMessage(serializedBytes: Data())

            /* let values = response.entity.compactMap { entity -> Vehicle? in
                guard entity.hasVehicle else { return nil }
                return .init(
                    id: Int(entity.vehicle.vehicle.id) ?? 1,
                    name: entity.vehicle.trip.routeID,
                    position: .init(
                        latitude: Double(entity.vehicle.position.latitude),
                        longitude: Double(entity.vehicle.position.longitude)
                    ),
                    bearing: Int(entity.vehicle.position.bearing) ?? 0,
                    alias: .init(id: 1, lineName: "1", contentColorHex: "#000000", backgroundColorHex: "#FFFFFF"),
                    isActive: true,
                    delay: Int(entity.tripUpdate.delay),
                    lastStopId: Int(entity.vehicle.stopID) ?? 0,
                    finalStopName: entity.vehicle.trip.routeID,
                    lineId: Int(entity.vehicle.stopID) ?? 0,
                    routeId: Int(entity.vehicle.stopID) ?? 0,
                    serviceId: Int(entity.vehicle.trip.directionID)
                )
            } */
            return []
            /* let vehicles = try await MapRequest.send { vehicle in
                Vehicle(
                    id: vehicle.ID,
                    name: vehicle.LineName,
                    position: .init(latitude: vehicle.Lat, longitude: vehicle.Lng),
                    bearing: vehicle.Bearing,
                    alias: aliases.first(where: { $0.lineName == vehicle.LineName })
                        ?? .init(id: 0, lineName: vehicle.LineName, contentColorHex: "#000000", backgroundColorHex: "#FFFFFF"),
                    isActive: !vehicle.IsInactive,
                    delay: vehicle.Delay,
                    lastStopId: vehicle.LastStopID,
                    finalStopName: vehicle.FinalStopName,
                    lineId: vehicle.LineID,
                    routeId: vehicle.RouteID,
                    serviceId: vehicle.ServiceId
                )
            }
            return vehicles */
        }
    }
    
    public func route(for vehicle: Vehicle) async throws -> VehicleRoute {
        /* let stops = staticModelsManager.stops

        let (route, times) = (
            try await RouteRequest(vehicle: vehicle).send { $0 },
            try await ServiceInfoRequest(vehicle: vehicle).send { $0 }
        )
        
        var vehicleStops = times.compactMap { time -> VehicleStop? in
            guard let stop = stops.first(where: { $0.id == time.StopId }) else { return nil }
            
            return VehicleStop(
                id: time.StopId,
                name: stop.name,
                isServed: false,
                time: time.Time,
                location: stop.position,
                path: route
                    .first(where: { $0.StopId == time.StopId })?.Path
                    .map { .init(latitude: $0[0], longitude: $0[1]) } ?? []
            )
        }
        
        if let index = vehicleStops.firstIndex(where: { $0.id == vehicle.lastStopId }) {
            (0...index).forEach { index in
                vehicleStops[index].isServed = true
            }
        }
        
        return .init(
            vehicle: vehicle,
            stops: vehicleStops
        ) */
        throw NSError()
    }
    
    public func departures(for stopId: String) async throws -> [Post] {
        []
        /* let aliases = staticModelsManager.aliases
        return try await DeparturesRequest(stopId: stopId).send { post in
            Post(
                name: post.Name,
                id: post.PostID,
                stopId: stopId,
                departures: post.Departures.compactMap { departure in
                    guard let value = departure.value, let alias = aliases.first(where: { $0.id == value.LineId }) else {
                        return nil
                    }
                    return Departure(
                        lineId: value.LineId,
                        alias: alias,
                        routeId: value.RouteId,
                        finalStopName: value.FinalStop,
                        time: value.TimeMark
                    )
                },
                lines: nil
            )
        } */
    }
    
    public func departures(for stop: Stop) async throws -> [Post] {
        try await departures(for: stop.id)
    }
    
    public init(staticModelsManager: StaticModelsManager) {
        self.staticModelsManager = staticModelsManager
    }
}
