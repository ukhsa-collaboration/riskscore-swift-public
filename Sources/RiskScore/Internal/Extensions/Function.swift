
precedencegroup infixr {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: MultiplicationPrecedence
}

infix operator <<<: infixr

func <<< <A, B, C>(_ g: @escaping (B) -> C, _ f: @escaping (A) -> B) -> (A) -> C {
  return { a in g(f(a)) }
}

func negate<N: Numeric>(_ a: N) -> N {
    return -1 * a
}
