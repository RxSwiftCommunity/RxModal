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

class FlowsListViewController: UITableViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { _ in
            for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }, completion: nil)
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Flow.allFlows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FlowCell
        cell.flow = Flow.allFlows[indexPath.row]
        return cell
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard
            let navigationController = segue.destination as? UINavigationController,
            let flowDetail = navigationController.topViewController as? FlowDetailViewController,
            let cell = sender as? FlowCell else {
            return
        }
        
        flowDetail.flow = cell.flow
    }
}

final class FlowCell: UITableViewCell {
    var flow: Flow? {
        didSet {
            textLabel?.text = flow?.title
            accessoryType = .disclosureIndicator
        }
    }
}
