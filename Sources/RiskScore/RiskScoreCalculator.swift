
import Foundation

/**
 ScoreCalculator computes the risk score from a list of ScanInstances
 */
public struct RiskScoreCalculator {
    var sampleResolution: Double // Assumption: Unit is minutes
    var smoother: BLEDistanceUnscentedKalmanSmoother
    var riskScore: QuadraticRiskScore
    
    public init(configuration: RiskScoreCalculatorConfiguration) {
        self.sampleResolution = configuration.sampleResolution
        self.smoother = BLEDistanceUnscentedKalmanSmoother(powerLossParameters: configuration.powerLossParameters,
                                                         observationType: configuration.observationType,
                                                         rssiParameters: configuration.rssiParameters,
                                                         expectedDistance: configuration.expectedDistance,
                                                         initialData: configuration.initialData,
                                                         smootherParameters: configuration.smootherParameters
        )
        self.riskScore = QuadraticRiskScore(minDistance: configuration.minimumDistance)
    }
    
    public func calculate(instances: [ScanInstance]) -> Double {
        let observations = self.observations(for: instances)
        let (distances, durations) = smoother.smooth(observations: observations).map { (mean: Double, covariance: Double) -> (Double, Double) in
            let scale = 1.0 / (mean / covariance)
            let shape = pow(mean, 2.0) / covariance
            let distance = GammaDistribution.median(shape: shape, scale: scale)
            let duration = sampleResolution
            return (distance, duration / 60.0)
        }.splitPairs()
        return riskScore.calculate(durations: durations, distances: distances, shouldNormalize: false)
    }
    
    private func observations(for instances: [ScanInstance]) -> [Double?] {
        makeObservations(instances: instances, sampleResolution: sampleResolution).map(\.value)
    }
    
    #if DEBUG
    public func filter(instances: [ScanInstance]) -> [(Double, Double)] {
        let observations = self.observations(for: instances)
        return smoother.filter(observations: observations)
    }
    
    public func smooth(instances: [ScanInstance]) -> [(Double, Double)] {
        let observations = self.observations(for: instances)
        return smoother.smooth(observations: observations)
    }
    #endif
}
