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
    public let textFields: [DialogTextField]
    public let actions: [DialogAction<T>]

    public init(title: String? = nil, message: String? = nil, textFields: [DialogTextField] = [], actions: [DialogAction<T>]) {
        assert(actions.isEmpty == false, "Must have at least one action")

        self.title = title
        self.message = message
        self.textFields = textFields
        self.actions = actions
    }
}

public enum DialogActionStyle {
    case `default`
    case cancel
    case destructive
}

public struct DialogTextField {
    internal let configuration: (UITextField) -> ()
    public init(configuration: @escaping (UITextField) -> () = { _ in }) {
        self.configuration = configuration
    }
    
    public static func email(configuration: @escaping (UITextField) -> () = { _ in }) -> DialogTextField {
        DialogTextField {
            if #available(iOS 10.0, *) {
                $0.textContentType = .emailAddress
            }
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none
            $0.spellCheckingType = .no
            configuration($0)
        }
    }

    public static func password(configuration: @escaping (UITextField) -> () = { _ in }) -> DialogTextField {
        DialogTextField {
            if #available(iOS 11.0, *) {
                $0.textContentType = .password
            }
            $0.isSecureTextEntry = true
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            configuration($0)
        }
    }

    public static func phoneNumber(configuration: @escaping (UITextField) -> () = { _ in }) -> DialogTextField {
        DialogTextField {
            if #available(iOS 11.0, *) {
                $0.textContentType = .telephoneNumber
            }
            $0.keyboardType = .phonePad
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            configuration($0)
        }
    }
}

public struct DialogAction<T> {
    public let title: String
    public let style: DialogActionStyle
    public let onNext: ([UITextField]) -> Observable<T>
    public let isPreferred: Bool

    public init(title: String, style: DialogActionStyle, onNext: @escaping ([UITextField]) -> Observable<T>, isPreferred: Bool = false) {
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

    // MARK: - flatMap with TextFields

    public static func `default`<O: ObservableConvertibleType>(title: String, flatMap observable: @escaping ([UITextField]) -> O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .default, onNext: { observable($0).asObservable() })
    }

    public static func cancel<O: ObservableConvertibleType>(title: String, flatMap observable: @escaping ([UITextField]) -> O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .cancel, onNext: { observable($0).asObservable() })
    }

    public static func destructive<O: ObservableConvertibleType>(title: String, flatMap observable: @escaping ([UITextField]) -> O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .destructive, onNext: { observable($0).asObservable() })
    }

    // MARK: -  flatMapTo without TextFields

    public static func `default`<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .default, onNext: { _ in observable.asObservable() })
    }

    public static func cancel<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .cancel, onNext: { _ in observable.asObservable() })
    }

    public static func destructive<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<T> where O.Element == T {
        DialogAction(title: title, style: .destructive, onNext: { _ in observable.asObservable() })
    }

    // MARK: -  map with TextFields

    public static func `default`(title: String, map value: @escaping ([UITextField]) -> T) -> DialogAction<T> {
        .default(title: title, flatMap: { Observable.just(value($0)) })
    }

    public static func cancel(title: String, map value: @escaping ([UITextField]) -> T) -> DialogAction<T> {
        .cancel(title: title, flatMap: { Observable.just(value($0)) })
    }

    public static func destructive(title: String, map value: @escaping ([UITextField]) -> T) -> DialogAction<T> {
        .destructive(title: title, flatMap: { Observable.just(value($0)) })
    }

    // MARK: -  mapTo without TextFields

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

extension DialogAction where T == Void {
    // MARK: - flatMap with TextFields

    public static func `default`<O: ObservableConvertibleType>(title: String, flatMap observable: @escaping ([UITextField]) -> O) -> DialogAction<Void> {
        DialogAction(title: title, style: .default, onNext: { observable($0).asObservable().map { _ in () } })
    }

    public static func cancel<O: ObservableConvertibleType>(title: String, flatMap observable: @escaping ([UITextField]) -> O) -> DialogAction<Void> {
        DialogAction(title: title, style: .cancel, onNext: { observable($0).asObservable().map { _ in () } })
    }

    public static func destructive<O: ObservableConvertibleType>(title: String, flatMap observable: @escaping ([UITextField]) -> O) -> DialogAction<Void> {
        DialogAction(title: title, style: .destructive, onNext: { observable($0).asObservable().map { _ in () } })
    }

    // MARK: -  flatMapTo without TextFields

    public static func `default`<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<Void> {
        DialogAction(title: title, style: .default, onNext: { _ in observable.asObservable().map { _ in () } })
    }

    public static func cancel<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<Void> {
        DialogAction(title: title, style: .cancel, onNext: { _ in observable.asObservable().map { _ in () } })
    }

    public static func destructive<O: ObservableConvertibleType>(title: String, flatMapTo observable: O) -> DialogAction<Void> {
        DialogAction(title: title, style: .destructive, onNext: { _ in observable.asObservable().map { _ in () } })
    }

}
