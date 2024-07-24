import Foundation
import SwiftUI

public protocol StaticModelsProviding {
    var isUpToDate: Bool { get async }
    var stops: [Stop] { get }
    var aliases: [Alias] { get }
    var filteredLines: Set<Int> { get set }
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
    var filteredLines: Set<Int> = []
}

private struct StaticDataProviderKey: EnvironmentKey {
    
    static let defaultValue: StaticModelsProviding = StaticDataProviderMock()
}
