//
//  Dialog.swift
//  RxModal
//
//  Created by Jérôme Alves on 07/02/2021.
//

import Foundation
import RxSwift

public struct Dialog<T> {
    public let title: String?
    public let message: String?
    public let actions: [DialogAction<T>]

    public init(title: String? = nil, message: String? = nil, actions: [DialogAction<T>]) {
        assert(actions.isEmpty == false, "Must have at least one action")

        self.title = title
        self.message = message
        self.actions = actions
    }
}

public enum DialogActionStyle {
    case `default`
    case cancel
    case destructive
}

public struct DialogAction<T> {
    public let title: String
    public let style: DialogActionStyle
    public let onNext: Observable<T>
    public let isPreferred: Bool

    public init(title: String, style: DialogActionStyle, onNext: Observable<T>, isPreferred: Bool = false) {
        self.title = title
        self.style = style
        self.onNext = onNext
        self.isPreferred = isPreferred
    }

    public func withStyle(_ newStyle: DialogActionStyle) -> DialogAction<T> {
        DialogAction<T>(
            title: title,
            style: newStyle,
            onNext: onNext,
            isPreferred: isPreferred
        )
    }

    // MARK: - Observables

    public static func `default`<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .default, onNext: observable.asObservable())
    }

    public static func cancel<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .cancel, onNext: observable.asObservable())
    }

    public static func destructive<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .destructive, onNext: observable.asObservable())
    }

    // MARK: - Values

    public static func `default`(title: String, mapTo value: T) -> DialogAction<T> {
        .default(title: title, flatMapTo: Observable.just(value))
    }

    public static func cancel(title: String, mapTo value: T) -> DialogAction<T> {
        .cancel(title: title, flatMapTo: Observable.just(value))
    }

    public static func destructive(title: String, mapTo value: T) -> DialogAction<T> {
        .destructive(title: title, flatMapTo: Observable.just(value))
    }

    // MARK: - Throw

    public static func `default`(title: String, throw error: Error) -> DialogAction<T> {
        .default(title: title, flatMapTo: Observable.error(error))
    }

    public static func cancel(title: String, throw error: Error) -> DialogAction<T> {
        .cancel(title: title, flatMapTo: Observable.error(error))
    }

    public static func destructive(title: String, throw error: Error) -> DialogAction<T> {
        .destructive(title: title, flatMapTo: Observable.error(error))
    }

    // MARK: - No Values

    public static func `default`(title: String) -> DialogAction<T> {
        .default(title: title, flatMapTo: Observable.empty())
    }

    public static func cancel(title: String) -> DialogAction<T> {
        .cancel(title: title, flatMapTo: Observable.empty())
    }

    public static func destructive(title: String) -> DialogAction<T> {
        .destructive(title: title, flatMapTo: Observable.empty())
    }

    // MARK: - Higher Order Actions

    public static func preferred(_ action: DialogAction<T>) -> DialogAction<T> {
        DialogAction(
            title: action.title,
            style: action.style,
            onNext: action.onNext,
            isPreferred: true
        )
    }
}
