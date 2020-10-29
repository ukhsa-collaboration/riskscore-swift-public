
@testable import RiskScore
import XCTest

class FriisCalculatorTests: XCTestCase {
    func assertFriisAndInverseFriis(distance: Double, rssi: Double, rxCorrection: Double, txCorrection: Double, _ params: PowerLossParameters, file: StaticString = #file, line: UInt = #line) {
        let ra = FriisCalculator(params: params)
        let actualRssi = ra.friis(rxCorrection: rxCorrection, txCorrection: txCorrection)(distance)
        let actualDistance = ra.inverseFriis(rxCorrection: rxCorrection, txCorrection: txCorrection)(rssi)
        
        assertDoubleEqual(rssi, actualRssi, file: file, line: line)
        assertDoubleEqual(distance, actualDistance, file: file, line: line)
    }
    
    func testFriisWithUnitWavelengthUnitLossFactorZeroDeviceLoss() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 0.0)
        assertFriisAndInverseFriis(distance: pow(10, 2.0), rssi: -2.0, rxCorrection: 0.0, txCorrection: 0.0, params)
    }
    
    func testInverseFriisWithZeroRssiUnitWavelength() {
        let params = PowerLossParameters(wavelength: 1.0, pathLossFactor: 1.0, refDeviceLoss: 0.0)
        
        let ra = FriisCalculator(params: params)
        let actualRssi = ra.friis(rxCorrection: .zero, txCorrection: .zero)(1/(4.0 * .pi))
        let actualDistance = ra.inverseFriis(rxCorrection: .zero, txCorrection: .zero)(.zero)
        
        // minimum rssi estimate is 1e-3
        assertDoubleEqual(-1e-3, actualRssi)
        assertDoubleEqual(1/(4.0 * .pi), actualDistance)
    }
    
    func testInverseFriisWithDoublePathLossFactor() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 2.0, refDeviceLoss: 0.0)
        
        let ra = FriisCalculator(params: params)
        let actualRssi = ra.friis(rxCorrection: .zero, txCorrection: .zero)(0.1)
        let actualDistance = ra.inverseFriis(rxCorrection: .zero, txCorrection: .zero)(2.0)
        
        // minimum rssi estimate is 1e-3
        assertDoubleEqual(-1e-3, actualRssi)
        assertDoubleEqual(0.1, actualDistance)
    }
    
    func testInverseFriisWithRxCorrection() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 0.0)
        assertFriisAndInverseFriis(distance: pow(10, 3.0), rssi: -2.0, rxCorrection: 1.0, txCorrection: 0.0, params)
    }
    
    func testInverseFriisWithTxCorrection() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 0.0)
        assertFriisAndInverseFriis(distance: pow(10, 3.0), rssi: -2.0, rxCorrection: 0.0, txCorrection: 1.0, params)
    }
    
    func testInverseFriisWithRefDeviceLoss() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 1.0)
        
        assertFriisAndInverseFriis(distance: pow(10, 3.0), rssi: -2.0, rxCorrection: 0.0, txCorrection: 0.0, params)
    }
}
