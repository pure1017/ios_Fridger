//
//  InFridgeViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 11/30/20.
//

import RealmSwift
import UIKit

struct inFrgResponse: Codable {
    let itemNum: String
    let note: String
    let outDate: String
    let inDate: String
    let expiration: String
    let iconUrl: String
    let id: String
    let mainURL: String
    let itemName: String
    //let expiration: String
}

class InFridgeViewController: UITableViewController {

    private var tableData = [String]()
    private var item = ""
    private var date = ""
    private var itemNum = ""
    private var note = ""
    private var outDate = ""
    private var inDate = ""
    private var expiration = ""
    private var iconUrl = ""
    private var id = ""
    private var mainURL = ""
    private var itemName = ""
    
    private var result: [inFrgResponse] = []
    
    private let realm = try! Realm()
    
    var inFrgdata = [InFrgListItem](){
        didSet {
            // tableView.reloadData()
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
    
    override func viewDidLoad() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh() {
        // Re-fetch data
        fetchData()
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
    
    private func fetchData() {
        // clear database
        tableData.removeAll()
        realm.beginWrite()
        realm.delete(inFrgdata)
        try! realm.commitWrite()
        
        print("fetching")
        guard let url = URL(string: "https://wdrd6suw5h.execute-api.us-east-1.amazonaws.com/test/item") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {[weak self] data, _, error in
            guard let strongSelf = self, let data = data, error == nil else {
                return
            }
            
//            var result: [inFrgResponse]?
//            do {
//                result = try JSONDecoder().decode([inFrgResponse].self, from: data)
//            }
//            catch {
//                // handle error
//            }
            self?.result = try! JSONDecoder().decode([inFrgResponse].self, from: data)
            
//            guard let final = self?.result.first?.itemNum else{
//                return
//            }
//
//            strongSelf.tableData.append("item: \(final.itemName)")
//            strongSelf.tableData.append("date: \(final.expiration)")
            
            // add data to inFrgdata
//            print("http responce::::")
//            print(final)
//            self!.item = "final.itemName"
//            self!.date = "final.inDate"
            
            DispatchQueue.main.async {
                strongSelf.tableView.refreshControl?.endRefreshing()
                strongSelf.tableView.reloadData()
            }
        })
        
        for itemData in result {
            itemNum = itemData.itemNum
            note = itemData.note
            outDate = itemData.outDate
            inDate = itemData.inDate
            expiration = itemData.expiration
            iconUrl = itemData.iconUrl
            id = itemData.id
            mainURL = itemData.mainURL
            itemName = itemData.itemName
            
            realm.beginWrite()
            let newItem = InFrgListItem()
            newItem.date = Date() //////////need to edit
            newItem.item = itemName
            newItem.itemNum = itemNum
            newItem.note = note
            newItem.outDate = outDate
            newItem.inDate = inDate
            newItem.expiration = expiration
            newItem.iconUrl = iconUrl
            newItem.id = id
            newItem.mainUrl = mainURL
            
            realm.add(newItem)
            try! realm.commitWrite()
        }
        
        
        
        //setNotification(title: newItem.item, date: newItem.inDate)
        
        task.resume()
    }
    
    func setNotification(title: String, date: Date) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = "Please have a look"
        
                let targetDate = Calendar.current.date(byAdding: .day, value: 3, to: date)!
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
            
                let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    print("something went wrong")
                    }
                })
            }
            else if error != nil {
                print("error occered")
            }
        })
    }
}
