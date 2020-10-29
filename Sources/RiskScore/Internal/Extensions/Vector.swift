
import Foundation

func vectorOperation(_ v1: [Double], _ v2: [Double], op: (Double, Double) -> Double) -> [Double] {
    zip(v1, v2).map(op)
}

func vectorSum(_ v1: [Double], _ v2: [Double]) -> [Double] {
    return vectorOperation(v1, v2, op: +)
}

func vectorProduct(_ v1: [Double], _ v2: [Double]) -> [Double] {
    return vectorOperation(v1, v2, op: *)
}
