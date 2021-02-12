//
//  RxModalCoordinator.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import Foundation
import RxSwift

public class RxModalCoordinator<ViewController: UIViewController>: NSObject, _RxModalCoordinator {
    private var _viewController: ViewController?
    public var viewController: ViewController {
        _viewController!
    }
    
    required public override init() {}
    
    public func present(_ controller: @autoclosure () -> ViewController, with presenter: Presenter) throws {
        guard let presenter = presenter() else {
            throw RxModalError.missingPresenter
        }
        _viewController = controller()
        presenter.present(viewController, animated: true, completion: nil)
    }
    
    public func dispose() {
        guard viewController.isBeingDismissed == false else {
            return
        }
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

public protocol _RxModalCoordinator: AnyObject, Disposable {
    init()
    associatedtype ViewController: UIViewController
    func present(_ controller: @autoclosure () -> ViewController, with presenter: Presenter) throws
}

extension NSObjectProtocol where Self: _RxModalCoordinator {
    
    //MARK: - Completable
    
    public static func present(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> Self.ViewController,
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
    
    public static func present<T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> Self.ViewController,
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

    public static func present<T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> Self.ViewController,
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

    public static func present<T>(
        using presenter: Presenter,
        controllerFactory: @escaping (Self) -> Self.ViewController,
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
