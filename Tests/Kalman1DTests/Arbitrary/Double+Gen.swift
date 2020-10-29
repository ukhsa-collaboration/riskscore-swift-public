
import SwiftCheck

let positiveDouble: Gen<Double> = Double.arbitrary.map(abs).map { $0 + 1e-3 }
