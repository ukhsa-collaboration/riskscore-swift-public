
import Foundation

extension Double {
    
    /**
     Replace non-finite values with specified values
     */
    func toFinite(nan: Double, minusInf: Double = .leastNormalMagnitude, plusInf: Double = .greatestFiniteMagnitude) -> Double {
        if self.isNaN {
            return nan
        } else if self.isInfinite {
            return .zero < self ? plusInf : minusInf
        } else {
            return self
        }
    }
}
