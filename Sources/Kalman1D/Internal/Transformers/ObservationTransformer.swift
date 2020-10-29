
struct ObservationTransformer {
    var sigmaPointsPropagator: SigmaPointsPropagator<ObservationSigmaPoints>
    var weights: Weights
    var unscentedTransformer: UnscentedTransformer<Observation, ObservationCovariance>
    
    init(weights: Weights,
         sigmaPointsPropagator: SigmaPointsPropagator<ObservationSigmaPoints>) {
        self.weights = weights
        self.unscentedTransformer = UnscentedTransformer(meanWeights: weights.meanWeights,
                                                         covarianceWeights: weights.covarianceWeights)
        self.sigmaPointsPropagator = sigmaPointsPropagator
    }
    
    func transform(predictedState: State,
                   propogatedStateSigmaPoints: Vector<StateSigmaPoints>,
                   observationSigmaPoints: Vector<ObservationSigmaPoints>) -> ObservationPrediction {
        let observationPoints = sigmaPointsPropagator.propagate(points: propogatedStateSigmaPoints, noise: observationSigmaPoints)
        
        let observationPrediction = unscentedTransformer.transform(progogatedSigmaPoints: observationPoints)
        
        let crossCovariance: Value<ObservationCovariance> = propogatedStateSigmaPoints
            .minus(predictedState.mean)
            .multiply(Matrix(diagonal: weights.covarianceWeights))
            .dot(observationPoints.minus(observationPrediction.mean))
        
        return ObservationPrediction(state: ObservationState(mean: observationPrediction.mean,
                                                             covariance: observationPrediction.covariance),
                                     crossCovariance: crossCovariance)
    }
}

struct ObservationPrediction {
    var state: ObservationState
    var crossCovariance: Value<ObservationCovariance>
}
