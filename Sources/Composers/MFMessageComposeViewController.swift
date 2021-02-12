//
//  MFMailComposeViewController.swift
//  RxModal
//
//  Created by Jérôme Alves on 06/02/2021.
//

#if canImport(MessageUI)
import UIKit
import MessageUI
import RxSwift

extension RxModal {
    
    public static func messageComposer(presenter: Presenter = .keyWindow, configuration: @escaping (MFMessageComposeViewController) -> Void = { _ in }) -> Single<MessageComposeResult> {
        .deferred {
            guard MFMessageComposeViewController.canSendText() else {
                throw RxModalError.unsupported
            }
            return MFMessageComposeViewControllerCoordinator.present(using: presenter) { delegate in
                MFMessageComposeViewController()..{
                    configuration($0)
                    $0.messageComposeDelegate = delegate
                }
            } sequence: {
                $0.composerResult.asSingle()
            }
        }
    }
}

private class MFMessageComposeViewControllerCoordinator: RxModalCoordinator<MFMessageComposeViewController>, MFMessageComposeViewControllerDelegate {
    required init() {}

    let composerResult = PublishSubject<MessageComposeResult>()

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        composerResult.onNext(result)
        composerResult.onCompleted()
    }
}
#endif
