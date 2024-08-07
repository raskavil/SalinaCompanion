import Foundation

public extension Vehicle {

    static var mock: Self {
        .init(
            id: 6705,
            name: "38",
            position: .init(latitude: 49.198277, longitude: 16.573307),
            bearing: 135,
            alias: .init(id: 12, lineName: "38", contentColorHex: "#FFFFFF", backgroundColorHex: "#AF37B5"),
            isActive: true,
            delay: 3,
            lastStopId: 0,
            finalStopName: "Psychiatrická léčebna",
            lineId: 0,
            routeId: 0,
            serviceId: 0
        )
    }
}

public extension Stop {
    
    static var mock: Self {
        .init(id: 1032, zone: 100, name: "Hlavní nádraží", position: .init(latitude: 0, longitude: 0), lines: [])
    }
}

public extension Alias {
    
    static var mock: Self {
        .init(id: 64, lineName: "64", contentColorHex: "#FFFFFF", backgroundColorHex: "#AF37B5")
    }
}

public extension Post {
    
    static var mock: Self {
        .init(name: "kolej 3", id: 1505, stopId: 1032, departures: [
            .init(lineId: 64, alias: .mock, routeId: 1064, finalStopName: "Chrlice, smyčka", time: "**"),
            .init(lineId: 64, alias: .mock, routeId: 1065, finalStopName: "Chrlice, smyčka", time: "15 min"),
            .init(lineId: 64, alias: .mock, routeId: 1066, finalStopName: "Chrlice, smyčka", time: "21:59"),
            .init(lineId: 64, alias: .mock, routeId: 1067, finalStopName: "Chrlice, smyčka", time: "22:14")
        ], lines: nil)
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
                    isServed: false,
                    time: 671,
                    location: .init(latitude: 49.199468, longitude: 16.570483),
                    path: [
                        .init(latitude: 49.199468, longitude: 16.570483),
                        .init(latitude: 49.19849, longitude: 16.57251)
                    ]
                ),
                .init(
                    id: 165,
                    name: "Marie Pujmanové 1",
                    isServed: false,
                    time: 671,
                    location: .init(latitude: 49.199468, longitude: 16.570483),
                    path: [
                        .init(latitude: 49.199468, longitude: 16.570483),
                        .init(latitude: 49.19849, longitude: 16.57251)
                    ]
                ),
                .init(
                    id: 1254,
                    name: "Marie Pujmanové 2",
                    isServed: false,
                    time: 671,
                    location: .init(latitude: 49.199468, longitude: 16.570483),
                    path: [
                        .init(latitude: 49.199468, longitude: 16.570483),
                        .init(latitude: 49.19849, longitude: 16.57251)
                    ]
                ),
                .init(
                    id: 1367,
                    name: "Marie Pujmanové 3",
                    isServed: false,
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
                    isServed: false,
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
