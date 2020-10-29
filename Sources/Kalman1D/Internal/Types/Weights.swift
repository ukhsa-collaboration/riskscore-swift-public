
import Foundation

struct Weights {
    static let augmentedDimension = 3.0 // stateDim + transitionDim + obserationDim
    static let numberOfSigmaPoints = 2 * Int(augmentedDimension) + 1
    static let numberOfSmootherSigmaPoints = 3 // stateDim + (stateDim + transitionDim)
    
    var meanWeights: Vector<MeanWeights>
    var covarianceWeights: Vector<CovarianceWeights>
    var scale: Value<Scale>
    
    init(alpha: Double,
         beta: Double,
         kappa: Double) {
        
        let lambda = alpha.squared() * (Weights.augmentedDimension + kappa) - Weights.augmentedDimension
        
        self.scale = Value(rawValue: Weights.augmentedDimension + lambda)
        
        let common = (2.0 * scale).inverse().rawValue
        self.meanWeights = Vector(first: lambda / scale, common: common)
        self.covarianceWeights = Vector(first: (lambda / scale) + (1 - alpha.squared() + beta), common: common)
    }
}
