import SwiftUI
import SupportPackageViews

public struct Alias: Codable {
    public let id: Int
    public let lineName: String
    public var contentColor: Color { .init(hexString: contentColorHex) }
    public var backgroundColor: Color { .init(hexString: backgroundColorHex) }
    let contentColorHex: String
    let backgroundColorHex: String
    
    public init(id: Int, lineName: String, contentColorHex: String, backgroundColorHex: String) {
        self.id = id
        self.lineName = lineName
        self.contentColorHex = contentColorHex
        self.backgroundColorHex = backgroundColorHex
    }
}
