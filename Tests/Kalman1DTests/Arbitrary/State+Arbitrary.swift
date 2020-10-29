

import SwiftCheck
@testable import Kalman1D

extension Value: Arbitrary {
    public static var arbitrary: Gen<Value<T>> {
        positiveDouble.map(Value.init(rawValue:))
    }
}

extension PredictionState: Arbitrary {

    public static var arbitrary: Gen<PredictionState<T, U>> {
        Gen.compose { gen in
            PredictionState(mean: gen.generate(), covariance: gen.generate())
        }
    }
}
