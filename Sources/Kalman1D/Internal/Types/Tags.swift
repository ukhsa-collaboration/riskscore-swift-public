
public protocol ValueTag {}

public enum StateMean: ValueTag {}
public enum CrossCovariance: ValueTag {}
public enum StateCovariance: ValueTag {}
public enum TransitionCovariance: ValueTag {}
public enum ObservationCovariance: ValueTag {}
public enum Observation: ValueTag {}
public enum Scale: ValueTag {}


protocol VectorTag {}

protocol WeightsTag: VectorTag {}

enum MeanWeights: WeightsTag {}
enum CovarianceWeights: WeightsTag {}
enum StateSigmaPoints: VectorTag {}
enum TransitionSigmaPoints: VectorTag {}
enum ObservationSigmaPoints: VectorTag {}
enum SmootherStateSigmaPoints: VectorTag {}
enum SmootherTransitionSigmaPoints: VectorTag {}
