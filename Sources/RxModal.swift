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
    case unsupported
    case authorizationDenied(Any.Type)
}
