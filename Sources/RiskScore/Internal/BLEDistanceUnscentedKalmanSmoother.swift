
import Foundation
import Kalman1D

/**
 Wrapper type around Unscented Kalman Filter adapted to smooth scalar (RSSI) input.
 */
struct BLEDistanceUnscentedKalmanSmoother {
    
    var powerLossParameters: PowerLossParameters
    var rssiParameters: RssiParameters
    var expectedDistance: Double

    var rssiAdapter: RssiAdapter
    private var filter: UnscentedKalmanSmoother
    
    /**
     - parameter expectedDistance: The expected distance moved per second.
     - parameter initialData: The initial data to initialize the filter.
     */
    init(powerLossParameters: PowerLossParameters,
         observationType: ObservationType,
         rssiParameters: RssiParameters,
         expectedDistance: Double,
         initialData: InitialData,
         smootherParameters: SmootherParameters) {
        self.powerLossParameters = powerLossParameters
        self.rssiParameters = rssiParameters
        let rssiAdapter = RssiAdapter(params: powerLossParameters,
                                      weightCoefficient: rssiParameters.weightCoefficient,
                                      intercept: rssiParameters.intercept,
                                      observationType: observationType)
        self.expectedDistance = expectedDistance
        
        let transitionCovariance = pow(expectedDistance, 2)
        let observationCovariance = rssiParameters.covariance
        let transitionFuncion = BLEDistanceUnscentedKalmanSmoother.transitionFunction
        let observationFunction = BLEDistanceUnscentedKalmanSmoother.observationFunction(rssiAdapter: rssiAdapter)
        
        self.rssiAdapter = rssiAdapter
        self.filter = UnscentedKalmanSmoother(initialStateMean: initialData.mean,
                                            initialStateCovariance: initialData.covariance,
                                            transitionCovariance: transitionCovariance,
                                            observationCovariance: observationCovariance,
                                            alpha: smootherParameters.alpha,
                                            beta: smootherParameters.beta,
                                            kappa: smootherParameters.kappa,
                                            transitionFunction: transitionFuncion,
                                            observationFunction: observationFunction)
    }
    
    func smooth(observations: [Double?]) -> [(Double, Double)] {
        filter.smooth(observationData: observations)
    }
    
    static func transitionFunction(state: Double, transitionNoise: Double) -> Double {
        abs(state + transitionNoise)
    }
    
    static func observationFunction(rssiAdapter: RssiAdapter) -> (Double, Double) -> Double {
        return { state, observationNoise in
            rssiAdapter.observationTransform(distance: abs(state)) + observationNoise
        }
    }
    
    #if DEBUG
    func filter(observations: [Double?]) -> [(Double, Double)] {
        filter.filter(observationData: observations)
    }
    #endif
}
