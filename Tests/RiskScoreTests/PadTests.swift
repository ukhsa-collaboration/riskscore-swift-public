
@testable import RiskScore
import XCTest
import SwiftCheck

func identity<A>(_ a: A) -> A {
    return a
}

class PadTests: XCTestCase {
    func testPadCanPadAListOfCharacters() {
        let input: [Character] = ["b", "e"]
        
        XCTAssertEqual(input.pad(makeEntry: { Character(UnicodeScalar($0 + 97)!) },
                                 using: { Int($0.asciiValue!) - 97 }),
                       ["a", "b", "c", "d", "e"])
    }
    
    func testProperties() {
        property("the size of the padded list is equal to the size of the input list") <- forAll(Gen.choose((0, 100)).proliferate) { l in
            Array(Set(l))
                .sorted()
                .pad(makeEntry:identity(_:), using: identity(_:)).count == l.max().map { $0 + 1 } ?? 0
        }
    }
}
