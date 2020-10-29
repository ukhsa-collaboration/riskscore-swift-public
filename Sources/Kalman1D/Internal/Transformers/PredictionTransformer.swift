
struct PredictionTransformer {
    var unscentedTransformer: UnscentedTransformer<StateMean, StateCovariance>
    
    init(weights: Weights) {
        self.unscentedTransformer = UnscentedTransformer(meanWeights: weights.meanWeights,
                                                         covarianceWeights: weights.covarianceWeights)
    }
    
    func transform(stateSigmaPoints: Vector<StateSigmaPoints>) -> State {
        let transformed = unscentedTransformer.transform(progogatedSigmaPoints: stateSigmaPoints)
        return State(mean: transformed.mean, covariance: transformed.covariance)
    }
}
