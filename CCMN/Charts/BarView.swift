//
//  barView.swift
//  CCMN
//
//  Created by Olga SKULSKA on 11/30/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import Foundation
import Charts

class BarView :  BarChartView, ChartViewDelegate{
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = .white
        self.chartDescription?.enabled = false
        self.delegate = self
        
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
        xaxis.centerAxisLabelsEnabled = false
        xaxis.granularityEnabled = true
        xaxis.enabled = true
        xaxis.forceLabelsEnabled = true
        self.xAxis.axisMinimum = 0.0
        self.xAxis.labelPosition = .bottom
        self.xAxis.labelRotationAngle = -60
        self.rightAxis.drawLabelsEnabled = false
        self.xAxis.granularityEnabled = true
        
    }
    
    func setChart(dataPoints :  [[(date : String, hour : String, val : Int)]]) {

        var dataEntriesConnected: [BarChartDataEntry] = []
        var dataEntriesVisitor: [BarChartDataEntry] = []
        var dataEntriesPasserby: [BarChartDataEntry] = []
        var labelArr = [String]()

        var minVal = dataPoints[0].count
        if dataPoints.count > 1{
            minVal = min(min(dataPoints[0].count, dataPoints[1].count), dataPoints[2].count)
        }

        for i in 0..<minVal{
            
            if let time = Int(dataPoints[0][i].hour){
                
                if time == 0 && !dataPoints[0][i].date.isEmpty{
                 labelArr.append(dataPoints[0][i].date)
                }else {
                    labelArr.append(time.makeHour(hour: time))
                }
            }else {
              labelArr.append(dataPoints[0][i].date)

            }
            
            let dataEntryConected = BarChartDataEntry(x: Double(i), y: Double(dataPoints[0][i].val))
            dataEntriesConnected.append(dataEntryConected)
            
            if  dataPoints.count > 1{
            let dataEntryPasserby = BarChartDataEntry(x: Double(i), y:  Double(dataPoints[1][i].val))
            dataEntriesPasserby.append(dataEntryPasserby)

            let dataEntryVisitor = BarChartDataEntry(x: Double(i), y:  Double(dataPoints[2][i].val))
                dataEntriesVisitor.append(dataEntryVisitor)}
        }
    
        let barChartDataSetConnected = BarChartDataSet(values: dataEntriesConnected, label: "Coonected users")
        barChartDataSetConnected.colors = [UIColor(red: 26/255, green: 102/255, blue: 255/255, alpha: 1)]

        let barChartDataSetVisitor = BarChartDataSet(values: dataEntriesVisitor, label: "Visitor")
        barChartDataSetVisitor.colors = [UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1)]

        let barChartDataSetPasserby = BarChartDataSet(values: dataEntriesPasserby, label: "Passerby")
        barChartDataSetPasserby.colors = [UIColor(red: 153/255, green: 255/255, blue: 204/255, alpha: 1)]

        let data: [IChartDataSet] = [barChartDataSetConnected, barChartDataSetVisitor, barChartDataSetPasserby]
        let chartData = BarChartData(dataSets: data)
        let groupSpace = 0.25
        let barSpace = 0.05
        let barWidth = 0.2

        let groupCount = dataPoints[0].count
        let start = 0

        chartData.barWidth = barWidth;
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        self.xAxis.axisMaximum = Double(start) + gg * Double(groupCount)
        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)

        self.xAxis.labelCount = groupCount
        self.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values:labelArr)
        self.xAxis.granularity = self.xAxis.axisMaximum / Double(groupCount)

        self.notifyDataSetChanged()
        self.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
        self.data = chartData
    }
}
