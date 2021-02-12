//
//  MPMediaPickerController.swift
//  RxModal
//
//  Created by Jérôme Alves on 03/02/2021.
//

#if canImport(MediaPlayer)
import MediaPlayer
import RxSwift
import RxCocoa

@available(iOS 9.3, *)
extension RxModal {
    public static var mediaLibraryAuthorizationStatus: Single<MPMediaLibraryAuthorizationStatus> {
        Single.deferred {
            let status = MPMediaLibrary.authorizationStatus()
            guard case .notDetermined = status else {
                return .just(status)
            }
            return Single.create { observer in
                MPMediaLibrary.requestAuthorization { status in
                    observer(.success(status))
                }
                return Disposables.create()
            }
        }
    }
    
    /**
     Media Picker
     
     Requires `NSAppleMusicUsageDescription` key in App's `Info.plist`
     */
    public static func mediaPicker(presenter: Presenter = .keyWindow, configuration: @escaping (MPMediaPickerController) -> Void = { _ in }) -> Single<MPMediaItemCollection> {
        MPMediaPickerControllerCoordinator.present(using: presenter) { delegate in
            MPMediaPickerController(mediaTypes: .any)..{
                configuration($0)
                $0.delegate = delegate
            }
        } sequence: {
            $0.subject.asSingle()
        }
        .require(mediaLibraryAuthorizationStatus, in: .authorized, .restricted)
    }
}

private class MPMediaPickerControllerCoordinator: RxModalCoordinator<MPMediaPickerController>, MPMediaPickerControllerDelegate {
    required init() {}

    let subject = PublishSubject<MPMediaItemCollection>()
        
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        subject.onNext(mediaItemCollection)
        subject.onCompleted()
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        subject.onNext(MPMediaItemCollection(items: []))
        subject.onCompleted()
    }
}
#endif
