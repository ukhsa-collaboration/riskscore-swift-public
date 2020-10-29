
/**
 The UnscentedTransformer computes the mean and covariance of Sigma points after they've been propogated though
 a non-linear function.
 */
struct UnscentedTransformer<T: ValueTag, U: ValueTag> {
    var meanWeights: Vector<MeanWeights>
    var covarianceWeights: Vector<CovarianceWeights>
    
    /**
     Compute the mean and covariance of the `propogatedSigmaPoints`.
     
        ` mean = sum_{p = sigma point} meanWeight_p * p`
        `covariance = sum_{p = sigma point} covarianceWeight_p (p - mean) (p - mean)^T`
     */
    func transform(progogatedSigmaPoints: Vector<StateSigmaPoints>) -> PredictionState<T, U> {
        let predictedMean: Value<T> = progogatedSigmaPoints.dot(meanWeights)
        let sigmaMeanDiff = progogatedSigmaPoints.minus(predictedMean)
        let covarianceMatrix = Matrix(diagonal: covarianceWeights)

        return PredictionState<T, U>(
            mean: predictedMean,
            covariance: sigmaMeanDiff
                .multiply(covarianceMatrix)
                .dot(sigmaMeanDiff))
    }
}
