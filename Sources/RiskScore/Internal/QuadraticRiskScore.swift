import Foundation

struct QuadraticRiskScore {
    var minDistance: Double
    
    func calculate(durations: [Double], distances: [Double], shouldNormalize: Bool) -> Double {
        
        let normDistances = distances.map { distance in
            pow(minDistance, 2) / pow(distance, 2)
        }.clip(lower: .zero, upper: 1.0)
        
        let product = vectorProduct(durations, normDistances)
        let sum = product.reduce(0, +)
        
        if shouldNormalize {
            return sum / durations.reduce(0, +)
        } else {
            return sum
        }
    }
}
