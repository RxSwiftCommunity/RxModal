//
//  RxModal.swift
//  RxSwiftCommunity
//
//  Created by Jérôme Alves on 03/02/2021.
//  Copyright © 2021 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RxSwift

public enum RxModal {
    
}

public enum RxModalError: Error {
    case missingPresenter
}

public struct Presenter {
    private let get: () -> UIViewController?
    
    public static let keyWindow = Presenter {
        UIApplication.shared.keyWindow?.rootViewController
    }
    
    public static func window(_ window: UIWindow?) -> Presenter {
        Presenter { [weak window] in
            window?.rootViewController
        }
    }
    
    public static func viewController(_ viewController: UIViewController?) -> Presenter {
        Presenter { [weak viewController] in
            viewController
        }
    }
    
    public static func view(_ view: UIView?) -> Presenter {
        Presenter { [weak view] in
            view?.window?.rootViewController
        }
    }
    
    @available(iOS 13.0, *)
    public static func scene(_ scene: UIWindowScene) -> Presenter {
        Presenter { [weak scene] in
            guard let scene = scene else { return nil }
            assert(scene.windows.count <= 1, "Several windows found in the scene")
            return scene.windows.first?.rootViewController
        }
    }
    
    func callAsFunction() -> UIViewController? {
        get()
    }
}

public class RxModalCoordinator: NSObject, Disposable {
    public private(set) var controller: UIViewController?
    
    required public override init() {}
    
    fileprivate func present(_ controller: @autoclosure () -> UIViewController, with presenter: Presenter) throws {
        guard let presenter = presenter() else {
            throw RxModalError.missingPresenter
        }
        self.controller = controller()
        presenter.present(self.controller!, animated: true, completion: nil)
    }
    
    public func dispose() {
        guard let controller = controller, controller.isBeingDismissed == false else {
            return
        }
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension NSObjectProtocol where Self: RxModalCoordinator {
    
    //MARK: - Completable
    
    public static func present<VC: UIViewController>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Completable
    ) -> Completable {
        .using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } primitiveSequenceFactory: { coordinator in
            sequence(coordinator)
        }
    }

    //MARK: - Single
    
    public static func present<VC: UIViewController, T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Single<T>
    ) -> Single<T> {
        .using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } primitiveSequenceFactory: { coordinator in
            sequence(coordinator)
        }
    }

    //MARK: - Maybe

    public static func present<VC: UIViewController, T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Maybe<T>
    ) -> Maybe<T> {
        .using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } primitiveSequenceFactory: { coordinator in
            sequence(coordinator)
        }
    }

    //MARK: - Observable

    public static func present<VC: UIViewController, T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Observable<T>
    ) -> Observable<T> {
        .using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } observableFactory: { coordinator in
            sequence(coordinator)
        }
    }

    
}

infix operator ..: MultiplicationPrecedence

@discardableResult
internal func .. <T>(object: T, configuration: (inout T) -> Void) -> T {
    var copy = object
    configuration(&copy)
    return copy
}
