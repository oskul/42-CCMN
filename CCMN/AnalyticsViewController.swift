//
//  AnalyticsViewController.swift
//  CCMN
//
//  Created by Sergiy SHILINGOV on 11/29/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import Alamofire

class AnalyticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var corelationSingleView: BarView!
    @IBOutlet weak var corelationBarView: CorelationBarView!
    @IBOutlet weak var barView: BarView!
    @IBOutlet weak var linearView: LinearView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var gradientLine: LinearView!

    @IBOutlet weak var topDevice: UILabel!
    @IBOutlet weak var conversionRate: UILabel!
    @IBOutlet weak var peakHour: UILabel!
    @IBOutlet weak var averageDwell: UILabel!
    @IBOutlet weak var totalVis: UILabel!
    @IBOutlet weak var forecast: UILabel!
    
    var pickerData: [String] = [String]()
    var selected : String =  "Today"
    let makeRequest = Request(baseURL: "https://cisco-presence.unit.ua/", user: "RO", passwd: "Passw0rd")
    let parser = Parser()
    var forecastVal : Int = 0
    var param: Dictionary<String,String> = [:]
    let timeDict : Dictionary<String, [String]> = ["Today": ["hourly/today", "today"] , "Yesterday": ["hourly/yesterday" , "yesterday"], "Last 3 days": ["hourly/3days", "3days"], "Last 7 days": ["daily/lastweek", "lastweek"], "Last 30 days": ["daily/lastmonth", "lastmonth"]]
    let alert = UIAlertController(title: "Error", message: "Please, try again later", preferredStyle: UIAlertControllerStyle.alert)

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        pickerData = ["Today", "Yesterday", "Last 3 days", "Last 7 days", "Last 30 days"]
        self.picker.delegate = self
        self.picker.dataSource = self
        self.title = selected
        
        makeRequest.makeRequest(url: "api/config/v1/sites/") { (success) in
            if success.error == nil{
                for s in success{
                    let arr = self.timeDict["Today"]
                    self.param["siteId"] = s.1["aesUidString"].string!
                    self.makeAllRequest(dateParam: self.param, repeatVis: arr![0], kpi: arr![1], dwell: arr![0], time: "Today")
                    self.param["startDate"] = self.parser.getDayRange().0
                    self.param["endDate"] = self.parser.getDayRange().1
                    self.getCorelation(param: self.param, repeatVis: "", kpi: "", dwell: "", time: "corelation")
                    self.makeForcast(url: "api/presence/v1/connected/hourly", siteId: self.param["siteId"]!, key : 0, completion: { IntVal in
                        var text = "Conected ~" + String(IntVal/3) + " Passerby ~"
                        self.makeForcast(url: "api/presence/v1/passerby/hourly", siteId: self.param["siteId"]!, key : 0, completion: { IntVal in
                            text += String(IntVal/3)
                            self.forecast.text = text
                        })
                    })
                }
            } else{
                self.present(self.alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func showPopup(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let popup = sb.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        popup.delegate = self
        self.present(popup, animated: true)
    }
    
    
    private func makeForcast(url: String, siteId : String, key : Int, completion:@escaping (Int) -> Void) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
    
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hourString = formatter.string(from: Date())
        self.forecastVal = 0
        
        makeRequest.getParam(url: url, param: ["siteId" : siteId, "date" : dateFormatter.string(from: (Date().xWeeks(-3)))]) { (result) in
            
            if result.error == nil{
                let res1 = self.parser.parseAllVisitor(period: "today", json: result)
                for (_, hour, val) in res1{
                    if hourString == hour{
                        self.forecastVal += val
                    }
                }
                self.makeRequest.getParam(url: url, param: ["siteId" : siteId, "date" : dateFormatter.string(from: (Date().xWeeks(-2)))]) { (result) in
                    if result.error == nil{
                        let res2 = self.parser.parseAllVisitor(period: "today", json: result)
                        for (_, hour, val) in res2{
                            if hourString == hour{
                                self.forecastVal += val
                            }
                        }
                        self.makeRequest.getParam(url: url, param: ["siteId" : siteId, "date" : dateFormatter.string(from: (Date().xWeeks(-1)))]) { (result) in
                            if result.error == nil{
                                let res3 = self.parser.parseAllVisitor(period: "today", json: result)
                                for (_, hour, val) in res3{
                                    if hourString == hour{
                                        self.forecastVal += val
                                        completion(self.forecastVal)
                                    }
                                }
                            }
                        }
                    }
                }
            } else{
                self.present(self.alert, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
        
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        selected = pickerData[row]
        let arr = self.timeDict[selected]

        self.title = selected
        param.removeValue(forKey: "startDate")
        param.removeValue(forKey: "endDate")
        makeAllRequest(dateParam: param, repeatVis: arr![0], kpi: arr![1], dwell: arr![0], time: selected)
    }

    func getCorelation(param : Dictionary<String,String>, repeatVis : String, kpi : String, dwell : String, time : String){
        
        makeRequest.getParam(url: "api/presence/v1/connected/daily", param: param, completion: { (result) in
            if result.error == nil {
                let dwellTime = self.parser.parseAllVisitor(period: "Last 7 days", json: result)
                self.corelationSingleView.setChart(dataPoints: [dwellTime])
            }else {
                self.present(self.alert, animated: true, completion: nil)
            }
        })
        makeRequest.getParam(url: "api/presence/v1/dwell/dailyaverage", param: param, completion: { (result) in
            if result.error == nil {
                let dwellTime = self.parser.parseDwellTime(period: "corelation", json: result)
                self.corelationBarView.setChart(dataPoints: dwellTime)
            }else {
                self.present(self.alert, animated: true, completion: nil)
            }
        })

    }
    
    
    func makeAllRequest(dateParam : Dictionary<String,String>, repeatVis : String, kpi : String, dwell : String, time : String){
       
        var allUser = [[(date : String, hour : String, val : Int)]]()
        makeRequest.getParam(url: "api/presence/v1/connected/\(repeatVis)", param: dateParam, completion: { (result) in
            if result.error == nil {
                let connectedUser  = self.parser.parseAllVisitor(period: self.selected, json: result)
                allUser.append(connectedUser)
                self.makeRequest.getParam(url: "api/presence/v1/passerby/\(repeatVis)", param: dateParam, completion: { (result) in
                    if result.error == nil{

                        let passerbyUser = self.parser.parseAllVisitor(period: self.selected, json: result)
                        allUser.append(passerbyUser)
                        self.makeRequest.getParam(url: "api/presence/v1/visitor/\(repeatVis)", param: dateParam, completion: { (result) in
                            if result.error == nil{

                                let visitorUser = self.parser.parseAllVisitor(period: self.selected, json: result)
                                allUser.append(visitorUser)
                                self.barView.setChart(dataPoints: allUser)
                            }
                        })
                    }
                })
            }else{
                self.present(self.alert, animated: true, completion: nil)
            }
        })
        
        makeRequest.getParam(url: "api/presence/v1/kpisummary/\(kpi)", param: dateParam, completion: { (result) in
            if result.error == nil{
                self.totalVis.text = ("Total Visitors: \(result["totalVisitorCount"].int!)")
                self.conversionRate.text = "Conversion Rate: \(result["conversionRate"].int!)%"
                if let device = result["topManufacturers"]["name"].string {
                    self.topDevice.text = "Top Device : " + device
                }
                if let peak =  result["peakSummary"]["peakHour"].int{
                   self.peakHour.text =  "Peak Hour: " + peak.makeHour(hour: peak)
                }
                self.averageDwell.text = ("Average Dwell Time: \(result["averageDwell"].int!)%")
            }else {
                self.present(self.alert, animated: true, completion: nil)
            }
        })
        
        makeRequest.getParam(url: "api/presence/v1/dwell/\(dwell)", param: dateParam, completion: { (result) in
            if result.error == nil {
                let dwellTime = self.parser.parseDwellTime(period: self.selected, json: result)
                self.gradientLine.setChart(dataPoints: dwellTime, setGradient: true)
            }else {
                self.present(self.alert, animated: true, completion: nil)
            }
        })
        
        makeRequest.getParam(url: "api/presence/v1/repeatvisitors/\(repeatVis)", param: dateParam, completion: { (result) in
            if result.error == nil{
                let repeatVis = self.parser.parseDwellTime(period: self.selected, json: result)
                self.linearView.setChart(dataPoints: repeatVis, setGradient: false)
            }else {
                self.present(self.alert, animated: true, completion: nil)
            }
        })
    }
}


extension AnalyticsViewController : GetPickerData{
    
    func popupValueSelected(from: String, to: String) {
        self.title = "From: \(from) To: \(to)"
        self.param["startDate"] = from
        self.param["endDate"] = to
        makeAllRequest(dateParam: param, repeatVis: "daily", kpi: "", dwell: "daily", time: "daily")
    }
}

extension Date {
    
    func xDays(_ x: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: x, to: self)!
    }
    
    func xWeeks(_ x: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: x, to: self)!
    }
    
    var weeksHoursFromToday: DateComponents {
        return Calendar.current.dateComponents( [.weekOfYear, .hour], from: self, to: Date())
    }
    
    var relativeDateString: String {
        var result = ""
        if let weeks = weeksHoursFromToday.weekOfYear,
            let hours = weeksHoursFromToday.hour,
            weeks > 0 {
            result +=  "\(weeks) week"
            if weeks > 1 { result += "s" }
            if hours > 0 { result += " and " }
        }
        if let hours = weeksHoursFromToday.hour, hours > 0 {
            result +=  "\(hours) hour"
            if hours > 1 { result += "s" }
        }
        return result
    }
}
