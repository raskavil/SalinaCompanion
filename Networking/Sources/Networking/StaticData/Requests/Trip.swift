
struct Trip: Codable {
    let routeID: String
    let finalStop: String
    let tripID: Int
}

extension Array<Trip> {

    init(csv: String) {
        self = csv
            .replacingOccurrences(of: "\"", with: "")
            .split(separator: "\r\n")
            .dropFirst()
            .compactMap { line in
                let separatedValues = line.split(separator: ",").map { String($0) }
                guard separatedValues.count >= 8, let tripID = Int(separatedValues[2]) else { return nil }
                return .init(
                    routeID: separatedValues[0],
                    finalStop: separatedValues[3],
                    tripID: tripID
                )
            }
    }
}
