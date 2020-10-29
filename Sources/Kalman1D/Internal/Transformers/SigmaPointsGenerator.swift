
/**
 `SigmaPointsGenerator` chooses a representative collection of points (called Sigma points) from the Gaussian distribution described by the current `State`.
 
 The Sigma points are chosen to be spaced around the `State`'s mean at a distance proportional to the `State`'s covariance and the covariance of
 both transition and observation noise in the augmented state space. In our case, where state, transition and observation dimensions are all equal to 1 we have.
 
 NB: The duplication of the points is necessary due to how the mean and covariance weights are used to compute mean and covariance of the Sigma points.
 
    State Sigma points: `[state.mean, state.mean + sqrt(scale * state.covariance), state.mean, state.mean - sqrt(scale * state.covariance), state.mean, state.mean]`
    Transition Sigma points:  `[0, 0, sqrt(scale * transitionCovariance), 0, 0,  -sqrt(scale * transitionCovariance), 0]`
    Observation Sigma points: `[0, 0, 0, sqrt(scale * observationCovariance), 0, 0, -sqrt(scale * observationCovariance)]`
 
 If you consider each collection of Sigma points as a row of a matrix they are constructed as follows:
 
 1) `augmentedMean = [state.mean, 0, 0]`
 2) `augmentedCovarianceMatrix` a diagonal matrix with
 
    `[sqrt(state.covariance), sqrt(transitionCovariance), sqrt(observationCovariance)]`
    
 3) Form `sigmaMatrix` a 3 x 7 matrix by concatenating the following matrices:
 
    `augmentedMean^T ,  augmentedMean^T .+ sqrt( scale * augmentedCovarianceMatrix), augmentedMean^T .- sqrt( scale * augmentedCovarianceMatrix)`
 
 where `augmentedMean^T .+` and `augmentedMean^T.-` means add the column matrix augmentedMean^T to each column of the right hand side matrix.
 
 4) The rows of `sigmaMatrix^T` are the Sigma points described above.
        
 */
struct SigmaPointsGenerator {
    var scale: Value<Scale>
    var transitionCovariance: Value<TransitionCovariance>
    var observationCovariance: Value<ObservationCovariance>
    
    func generatePoints(for state: State) -> SigmaPoints {
        SigmaPoints(
            statePoints: Vector(scale: scale, stateMean: state.mean, stateCovariance: state.covariance),
            transitionPoints: Vector(scale: scale, transitionCovariance: transitionCovariance),
            observationSigmaPoints: Vector(scale: scale, observationCovariance: observationCovariance)
        )
    }
    
    /**
     Generates Sigma points from the `State` as described above but in this case only the state and transition dimensions are taken into account.
     */
    func generateSmootherPoints(for state: State) -> SmootherSigmaPoints {
        SmootherSigmaPoints(
            statePoints: Vector(scale: scale, stateMean: state.mean, stateCovariance: state.covariance),
            transitionPoints: Vector(scale: scale, transitionCovariance: transitionCovariance)
        )
    }
}

struct SigmaPoints {
    var statePoints: Vector<StateSigmaPoints>
    var transitionPoints: Vector<TransitionSigmaPoints>
    var observationSigmaPoints: Vector<ObservationSigmaPoints>
}

struct SmootherSigmaPoints {
    var statePoints: Vector<StateSigmaPoints>
    var transitionPoints: Vector<TransitionSigmaPoints>
}
