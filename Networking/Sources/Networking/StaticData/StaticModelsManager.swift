import Foundation
import Models
import SupportPackage

public final class StaticModelsManager: StaticModelsProviding {
    
    public enum SaveMode {
        case appGroup
        case local
        
        private static let group = "group.cz.raskavil.SalinaCompanion.staticData"
        
        var userDefaults: UserDefaults? {
            switch self {
            case .appGroup: return UserDefaults(suiteName: Self.group)
            case .local:    return UserDefaults.standard
            }
        }
        
        var directoryUrl: URL? {
            switch self {
            case .appGroup: return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.group)
            case .local:    return try? FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false
            )
            }
        }
    }
    
    
    // MARK: - UserDefaults values
    private static let filteredLinesKey = "SalinaCompanion.filteredLines"
    private static let timestampKey = "SalinaCompanion.staticDataTimestamp"
    private static let favoriteStopsKey = "SalinaCompanion.favoriteStops"
    
    public var timestamp: Date? {
        get { saveMode.userDefaults?.value(forKey: Self.timestampKey) as? Date }
        set { saveMode.userDefaults?.setValue(newValue, forKey: Self.timestampKey) }
    }
    
    public var filteredLines: Set<Int> {
        didSet { saveMode.userDefaults?.setValue(Array(filteredLines), forKey: Self.filteredLinesKey) }
    }
    
    public var favoriteStops: Set<Int> {
        didSet { saveMode.userDefaults?.setValue(Array(favoriteStops), forKey: Self.favoriteStopsKey) }
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
                directoryUrl
                    .map { $0.appendingPathComponent(path.fileName) }
                    .map { try? JSONEncoder().encode(wrappedValue).write(to: $0) }
            }
        }
        
        private let path: Path
        private let directoryUrl: URL?
        
        init(wrappedValue defaultValue: Value, _ path: Path, directoryUrl: URL?) {
            self.path = path
            self.directoryUrl = directoryUrl
            self.wrappedValue = directoryUrl
                .map { $0.appendingPathComponent(path.fileName) }
                .flatMap { FileManager.default.contents(atPath: $0.path) }
                .flatMap { try? JSONDecoder().decode(Value.self, from: $0) } ?? defaultValue
        }

    }

    @SavedInFile public var stops: [Stop]
    @SavedInFile public var aliases: [Alias]
    @SavedInFile public var posts: [Int: [Post]]
    
    private let saveMode: SaveMode
    
    // MARK: Init, integrity and load functions
    public init(saveMode: SaveMode = .appGroup) {
        self.saveMode = saveMode
        self._stops = .init(wrappedValue: [], .stops, directoryUrl: saveMode.directoryUrl)
        self._aliases = .init(wrappedValue: [], .aliases, directoryUrl: saveMode.directoryUrl)
        self._posts = .init(wrappedValue: [:], .posts, directoryUrl: saveMode.directoryUrl)
        self.filteredLines = Set(saveMode.userDefaults?.value(forKey: Self.filteredLinesKey) as? Array<Int> ?? [])
        self.favoriteStops = Set(saveMode.userDefaults?.value(forKey: Self.favoriteStopsKey) as? Array<Int> ?? [])
    }
    
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
    
    public func toggleFavorite(_ stopId: Int) {
        if favoriteStops.contains(stopId) {
            favoriteStops.remove(stopId)
        } else {
            favoriteStops.insert(stopId)
        }
    }
}
