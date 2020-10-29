
struct PredictionState<T: ValueTag, U: ValueTag> {
    var mean: Value<T>
    var covariance: Value<U>
}

typealias State = PredictionState<StateMean, StateCovariance>
typealias ObservationState = PredictionState<Observation, ObservationCovariance>

extension PredictionState where T == StateMean, U == StateCovariance {
    func correct(using observationState: ObservationState) -> State {
        State(mean: mean.translate(observationState.mean),
              covariance: covariance.translate(-observationState.covariance))
    }
}
