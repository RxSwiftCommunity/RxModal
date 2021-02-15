//
//  Flow.swift
//  RxModalExample
//
//  Created by Jérôme Alves on 11/02/2021.
//

import UIKit
import RxSwift
import RxModal

struct Flow {
    let title: String
    let source: (UIBarButtonItem) -> Observable<String>
    
    init<O: ObservableConvertibleType>(_ title: String, source: @escaping () -> O) {
        self = .init(title, source: { _ in source() })
    }
    
    init<O: ObservableConvertibleType>(_ title: String, source: @escaping (UIBarButtonItem) -> O) {
        self.title = title
        self.source = { sender in
            source(sender)
                .asObservable()
                .map { String(rxModalDescribing: $0) }
                .materialize()
                .map { ".\($0)" }
                .startWith(
                    "\(O.self)"
                        .replacingOccurrences(of: "PrimitiveSequence<", with: "")
                        .replacingOccurrences(of: "Trait, ", with: "<"),
                    ".subscribe"
                )
                .concat(Single.just(".dispose"))
        }
    }

    static var allFlows: [Flow] = {
        var flows = [
            Flow("Alert") {
                RxModal.alert(
                    AlertResult.self,
                    title: "Delete Item",
                    message: "Are you sure you want to delete something?",
                    actions: [
                        .cancel(title: "Cancel", mapTo: .cancel),
                        .destructive(title: "Delete", mapTo: .delete)
                    ]
                )
            },
            Flow("Action Sheet") { sender in
                RxModal.actionSheet(
                    AlertResult.self,
                    source: .barButtonItem(sender),
                    title: "Delete Item",
                    message: "Are you sure you want to delete something?",
                    actions: [
                        .cancel(title: "Cancel", mapTo: .cancel),
                        .destructive(title: "Delete", mapTo: .delete)
                    ]
                )
            },
            Flow("Media Picker") {
                RxModal.mediaPicker {
                    $0.allowsPickingMultipleItems = true
                }.map(\.items)
            },
            Flow("Mail Composer") {
                RxModal.mailComposer {
                    $0.setToRecipients(["rxmodal@rxswiftcommunity.org"])
                    $0.setSubject("RxModal")
                    $0.setMessageBody("""
                    Hey,
                    This library is awesome!
                    Thanks :)
                    """, isHTML: false)
                }
            },
            Flow("Message Composer") {
                RxModal.messageComposer {
                    $0.recipients = ["0639981337"]
                    $0.body = """
                    Hey,
                    This library is awesome!
                    Thanks :)
                    """
                }
            },
            Flow("Composer Chooser") { sender in
                RxModal.actionSheet(
                    source: .barButtonItem(sender),
                    title: "Contact Us",
                    actions: [
                        .default(title: "Mail", flatMapTo: RxModal.mailComposer {
                            $0.setToRecipients(["rxmodal@rxswiftcommunity.org"])
                            $0.setMessageBody("Hello World!", isHTML: false)
                        }),
                        .default(title: "Message", flatMapTo: RxModal.messageComposer {
                            $0.recipients = ["0639981337"]
                            $0.body = "Hello World!"
                        }),
                        .cancel(title: "Cancel")
                    ]
                )
            },
            Flow("Sign In alert") {
                RxModal.alert(
                    title: "Sign in",
                    message: "Please sign in using your credentials",
                    textFields: [
                        DialogTextField.email { $0.placeholder = "e-mail" },
                        DialogTextField.password { $0.placeholder = "password" }
                    ],
                    actions: [
                        .cancel(title: "Cancel"),
                        .default(title: "Sign In") { textFields in
                            Credentials(
                                email: textFields[0].text ?? "",
                                password: textFields[1].text ?? ""
                            )
                        },
                    ]
                )
            }
        ]
        
        #if targetEnvironment(macCatalyst)
        // OAuth playgrounds seem to work only on macOS 🤷🏻‍♂️
        flows.append(
            Flow("Web Session") { () -> Single<URL> in
                RxModal.alert(
                    String?.self,
                    title: "Client ID",
                    message: "You must register a playground client on oauth.com first",
                    textFields: [DialogTextField { $0.placeholder = "CLIENT ID" }],
                    actions: [
                        .cancel(title: "Cancel", throw: WebSessionError.missingClientID),
                        .default(title: "Register New Client", mapTo: nil),
                        .preferred(.default(title: "Continue", map: { $0.first?.text })),
                    ])
                    .asSingle()
                    .flatMap { clientID in
                        guard let clientID = clientID else {
                            UIApplication.shared.open(URL(string: "https://www.oauth.com/playground/client-registration.html")!)
                            throw WebSessionError.missingClientID
                        }
                        return RxModal.webAuthenticationSession(
                            url: URL(string: "https://www.oauth.com/playground/auth-dialog.html?response_type=token&client_id=\(clientID)&redirect_uri=rx-modal-example://&scope=photo&state=NESR37xhi7JGQ6xI")!,
                            callbackURLScheme: "rx-modal-example"
                        )
                    }
            }
        )
        #endif
        
        if #available(iOS 14, *) {
            flows.append(
                Flow("Photo Picker") {
                    RxModal.photoPicker {
                        $0.selectionLimit = 3
                    }
                }
            )
        }
        
        return flows
    }()

}

enum AlertResult {
    case delete, cancel
}

enum WebSessionError: Error {
    case missingClientID
}

struct Credentials {
    let email: String
    let password: String
}
