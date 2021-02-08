//
//  ViewController.swift
//  RxModalExample
//
//  Created by Jérôme Alves on 03/02/2021.
//

import UIKit
import RxModal
import RxSwift
import PhotosUI
import RxCocoa

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Flows
    
    enum AlertResult {
        case delete, cancel
    }

    private lazy var flows: [Flow] = {
        var flows = [
            Flow(title: "Alert") {
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
            Flow(title: "Action Sheet") {
                RxModal.actionSheet(
                    AlertResult.self,
                    source: .barButtonItem(startBarButtonItem),
                    title: "Delete Item",
                    message: "Are you sure you want to delete something?",
                    actions: [
                        .cancel(title: "Cancel", mapTo: .cancel),
                        .destructive(title: "Delete", mapTo: .delete)
                    ]
                )
            },
            Flow(title: "Media Picker") {
                RxModal.mediaPicker {
                    $0.allowsPickingMultipleItems = true
                }.map(\.items)
            },
            Flow(title: "Mail Composer") {
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
            Flow(title: "Message Composer") {
                RxModal.messageComposer {
                    $0.recipients = ["0639981337"]
                    $0.body = """
                    Hey,
                    This library is awesome!
                    Thanks :)
                    """
                }
            },
        ]
        
        if #available(iOS 14, *) {
            flows.append(
                Flow(title: "Photo Picker") {
                    RxModal.photoPicker {
                        $0.selectionLimit = 3
                    }
                }
            )
        }
        
        return flows
    }()
    

    var selectedFlow: Flow {
        flows[flowPicker.selectedRow(inComponent: 0)]
    }
    
    @IBAction func startFlow(_ sender: Any) {
        flowDisposable = selectedFlow
            .source
            .scan("") { (result, event) in
                [result, event]
                    .filter { $0.isEmpty == false }
                    .joined(separator: "\n\n")
            }
            .bind(to: flowOutputTextView.rx.text)
    }
    
    private var flowDisposable: Disposable? {
        didSet { oldValue?.dispose() }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpOutputTextView()
    }
    
    deinit {
        flowDisposable?.dispose()
    }
    
    // MARK: - Flow Picker

    @IBOutlet weak var startBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var flowPicker: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        flows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        flows[row].title
    }

    // MARK: - Output Text View

    @IBOutlet weak var flowOutputTextView: UITextView!
    
    private func setUpOutputTextView() {
        flowOutputTextView.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
    }
    
}

struct Flow {
    let title: String
    let source: Observable<String>
    
    init<O: ObservableConvertibleType>(title: String, source: () -> O) {
        self.title = title
        self.source = source()
            .asObservable()
            .map { String(rxModalDescribing: $0) }
            .materialize()
            .map { ".\($0)" }
    }
}

infix operator ..: MultiplicationPrecedence

@discardableResult
func .. <T>(object: T, configuration: (inout T) -> Void) -> T {
    var copy = object
    configuration(&copy)
    return copy
}
