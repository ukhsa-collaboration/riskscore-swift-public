
import XCTest

extension XCTest {
    func assertDoubleEqual(_ d1: Double, _ d2: Double, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(d1, d2, accuracy: 1e-8, file: file, line: line)
    }
}
