
import Foundation

public struct UnscentedKalmanSmoother {
    private var transitionCovariance: Value<TransitionCovariance>
    private var observationCovariance: Value<ObservationCovariance>
    private var initialState: State
    
    private var coordinator: TransformerCoordinator
    
    /**
     An implementation of the Augmented Unscented Kalman Smoother for one dimensional state
     
     - parameter initialStateMean: The mean of the initial state distribution
     - parameter initialStateCovariance: The covariance of the initial state distribution
     - parameter transitionCovariance: The transition noise covariance
     - parameter observationCovariance: The observation noise covariance
     - parameters alpha, beta, kappa: Parameters for the Sigma points calculation
     - parameter transitionFunction: A function of state and transition covariance that projects the state forwards by 1 time-step.
     - parameter observationFunction: A function of state and observation covariance that projects the state into the measurement space.

     */
    public init(initialStateMean: Double,
                initialStateCovariance: Double,
                transitionCovariance: Double,
                observationCovariance: Double,
                alpha: Double,
                beta: Double,
                kappa: Double,
                transitionFunction: @escaping (Double, Double) -> Double,
                observationFunction: @escaping (Double, Double) -> Double) {
        
        
        self.initialState = State(mean: Value(rawValue: initialStateMean),
                                  covariance: Value(rawValue: initialStateCovariance))
        
        let transitionValue = Value<TransitionCovariance>(rawValue: transitionCovariance)
        let observationVlaue = Value<ObservationCovariance>(rawValue: observationCovariance)
        
        let weights = Weights(alpha: alpha, beta: beta, kappa: kappa)
        self.coordinator = TransformerCoordinator(transitionCovariance: transitionValue,
                                                  observationCovariance: observationVlaue,
                                                  weights: weights,
                                                  transitionFunction: transitionFunction,
                                                  observationFunction: observationFunction)
        self.transitionCovariance = transitionValue
        self.observationCovariance = observationVlaue
    }
    
    /**
    - parameter observationData: An array of observation values .
        The element at index `t` in the list is the observation at time `t`. The element should bet set to `null` if the observation is missing.
    
    - returns: An array of `(stateMean, stateCovariance)` tuples.
     The components at index `t` are defined as follows:
     
     - `stateMean` is the mean of the state distrubution at time `t` given observations from times `0` through `t`.
     - `stateCovariance` is the covariance of the state distrubution at time `t` given observations from times `0` through `t`.
     */
    public func filter(observationData data: [Double?]) -> [(Double, Double)] {
        guard let firstDatum = data.first else {
            preconditionFailure("There must be at least one observation")
        }
        
        let headObservation = firstDatum.map(Value<Observation>.init(rawValue:))
        let tailObservations = data.dropFirst().map { datum in datum.map(Value<Observation>.init(rawValue:)) }
        return internalFilter(headObservation: headObservation,
                              tailObservations: tailObservations).map { ($0.mean.rawValue, $0.covariance.rawValue) }
    }
    
    private func internalFilter<S: Sequence>(headObservation: Value<Observation>?, tailObservations data: S) -> [State] where S.Element == Value<Observation>? {
        
        let firstState = coordinator.filter.initialTransform(state: initialState,
                                                             observation: headObservation)
        return data
            .reduce(into: (previousState: firstState, previousStates: [firstState]), { previous, nextObservation in
                let nextState = coordinator.filter.transform(state: previous.previousState,
                                                             observation: nextObservation)
                previous.previousState = nextState
                previous.previousStates.append(nextState)
            }).previousStates
    }
    
    /**
     
     - parameter observationData: An array of `(observation, transitionFunction, observationFunction)` tuples.
     TThe element at index `t` in the list is the observation at time `t`. The element should bet set to `null` if the observation is missing.
    
     - returns: An array of `State` values.
     Let the size of `observationData` be `timesteps` then components at index `t` are defined as follows:
     
     - `stateMean` is the mean of the state distrubution at time `t` fiven observations from times `0` through `timesteps - 1`.
     - `stateCovariance` is the covariance of the state distrubution at time `t` given observations from times `0` through `timesteps - 1`.
     */
    public func smooth(observationData data: [Double?]) -> [(Double, Double)] {
        guard let firstDatum = data.first else {
            preconditionFailure("There must be at least one observation")
        }
        
        let headObservation = firstDatum.map(Value<Observation>.init(rawValue:))
        let tailObservations = data.dropFirst().map { datum in datum.map(Value<Observation>.init(rawValue:)) }

        let filteredResult = internalFilter(headObservation: headObservation,
                                            tailObservations: tailObservations)
        
        guard let lastResult = filteredResult.last else {
            preconditionFailure("There must be at least one observation")
        }
        
        return filteredResult.dropLast().reversed()
            .reduce(into: (previousResult: lastResult, previousResults: [lastResult]), { previous, currentState in
                let nextState = coordinator.smoother.transform(state: currentState,
                                                               previousState: previous.previousResult)
                previous.previousResult = nextState
                previous.previousResults.append(nextState)
            }).previousResults.reversed().map { state in
                (state.mean.rawValue, state.covariance.rawValue)
            }
    }
}
