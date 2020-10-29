
/**
 The `FilterTransformerCoordinator` projects the current `State` (i.e prediction of the Gaussian distribution of the system) forwards to the next time step in the following steps:
 
 1) Choose Sigma points.
 
 A subset of points in the system are chosen relative to the current state, transition and observation covariance as representatives of the system.

 2) Prediction
 
 The Sigma points are propogated through the process model (given by the `transitionFunction`). The mean and covariance of the new state of the
 system are computed using the `unscentedTransformer`.
 
 3) Update
 
 The propogated Sigma points are then converted into points of the measurement space using the `observationFunction`. The mean  and covariance  of the Sigma points in the measurement space are then computed using the `unscentedTransformer`. These values, together with the observation for this time step, are used to update the `State`  which is then returned.
 
 Initial step:
 
 The `initialTransform` takes the first observation and initial estimate of the `State` and comptes a prediction using just the update step above.
 */
struct FilterTransformerCoordinator {
    var sigmaPointsGenerator: SigmaPointsGenerator
    var predictionTransformer: PredictionTransformer
    var observationTransformer: ObservationTransformer
    var sigmaPointsPropagator: SigmaPointsPropagator<TransitionSigmaPoints>
    
    init(transitionCovariance: Value<TransitionCovariance>,
         observationCovariance: Value<ObservationCovariance>,
         weights: Weights,
         transitionFunction: @escaping (Double, Double) -> Double,
         observationFunction: @escaping (Double, Double) -> Double) {
        
        self.sigmaPointsGenerator = SigmaPointsGenerator(scale: weights.scale,
                                                         transitionCovariance: transitionCovariance,
                                                         observationCovariance: observationCovariance)
        self.sigmaPointsPropagator = SigmaPointsPropagator(transformation: transitionFunction)
        self.predictionTransformer = PredictionTransformer(weights: weights)
        self.observationTransformer = ObservationTransformer(weights: weights,
                                                             sigmaPointsPropagator:
                                                                SigmaPointsPropagator(transformation: observationFunction)) 
    }
    
    /**
     Projects `state` forward to the next time-step.
     
     - parameter state: The current state.
     - parameter observation: The observation associated with this time-step. The observation should be set to `nil` if there is no observation for this time-step.
     - returns: The updated state after the filter step has been performed for this time-step.
     */
    func transform(state: State, observation: Value<Observation>?) -> State {
        let sigmaPoints = sigmaPointsGenerator.generatePoints(for: state)
        let propogatedSigmaPoints = sigmaPointsPropagator.propagate(points: sigmaPoints.statePoints, noise: sigmaPoints.transitionPoints)
        return predictionAndUpdate(propogatedStateSigmaPoints: propogatedSigmaPoints,
                                   observationSigmaPoints: sigmaPoints.observationSigmaPoints,
                                   observation: observation)
    }
    
    /**
     Estimates the state at the first time-step.
     
     - parameter state: The  estimated initial state of the system.
     - parameter observation: The first observation. The observation should be set to `nil` if there is no observation for this time-step.
     - returns: The estimated state, taking into account the first observation.
     */
    func initialTransform(state: State, observation: Value<Observation>?) -> State {
        let sigmaPoints = sigmaPointsGenerator.generatePoints(for: state)
        return predictionAndUpdate(propogatedStateSigmaPoints: sigmaPoints.statePoints,
                                   observationSigmaPoints: sigmaPoints.observationSigmaPoints,
                                   observation: observation)
    }
    
    private func predictionAndUpdate(propogatedStateSigmaPoints: Vector<StateSigmaPoints>,
                                     observationSigmaPoints: Vector<ObservationSigmaPoints>,
                                     observation: Value<Observation>?) -> State {
        let predictedState = predictionTransformer.transform(stateSigmaPoints: propogatedStateSigmaPoints)
        let predictedOutput = observationTransformer.transform(predictedState: predictedState,
                                                               propogatedStateSigmaPoints: propogatedStateSigmaPoints,
                                                               observationSigmaPoints: observationSigmaPoints)
        return MeasurementUpdater.update(predictedState: predictedState,
                                         predictedObservation: predictedOutput,
                                         observation: observation)
    }
}
