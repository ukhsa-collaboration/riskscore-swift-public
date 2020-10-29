
@testable import RiskScore
import XCTest
import SwiftCheck

class GammaDistributionTests: XCTestCase {
    func testInverseCdf() {        
        assertDoubleEqual(GammaDistribution(shape: 2.5, scale: 1.0).inverseCDF(probability: 1.199675720590626e-02), 0.3)
        assertDoubleEqual(GammaDistribution(shape: 10, scale: 1.0).inverseCDF(probability: 1.114254783387200e-07), 1.0)
        assertDoubleEqual(GammaDistribution(shape: 0.5, scale: 1.0).inverseCDF(probability: .zero), .zero)
    }
    
    func testMedian() {
        assertDoubleEqual(GammaDistribution.median(shape: 2.5, scale: 1.0), 2.175730095547763)
    }
    
    func testScale() {
        property("scale parameter multiplies the inverseCDF result") <- forAll(Gen.choose((0.0, 100.0)), Gen.choose((0.0, 100.0)), Gen.choose((0.0, 1.0))) { (scale, shape, probability) in
            let scaled = GammaDistribution(shape: shape, scale: scale).inverseCDF(probability: probability)
            let unscaled = GammaDistribution(shape: shape, scale: 1.0).inverseCDF(probability: probability)
            
            return abs(scaled - scale * unscaled) < 1e-8
        }
    }
    
    func testMedianScale() {
        property("scale parameter multiplies the median result") <- forAll(Gen.choose((0.0, 100.0)), Gen.choose((0.0, 100.0))) { (scale, shape) in
            let scaled = GammaDistribution.median(shape: shape, scale: scale)
            let unscaled = GammaDistribution.median(shape: shape, scale: 1.0)
            
            return abs(scaled - scale * unscaled) < 1e-8
        }
    }
    
}
