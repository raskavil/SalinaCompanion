import Foundation
import SwiftData

class DataManager {
    
    static let weekInterval = 0.0 // 60.0 * 60 * 24 * 7
    
    private var context: ModelContext?
    
    func set(_ container: ModelContainer) {
        context = .init(container)
        checkData()
    }
    
    private func checkData() {
        guard let context else { return }
        
        let timestamps = try? context.fetch(FetchDescriptor<Timestamp>())
        
        guard let timestamps, timestamps.count == 1, -timestamps[0].timestamp.timeIntervalSinceNow < Self.weekInterval else {
            reloadData()
            return
        }
        
        guard let stopsCount = try? context.fetchCount(FetchDescriptor<Stop>()),
              let lineAliasesCount = try? context.fetchCount(FetchDescriptor<LineAlias>()),
              stopsCount > 0 && lineAliasesCount > 0
        else {
            reloadData()
            return
        }
    }
    
    private func reloadData() {
        Task {
            guard let context else { return }

            let stops = try await StopsRequest.send({ response -> Stop? in
                guard response.LineList.isEmpty == false else { return nil }
                return Stop(
                    id: response.StopID,
                    name: response.Name,
                    longitude: response.Longitude,
                    latitude: response.Latitude,
                    lines: response.LineList.components(separatedBy: ",")
                )
            })
            let lineAliases = try await LineAliasesRequest.send { response in
                LineAlias(id: response.LineId, alias: response.LineName, colorHex: response.Color, textHex: response.TextColor)
            }
            
            guard stops.isEmpty == false, lineAliases.isEmpty == false else {
                return
            }
            
            try context.delete(model: Stop.self)
            try context.delete(model: LineAlias.self)
            try context.delete(model: Timestamp.self)
            
            stops.forEach(context.insert)
            lineAliases.forEach(context.insert)
            context.insert(Timestamp(timestamp: .now))
            try context.save()
        }
    }
}

@Model
class Timestamp {
    let timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Model
class Stop: Identifiable {
    @Attribute(.unique) let id: Int
    let name: String
    let longitude: Double
    let latitude: Double
    let lines: [String]
    
    init(id: Int, name: String, longitude: Double, latitude: Double, lines: [String]) {
        self.id = id
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.lines = lines
    }
}

@Model
class LineAlias {
    @Attribute let id: Int
    let alias: String
    let colorHex: String
    let textHex: String
    
    init(id: Int, alias: String, colorHex: String, textHex: String) {
        self.id = id
        self.alias = alias
        self.colorHex = colorHex
        self.textHex = textHex
    }
}
