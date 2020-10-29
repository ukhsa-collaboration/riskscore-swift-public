
import Foundation

struct RssiAdapter {
    private var observationType: ObservationType
    private var friisCalculator: FriisCalculator
    private var weightCoefficient: Double
    private var intercept: Double
    
    init(params: PowerLossParameters, weightCoefficient: Double, intercept: Double, observationType: ObservationType) {
        self.observationType = observationType
        self.friisCalculator = FriisCalculator(params: params)
        self.weightCoefficient = weightCoefficient
        self.intercept = intercept
    }
    
    func observationTransform(distance: Double) -> Double {
        let transform: (Double) -> Double
        switch observationType {
        case .log:
            transform = log
        case .gen:
            transform = log <<< negate <<< friisCalculator.friis(rxCorrection: .zero, txCorrection: .zero)
        }
        return weightCoefficient * transform(distance) + intercept
    }
}
