
import Foundation


struct FriisCalculator {
    var params: PowerLossParameters

    /**
     The inverse Friis function. Computes distance from RSSI
     
     - parameter rxCorrection: Correction shift in dBm for receiver device
     - parameter txCorrection: Correction shift in dBm for transmitter device
     
     - returns: A dunction from RSSI to distance in meters
     */
    func inverseFriis(rxCorrection: Double, txCorrection: Double) -> (Double) -> Double {
        let params = self.params
        return { rssi in
            let adjRssi = rssi - rxCorrection - txCorrection
            let powerLoss = log10(params.wavelength / (4.0 * .pi))
            let exponent = adjRssi - params.pathLossFactor * powerLoss - params.refDeviceLoss
            return pow(10.0, -exponent / params.pathLossFactor)
        }
    }
    
    /**
    The Friis function. Computes RSSI from distance
     
     - parameter rxCorrection: Correction shift in dBm for receiver device
     - parameter txCorrection: Correction shift in dBm for transmitter device
     
     - returns: A function from distance in meters to RSSI
     */
    func friis(rxCorrection: Double, txCorrection: Double) -> (Double) -> Double {
        let params = self.params
        return { distance in
            let effectiveDistance = distance > .zero ? distance : 1e-3
            
            let result = -1 * log10(effectiveDistance) + rxCorrection + txCorrection + params.pathLossFactor * ( log10(params.wavelength / (4.0 * .pi))) + params.refDeviceLoss
            
            return result < 0 ? result : -1e-3
        }
    }
}
