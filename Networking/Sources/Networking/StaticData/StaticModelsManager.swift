import Foundation
import Models
import SupportPackage

public class StaticModelsManager: StaticModelsProviding {
    
    private static let weekInterval = 60.0 * 60 * 24 * 7
    
    public var isUpToDate: Bool {
        get async {
            guard
                let timestamp,
                timestamp.timeIntervalSinceNow < Self.weekInterval,
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
        
        timestamp = .now
        return true
    }
    
    public var timestamp: Date? {
        get { UserDefaults.standard.value(forKey: Self.timestampKey) as? Date }
        set { UserDefaults.standard.setValue(newValue, forKey: Self.timestampKey) }
    }
    @Saved("stops") public var stops: [Stop] = []
    @Saved("aliases") public var aliases: [Alias] = []
    public var filteredLines: Set<Int> {
        get { Set(UserDefaults.standard.value(forKey: Self.filteredLinesKey) as? Array<Int> ?? []) }
        set { UserDefaults.standard.setValue(Array(newValue), forKey: Self.filteredLinesKey) }
    }
    
    private static let filteredLinesKey = "SalinaCompanion.filteredLines"
    private static let timestampKey = "SalinaCompanion.staticDataTimestamp"
    
    public init() {}
}

struct Timestamp: Codable {
    let date: Date
}
