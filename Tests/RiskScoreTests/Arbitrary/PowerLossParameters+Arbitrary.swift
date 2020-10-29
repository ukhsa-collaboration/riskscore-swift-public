
import SwiftCheck
@testable import RiskScore

extension PowerLossParameters: Arbitrary {
    
    public static var arbitrary: Gen<PowerLossParameters> {        
        Gen.compose { c in
            PowerLossParameters(wavelength: c.generate(), pathLossFactor: c.generate(), refDeviceLoss: c.generate())
        }
    }
}
