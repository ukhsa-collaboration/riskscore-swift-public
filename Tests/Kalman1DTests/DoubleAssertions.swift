
import Foundation
@testable import Kalman1D

let defaultAccuracy = 1e-8

func closeEnough(_ a: Double, _ b: Double, accuracy: Double = defaultAccuracy) -> Bool {
    return abs(b - a) < accuracy
}

func closeEnough<S: ValueTag, T: ValueTag>(_ a: Value<S>, _ b: Value<T>, accuracy: Double = defaultAccuracy) -> Bool {
    return abs(b.rawValue - a.rawValue) < accuracy
}


