//
//  PHPickerViewController.swift
//  RxModal
//
//  Created by Jérôme Alves on 03/02/2021.
//

#if canImport(PhotosUI)
import PhotosUI
import RxSwift
import RxCocoa

extension RxModal {
    @available(iOS 14, *)
    public static func mediaPicker(configuration: PHPickerConfiguration, presenter: Presenter = .keyWindow) -> Single<[PHPickerResult]> {
        PickerViewControllerCoordinator.present(using: presenter) { delegate in
            PHPickerViewController(configuration: configuration)..{
                $0.delegate = delegate
            }
        } sequence: {
            $0.pickerResults.asSingle()
        }
    }
}

@available(iOS 14, *)
private class PickerViewControllerCoordinator: RxModalCoordinator, PHPickerViewControllerDelegate {
    required init() {}

    let pickerResults = PublishSubject<[PHPickerResult]>()
        
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        pickerResults.onNext(results)
        pickerResults.onCompleted()
    }
}
#endif
