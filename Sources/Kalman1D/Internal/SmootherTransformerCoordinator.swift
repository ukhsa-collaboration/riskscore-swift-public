
struct SmootherTransformerCoordinator {
    var weights: Weights
    var sigmaPointsGenerator: SigmaPointsGenerator
    var predictionTransformer: PredictionTransformer
    var sigmaPointsPropagator: SigmaPointsPropagator<TransitionSigmaPoints>
    
    init(transitionCovariance: Value<TransitionCovariance>,
         observationCovariance: Value<ObservationCovariance>,
         weights: Weights,
         transitionFunction: @escaping (Double, Double) -> Double) {
        
        self.weights = weights
        self.sigmaPointsGenerator = SigmaPointsGenerator(scale: weights.scale,
                                                         transitionCovariance: transitionCovariance,
                                                         observationCovariance: observationCovariance)
        self.sigmaPointsPropagator = SigmaPointsPropagator(transformation: transitionFunction)
        self.predictionTransformer = PredictionTransformer(weights: weights)
    }
    
    func transform(state: State, previousState: State) -> State {
        let sigmaPoints = sigmaPointsGenerator.generateSmootherPoints(for: state)
        let propogatedStateSigmaPoints = sigmaPointsPropagator.propagate(points: sigmaPoints.statePoints, noise: sigmaPoints.transitionPoints)
        let predictedState = predictionTransformer.transform(stateSigmaPoints: propogatedStateSigmaPoints)
        
        let crossCovariance: Value<StateMean> = propogatedStateSigmaPoints
            .minus(predictedState.mean)
            .multiply(Matrix(diagonal: weights.covarianceWeights))
            .dot(sigmaPoints.statePoints.minus(state.mean))
        
        let smootherGain = crossCovariance.scale(predictedState.covariance.inverse())
        
        let meanCorrection = (previousState.mean - predictedState.mean).scale(smootherGain)
        let covarianceCorrection = (previousState.covariance - predictedState.covariance).scale(smootherGain * smootherGain)
        
        return State(mean: state.mean.translate(meanCorrection),
                     covariance: state.covariance.translate(covarianceCorrection))
    }
}
