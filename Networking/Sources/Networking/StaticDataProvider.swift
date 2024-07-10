import Foundation
import Models
import SwiftUI

public protocol StaticDataProvider {
    var isUpToDate: Bool { get async }
    var stops: [Stop] { get }
    var aliases: [Alias] { get }
}

public extension EnvironmentValues {
    
    var staticDataProvider: StaticDataProvider {
        get { self[StaticDataProviderKey.self] }
        set { self[StaticDataProviderKey.self] = newValue }
    }
}

private struct StaticDataProviderMock: StaticDataProvider {
    
    var isUpToDate: Bool { true }
    var stops: [Stop] { [] }
    var aliases: [Alias] { [] }
}

private struct StaticDataProviderKey: EnvironmentKey {
    
    static let defaultValue: StaticDataProvider = StaticDataProviderMock()
}
