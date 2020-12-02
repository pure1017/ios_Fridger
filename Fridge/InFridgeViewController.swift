//
//  InFridgeViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 11/30/20.
//

import RealmSwift
import UIKit

class InFridgeViewController: UITableViewController {

    private let realm = try! Realm()
    
    var inFrgdata = [InFrgListItem](){
        didSet {
            // tableView.reloadData()
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        inFrgdata = realm.objects(InFrgListItem.self).map({ $0 })
        return inFrgdata.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open the screen where we can see item info and delete
        let item = inFrgdata[indexPath.row]
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "viewFrg") as? ViewFrgViewController else {
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
        cell.textLabel?.text = inFrgdata[indexPath.row].item
        
        let date = inFrgdata[indexPath.row].date

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY"
        cell.detailTextLabel?.text = formatter.string(from: date)
        
        cell.textLabel?.font = UIFont(name: "Arial", size: 25)
        cell.detailTextLabel?.font = UIFont(name: "Arial", size: 15)
        
        return cell
    }
    
    func refresh() {
        inFrgdata = realm.objects(InFrgListItem.self).map({ $0 })
        tableView.reloadData()
    }
}
