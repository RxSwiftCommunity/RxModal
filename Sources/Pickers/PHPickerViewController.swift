//
//  PHPickerViewController.swift
//  RxModal
//
//  Created by Jérôme Alves on 03/02/2021.
//

#if canImport(PhotosUI)
import UIKit
import PhotosUI
import RxSwift
import RxCocoa

extension RxModal {
    @available(iOS 14, *)
    public static func photoPicker(presenter: Presenter = .keyWindow, configuration: @escaping (inout PHPickerConfiguration) -> Void = { _ in }) -> Single<[PHPickerResult]> {
        PHPickerViewControllerCoordinator.present(using: presenter) { delegate in
            PHPickerViewController(configuration: PHPickerConfiguration() .. configuration)..{
                $0.delegate = delegate
            }
        } sequence: {
            $0.pickerResults.asSingle()
        }
    }
}

@available(iOS 14, *)
private class PHPickerViewControllerCoordinator: RxModalCoordinator<PHPickerViewController>, PHPickerViewControllerDelegate {
    required init() {}

    let pickerResults = PublishSubject<[PHPickerResult]>()
        
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        pickerResults.onNext(results)
        pickerResults.onCompleted()
    }
}
#endif
