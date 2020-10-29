import Foundation

public struct RiskScoreResultsCSVDecoder {
    public static func decode(from path: String) throws -> [InstanceName: RiskScoreValue] {
        guard let data = try? String(contentsOfFile: path) else {
            throw Errors.badPath(path)
        }
        
        let scenarioCsvFieldIndex = 7
        let score16FieldIndex = 4
        
        return try data.split(separator: "\n").enumerated().dropFirst().reduce(into: [InstanceName: RiskScoreValue]()) { result, next in
            let (idx, line) = next
            
            let fields = line.split(separator: ",", maxSplits: 7)
            
            guard let score16 = Double(fields[score16FieldIndex]) else {
                throw Errors.lineMalformed(path: path, lineNumber: idx+1)
            }
            
            let name = fields[scenarioCsvFieldIndex].trimmingCharacters(in: ["\""])
            
            result[InstanceName(name: name)] = RiskScoreValue(score: score16)
        }
    }
}
