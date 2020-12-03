//
//  ShoppingViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 11/30/20.
//

import RealmSwift
import UIKit

class ShoppingViewController: UITableViewController {
    private let realm = try! Realm()
    
    var data = [ToDoListItem](){
        didSet {
            // tableView.reloadData()
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data = realm.objects(ToDoListItem.self).map({ $0 })
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open the screen where we can see item info and delete
        let item = data[indexPath.row]
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "view") as? ViewViewController else {
            print("not found")
            return
        }

        vc.item = item
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.item
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell.textLabel?.text = data[indexPath.row].item
        
        let date = data[indexPath.row].date

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY"
        cell.detailTextLabel?.text = formatter.string(from: date)
        
        cell.textLabel?.font = UIFont(name: "Arial", size: 25)
        cell.detailTextLabel?.font = UIFont(name: "Arial", size: 15)
        
        return cell
    }
    
    func refresh() {
        data = realm.objects(ToDoListItem.self).map({ $0 })
        tableView.reloadData()
    }
}
