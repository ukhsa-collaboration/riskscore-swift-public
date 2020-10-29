
import Foundation

extension Array {
    /*
     Pads an array with an entry produced by `makeEntry` so that each index in the array from 0 to the maximum value of the `index` function is assigned.
     Assumptions:
        - The array is sorted ascending by the index function.
        - The index function is injective when restricted to the elements of the input array.
     */
    func pad(makeEntry: (Int) -> Element, using index: (Element) -> Int) -> [Element] {
        return reduce(into: [Element]()) { (result, next) in
            let upto = index(next)
            let top = result.count
            result.append(contentsOf: (top..<upto).map(makeEntry))
            result.append(next)
        }
    }
}
