import Foundation
import Models
import SupportPackage
import ZIPFoundation

@globalActor actor StaticDataLoader: GlobalActor {
    static let shared = StaticDataLoader()
}

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
    
    public var filteredLines: Set<String> {
        didSet { saveMode.userDefaults?.setValue(Array(filteredLines), forKey: Self.filteredLinesKey) }
    }
    
    public var favoriteStops: Set<String> {
        didSet { saveMode.userDefaults?.setValue(Array(favoriteStops), forKey: Self.favoriteStopsKey) }
    }
    
    // MARK: - File values
    
    @propertyWrapper
    public struct SavedInFile<Value: Codable> {
        
        public enum Path: String {
            case stops = "downloadedStops"
            case aliases = "downloadedAliases"
            case posts = "downloadedPosts"
            case trips = "downloadedTrips"

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
    @SavedInFile public var posts: [String: [Post]]
    @SavedInFile var trips: [Trip]

    private let saveMode: SaveMode
    
    // MARK: Init, integrity and load functions
    public init(saveMode: SaveMode = .appGroup) {
        self.saveMode = saveMode
        self._stops = .init(wrappedValue: [], .stops, directoryUrl: saveMode.directoryUrl)
        self._aliases = .init(wrappedValue: [], .aliases, directoryUrl: saveMode.directoryUrl)
        self._posts = .init(wrappedValue: [:], .posts, directoryUrl: saveMode.directoryUrl)
        self._trips = .init(wrappedValue: [], .trips, directoryUrl: saveMode.directoryUrl)
        self.filteredLines = Set(saveMode.userDefaults?.value(forKey: Self.filteredLinesKey) as? Array<String> ?? [])
        self.favoriteStops = Set(saveMode.userDefaults?.value(forKey: Self.favoriteStopsKey) as? Array<String> ?? [])
    }
    
    private static let weekInterval = 60.0 * 60 * 24 * 7

    @StaticDataLoader
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
    @StaticDataLoader
    func reloadData() async -> Bool {
        do {
            let url = FileManager.default.temporaryDirectory.appending(path: "Salinappka")
            if FileManager.default.fileExists(atPath: url.path()) {
                try? FileManager.default.removeItem(at: url)
            }
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            let data = try await URLSession.shared.data(from: .init(string: "https://kordis-jmk.cz/gtfs/gtfs.zip")!)
            FileManager.default.createFile(atPath: url.appending(path: "gtfs.zip").path(), contents: data.0)
            try FileManager.default.unzipItem(at: url.appending(path: "gtfs.zip"), to: url)

            let stopsCSV = try String(contentsOf: url.appending(path: "stops.txt"), encoding: .utf8)
            let tripsCSV = try String(contentsOf: url.appending(path: "trips.txt"), encoding: .utf8)
            let routesCSV = try String(contentsOf: url.appending(path: "routes.txt"), encoding: .utf8)

            stops = StopsRequest.decode(from: stopsCSV)
            posts = Dictionary<String, [Post]>(grouping: PostsRequest.decode(from: stopsCSV), by: \.stopId)
            trips = .init(csv: tripsCSV)
            aliases = AliasesRequest.decode(from: routesCSV)

            try? FileManager.default.removeItem(at: url)
        } catch {
            return false
        }

        guard stops.isEmpty == false, aliases.isEmpty == false, posts.isEmpty == false, trips.isEmpty == false else {
            return false
        }
        
        timestamp = .now
        return true
    }
    
    public func toggleFavorite(_ stopId: String) {
        if favoriteStops.contains(stopId) {
            favoriteStops.remove(stopId)
        } else {
            favoriteStops.insert(stopId)
        }
    }
}
