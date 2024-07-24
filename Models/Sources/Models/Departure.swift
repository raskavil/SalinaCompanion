import Foundation

public struct Departure {
    public let lineId: Int
    public let alias: Alias
    public let routeId: Int
    public let finalStopName: String
    public let time: String
    
    public init(lineId: Int, alias: Alias, routeId: Int, finalStopName: String, time: String) {
        self.lineId = lineId
        self.alias = alias
        self.routeId = routeId
        self.finalStopName = finalStopName
        self.time = time
    }
}
