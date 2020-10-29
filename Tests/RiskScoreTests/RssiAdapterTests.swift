
@testable import RiskScore
import Foundation
import XCTest

class RssiAdapterTests: XCTestCase {
    
    func testObservationTransformIsLogForLogType() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 1.0)
        
        let ra = RssiAdapter(params: params, weightCoefficient: 1.0, intercept: .zero, observationType: .log)
        assertDoubleEqual(ra.observationTransform(distance: 1.0), .zero)
        assertDoubleEqual(ra.observationTransform(distance: M_E), 1.0)
    }
    
    func testObservationTransformIsLogForLogTypeWeightCoefficient() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 1.0)
        
        let ra = RssiAdapter(params: params, weightCoefficient: 2.0, intercept: .zero, observationType: .log)
        assertDoubleEqual(ra.observationTransform(distance: M_E), 2.0)

    }
    
    func testObservationTransformIsLogForLogTypeIntercept() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 1.0)
        
        let ra = RssiAdapter(params: params, weightCoefficient: 2.0, intercept: 1.0, observationType: .log)
        assertDoubleEqual(ra.observationTransform(distance: M_E), 3.0)
    }
    
    func testObservationTransformIsFriisForGenType() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 3.0 - M_E)
        
        let ra = RssiAdapter(params: params, weightCoefficient: 1.0, intercept: .zero, observationType: .gen)
        assertDoubleEqual(ra.observationTransform(distance: pow(10, 3.0)), 1.0)
    }
    
    func testObservationTransformIsFriisForGenTypeWeightCoefficient() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 3.0 - M_E)
        
        let ra = RssiAdapter(params: params, weightCoefficient: 0.5, intercept: .zero, observationType: .gen)
        assertDoubleEqual(ra.observationTransform(distance: pow(10, 3.0)), 0.5)

    }
    
    func testObservationTransformIsFrisForGenTypeIntercept() {
        let params = PowerLossParameters(wavelength: 4.0 * Double.pi, pathLossFactor: 1.0, refDeviceLoss: 3.0 - M_E)
        
        let ra = RssiAdapter(params: params, weightCoefficient: 1.0, intercept: -2.0, observationType: .gen)
        assertDoubleEqual(ra.observationTransform(distance: pow(10, 3.0)), -1.0)
    }
}
