//
//  Settings.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 1/15/18.
//  Copyright © 2018 Miro Manestar. All rights reserved.
//

import Foundation
import UIKit

class Settings: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var machineSize: DecimalMinusTextField!
    @IBOutlet weak var name: UITextField!
    
    static public var machineISO = 100
    static public var userName = ""
    
    let sizes = ["Select an option", "100", "80"]
    
    //Sets number of columns in the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Sets the number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizes.count
    }
    
    //sets the pickerview to use the array "energies"
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sizes[row]
    }
    
    //sets text of the target UITextField to the chosen selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Won't allow "select an option" to be chosen
        if(sizes[row] != "Select an option") {
            machineSize.text = sizes[row]
        } else {
            //Do nothing if chosen value is not a number
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        //User picker view instead of decimal pad on machine size
        //Use UIPicker on energy instead of keyboard
        let sizePicker = UIPickerView()
        sizePicker.delegate = self
        machineSize.inputView = sizePicker
        
        //Will save your last entered value even when app closes
        if(defaults.integer(forKey: "userISO") != 0) {
            Settings.machineISO = defaults.integer(forKey: "userISO")
        } else {
            defaults.set(Settings.machineISO, forKey: "userISO")
        }
        machineSize.text = String(Settings.machineISO)
        
        if(defaults.string(forKey: "user") != nil) {
            Settings.userName = defaults.string(forKey: "user")!
        } else {
            defaults.set(Settings.userName, forKey: "user")
        }
        name.text = Settings.userName
    }
    
    @IBAction func isoChanged(_ sender: DecimalMinusTextField) {
        Settings.machineISO = Int(machineSize.text!)!
        let defaults = UserDefaults.standard
        defaults.set(Settings.machineISO, forKey: "userISO")
    }
    @IBAction func nameChanged(_ sender: UITextField) {
        Settings.userName = name.text!
        let defaults = UserDefaults.standard
        defaults.set(Settings.userName, forKey: "user")
    }
    
}
