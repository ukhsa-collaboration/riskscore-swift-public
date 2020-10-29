

import Foundation
@testable import RiskScore
import SwiftCheck
import XCTest

class BLEDistanceUnscentedKalmanSmootherTests: XCTestCase {

    func testProperties() {
        // At least two observations are required
        let optionalDoubleArray = Gen<[Double?]>.sized { n in
            return Gen<Int>.choose((2, max(2, n))).flatMap(Double?.arbitrary.map { $0.map(abs) }.proliferate(withSize:))
        }
            
        property("first component of transition function is non-negative") <- forAll(positiveDouble, positiveDouble, BLEDistanceUnscentedKalmanSmoother.arbitrary) { (state, noise, filter) in
            let result = BLEDistanceUnscentedKalmanSmoother.transitionFunction(state: state, transitionNoise: noise)
            return result >= 0
        }
        
        property("observation function returns a finite Double") <- forAll(positiveDouble, positiveDouble, BLEDistanceUnscentedKalmanSmoother.arbitrary) { (state, noise, filter) in
            let result = BLEDistanceUnscentedKalmanSmoother.observationFunction(rssiAdapter: filter.rssiAdapter)(state, noise)
            return result.isFinite
        }
        
        property("smooth function returns the same number of elements as the input") <- forAllNoShrink(BLEDistanceUnscentedKalmanSmoother.arbitrary, optionalDoubleArray) { (filter, observations) in
            filter.smooth(observations: observations).count == observations.count
        }
        
        property("smooth function returns finite results") <- forAllNoShrink(BLEDistanceUnscentedKalmanSmoother.arbitrary, optionalDoubleArray) { (filter, observations) in
            filter.smooth(observations: observations).allSatisfy { (mean, covariance) in
                return mean.isFinite && covariance.isFinite
            }
        }
    }
}
