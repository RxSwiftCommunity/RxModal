//
//  Presenter.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import Foundation

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
    
    public func callAsFunction() -> UIViewController? {
        get()
    }
}
