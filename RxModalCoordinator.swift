//
//  RxModalCoordinator.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import Foundation
import RxSwift

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
        Completable.using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } primitiveSequenceFactory: { coordinator in
            sequence(coordinator)
        }
        .subscribe(on: MainScheduler.instance)

    }

    //MARK: - Single
    
    public static func present<VC: UIViewController, T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Single<T>
    ) -> Single<T> {
        Single.using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } primitiveSequenceFactory: { coordinator in
            sequence(coordinator)
        }
        .subscribe(on: MainScheduler.instance)
    }

    //MARK: - Maybe

    public static func present<VC: UIViewController, T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Maybe<T>
    ) -> Maybe<T> {
        Maybe.using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } primitiveSequenceFactory: { coordinator in
            sequence(coordinator)
        }
        .subscribe(on: MainScheduler.instance)
    }

    //MARK: - Observable

    public static func present<VC: UIViewController, T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> VC,
        sequence: @escaping (Self) -> Observable<T>
    ) -> Observable<T> {
        Observable.using {
            let coordinator = Self.init()
            try coordinator.present(controllerFactory(coordinator), with: presenter)
            return coordinator
        } observableFactory: { coordinator in
            sequence(coordinator)
        }
        .subscribe(on: MainScheduler.instance)
    }

}
