//
//  TableViewController.swift
//  CCMN
//
//  Created by Sergiy SHILINGOV on 11/26/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import UIKit
import CoreData
import SwiftMessageBar
import SVProgressHUD

class TableViewController: UITableViewController {

    var flrArr = [Floor]()
    var result = [Floor]()
    let db = CRUD(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    var floor : String = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        result = db.loadFloorsData()
        result = result.sorted(by: { $0.floorName! < $1.floorName! })
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "floorCell", for: indexPath)
        cell.textLabel?.text = result[indexPath.row].floorName!
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        floor = result[indexPath.row].floorName!
        performSegue(withIdentifier: "toExactFloor", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExactFloor" {
            let destinationVC = segue.destination as! FloorViewController
        
            if let floorInfo = db.getFloorsData(floor: floor){
                SVProgressHUD.show()
                self.view.isUserInteractionEnabled = false
                destinationVC.floorInfo = (floorInfo.floorName, floorInfo.img)
                SVProgressHUD.dismiss(withDelay: 0.1, completion: {
                    self.view.isUserInteractionEnabled = true
                })
            } else {
                
            }
        }
    }

}
