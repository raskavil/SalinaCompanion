import Foundation
import SwiftUI

public protocol StaticModelsProviding {
    var isUpToDate: Bool { get async }
    var stops: [Stop] { get }
    var aliases: [Alias] { get }
    var posts: [Int: [Post]] { get }
    var favoriteStops: Set<Int> { get set }
    var filteredLines: Set<Int> { get set }
    func toggleFavorite(_ stopId: Int)
}

public extension EnvironmentValues {
    
    var staticDataProvider: StaticModelsProviding {
        get { self[StaticDataProviderKey.self] }
        set { self[StaticDataProviderKey.self] = newValue }
    }
}

private struct StaticDataProviderMock: StaticModelsProviding {
    
    var isUpToDate: Bool { true }
    var stops: [Stop] { [] }
    var aliases: [Alias] { [] }
    var posts: [Int: [Post]] { [:] }
    var favoriteStops: Set<Int> = []
    var filteredLines: Set<Int> = []
    func toggleFavorite(_ stopId: Int) {}
}

private struct StaticDataProviderKey: EnvironmentKey {
    
    static let defaultValue: StaticModelsProviding = StaticDataProviderMock()
}
