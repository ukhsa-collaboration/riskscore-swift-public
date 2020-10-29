
@testable import Kalman1D
import XCTest
import SwiftCheck

class PredictionTransformerTests: XCTestCase {
    
    func testProperties() {
        property("can recover original mean and covariance from prediction with identity transform")
            <- forAll { (state: State,
                         transitionCovariance: Value<TransitionCovariance>,
                         observationCovariance: Value<ObservationCovariance>) in
                
                let weights = Weights(alpha: 1.0,
                                      beta: .zero,
                                      kappa: .zero)
                
                let generator = SigmaPointsGenerator(scale: weights.scale,
                                                     transitionCovariance: transitionCovariance,
                                                     observationCovariance: observationCovariance)
                let sigmaPoints = generator.generatePoints(for: state)
                
                let propagated = SigmaPointsPropagator { s, _ in s }.propagate(points: sigmaPoints.statePoints,
                                                                               noise: sigmaPoints.transitionPoints)
                
                let predictionTransformer = PredictionTransformer(weights: weights)
                let prediction = predictionTransformer.transform(stateSigmaPoints: propagated)
                
                return
                    closeEnough(state.mean, prediction.mean)
                    ^&&^
                    closeEnough(state.covariance, prediction.covariance)
            }
    }
}
