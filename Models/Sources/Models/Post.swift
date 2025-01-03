
public struct Post: Identifiable, Codable {
    public let name: String
    public let id: String
    public let stopId: String
    public let departures: [Departure]?
    public let lines: [String]?
    
    public init(name: String, id: String, stopId: String, departures: [Departure]?, lines: [String]?) {
        self.name = name
        self.id = id
        self.stopId = stopId
        self.departures = departures
        self.lines = lines
    }
}
