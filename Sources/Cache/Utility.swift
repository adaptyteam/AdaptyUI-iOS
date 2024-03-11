//
//  Utility.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

extension Result where Failure: Error {
    /// Evaluates the given transform closures to create a single output value.
    ///
    /// - Parameters:
    ///   - onSuccess: A closure that transforms the success value.
    ///   - onFailure: A closure that transforms the error value.
    /// - Returns: A single `Output` value.
    func match<Output>(
        onSuccess: (Success) -> Output,
        onFailure: (Failure) -> Output) -> Output {
        switch self {
        case let .success(value):
            return onSuccess(value)
        case let .failure(error):
            return onFailure(error)
        }
    }
}

class Delegate<Input, Output> {
    init() {}

    private var block: ((Input) -> Output?)?
    func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }

    func call(_ input: Input) -> Output? {
        return block?(input)
    }

    func callAsFunction(_ input: Input) -> Output? {
        return call(input)
    }
}

extension Delegate where Input == Void {
    func call() -> Output? {
        return call(())
    }

    func callAsFunction() -> Output? {
        return call()
    }
}

extension Delegate where Input == Void, Output: OptionalProtocol {
    func call() -> Output {
        return call(())
    }

    func callAsFunction() -> Output {
        return call()
    }
}

extension Delegate where Output: OptionalProtocol {
    func call(_ input: Input) -> Output {
        if let result = block?(input) {
            return result
        } else {
            return Output._createNil
        }
    }

    func callAsFunction(_ input: Input) -> Output {
        return call(input)
    }
}

protocol OptionalProtocol {
    static var _createNil: Self { get }
}

extension Optional: OptionalProtocol {
    static var _createNil: Optional<Wrapped> {
        return nil
    }
}
