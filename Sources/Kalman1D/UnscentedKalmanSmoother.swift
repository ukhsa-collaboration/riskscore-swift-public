
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
    - parameter observationData: An array of `ObservationDatum` values .
    The components at index `t` are defined as follows:
    
    - `observation` is the observed value at time `t` (`nil` if the observation is missing).
    - `transitionFunction` is a function of the state and the transition noise at time `t` that returns the state at time `t + 1`.
    - `observationFunction ` is a function of the state and the observation noise at time `t` that returns the observation at time `t`.
    
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
     The components at index `t` are defined as follows:
     
     - `observation` is the observed value at time `t` (`nil` if the observation is missing).
     - `transitionFunction` is a function of the state and the transition noise at time `t` that returns the state at time `t + 1`.
     - `observationFunction ` is a function of the state and the observation noise at time `t` that returns the observation at time `t`.
     
     - returns: An array of `State` values.
     Let the size of `observationData` be `timesteps` then components at index `t` are defined as follows:
     
     - `stateMean` is the mean of the state distrubution at time `t` fiven observations from times `0` through `timesteps - 1`.
     - `stateCovariance` is the covariance of the state distrubution at time `t` given observations from times `0` through `timesteps - 1`.
     
     - throws: When:
         - The value of the `observationData` is empty.
         - The dimensions of any `ObservationDatum` are not consistent with the dimensions configured in the initializer.
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
