
import Foundation


/**
 Configuration for the RiskScoreCalculator
 */
public struct RiskScoreCalculatorConfiguration {
    var sampleResolution: Double
    var expectedDistance: Double
    var minimumDistance: Double
    var rssiParameters: RssiParameters
    var powerLossParameters: PowerLossParameters
    var observationType: ObservationType
    var initialData: InitialData
    var smootherParameters: SmootherParameters
    
    /**
     - parameter sampleResolution: The resolution of samples taken in seconds.
     - parameter expectedDistance: The expected distance moved per second in meters.
     - parameter minimumDistance: The minimum distance in meters. Any estimated distance lower than this will be replaced with this value.
     - parameter rssiParameters: Parameters for the RSSI emission model.
     - parameter powerLossParaeters: Parameters used in the Friis function for RSSi to estimated distance calculation.
     - parameter observationType: The observation model to use.
     - parameter initialData:Prior values for the Kalman smoother.
     - parameter smootherParameters: Parameters for the Kalman smoother.
     */
    public init(sampleResolution: Double,
                expectedDistance: Double,
                minimumDistance: Double,
                rssiParameters: RssiParameters,
                powerLossParameters: PowerLossParameters,
                observationType: ObservationType,
                initialData: InitialData,
                smootherParameters: SmootherParameters) {
        self.sampleResolution = sampleResolution
        self.expectedDistance = expectedDistance
        self.minimumDistance = minimumDistance
        self.rssiParameters = rssiParameters
        self.powerLossParameters = powerLossParameters
        self.observationType = observationType
        self.initialData = initialData
        self.smootherParameters = smootherParameters
    }
    
    public static var exampleConfiguration: RiskScoreCalculatorConfiguration {
        RiskScoreCalculatorConfiguration(
            sampleResolution: 1.0,
            expectedDistance: 0.1,
            minimumDistance: 1.0,
            rssiParameters: RssiParameters(
                weightCoefficient: 0.1270547531082051,
                intercept: 4.2309333657856945,
                covariance: 0.4947614361027773
            ),
            powerLossParameters: PowerLossParameters(
                wavelength: 0.125,
                pathLossFactor: 20.0,
                refDeviceLoss: .zero
            ),
            observationType: .log,
            initialData: InitialData(
                mean: 2.0,
                covariance: 10.0
            ),
            smootherParameters: SmootherParameters(
                alpha: 1.0,
                beta: .zero,
                kappa: .zero
            )
        )
    }
}

/**
 Parameters for the RSSI emissions model.
 */
public struct RssiParameters {
    var weightCoefficient: Double
    var intercept: Double
    var covariance: Double
    
    public init(weightCoefficient: Double, intercept: Double, covariance: Double) {
        self.weightCoefficient = weightCoefficient
        self.intercept = intercept
        self.covariance = covariance
    }
}

public enum ObservationType {
    case log
    case gen
}

public struct InitialData {
    var mean: Double
    var covariance: Double
    
    public init(mean: Double, covariance: Double) {
        self.mean = mean
        self.covariance = covariance
    }
}

public struct PowerLossParameters {
    var wavelength: Double
    var pathLossFactor: Double
    var refDeviceLoss: Double
    
    /**
     - parameter wavelength: The signal wavelength in meters.
     - parameter pathLossFactor: The free-space loss factor.
     - parameter refDeviceLoss: The reference device losses.
     */
    public init(wavelength: Double, pathLossFactor: Double, refDeviceLoss: Double) {
        self.wavelength = wavelength
        self.pathLossFactor = pathLossFactor
        self.refDeviceLoss = refDeviceLoss
    }
}

public struct SmootherParameters {
    var alpha: Double
    var beta: Double
    var kappa: Double
    
    public init(alpha: Double, beta: Double, kappa: Double) {
        self.alpha = alpha
        self.beta = beta
        self.kappa = kappa
    }
}
