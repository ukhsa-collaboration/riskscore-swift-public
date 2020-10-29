

/**
 A 3x3 Diagonal Matrix
 */
struct Matrix<Tag: VectorTag> {
    var diagonal: Vector<Tag>
    
    private init(_ diagonal: Vector<Tag>) {
        self.diagonal = diagonal
    }
}

extension Matrix where Tag == CovarianceWeights {
    init(diagonal: Vector<CovarianceWeights>) {
        self.init(diagonal)
    }
}
