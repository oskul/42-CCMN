//
//  DatePickerViewController.swift
//  CCMN
//
//  Created by Olga SKULSKA on 12/6/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import UIKit

protocol GetPickerData {
    func popupValueSelected(from : String, to : String)
}

class DatePickerViewController: UIViewController {

    @IBOutlet weak var from: UIDatePicker!
    @IBOutlet weak var to: UIDatePicker!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var saveBt: UIButton!
    
    let dateFormatter = DateFormatter()
    var delegate: GetPickerData?
    var fromDate = Date()
    var toDate = Date()
    
    private func formatLabel(currDate: Date, label: UILabel, text: String){
        
        saveBt.isEnabled = true
        let strDate = dateFormatter.string(from: currDate)
        label.text = text + strDate
    }
    
    private func setDatePicker(){
        
        from.datePickerMode = .date
        to.datePickerMode = .date
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        from.minimumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        from.maximumDate = Date()
        to.maximumDate = Date()
        to.minimumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setDatePicker()
        formatLabel(currDate: Date(), label: fromLabel, text: "From: ")
        formatLabel(currDate: Date(), label: toLabel, text: "To: ")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func checkData(_ sender: Any) {
        
        if (fromDate > toDate){
            saveBt.isEnabled = false
            let alert = UIAlertController(title: "Error, not correct data format", message: "Please, change your search request", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
            dateFormatter.dateFormat = "yyyy-MM-dd"
            delegate?.popupValueSelected(from: dateFormatter.string(from: fromDate), to: dateFormatter.string(from: toDate))
            dismiss(animated: true)
        }
    }
    
    @IBAction func choseFromDate(_ sender: Any) {
        
        fromDate = from.date
        formatLabel(currDate: fromDate, label: fromLabel, text: "From: ")
    }
    
    @IBAction func choseToDate(_ sender: Any) {
        
        toDate = to.date
        formatLabel(currDate: toDate, label: toLabel, text: "To: ")
    }
    
}
