
import Foundation

extension Array where Element == (Double, Double) {
    func splitPairs() -> ([Double], [Double]) {
        return reduce(into: ([Double](), [Double]())) { (result, next) in
            let (left, right) = next
            result.0.append(left)
            result.1.append(right)
        }
    }
}
