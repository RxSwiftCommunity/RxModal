//
//  FlowDetailViewController.swift
//  RxModalExample
//
//  Created by Jérôme Alves on 11/02/2021.
//

import UIKit
import Splash
import RxSwift

final class FlowDetailViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = flow?.title
        navigationItem.rightBarButtonItem = startBarButtonItem
        flowOutputTextView.backgroundColor = format.theme.backgroundColor
        flowOutputTextView.textColor = .white
        flowOutputTextView.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
    }
    
    deinit {
        flowDisposable?.dispose()
    }
    
    // MARK: - Output Text View

    @IBOutlet weak var flowOutputTextView: UITextView!

    private let format = AttributedStringOutputFormat(theme: .sundellsColors(withFont: Font(size: 17)))
    private lazy var highlighter = SyntaxHighlighter(format: format)

    // MARK: - Flow Lifecycle
    
    var flow: Flow?

    @IBOutlet weak var startBarButtonItem: UIBarButtonItem!
    
    @IBAction func startFlow(_ sender: Any) {
        flowDisposable = flow?
            .source(startBarButtonItem)
            .scan("") { (result, event) -> String in
                [result, event]
                    .filter { $0.isEmpty == false }
                    .joined(separator: "\n\n")
            }
            .map(highlighter.highlight)
            .bind(to: flowOutputTextView.rx.attributedText)
    }
    
    private var flowDisposable: Disposable? {
        didSet { oldValue?.dispose() }
    }

}
