//
//  ViewController.swift
//  CCMN
//
//  Created by Olga SKULSKA on 11/21/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Alamofire
import SVProgressHUD

class ViewController: UIViewController {

    var json : JSON?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let db = CRUD(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    let makeRequestToCMX = Request(baseURL: "https://cisco-cmx.unit.ua/", user: "RO", passwd: "just4reading")
    let alert = UIAlertController(title: "Error", message: "Please, try again later", preferredStyle: UIAlertControllerStyle.alert)
    var userArray = [ActiveUser]()
    let parser = Parser()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(getActiveUserData), userInfo: nil, repeats: true)
        
        makeRequestToCMX.makeRequest(url: "api/config/v1/maps") { (success) -> Void in
            if success.error != nil {
                self.present(self.alert, animated: true, completion: nil)
            }else {
                self.getCampusData(jsonData: success)
                self.getActiveUserData()
            }
        }
    }
    
    
    @objc func getActiveUserData(){
        
        makeRequestToCMX.makeRequest(url: "api/location/v2/clients") { (response) in
            if response.error == nil{
                self.db.removeAllUserData()
                for elem in response{
                    
                    var user = ActiveUser(context: self.context)
                    self.parser.parseActiveUserInfo(elem, &user)
                    self.db.saveData()
                }
            }else {
                self.present(self.alert, animated: true, completion: nil)
            }
        }
    }
    
    func getCampusData(jsonData : JSON){
        
        var campusName : String
        var buildName : String
        
        self.db.removeAllFloorData()
        for elem in jsonData{
            for campuses in elem.1{
              campusName = campuses.1["name"].string!
                for build in campuses.1["buildingList"]{
                 buildName = build.1["name"].string!
                    for i in build.1["floorList"]{
                        let flr =  Floor(context: self.context)
                        flr.floorName = i.1["name"].string
                        flr.buildingName = buildName
                        flr.campusName = campusName
                        makeRequestToCMX.getImg(url: "api/config/v1/maps/image/\(flr.campusName!)/\(flr.buildingName!)/\(flr.floorName!)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! ,imgName: flr.floorName!, completion: { (imgPath) in
                            if !imgPath.isEmpty{
                                flr.img = imgPath
                            }else{
                                self.present(self.alert, animated: true, completion: nil)
                            }
                        })
                    }
                }
            }
        }
    }
    

   
}


