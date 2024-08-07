import Foundation
import Models
import SupportPackage

public final class StaticModelsManager: StaticModelsProviding {
    
    private static let group = "group.cz.raskavil.SalinaCompanion.staticData"
    
    // MARK: - UserDefaults values
    private static let filteredLinesKey = "SalinaCompanion.filteredLines"
    private static let timestampKey = "SalinaCompanion.staticDataTimestamp"
    
    public var timestamp: Date? {
        get { UserDefaults(suiteName: Self.group)?.value(forKey: Self.timestampKey) as? Date }
        set { UserDefaults(suiteName: Self.group)?.setValue(newValue, forKey: Self.timestampKey) }
    }
    
    public var filteredLines: Set<Int> {
        get { Set(UserDefaults(suiteName: Self.group)?.value(forKey: Self.filteredLinesKey) as? Array<Int> ?? []) }
        set { UserDefaults(suiteName: Self.group)?.setValue(Array(newValue), forKey: Self.filteredLinesKey) }
    }
    
    // MARK: - File values
    
    @propertyWrapper
    public struct SavedInFile<Value: Codable> {
        
        public enum Path: String {
            case stops = "downloadedStops"
            case aliases = "downloadedAliases"
            case posts = "downloadedPosts"
            
            var fileName: String { rawValue + ".json" }
        }
        
        public var wrappedValue: Value {
            didSet {
                FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: StaticModelsManager.group)
                    .map { $0.appendingPathComponent(path.fileName) }
                    .map { try? JSONEncoder().encode(wrappedValue).write(to: $0) }
            }
        }
        
        private let path: Path
        
        init(wrappedValue defaultValue: Value, _ path: Path) {
            self.path = path
            self.wrappedValue = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: StaticModelsManager.group)
                .map { $0.appendingPathComponent(path.fileName) }
                .flatMap { FileManager.default.contents(atPath: $0.path) }
                .flatMap { try? JSONDecoder().decode(Value.self, from: $0) } ?? defaultValue
        }

    }

    @SavedInFile(.stops) public var stops: [Stop] = []
    @SavedInFile(.aliases) public var aliases: [Alias] = []
    @SavedInFile(.posts) public var posts: [Int: [Post]] = [:]
    
    // MARK: Init, integrity and load functions
    public init() {}
    
    private static let weekInterval = 60.0 * 60 * 24 * 7
    
    public var isUpToDate: Bool {
        get async {
            guard
                let timestamp,
                timestamp.timeIntervalSinceNow < Self.weekInterval,
                stops.isEmpty == false,
                aliases.isEmpty == false,
                posts.isEmpty == false
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
        
        do {
            let posts = try await PostsRequest.send { response in
                Post(
                    name: response.Name,
                    id: response.ID,
                    stopId: response.StopID,
                    departures: nil,
                    lines: response.LineList.components(separatedBy: ",")
                )
            }
            self.posts = .init(grouping: posts, by: \.stopId)
        } catch {
            return false
        }
        
        guard stops.isEmpty == false, aliases.isEmpty == false, posts.isEmpty == false else {
            return false
        }
        
        timestamp = .now
        return true
    }
}
