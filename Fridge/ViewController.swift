//
//  ViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 11/30/20.
//

import RealmSwift
import UserNotifications
import SideMenu
import UIKit

class ToDoListItem: Object {
    @objc dynamic var item: String = ""
    @objc dynamic var date: Date = Date()
}

class InFrgListItem: Object {
    @objc dynamic var itemNum: String = ""
    @objc dynamic var note: String = ""
    @objc dynamic var outDate: String = ""
    @objc dynamic var inDate: String = ""
    @objc dynamic var expiration: String = ""
    @objc dynamic var iconUrl: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var mainUrl: String = ""
    @objc dynamic var item: String = ""
    @objc dynamic var date: Date = Date()
}

class ViewController: UIViewController, MenuControllerDelegate {
    
    private var sideMenu: SideMenuNavigationController?
    
    private let shoppingController = ShoppingViewController()
    private let firdgeController = InFridgeViewController()
    
    private let realm = try! Realm()
    private var data = [ToDoListItem]()
    private var inFrgdata = [InFrgListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // side menu
        let menu = MenuController(with: SideMenuItem.allCases)
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        self.navigationItem.rightBarButtonItem?.tintColor = .clear
        addChildControllers()
    }
    
    private func addChildControllers() {
        addChild(shoppingController)
        addChild(firdgeController)
        
        view.addSubview(shoppingController.view)
        view.addSubview(firdgeController.view)
        
        shoppingController.view.frame = view.bounds
        firdgeController.view.frame = view.bounds
        
        shoppingController.didMove(toParent: self)
        firdgeController.didMove(toParent: self)
        
        shoppingController.view.isHidden = true
        firdgeController.view.isHidden = true
    }
    
    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }
    
    func didSelectMenuItem(named: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)
            
            title = named.rawValue
            
            switch named {
            case .homePage:
                self.navigationItem.rightBarButtonItem?.tintColor = .clear
                shoppingController.view.isHidden = true
                firdgeController.view.isHidden = true
            case .shoppingList:
                self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
                shoppingController.view.isHidden = false
                firdgeController.view.isHidden = true
//                let controller = ShoppingViewController()
//                present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
            case .fridgeList:
                self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
                shoppingController.view.isHidden = true
                firdgeController.view.isHidden = false
            }

    }
    
    @IBAction func didTapAddButton() {
        if shoppingController.view.isHidden == false {
            guard let vc = storyboard?.instantiateViewController(identifier: "enter") as? EntryViewController else {
                return
            }

            vc.title = "New Item"
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.completionHandler = { title, date in
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
                        if success {
                            
                            let content = UNMutableNotificationContent()
                            content.title = title
                            content.sound = .default
                            content.body = "Please have a look"
                            
                            let targetDate = date
                            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],from: targetDate),repeats: false)

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
                
                    self.shoppingController.data = self.realm.objects(ToDoListItem.self).map({ $0 })
                    self.shoppingController.tableView.reloadData()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    @IBAction func didTapTest() {
//            // fire test notification
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
//                if success {
//                    // schedule test
//                    self.scheduleTest()
//                }
//                else if error != nil {
//                    print("error occered")
//                }
//            })
//        }
//
//        func  scheduleTest() {
//            let content = UNMutableNotificationContent()
//            content.title = "Hello World"
//            content.sound = .default
//            content.body = "My long body....."
//
//            let targetDate = Date().addingTimeInterval(5)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
//
//            let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
//                if error != nil {
//                    print("something went wrong")
//                }
//            })
//        }
    
}

