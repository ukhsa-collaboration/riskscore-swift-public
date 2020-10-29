
import RiskScore
import XCTest

// TODO: More systematic testing is required, potentially based on the output of the Python code.
// See riskscorechecker CLI and github workflow
class RiskScoreCalculatorTests: XCTestCase {
    func testScoreCalculatorWithExampleConfiguration() {
        let calculator = RiskScoreCalculator(configuration: .exampleConfiguration)

        XCTAssertEqual(calculator.calculate(instances: exampleDataSingleValues), 2.149345279234102, accuracy: 1e-8)
    }
}
