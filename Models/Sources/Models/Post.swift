
public struct Post: Identifiable, Codable {
    public let name: String
    public let id: Int
    public let stopId: Int
    public let departures: [Departure]?
    public let lines: [String]?
    
    public init(name: String, id: Int, stopId: Int, departures: [Departure]?, lines: [String]?) {
        self.name = name
        self.id = id
        self.stopId = stopId
        self.departures = departures
        self.lines = lines
    }
}
