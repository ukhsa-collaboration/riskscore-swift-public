
import Foundation

struct Vector<T: VectorTag> {
    private var array: [Double]
}

// MARK: Mean and Covariance weights constructions
extension Vector where T: WeightsTag {
    init(first: Double, common: Double) {
        self.array = [first] + Array(repeating: common, count: Weights.numberOfSigmaPoints - 1)
    }
}

// MARK: Sigma Point constructions
//TODO: REFACTOR: The `base` arrays could be factored out into a common array that is sliced according
// to the static dimensions stored on `Weights` to avoid array accesses.
extension Vector where T == StateSigmaPoints {
    init(scale: Value<Scale>, stateMean: Value<StateMean>, stateCovariance: Value<StateCovariance>) {
        let factor = sqrt(scale.rawValue * stateCovariance.rawValue)
        var base = Array(repeating: stateMean.rawValue, count: Weights.numberOfSigmaPoints)
        base[1] += factor
        base[4] -= factor
        self.array = base
    }
}

extension Vector where T == TransitionSigmaPoints {
    init(scale: Value<Scale>, transitionCovariance: Value<TransitionCovariance>) {
        let factor = sqrt(scale.rawValue * transitionCovariance.rawValue)
        var base = Array(repeating: Double.zero, count: Weights.numberOfSigmaPoints)
        base[2] += factor
        base[5] -= factor
        self.array = base
    }
}

extension Vector where T == ObservationSigmaPoints {
    init(scale: Value<Scale>, observationCovariance: Value<ObservationCovariance>) {
        let factor = sqrt(scale.rawValue * observationCovariance.rawValue)
        var base = Array(repeating: Double.zero, count: Weights.numberOfSigmaPoints)
        base[3] += factor
        base[6] -= factor
        self.array = base
    }
}

extension Vector where T == SmootherStateSigmaPoints {
    init(scale: Value<Scale>, stateMean: Value<StateMean>, stateCovariance: Value<StateCovariance>) {
        let factor = sqrt(scale.rawValue * stateCovariance.rawValue)
        var base = Array(repeating: stateMean.rawValue, count: Weights.numberOfSmootherSigmaPoints)
        base[1] += factor
        self.array = base
    }
}

extension Vector where T == SmootherTransitionSigmaPoints {
    init(scale: Value<Scale>, transitionCovariance: Value<TransitionCovariance>) {
        let factor = sqrt(scale.rawValue * transitionCovariance.rawValue)
        var base = Array(repeating: Double.zero, count: Weights.numberOfSmootherSigmaPoints)
        base[2] += factor
        self.array = base
    }
}

// MARK: Utilities
extension Vector {
    func minus<V: ValueTag>(_ value: Value<V>) -> Vector<T> {
        Vector(array: array.map { $0 - value.rawValue })
    }
    
    func map(_ transform: (Double) -> Double) -> Vector<T> {
        Vector(array: array.map(transform))
    }
    
    func dot<U: VectorTag, V: ValueTag>(_ other: Vector<U>) -> Value<V> {
        Value<V>(rawValue: zip(array, other.array).map(*).reduce(0, +))
    }
    
    func multiply<U: VectorTag>(_ matrix: Matrix<U>) -> Vector<T> {
        Vector(array: zip(array, matrix.diagonal.array).map(*))
    }
    
    static func zipWith<U: VectorTag>(_ v1: Vector<T>, _ v2: Vector<U>, transform: (Double, Double) -> Double) -> Vector<T> {
        Vector(array: zip(v1.array, v2.array).map(transform))
    }
}
