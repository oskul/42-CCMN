//
//  FloorViewController.swift
//  CCMN
//
//  Created by Olga SKULSKA on 11/23/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.

import UIKit
import CoreData
import SwiftMessageBar
import SVProgressHUD

class FloorViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var floor: UIScrollView!
    @IBOutlet weak var img: UIImageView!
    
    
    var userArray = [ActiveUser]()
    var tmpUsers = [ActiveUser]()
    var timerTest : Timer?
    var timerTestForSearch : Timer?
    var floorInfo : (String?, String?)
    var imgArr: [UIImageView] = []
    var currUserSet  = Set<String>()
    var oldUserSet  = Set<String>()
    let db = CRUD(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    var minZoom = 1.13
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setZoomScale()

        timerTest = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(printUser), userInfo: nil, repeats: true)
    
        searchBar.delegate = self
        floor.delegate = self
        
        img.image = UIImage(contentsOfFile: (floorInfo.1)!)
        floor.addSubview(img)
        floor.contentSize = img.frame.size
        floor.maximumZoomScale = 100

        searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchBar.placeholder = " Search by MAC-addres..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = UIColor.darkGray
        self.tableView.separatorStyle = .none
        
        let config = MessageBarConfig.Builder()
            .withInfoColor(.lightGray)
            .withTitleFont(.boldSystemFont(ofSize: 30))
            .withMessageFont(.systemFont(ofSize: 17))
            .build()
        SwiftMessageBar.setSharedConfig(config)
    }
    
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
        printUser()
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "macCell", for: indexPath)
        if let macAddr = tmpUsers[indexPath.row].macAddress {
            cell.textLabel?.text = "User #\(indexPath.row + 1) - \(macAddr)"
        } else {
            cell.textLabel?.text = "User #\(indexPath.row + 1) - Uploading MAC Address..."
        }
        return cell
    }
    
    @objc func printUser(){

        createNotification()
        getImgArr(arr: userArray)
        tableView.reloadData()
    }
    
    override func willMove(toParentViewController parent: UIViewController?)
    {
        SwiftMessageBar.sharedMessageBar.cancelAll(force: true)
        timerTest?.invalidate()
        timerTestForSearch?.invalidate()
        userArray.removeAll()
        
    }
}


extension FloorViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        timerTestForSearch = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(printUser), userInfo: nil, repeats: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.dismiss(withDelay: 6)
        self.view.isUserInteractionEnabled = true

        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let textField: UITextField = searchBar.value(forKey: "_searchField") as! UITextField
        textField.clearButtonMode = .never
        searchBar.showsCancelButton = true
        timerTest?.invalidate()
        timerTestForSearch?.invalidate()
        tmpUsers = [ActiveUser]()
        if !searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            for user in userArray {
                if user.macAddress != nil {
                    if (user.macAddress?.localizedCaseInsensitiveContains(searchBar.text!))! {
                        tmpUsers.append(user)
                    }
                }
            }
        }else {
            tmpUsers = userArray
        }
        getImgArr(arr: tmpUsers)
        tableView.reloadData()
    }
    
    private func setZoomScale() {
        
        var minZoom = min(self.view.bounds.size.width / img.bounds.size.width, self.view.bounds.size.height / img.bounds.size.height);
        if (minZoom > 1.0) {
            minZoom = 1.0;
        }
        
        floor.minimumZoomScale = minZoom;
        floor.zoomScale = minZoom;
    }
    
    private func createNotification(){
    
        currUserSet.removeAll()
        userArray = db.getUserForFloor(userFloor: floorInfo.0!)
        tmpUsers = userArray
        for user in userArray{
            currUserSet.insert(user.macAddress!)
        }
        let conectedUser  = currUserSet.subtracting(oldUserSet)
        if oldUserSet.count > 0 {
            for user in conectedUser{
                SwiftMessageBar.showMessageWithTitle(message: "MAC: \(user) now is on \(floorInfo.0!)", type: .info, duration: 2, dismiss: true)
            }
        }
        oldUserSet = currUserSet
    }
    
    private func getImgArr(arr : [ActiveUser]){
        
        for img in imgArr{
            
            img.isHidden = true
        }
        imgArr.removeAll()
        for user in arr{
            
            let frontimg = UIImage(named: "circle")
            let frontimgview = UIImageView(image: frontimg)
            frontimgview.tintColor = UIColor.blue
            frontimgview.frame = CGRect(x: user.mapCoordinate_x * minZoom, y: user.mapCoordinate_y * minZoom, width: 15, height: 15)
            frontimgview.accessibilityIdentifier = user.macAddress
            img.addSubview(frontimgview)
            imgArr.append(frontimgview)
        }
    }
    
}










