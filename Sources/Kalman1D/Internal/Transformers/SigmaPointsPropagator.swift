
import Foundation

/**
    SigmaPointsPropogator propogates each state Sigma point though the transformation function.
 */
struct SigmaPointsPropagator<S: VectorTag> {
    var transformation: (Double, Double) -> Double
    
    /**
     - parameter points: A vector of state Sigma points.
     - parameter noise: A vector of Sigma points representing the noise of the process (transition or observation noise).
     - returns: The propogated state Sigma points.
     */
    func propagate(points: Vector<StateSigmaPoints>, noise: Vector<S>) -> Vector<StateSigmaPoints> {
        Vector.zipWith(points, noise, transform: transformation)
    }
}
