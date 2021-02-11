//
//  UIAlertController.swift
//  RxModal
//
//  Created by Jérôme Alves on 07/02/2021.
//

import Foundation
import RxSwift

extension DialogActionStyle {
    fileprivate var alertActionStyle: UIAlertAction.Style {
        switch self {
        case .default:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

extension DialogAction {
    fileprivate func makeAlertAction(observer: AnyObserver<Observable<T>>, textFields: @escaping () -> [UITextField]) -> UIAlertAction {
        UIAlertAction(title: title, style: style.alertActionStyle) { _ in
            observer.onNext(self.onNext(textFields()))
            observer.onCompleted()
        }
    }
}

extension Dialog {
    fileprivate func makeAlertController(style: DialogStyle, observer: AnyObserver<Observable<T>>) -> UIAlertController {
        let controller: UIAlertController

        switch style {
        case .alert:
            controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        case .actionSheet(let source):
            controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            switch source {
            case .view(let view, let rect):
                controller.popoverPresentationController?.sourceRect = rect
                controller.popoverPresentationController?.sourceView = view
            case .barButtonItem(let item):
                controller.popoverPresentationController?.barButtonItem = item
            }
        }
        
        for textField in textFields {
            controller.addTextField(configurationHandler: textField.configuration)
        }

        for action in actions {
            let alertAction = action.makeAlertAction(observer: observer) { [unowned controller] in
                controller.textFields ?? []
            }
            controller.addAction(alertAction)
            if action.isPreferred {
                controller.preferredAction = alertAction
            }
        }

        return controller
    }
}

public enum DialogSource {
    case view(UIView, rect: CGRect)
    case barButtonItem(UIBarButtonItem)
    public static func bounds(_ view: UIView) -> DialogSource {
        .view(view, rect: view.bounds)
    }
}

public enum DialogStyle {
    case alert
    case actionSheet(source: DialogSource)
}

extension RxModal {
    public static func alert<T>(
        _ type: T.Type = T.self,
        presenter: Presenter = .keyWindow,
        title: String? = nil,
        message: String? = nil,
        textFields: [DialogTextField] = [],
        actions: [DialogAction<T>]
    ) -> Observable<T> {
        present(.alert, presenter: presenter, title: title, message: message, textFields: textFields, actions: actions)
    }

    public static func actionSheet<T>(
        _ type: T.Type = T.self,
        presenter: Presenter = .keyWindow,
        source: DialogSource,
        title: String? = nil,
        message: String? = nil,
        textFields: [DialogTextField] = [],
        actions: [DialogAction<T>]
    ) -> Observable<T> {
        present(.actionSheet(source: source), presenter: presenter, title: title, message: message, textFields: textFields, actions: actions)
    }

    public static func present<T>(
        _ style: DialogStyle,
        type: T.Type = T.self,
        presenter: Presenter = .keyWindow,
        title: String? = nil,
        message: String? = nil,
        textFields: [DialogTextField] = [],
        actions: [DialogAction<T>]
    ) -> Observable<T> {
        let dialog = Dialog(title: title, message: message, textFields: textFields, actions: actions)
        return present( dialog, style: style, presenter: presenter)
    }

    public static func present<T>(
        _ dialog: Dialog<T>,
        style: DialogStyle,
        presenter: Presenter = .keyWindow
    ) -> Observable<T> {
        UIAlertControllerCoordinator<T>.present(using: presenter) { coordinator in
            dialog.makeAlertController(style: style, observer: coordinator.result.asObserver())
        } sequence: { coordinator in
            coordinator.result.merge()
        }
    }
}

private class UIAlertControllerCoordinator<T>: RxModalCoordinator {
    required init() {}
    let result = PublishSubject<Observable<T>>()
}


