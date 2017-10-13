//
//  ViewController.swift
//  ios_test
//
//  Created by Michael Westbrooks II on 10/12/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import Foundation

struct Obj {
    let userId : Int?
    let id : Int?
    let title : String?
    let completed: Bool?
}

class ViewController: UIViewController {

    @IBOutlet var mainTable: UITableView!
    var itemArray = [String: Any]()
    var uids = [Int]()
    
    //  MARK:- Manage selection data
    var selectedUser = Int()
    var selectedItem = [Obj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData(refresh: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "go" {
            self.navigationItem.title = ""
            let vc = segue.destination as! DetailViewController
            vc.todosList = self.selectedItem
            vc.user = self.selectedUser
        }
    }

    @IBAction func refresh(_ sender: Any) {
        print("Refreshed Clicked")
        retrieveData(refresh: true)
    }
    
    func retrieveData(refresh: Bool) {
        let queue = DispatchQueue(label: "com.ios_test.data", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: DispatchQueue.global())
        
        if refresh == true {
            //  MARK:- Clean Arrays
            uids.removeAll()
            itemArray.removeAll()
        }
        
        queue.async {
            
            let endpoint: String = "http://jsonplaceholder.typicode.com/todos"
            guard let url = URL(string: endpoint) else {
                print("Can't create url")
                return
            }
            
            let request: URLRequest = URLRequest(url: url)
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: {
                (data, response, error) in
                guard error == nil else {
                    print(error as Any)
                    return
                }
                print("URL Data fetch is running on = \(Thread.isMainThread ? "Main Thread":"Background Thread")")
                
                guard let responseData = data else {
                    print("No data")
                    return
                }
                
                do {
                    
                    //  MARK:- Serialize JSON
                    guard let rawjsonArray = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments)
                        as? [[String: Any]] else {
                            print("Error")
                            return
                    }
                    
                    //  MARK:- Set up raw array's and sets
                    var rawSet = Set<Int>()
                    var rawArray = [Obj]()
                    
                    //  MARK:- Sort data by UID
                    let jsonArray = rawjsonArray.sorted(by: { (json1, json2) -> Bool in
                        var returnVal = Bool()
                        if let uid1 = json1["userId"] as? Int, let uid2 = json2["userId"] as? Int {
                            returnVal = uid1 < uid2
                            
                            //  MARK:- Place uid into raw set
                            rawSet.insert(uid1)
                        }
                        return returnVal
                    })
                    
                    //  MARK:- Place data in array by ID
                    for json in jsonArray {
                        let item = json as [String: Any]
                        guard let UserID = item["userId"] as? Int, let ID = item["id"] as? Int, let Title = item["title"] as? String, let Completed = item["completed"] as? Bool else {
                            print("Error with data conversion")
                            return
                        }
                        
                        //  MARK:- Save data into struct and place into raw array
                        let obj = Obj(userId: UserID, id: ID, title: Title, completed: Completed)
                        rawArray.append(obj)
                    }
                    
                    DispatchQueue.main.async {
                        //  Mark:- Place raw set into array. Just 1 item so no need to define sort parameters.
                        self.uids = rawSet.sorted()
                        self.itemArray = rawArray.grouped(by: { (elem: Obj) -> String in
                            return "\(elem.userId!)"
                        })
                        self.mainTable.reloadData()
                    }
                    
                } catch {
                    print("Error with converting the data.")
                    return
                }
            })
            task.resume()
        }
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let item = self.uids[indexPath.row]
        let todos = self.itemArray[String(describing: item)] as! [Obj]
        var incompleteCount = 0
        for i in todos {
            if i.completed == false {
                incompleteCount += 1
            }
        }
        cell.textLabel?.text = "User \(item) has \(incompleteCount) incomplete tasks"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = self.uids[indexPath.row]
        selectedItem = self.itemArray[String(describing: self.uids[indexPath.row])] as! [Obj]
        self.performSegue(withIdentifier: "go", sender: self)
    }
}

extension Array {
    func grouped<T>(by criteria: (Element) -> T) -> [T: [Element]] {
        var groups = [T: [Element]]()
        for element in self {
            let key = criteria(element)
            if groups.keys.contains(key) == false {
                groups[key] = [Element]()
            }
            groups[key]?.append(element)
        }
        return groups
    }
}
