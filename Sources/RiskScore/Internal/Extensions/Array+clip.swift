
import Foundation

extension Array where Element: Comparable {
    func clip(lower: Element, upper: Element) -> Self {
        map { element in
            if element < lower {
                return lower
            } else if element > upper {
                return upper
            } else {
                return element
            }
        }
    }
}
