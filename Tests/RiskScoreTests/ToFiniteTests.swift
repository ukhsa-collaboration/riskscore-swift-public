
@testable import RiskScore
import XCTest
import SwiftCheck

class ToFiniteTests: XCTestCase {
    func testProperties() {
        property("Doubles returned by toFinite are all finite") <- forAll { (d: Double) in
            d.toFinite(nan: 1e-3).isFinite
        }
    }
    
    func testNanIsRemoved() {
        XCTAssertEqual(Double.nan.toFinite(nan: .zero), Double.zero)
    }
    
    func testPlusInfinityIsReplaced() {
        XCTAssertEqual(Double.infinity.toFinite(nan: .zero), Double.greatestFiniteMagnitude)
    }
    
    func testMinusInfinityIsReplaced() {
        XCTAssertEqual((-Double.infinity).toFinite(nan: .zero), Double.leastNormalMagnitude)
    }
}
