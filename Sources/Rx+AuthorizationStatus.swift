//
//  Rx+AuthorizationStatus.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import UIKit
import RxSwift

// MARK: - Completable

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    public func require<T: Equatable>(_ status: Single<T>, in expectedStatus: T...) -> Completable {
        status.flatMapCompletable { status in
            guard expectedStatus.contains(status) else {
                return .error(RxModalError.authorizationDenied(T.self))
            }
            return self
        }
    }
}

// MARK: - Single

extension PrimitiveSequence where Trait == SingleTrait {
    public func require<T: Equatable>(_ status: Single<T>, in expectedStatus: T...) -> Single<Element> {
        status.flatMap { status -> Single<Element> in
            guard expectedStatus.contains(status) else {
                return .error(RxModalError.authorizationDenied(T.self))
            }
            return self
        }
    }
}

// MARK: - Maybe

extension PrimitiveSequence where Trait == MaybeTrait {
    public func require<T: Equatable>(_ status: Single<T>, in expectedStatus: T...) -> Maybe<Element> {
        status.flatMapMaybe { status in
            guard expectedStatus.contains(status) else {
                return .error(RxModalError.authorizationDenied(T.self))
            }
            return self
        }
    }
}

// MARK: - Observable

extension Observable {
    public func require<T: Equatable>(_ status: Single<T>, in expectedStatus: T...) -> Observable<Element> {
        status.asObservable().flatMap { status -> Observable<Element> in
            guard expectedStatus.contains(status) else {
                return .error(RxModalError.authorizationDenied(T.self))
            }
            return self
        }
    }
}
