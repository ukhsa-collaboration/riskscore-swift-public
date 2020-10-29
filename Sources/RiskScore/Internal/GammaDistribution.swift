
import BoostSwift

/**
 The Gamma distribution
 
 - parameter shape: The shape parameter of the distribution
 - parameter scale: The scale factor to apply
 */
struct GammaDistribution {
    var shape: Double
    var scale: Double
    
    /**
     Convenience function to compute the median value of an observation for a Gamma distribution with a specified shape and scale.
     */
    static func median(shape: Double, scale: Double) -> Double {
        return GammaDistribution(shape: shape, scale: scale).inverseCDF(probability: 0.5)
    }
    
    /**
     Computes the inverse cumulative distrubution function of this Gamma distribution
     
     i.e the function computes a value x of an observation from the Gamma distribution is in the range [0,x] with given probability p
     
     - parameter probability: A probability value between `0` and `1`
     - returns: A value x such that observations from the Gamma distribution is in the range [0,x] occur with the given `probability`.
     */
    func inverseCDF(probability: Double) -> Double {
        return (gamma_p_inv(shape, probability) * scale).toFinite(nan: 1e-3)
    }
}
