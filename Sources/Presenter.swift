//
//  Presenter.swift
//  RxModal
//
//  Created by Jérôme Alves on 05/02/2021.
//

import UIKit

public struct Presenter {
    private let get: () -> UIViewController?
    
    public static let keyWindow = Presenter {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            assert(scenes.count <= 1, "Several connected scenes. You probably want to use a more specific presenter.")
            let windows = scenes.first?.windows.filter { $0.isKeyWindow } ?? []
            assert(windows.count <= 1, "Several windows found in the scene. You probably want to use a more specific presenter.")
            return windows.first?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
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
            assert(scene.windows.count <= 1, "Several windows found in the scene. You probably want to use a more specific presenter.")
            return scene.windows.first?.rootViewController
        }
    }
    
    public func callAsFunction() -> UIViewController? {
        get()
    }
}
