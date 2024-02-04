import Foundation

struct FailableDecodable<T: Decodable>: Decodable {
    
    let value: T?
    
    init(from decoder: Decoder) throws {
        value = try? decoder.singleValueContainer().decode(T.self)
    }
}
