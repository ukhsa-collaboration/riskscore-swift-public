
import Foundation
import struct RiskScore.ScanInstance

public struct ScanInstanceCSVDecoder {
    public static func decode(from path: String) throws -> [ScanInstance] {
        guard let data = try? String(contentsOfFile: path) else {
            throw Errors.badPath(path)
        }
        
        return try data.split(separator: "\n").enumerated().map { idx, line in
            var fields = line.split(separator: ",", maxSplits: 1)
            
            guard let secondsField = Double(fields.removeFirst()),
                  let valueField = Double(fields.removeFirst()) else {
                throw Errors.lineMalformed(path: path, lineNumber: idx+1)
            }
            
            return ScanInstance(value: valueField, secondsSinceLastScan: secondsField)
        }
    }
}


