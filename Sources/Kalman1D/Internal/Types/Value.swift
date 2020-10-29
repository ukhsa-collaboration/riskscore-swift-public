
import Foundation

struct Value<T: ValueTag> {
    var rawValue: Double
    
    init(rawValue: Double) {
        self.rawValue = rawValue
    }
}

extension Value: ExpressibleByFloatLiteral {    
    init(floatLiteral value: Double) {
        self.rawValue = value
    }
}

extension Value: AdditiveArithmetic {
    
    static var zero: Value<T> {
        self.init(rawValue: .zero)
    }
    
    static func + (lhs: Value<T>, rhs: Value<T>) -> Value<T> {
        self.init(rawValue: lhs.rawValue + rhs.rawValue)
    }
    
    static func += (lhs: inout Value, rhs: Value) {
        lhs.rawValue += rhs.rawValue
    }
    
    static func - (lhs: Value<T>, rhs: Value<T>) -> Value<T> {
        self.init(rawValue: lhs.rawValue - rhs.rawValue)
    }
    
    static func -= (lhs: inout Value, rhs: Value) {
        lhs.rawValue -= rhs.rawValue
    }
}

extension Value: Numeric {
    init(integerLiteral value: Int) {
        self.init(rawValue: Double(value))
    }
    
    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let rawValue = Double(exactly: source) else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public var magnitude: Double.Magnitude {
      return self.rawValue.magnitude
    }

    public static func * (lhs: Value, rhs: Value) -> Value {
      return self.init(rawValue: lhs.rawValue * rhs.rawValue)
    }

    public static func *= (lhs: inout Value, rhs: Value) {
      lhs.rawValue *= rhs.rawValue
    }
}

extension Value {
    static func / (lhs: Double, rhs: Value) -> Double {
        return lhs / rhs.rawValue
    }
    
    func inverse() -> Value<T> {
        precondition(rawValue != 0, "Division by zero")
        return Value(rawValue: 1 / rawValue)
    }
    
    func scale<S: ValueTag>(_ other: Value<S>) -> Value {
        Value(rawValue: other.rawValue * rawValue)
    }
    
    func translate<S: ValueTag>(_ other: Value<S>) -> Value {
        Value(rawValue: rawValue + other.rawValue)
    }
}

extension Value: SignedNumeric {}
