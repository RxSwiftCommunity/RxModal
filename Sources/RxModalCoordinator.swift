//
//  RxModalCoordinator.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import UIKit
import RxSwift

open class RxModalCoordinator<ViewController: UIViewController>: NSObject, Disposable {
    private var _viewController: ViewController?
    public var viewController: ViewController {
        _viewController!
    }
    
    required public override init() {}
    
    open func present(_ controller: @autoclosure () -> ViewController, with presenter: Presenter) throws {
        guard let presenter = presenter() else {
            throw RxModalError.missingPresenter
        }
        _viewController = controller()
        presenter.present(viewController, animated: true, completion: nil)
    }
    
    open func dispose() {
        guard viewController.isBeingDismissed == false else {
            return
        }
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension NSObjectProtocol {
    
    //MARK: - Completable
    
    public static func present<ViewController>(
        using presenter: Presenter = .keyWindow,
        controllerFactory: @escaping (Self) -> ViewController,
        sequence: @escaping (Self) -> Completable
    ) -> Completable where Self: RxModalCoordinator<ViewController> {
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
    
    public static func present<ViewController, T>(
        using presenter: Presenter = .keyWindow,
        controllerFactory: @escaping (Self) -> ViewController,
        sequence: @escaping (Self) -> Single<T>
    ) -> Single<T> where Self: RxModalCoordinator<ViewController> {
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

    public static func present<ViewController, T>(
        using presenter: Presenter = .keyWindow,
        controllerFactory: @escaping (Self) -> ViewController,
        sequence: @escaping (Self) -> Maybe<T>
    ) -> Maybe<T> where Self: RxModalCoordinator<ViewController> {
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

    public static func present<ViewController, T>(
        using presenter: Presenter = .keyWindow,
        controllerFactory: @escaping (Self) -> ViewController,
        sequence: @escaping (Self) -> Observable<T>
    ) -> Observable<T> where Self: RxModalCoordinator<ViewController> {
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
