import Foundation
import Models
import SupportPackage

public class StaticModelsManager: StaticModelsProviding {
    
    private static let weekInterval = 60.0 * 60 * 24 * 7
    
    public var isUpToDate: Bool {
        get async {
            guard
                let timestamp,
                timestamp.date.timeIntervalSinceNow < Self.weekInterval,
                stops.isEmpty == false,
                aliases.isEmpty == false
            else {
                return await reloadData()
            }
            
            return true
        }
    }
    
    @discardableResult
    func reloadData() async -> Bool {
        do {
            stops = try await StopsRequest.send({ response -> Stop? in
                Stop(
                    id: response.StopID,
                    zone: response.Zone,
                    name: response.Name,
                    position: .init(latitude: response.Latitude, longitude: response.Longitude),
                    lines: response.LineList.components(separatedBy: ",")
                )
            })
        } catch {
            return false
        }
        
        do {
            aliases = try await AliasesRequest.send { response in
                Alias(
                    id: response.LineId,
                    lineName: response.LineName,
                    contentColorHex: response.TextColor,
                    backgroundColorHex: response.Color
                )
            }
        } catch {
            return false
        }
        
        guard stops.isEmpty == false, aliases.isEmpty == false else {
            return false
        }
        
        timestamp = .init(date: .now)
        return true
    }
    
    @Saved("timestamp") var timestamp: Timestamp? = nil
    @Saved("stops") public var stops: [Stop] = []
    @Saved("aliases") public var aliases: [Alias] = []
    public var filteredLines: Set<Int> {
        get { UserDefaults.standard.value(forKey: Self.filteredLinesKey) as? Set<Int> ?? [] }
        set { UserDefaults.standard.setValue(newValue, forKey: Self.filteredLinesKey) }
    }
    
    private static let filteredLinesKey = "SalinaCompanion.filteredLines"
    
    public init(timestamp: Date? = nil, stops: [Stop] = [], aliases: [Alias] = []) {
        self.timestamp = timestamp.map(Timestamp.init(date:))
        self.stops = stops
        self.aliases = aliases
    }
}

struct Timestamp: Codable {
    let date: Date
}
