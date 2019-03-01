//
//  Parser.swift
//  CCMN
//
//  Created by Olga SKULSKA on 12/4/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import Foundation
import SwiftyJSON

class Parser{
    
    let timeDict : Dictionary<String, [String]> = ["Today": ["hourly/today", "today"] , "Yesterday": ["hourly/yesterday" , "yesterday"], "Last 3 days": ["hourly/3days", "3days"], "Last 7 days": ["daily/lastweek", "lastweek"], "Last 30 days": ["daily/lastmonth", "lastmonth"]]

    
    func parseActiveUserInfo(_ elem: (String, JSON), _ user : inout ActiveUser){
        
        user.currentFloor = elem.1["mapInfo"]["mapHierarchyString"].string
        user.macAddress = elem.1["macAddress"].string
        user.manufacturer = elem.1["manufacturer"].string
        user.mapCoordinate_x = elem.1["mapCoordinate"]["x"].double!
        user.mapCoordinate_y = elem.1["mapCoordinate"]["y"].double!
        user.networkStatus = elem.1["networkStatus"].string
    }

    func parseAllVisitor(period: String, json : JSON) ->  [(date : String, hour : String, val : Int)]{
        
        var conected  = [(date : String, hour : String, val : Int)]()
        var tuple = (date : "", hour : "", val : 0)
        let jsonSorted = json.sorted(by: <)
        
        switch period {
        case "Last 3 days":
            for (time, value) in jsonSorted{
                tuple.date = time
                for val in value{
                    tuple.hour = val.0
                    if let num = val.1.int {
                        tuple.val = num
                    }else {
                        tuple.val = 0
                    }
                    conected.append(tuple)
                }
            }
            conected.sortDay(arr: &conected)
        case "Last 7 days", "Last 30 days", "daily":
            for (time, value) in jsonSorted{
                tuple.date = time
                if let num = value.int {
                    tuple.val = num
                }else {
                   tuple.val = 0
                }
                conected.append(tuple)
            }
        case "corelation":
            for (time, value) in jsonSorted{
                tuple.date = formatDay(day: time)
                if let num = value.int {
                    tuple.val = num
                }else {
                    tuple.val = 0
                }
                conected.append(tuple)
            }
        default:
            for (time, value) in jsonSorted{
                tuple.hour = time
                if let num = value.int {
                    tuple.val = num
                }else {
                    tuple.val = 0
                }
                conected.append(tuple)
            }
            conected.sortDay(arr: &conected)
        }
        return conected
    }
    
    func parseDwellTime(period: String, json : JSON) ->  [(date: String , hour : String, nameArr : [String], valArr : [Int])]{
        
        var dwellTime  = [(date: String , hour : String, nameArr : [String], valArr : [Int])]()
        var dwellTuple = (date : "" , hour : "", nameArr : [String](), valArr : [Int]())
        
        let jsonSorted = json.sorted(by:  <)

        switch period {
        case "Last 3 days":
            for (date, val) in jsonSorted{
                dwellTuple.date = date
                for (d, v) in val{
                    dwellTuple.hour = d
                    dwellTuple.nameArr.removeAll()
                    dwellTuple.valArr.removeAll()
                    for (period, num) in v{
                        dwellTuple.nameArr.append(period)
                        dwellTuple.valArr.append(num.int!)
                    }
                    dwellTime.append(dwellTuple)
                }
            }
            dwellTime.sortDayAndHour(arr: &dwellTime)
        case "Last 7 days", "Last 30 days", "daily":
            for (date, val) in jsonSorted{
                dwellTuple.date = date
                dwellTuple.nameArr.removeAll()
                dwellTuple.valArr.removeAll() 
                for (d, v) in val{
                    
                    dwellTuple.nameArr.append(d)
                    dwellTuple.valArr.append(v.int!)
                }
                dwellTime.append(dwellTuple)
            }
        case "corelation":
            for (date, val) in jsonSorted{
                dwellTuple.date = formatDay(day: date)
                dwellTuple.nameArr.removeAll()
                dwellTuple.valArr.removeAll()
                for (d, v) in val{
                    
                    dwellTuple.nameArr.append(d)
                    dwellTuple.valArr.append(v.int!)
                }
                dwellTime.append(dwellTuple)
            }
        default:
            for (date, val) in jsonSorted{
                dwellTuple.hour = date
                dwellTuple.nameArr.removeAll()
                dwellTuple.valArr.removeAll()
                for (d, v) in val{
                    dwellTuple.nameArr.append(d)
                    dwellTuple.valArr.append(v.int!)
                }
                dwellTime.append(dwellTuple)
            }
            dwellTime.sortDayAndHour(arr: &dwellTime)
        }
        return dwellTime
    }

    func dayRangeOf(weekOfYear: Int, for date: Date) -> (String ,String)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let startComponents = DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: year)
        let startDate = calendar.date(from: startComponents)!
        let endComponents = DateComponents(day:7, second: -1)
        let endDate = calendar.date(byAdding: endComponents, to: startDate)!
        
        let startDate2 = dateFormatter.string(from: startDate)
        let endDate2 = dateFormatter.string(from: endDate)
        return (startDate2, endDate2)
    }
    
    func formatDay(day : String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: day) {
            dateFormatter.dateFormat = "EEEE"
            let weekday = dateFormatter.string(from: date)
            return weekday
        }
        return ""
    }
    
    func getDayRange() -> (String ,String){
        
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0)) - 1
        
        let startDay = dayRangeOf(weekOfYear: weekOfYear, for: Date()).0
        let endDay = dayRangeOf(weekOfYear: weekOfYear, for: Date()).1
        
        return(startDay , endDay)
    }
    
   
}

extension Array{
    
    func sortDay( arr: inout Array<(date : String, hour : String, val : Int)>){
        
        arr = arr.sorted {first,second in
            if first.date != second.date {
                return first.date < second.date
            } else {
                if Int(first.hour) != nil && Int(second.hour) != nil {
                    return Int(first.hour)! < Int(second.hour)!
                }
                return true
            }
        }
    }
    
    func sortDayAndHour( arr: inout Array<(date: String , hour : String, nameArr : [String], valArr : [Int])>){
        
        arr = arr.sorted {first,second in
            if first.date != second.date {
                return first.date < second.date
            } else {
                if Int(first.hour) != nil && Int(second.hour) != nil {
                    return Int(first.hour)! < Int(second.hour)!
                }
                return true
            }
        }
    }
    
}
