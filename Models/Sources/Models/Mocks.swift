import Foundation

public extension Vehicle {

    static var mock: Self {
        .init(
            id: 6705,
            name: "38",
            type: .bus,
            position: .init(latitude: 49.198277, longitude: 16.573307),
            bearing: 135,
            alias: .init(id: 12, lineName: "38", contentColorHex: "#FFFFFF", backgroundColorHex: "#AAAAAA"),
            isActive: true,
            delay: 0,
            lastStopId: 0,
            finalStopName: "Psychiatrická léčebna",
            lineId: 0,
            routeId: 0,
            serviceId: 0
        )
    }
}

public extension VehicleRoute {
    
    static var mock: Self {
        .init(
            vehicle: .mock,
            stops: [
                .init(
                    id: 1517,
                    name: "Preslova",
                    isServed: true,
                    time: 671,
                    location: .init(latitude: 49.199468, longitude: 16.570483),
                    path: [.init(latitude: 49.199468, longitude: 16.570483)]
                ),
                .init(
                    id: 1366,
                    name: "Marie Pujmanové",
                    isServed: true,
                    time: 671,
                    location: .init(latitude: 49.199468, longitude: 16.570483),
                    path: [
                        .init(latitude: 49.199468, longitude: 16.570483),
                        .init(latitude: 49.19849, longitude: 16.57251)
                    ]
                ),
                .init(
                    id: 1433,
                    name: "Neumannova",
                    isServed: true,
                    time: 672,
                    location: .init(latitude: 49.196459, longitude: 16.578249),
                    path: [
                        .init(latitude: 49.196459, longitude: 16.578249),
                        .init(latitude: 49.198299, longitude: 16.595263),
                    ]
                ),
                .init(
                    id: 1442,
                    name: "Úvoz",
                    isServed: false,
                    time: 677,
                    location: .init(latitude: 49.198299, longitude: 16.595263),
                    path: [
                        .init(latitude: 49.198299, longitude: 16.595263),
                        .init(latitude: 49.1982, longitude: 16.59741)
                    ]
                ),
                .init(
                    id: 1257,
                    name: "Komenského náměstí",
                    isServed: false,
                    time: 679,
                    location: .init(latitude: 49.197026, longitude: 16.602057),
                    path: [
                        .init(latitude: 49.197026, longitude: 16.602057),
                        .init(latitude: 49.197346, longitude: 16.604057)
                    ]
                )
            ]
        )
    }
}
