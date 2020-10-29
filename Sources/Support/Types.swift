
public struct InstanceName: Hashable, Equatable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct RiskScoreValue {
    public var score: Double
    
    public init(score: Double) {
        self.score = score
    }
}

public enum Errors: Error {
    case badPath(String)
    case lineMalformed(path: String, lineNumber: Int)
}
