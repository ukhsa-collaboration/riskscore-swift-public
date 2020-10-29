
import SwiftCheck
@testable import RiskScore

extension BLEDistanceUnscentedKalmanSmoother: Arbitrary {
    public static var arbitrary: Gen<BLEDistanceUnscentedKalmanSmoother> {
        return Gen.compose { c in
            BLEDistanceUnscentedKalmanSmoother(powerLossParameters: c.generate(),
                                             observationType: c.generate(using: Gen.fromElements(of: [.log, .gen])),
                                             rssiParameters: RssiParameters(weightCoefficient: c.generate(),
                                                                            intercept: c.generate(),
                                                                            covariance: c.generate(using: positiveDouble)),
                                             expectedDistance: c.generate(using: positiveDouble),
                                             initialData: InitialData(mean: c.generate(using: positiveDouble),
                                                                      covariance: c.generate(using: positiveDouble)),
                                             smootherParameters: SmootherParameters(alpha: 1.0, beta: .zero, kappa: .zero) )
        }
    }
}
