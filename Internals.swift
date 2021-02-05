//
//  Internals.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import Foundation

infix operator ..: MultiplicationPrecedence

@discardableResult
internal func .. <T>(object: T, configuration: (inout T) -> Void) -> T {
    var copy = object
    configuration(&copy)
    return copy
}
