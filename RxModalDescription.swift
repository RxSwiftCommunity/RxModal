//
//  RxModalDescription.swift
//  RxModal
//
//  Created by Jérôme Alves on 06/02/2021.
//

import Foundation

public protocol RxModalCustomStringConvertible {
    var rxModalDescription: String { get }
}

extension String {
    public init(rxModalDescribing value: Any) {
        if let value = value as? RxModalCustomStringConvertible {
            self = value.rxModalDescription
        } else {
            self = String(describing: value)
        }
    }
}

#if canImport(MessageUI)
import MessageUI
extension MFMailComposeResult: RxModalCustomStringConvertible {
    public var rxModalDescription: String {
        switch self {
        case .cancelled:
            return ".cancelled"
        case .saved:
            return ".saved"
        case .sent:
            return ".sent"
        case .failed:
            return ".failed"
        @unknown default:
            return "@unknown"
        }
    }
}

extension MessageComposeResult: RxModalCustomStringConvertible {
    public var rxModalDescription: String {
        switch self {
        case .cancelled:
            return ".cancelled"
        case .sent:
            return ".sent"
        case .failed:
            return ".failed"
        @unknown default:
            return "@unknown"
        }
    }
}
#endif

#if canImport(MediaPlayer)
import MediaPlayer
extension MPMediaLibraryAuthorizationStatus: RxModalCustomStringConvertible {
    public var rxModalDescription: String {
        switch self {
        case .notDetermined:
            return ".notDetermined"
        case .denied:
            return ".denied"
        case .restricted:
            return ".restricted"
        case .authorized:
            return ".authorized"
        @unknown default:
            return "@unknown"
        }
    }
}

#endif
