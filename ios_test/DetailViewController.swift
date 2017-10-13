//
//  DetailViewController.swift
//  ios_test
//
//  Created by Michael Westbrooks II on 10/13/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var completionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
    }
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mainTable: UITableView!
    var user = Int()
    var todosList = [Obj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "User: \(user)"
    }

}

extension DetailViewController: UITableViewDelegate {
    
}

extension DetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todosList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        let item = self.todosList[indexPath.row] as Obj
        cell.titleLabel.text = item.title
        
        switch item.completed! as Bool {
        case true:
            cell.completionLabel?.textColor = .green
            cell.completionLabel?.text = "COMPLETED"
        case false:
            cell.completionLabel?.textColor = .red
            cell.completionLabel?.text = "INCOMPLETE"
        }
        
        return cell
    }
    
}
