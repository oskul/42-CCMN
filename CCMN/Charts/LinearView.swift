//
//  LinearView.swift
//  CCMN
//
//  Created by Olga SKULSKA on 11/30/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import Foundation
import Charts
import SwiftyJSON

class LinearView : LineChartView{
    
    var setGradient = true
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        self.backgroundColor = .white
        self.chartDescription?.enabled = false

        let legend = self.legend
        legend.enabled = true
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.font = UIFont.systemFont(ofSize: 9)
        legend.drawInside = true
        legend.yOffset = 0.0;
        legend.xOffset = 0.0;
        legend.yEntrySpace = 0.0;
        
        self.rightAxis.enabled = false
        let yaxis = self.leftAxis
        yaxis.enabled = false
        yaxis.drawAxisLineEnabled = false
        yaxis.drawGridLinesEnabled = false

        let xaxis = self.xAxis
        xaxis.labelPosition = .bottom
        xaxis.drawAxisLineEnabled = true
        xaxis.drawGridLinesEnabled = true
        xaxis.centerAxisLabelsEnabled = true
        xaxis.enabled = true
        self.rightAxis.drawLabelsEnabled = false
        self.rightAxis.drawGridLinesEnabled = true
        self.xAxis.granularityEnabled = true
        self.xAxis.granularity = 1

    }

    func setChart(dataPoints : [(date: String, hour: String, nameArr: [String], valArr: [Int])], setGradient : Bool) {
        
        self.setGradient = setGradient

    
        var dataEntriesFirstTime: [ChartDataEntry] = []
        var dataEntriesDaily: [ChartDataEntry] = []
        var dataEntriesWeekly: [ChartDataEntry] = []
        var dataEntriesYestarday: [ChartDataEntry] = []
        var dataEntriesOccasional: [ChartDataEntry] = []
        var labelArr = [String]()

        for i in 0..<dataPoints.count {
            
            if let time = Int(dataPoints[i].hour){
                
                if time == 0 && !dataPoints[i].date.isEmpty{
                    labelArr.append(dataPoints[i].date)
                }else{
                    labelArr.append(time.makeHour(hour: time))
                }
            } else {
                labelArr.append(dataPoints[i].date)
            }
            
            let dataEntryFirstTime = ChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[0]))
            dataEntriesFirstTime.append(dataEntryFirstTime)

            let dataEntryDaily = ChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[1]))
            dataEntriesDaily.append(dataEntryDaily)

            let dataEntryWeekly = ChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[2]))
            dataEntriesWeekly.append(dataEntryWeekly)

            let dataEntryYestarday = ChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[3]))
            dataEntriesYestarday.append(dataEntryYestarday)

            let dataEntryOccasional = ChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[4]))
            dataEntriesOccasional.append(dataEntryOccasional)
        }

        let lineChartDataSetFirstTime = LineChartDataSet(values: dataEntriesFirstTime, label: dataPoints[0].nameArr[0].replacingOccurrences(of: "_", with: " ").lowercased().capitalized)
        lineChartDataSetFirstTime.colors = [UIColor(red: 136/255, green: 77/255, blue: 255/255, alpha: 1)]
        lineChartDataSetFirstTime.drawValuesEnabled = false
        self.setGradient(colorFrom: UIColor.purple.cgColor, colorTo: UIColor.clear.cgColor, line: lineChartDataSetFirstTime)

        let lineChartDataSetDaily = LineChartDataSet(values: dataEntriesDaily, label: dataPoints[0].nameArr[1].replacingOccurrences(of: "_", with: " ").lowercased().capitalized)
        lineChartDataSetDaily.colors = [UIColor(red: 77/255, green: 136/255, blue: 255/255, alpha: 1)]
        self.setGradient(colorFrom: UIColor.blue.cgColor, colorTo: UIColor.clear.cgColor, line: lineChartDataSetDaily)


        let lineChartDataSetWeekly = LineChartDataSet(values: dataEntriesWeekly, label: dataPoints[0].nameArr[2].replacingOccurrences(of: "_", with: " ").lowercased().capitalized)
        lineChartDataSetWeekly.colors = [UIColor(red: 77/255, green: 255/255, blue: 195/255, alpha: 1)]
        self.setGradient(colorFrom: UIColor.brown.cgColor, colorTo: UIColor.clear.cgColor, line: lineChartDataSetWeekly)

        let lineChartDataSetYestarday = LineChartDataSet(values: dataEntriesYestarday, label: dataPoints[0].nameArr[3].replacingOccurrences(of: "_", with: " ").lowercased().capitalized)
        lineChartDataSetYestarday.colors = [UIColor(red: 153/255, green: 255/255, blue: 51/255, alpha: 1)]
        self.setGradient(colorFrom: UIColor.blue.cgColor, colorTo: UIColor.clear.cgColor, line: lineChartDataSetYestarday)


        let lineChartDataSetOccasional = LineChartDataSet(values: dataEntriesOccasional, label: dataPoints[0].nameArr[4].replacingOccurrences(of: "_", with: " ").lowercased().capitalized)
        lineChartDataSetOccasional.colors = [UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1)]
        self.setGradient(colorFrom: UIColor.brown.cgColor, colorTo: UIColor.clear.cgColor, line: lineChartDataSetOccasional)

        let values : [LineChartDataSet] = [lineChartDataSetDaily, lineChartDataSetWeekly, lineChartDataSetFirstTime, lineChartDataSetYestarday, lineChartDataSetOccasional]
        let lineChartData = LineChartData(dataSets: values)
        self.data = lineChartData
        self.rightAxis.drawLabelsEnabled = false
        self.rightAxis.drawGridLinesEnabled = true
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values: labelArr)
        self.xAxis.drawGridLinesEnabled = false
    }
    
    func setGradient(colorFrom : CGColor, colorTo : CGColor, line: LineChartDataSet ){

        let gradientColors = [colorFrom, colorTo] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        line.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        line.drawFilledEnabled =  setGradient// Draw the Gradient
        line.circleRadius = 2.0
        line.circleHoleRadius = 1.0

    }
}


extension Int{
    
    func makeHour(hour: Int) -> String {
        let h = hour % 24
        
        if h == 0 {
            return "12am-1am"
        }
        else if h == 11 {
            return "11am-12pm"
        }
        else if h == 12 {
            return "12pm-1pm"
        }
        else if h == 23 {
            return "11pm-12am"
        }
        else if h < 11 {
            return "\(h)am-\(h+1)am"
        }
        else {
            return "\(h%12)pm-\(h%12+1)pm"
        }
    }
    
}
