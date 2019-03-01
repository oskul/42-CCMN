//
//  CorelationBarView.swift
//  CCMN
//
//  Created by Olga SKULSKA on 12/5/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import Foundation
import Foundation
import Charts

class CorelationBarView :  BarChartView, ChartViewDelegate{
    
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
        legend.drawInside = false

        legend.yOffset = 0.0
        legend.xOffset = 0.0
        legend.yEntrySpace = 10.0
        
        self.rightAxis.enabled = false
        self.rightAxis.drawLabelsEnabled = false
        self.rightAxis.drawGridLinesEnabled = true
        
        self.leftAxis.enabled = false
        self.leftAxis.drawAxisLineEnabled = false
        self.leftAxis.drawGridLinesEnabled = false
        
        self.xAxis.labelPosition = .bottom
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.drawGridLinesEnabled = true
        self.xAxis.centerAxisLabelsEnabled = true
        self.xAxis.enabled = true
        self.xAxis.granularityEnabled = true
        self.xAxis.axisMinimum = 0.0
        self.xAxis.labelPosition = .bottom
        self.xAxis.labelRotationAngle = -60
        self.rightAxis.drawLabelsEnabled = false
    }
    
    func setChart(dataPoints :   [(date: String, hour: String, nameArr: [String], valArr: [Int])]) {
        
        var dataEntriesConnected1: [BarChartDataEntry] = []
        var dataEntriesConnected2: [BarChartDataEntry] = []
        var dataEntriesConnected3: [BarChartDataEntry] = []
        var dataEntriesConnected4: [BarChartDataEntry] = []
        var dataEntriesConnected5: [BarChartDataEntry] = []
        var labelArr = [String]()
        
        for i in 0..<dataPoints.count{
            
            labelArr.append(dataPoints[i].date)
            
            if let index = dataPoints[i].nameArr.index(of: "THIRTY_TO_SIXTY_MINUTES"){
                let dataEntryConected1 = BarChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[index]))
                dataEntriesConnected1.append(dataEntryConected1)
                
            }else {
                let dataEntryConected1 = BarChartDataEntry(x: Double(i), y: Double(0))
                dataEntriesConnected1.append(dataEntryConected1)
                
            }
            if let index = dataPoints[i].nameArr.index(of: "EIGHT_PLUS_HOURS"){
                let dataEntryConected2 = BarChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[index]))
                dataEntriesConnected2.append(dataEntryConected2)
            }else {
                let dataEntryConected2 = BarChartDataEntry(x: Double(i), y: Double(0))
                dataEntriesConnected2.append(dataEntryConected2)
            }
            if let index = dataPoints[i].nameArr.index(of: "ONE_TO_FIVE_HOURS"){
                let dataEntryConected3 = BarChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[index]))
                dataEntriesConnected3.append(dataEntryConected3)
            }else {
                let dataEntryConected3 = BarChartDataEntry(x: Double(i), y: Double(0))
                dataEntriesConnected3.append(dataEntryConected3)
            }
            if let index = dataPoints[i].nameArr.index(of: "FIVE_TO_THIRTY_MINUTES"){
                let dataEntryConected4 = BarChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[index]))
                dataEntriesConnected4.append(dataEntryConected4)
            }else {
                let dataEntryConected4 = BarChartDataEntry(x: Double(i), y: Double(0))
                dataEntriesConnected4.append(dataEntryConected4)
            }
            if let index = dataPoints[i].nameArr.index(of: "FIVE_TO_EIGHT_HOURS"){
                let dataEntryConected5 = BarChartDataEntry(x: Double(i), y: Double(dataPoints[i].valArr[index]))
                dataEntriesConnected5.append(dataEntryConected5)
            }else {
                let dataEntryConected5 = BarChartDataEntry(x: Double(i), y: Double(0))
                dataEntriesConnected5.append(dataEntryConected5)
            }
        }
        
        let barChartDataSetConnected1 = BarChartDataSet(values: dataEntriesConnected1, label: "Thirty To Sixty Minutes")
        barChartDataSetConnected1.colors = [UIColor(red: 136/255, green: 77/255, blue: 255/255, alpha: 1)]
        
        let barChartDataSetConnected2 = BarChartDataSet(values: dataEntriesConnected2, label: "Eight Plus Hours")
        barChartDataSetConnected2.colors = [UIColor(red: 77/255, green: 136/255, blue: 255/255, alpha: 1)]
        
        let barChartDataSetConnected3 = BarChartDataSet(values: dataEntriesConnected3, label: "One To Five Hours")
        barChartDataSetConnected3.colors = [UIColor(red: 77/255, green: 255/255, blue: 195/255, alpha: 1)]
        
        let barChartDataSetConnected4 = BarChartDataSet(values: dataEntriesConnected4, label: "Five To Thirty Minutes")
        barChartDataSetConnected4.colors = [UIColor(red: 153/255, green: 255/255, blue: 51/255, alpha: 1)]
        
        let barChartDataSetConnected5 = BarChartDataSet(values: dataEntriesConnected5, label: "Five To Eight Hours")
        barChartDataSetConnected5.colors = [UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1)]
        
        let data: [IChartDataSet] = [barChartDataSetConnected1, barChartDataSetConnected2 ,barChartDataSetConnected3, barChartDataSetConnected4,barChartDataSetConnected5]
        let chartData = BarChartData(dataSets: data)
        let groupSpace = 0.15
        let barSpace = 0.02
        let barWidth = 0.15
        let groupCount = dataPoints.count
        let start = 0
        
        chartData.barWidth = barWidth;
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        self.xAxis.axisMaximum = Double(start) + gg * Double(groupCount)
        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        self.xAxis.labelCount = groupCount
        self.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values:labelArr)
        self.xAxis.granularity = self.xAxis.axisMaximum / Double(groupCount)
        
        self.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
        self.data = chartData
        self.notifyDataSetChanged()
    }
}
