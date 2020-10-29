
@testable import RiskScore
import XCTest
import SwiftCheck

class QuadraticRiskScoreTests: XCTestCase {
    func testProperties() {
        property("risk score is bounded above by sum of durations") <- forAll(positiveDouble, positiveDouble.proliferateNonEmpty, positiveDouble.proliferateNonEmpty) { (minDistance, durations, distances) in
            
            let score = QuadraticRiskScore(minDistance: minDistance)
                .calculate(durations: durations,
                           distances: distances,
                           shouldNormalize: false)
            
            return score <= durations.reduce(0, +)
        }
        
        property("normalized risk score is bounded above by 1") <- forAll(positiveDouble, positiveDouble.proliferateNonEmpty, positiveDouble.proliferateNonEmpty) { (minDistance, durations, distances) in
            
            let score = QuadraticRiskScore(minDistance: minDistance)
                .calculate(durations: durations,
                           distances: distances,
                           shouldNormalize: true)
            
            return score <= 1.0
        }
    }
}
