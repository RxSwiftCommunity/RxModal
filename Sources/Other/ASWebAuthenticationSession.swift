//
//  ASWebAuthenticationSession.swift
//  RxModal
//
//  Created by Jérôme Alves on 10/02/2021.
//

import Foundation
import AuthenticationServices
import RxSwift

extension RxModal {
    
    @available(iOS 12.0, *)
    public static func webAuthenticationSession(
        presenter: Presenter = .keyWindow,
        url: URL,
        callbackURLScheme: String,
        configuration: @escaping (ASWebAuthenticationSession) -> Void = { _ in }
    ) -> Single<URL> {
        .using {
            try RxWebAuthenticationSessionCoordinator(
                presenter: presenter,
                url: url,
                callbackURLScheme: callbackURLScheme,
                configuration: configuration
            )
        } primitiveSequenceFactory: { coordinator in
            coordinator.result.asSingle()
        }
    }
}

@available(iOS 12.0, *)
private class RxWebAuthenticationSessionCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding, Disposable {
    var window: UIWindow!
    let session: ASWebAuthenticationSession
    let result: PublishSubject<URL>
    
    init(
        presenter: Presenter,
        url: URL,
        callbackURLScheme: String,
        configuration: @escaping (ASWebAuthenticationSession) -> Void
        ) throws {
        let result = PublishSubject<URL>()
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackURLScheme,
            completionHandler: {  url, error in
                if let error = error {
                    return result.onError(error)
                }
                guard let url = url else {
                    return result.onError(RxModalError.unsupported)
                }
                result.onNext(url)
                result.onCompleted()
            }
        )
        
        configuration(session)
        
        self.result = result
        self.session = session
        
        super.init()
        
        if #available(iOS 13.0, *) {
            guard let window = presenter()?.viewIfLoaded?.window else {
                throw RxModalError.missingPresenter
            }
            self.window = window
            self.session.presentationContextProvider = self
        }
        
        self.session.start()
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window
    }

    public func dispose() {
        session.cancel()
    }
    
}
