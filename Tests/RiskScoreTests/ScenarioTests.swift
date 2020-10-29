
import Support
import RiskScore
import XCTest

class ScenarioTests: XCTestCase {
    func testRiskScoresAgreeWithPython() throws {
        let calculator = RiskScoreCalculator(configuration: .exampleConfiguration)
        
        guard let riskScoreCsv = Bundle.module.path(forResource: "pythonRiskScores", ofType: ".csv", inDirectory: "TestData") else {
            XCTFail("Failed to find riskScoreCsv file")
            return
        }
        let expectedResults = try RiskScoreResultsCSVDecoder.decode(from: riskScoreCsv)
        let scanInstancePaths = Bundle.module.paths(forResourcesOfType: ".csv", inDirectory: "TestData/ScanInstances")
        
        guard !scanInstancePaths.isEmpty else {
            XCTFail("no ScanInstances found")
            return
        }
        
        try scanInstancePaths.forEach { path in
            let instances = try ScanInstanceCSVDecoder.decode(from: path)
            let score = calculator.calculate(instances: instances)
            let instanceName = InstanceName(name: String(path.split(separator: "/").last!))
            guard let expectedScore = expectedResults[instanceName]?.score else {
                XCTFail("Failed to find expected score for \(instanceName)")
                return
            }
            
            XCTAssertLessThan(abs(score - expectedScore), 0.05 * expectedScore, "expected: \(expectedScore) actual: \(score)")
        }
    }
}
