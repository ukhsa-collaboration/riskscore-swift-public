
@testable import RiskScore
import XCTest

extension ScanInstance {
    init(_ date: String, _ values: [Double], _ secondsSinceLastScan: TimeInterval) {
        self.init(value: values.first!, secondsSinceLastScan: secondsSinceLastScan)
    }
}

class ScanInstanceTests: XCTestCase {
    
    func assertObservations(_ inputData: [ScanInstance], sampleResolution: Double, file: StaticString = #file, line: UInt = #line) {
        let observations = makeObservations(instances: inputData, sampleResolution: sampleResolution)

        let intervalSum = inputData.dropFirst().map(\.secondsSinceLastScan).reduce(0, +)
        XCTAssertEqual(observations.count, Int((1.0/sampleResolution) * intervalSum) + 1, file: file, line: line)
        XCTAssertEqual(observations.map(\.value).compactMap { $0 }, inputData.map(\.value).filter(\.isFinite).map(log), file: file, line: line)
    }
    
    func testMakeObservationsFromScanInstancesEachWithSingleValues() {
        assertObservations(exampleDataSingleValues, sampleResolution: 1.0)
    }
    
    func testMakeObservationsFromScanInstancesEachWithSingleValuesPublicAPI() {
        assertObservations(exampleDataPublicApi, sampleResolution: 1.0)
    }
    
    func testMakeObservationsFromScanInstancesWithMultipleValues() {
        assertObservations(exampleDataMultipleValues, sampleResolution: 1.0)
    }
    
    func testMakeObservationsFromScanInstancesEachWithSingleValuesHalfResolution() {
        assertObservations(exampleDataSingleValues, sampleResolution: 0.5)
    }
    
    func testMakeObservationsFromScanInstancesEachWithNonFiniteValues() {
        assertObservations(exampleDataSingleNonFinite, sampleResolution: 1.0)

    }
}
