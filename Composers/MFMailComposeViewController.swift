//
//  MFMailComposeViewController.swift
//  Pods-RxModalExample
//
//  Created by Jérôme Alves on 06/02/2021.
//

#if canImport(MessageUI)
import Foundation
import MessageUI
import RxSwift

extension RxModal {
    
    public static func mailComposer(presenter: Presenter = .keyWindow, configuration: @escaping (MFMailComposeViewController) -> Void = { _ in }) -> Single<MFMailComposeResult> {
        .deferred {
            guard MFMailComposeViewController.canSendMail() else {
                throw RxModalError.unsupported
            }
            return MFMailComposeViewControllerCoordinator.present(using: presenter) { delegate in
                MFMailComposeViewController()..{
                    configuration($0)
                    $0.mailComposeDelegate = delegate
                }
            } sequence: {
                $0.composerResult.asSingle()
            }
        }
    }
}

private class MFMailComposeViewControllerCoordinator: RxModalCoordinator, MFMailComposeViewControllerDelegate {
    required init() {}

    let composerResult = PublishSubject<MFMailComposeResult>()
        
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            composerResult.onError(error)
        } else {
            composerResult.onNext(result)
            composerResult.onCompleted()
        }
    }
}
#endif
