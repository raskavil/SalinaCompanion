
public struct Post: Identifiable {
    public let name: String
    public let id: Int
    public let departures: [Departure]
    
    public init(name: String, id: Int, departures: [Departure]) {
        self.name = name
        self.id = id
        self.departures = departures
    }
}
