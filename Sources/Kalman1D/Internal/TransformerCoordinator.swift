
struct TransformerCoordinator {
    var filter: FilterTransformerCoordinator
    var smoother: SmootherTransformerCoordinator
    
    init(transitionCovariance: Value<TransitionCovariance>,
         observationCovariance: Value<ObservationCovariance>,
         weights: Weights,
         transitionFunction: @escaping (Double, Double) -> Double,
         observationFunction: @escaping (Double, Double) -> Double) {
                
        filter = FilterTransformerCoordinator(transitionCovariance: transitionCovariance,
                                              observationCovariance: observationCovariance,
                                              weights: weights,
                                              transitionFunction: transitionFunction,
                                              observationFunction: observationFunction)
        
        smoother = SmootherTransformerCoordinator(transitionCovariance: transitionCovariance,
                                                  observationCovariance: observationCovariance,
                                                  weights: weights,
                                                  transitionFunction: transitionFunction)
    }
}
