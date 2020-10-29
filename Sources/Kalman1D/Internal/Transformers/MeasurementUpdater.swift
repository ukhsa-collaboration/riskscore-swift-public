
struct MeasurementUpdater {
    /**
     Update the state based on the prediction of the observation.
     
     - parameter predictedState: The current state after the prediction step.
     - parameter predictedObservation: The state after the sigma points have been mapped to the measurement space.
     - parameter observation: The current observation.
     - returns: The new `predictedState` updated using the `predictedObservation`.
    */
    static func update(predictedState: State,
                       predictedObservation: ObservationPrediction,
                       observation: Value<Observation>?) -> State {
        
        //TODO: Move this check to the call-site to avoid passing in the observation.
        guard let unmaskedObservation = observation else {
            return State(mean: predictedState.mean,
                         covariance: predictedState.covariance)
        }
        
        let kalmainGain = predictedObservation.crossCovariance * predictedObservation.state.covariance.inverse()
        let residual = unmaskedObservation - predictedObservation.state.mean
        
        let correction = ObservationState(mean: residual.scale(kalmainGain),
                                          covariance:  predictedObservation.crossCovariance.scale(kalmainGain))
        
        return predictedState.correct(using: correction)
    }
}
