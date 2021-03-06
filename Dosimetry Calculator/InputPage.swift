//
//  SSDCalculation.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 12/28/17.
//  Copyright © 2017 Miro Manestar. All rights reserved.
//

import UIKit

class InputPage: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Sets number of columns in the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Sets the number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerSelected {
            case 0: return 0
            case 1: return scripts.count
            case 2: return energies.count
            default: return 0
        }
    }
    
    //sets the pickerview to use the array "energies"
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerSelected {
        case 0: return "ERROR"
        case 1: return scripts[row]
        case 2: return energies[row]
        default: return "ERROR"
        }
    }
    
    //sets text of the target UITextField to the chosen selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Won't allow "select an option" to be chosen
        if(energies[row] != "Select an option" && pickerSelected == 2) {
            energy.text = energies[row]
        }
        if(pickerSelected == 1 && scripts[row] != "Select an option") {
            scriptType.text = scripts[row]
        }
    }
    
    //Choices for the energy tab
    let energies = ["Select an option", "6", "10", "18"]
    let scripts = ["Select an option", "Single Field", "Opposed Field"]
    
    var pickerSelected = 0
    
    @IBAction func scriptSelected(_ sender: UITextField) {
        pickerSelected = 1
        multiPicker.selectRow(0, inComponent: 0, animated: true) //Resets index position of selection
        multiPicker.delegate = self //Refreshes the contents of the picker
    }
    @IBAction func energySelected(_ sender: UITextField) {
        pickerSelected = 2
        multiPicker.selectRow(0, inComponent: 0, animated: true) //Resets index position of selection
        multiPicker.delegate = self //Refreshes the contents of the picker
    }
    @IBAction func scriptExit(_ sender: UITextField) {
    }
    @IBAction func energyExit(_ sender: UITextField) {
    }
    
    @IBOutlet weak var patientID: UITextField!
    @IBOutlet weak var treatSite: UITextField!
    
    @IBOutlet weak var X1: DecimalMinusTextField!
    @IBOutlet weak var X2: DecimalMinusTextField!
    @IBOutlet weak var length: DecimalMinusTextField!
    
    @IBOutlet weak var Y1: DecimalMinusTextField!
    @IBOutlet weak var Y2: DecimalMinusTextField!
    @IBOutlet weak var width: DecimalMinusTextField!
    
    @IBOutlet weak var equivSqr: UITextField!
    @IBOutlet weak var scriptType: UITextField!
    
    var iso = Settings.machineISO
    var globalWidth: Double = 0
    var globalLength: Double = 0
    var equivalentSquareResult: Double = 0
    
    let multiPicker = UIPickerView() //Sets a variable for pickerview

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use UIPicker on energy  and scriptType instead of keyboard
        multiPicker.delegate = self
        energy.inputView = multiPicker
        scriptType.inputView = multiPicker

        //Enacts the changes brough by "textFieldShouldReturn" method
        self.treatSite.delegate = self
        self.patientID.delegate = self
        
        //Makes keyboard dissapear when you tap off of it
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        //This block of code controls the "done" button toolbar for specific text fields which do not use the default keyboard type
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        energy.inputAccessoryView = keyboardToolBar
        scriptType.inputAccessoryView = keyboardToolBar
        //end block of code
        
        //Manages certain aesthetics and UI elements based on either SSD or SAD calculations are used
        if(Main.whichCalcSelected == "ssd") {
            ssd.text = String(Settings.machineISO)
            self.title = "SSD Calculation"
            self.scriptType.text = "Single Field"
            self.scriptType.isUserInteractionEnabled = false
        } else { self.title = "SAD Calculation"; self.ssd.isUserInteractionEnabled = true }
    }
    
    //Always ensures ssd.text is showing the correct value
    override func viewDidAppear(_ animated: Bool) {
        if(Main.whichCalcSelected == "ssd") { ssd.text = String(Settings.machineISO) }
    }
    
    //Defines the behavior of the "done" button
    @objc func doneClicked() {
        energy.resignFirstResponder()
        scriptType.resignFirstResponder()
    }
    
    //These two methods makes keyboard dissapear when "done" key is pressed (Only for those viewcontrollers using the SDSCalculation class default keyboard type)
    func textFieldShouldReturn(_ treatSite: UITextField) -> Bool {
        treatSite.resignFirstResponder()
        return(true)
    }
    func textFieldShouldReturn1(_ patientID: UITextField) -> Bool {
        patientID.resignFirstResponder()
        return(true)
    }
    
    //Method doesn't currently do anything
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //These four methods calculate the length and width given user input
    @IBAction func addLengths(_ sender: DecimalMinusTextField) {
        let length1 = NSString(string: X1.text!).doubleValue
        let length2 = NSString(string: X2.text!).doubleValue
        if(length1 != 0.0 || length2 != 0.0) {
            length.text = String(length1 + length2)
            length.textColor = UIColor.black

        } else {
            length.text = ""
            length.textColor = UIColor.black

        }
        globalLength = length1 + length2
        equivalentSquare()
    }
    
    @IBAction func addLengths2(_ sender: DecimalMinusTextField) {
        let length1 = NSString(string: X1.text!).doubleValue
        let length2 = NSString(string: X2.text!).doubleValue
        if(length1 != 0.0 || length2 != 0.0) {
            length.text = String(length1 + length2)
            length.textColor = UIColor.black
        } else {
            length.text = ""
            length.textColor = UIColor.black
        }
        globalLength = length1 + length2
        equivalentSquare()
    }

    @IBAction func addWidths(_ sender: DecimalMinusTextField) {
        let width1 = NSString(string: Y1.text!).doubleValue
        let width2 = NSString(string: Y2.text!).doubleValue
        if(width1 != 0.0 || width2 != 0.0) {
            width.text = String(width1 + width2)
            width.textColor = UIColor.black

        } else {
            width.text = ""
            width.textColor = UIColor.black

        }        
        globalWidth = width1 + width2
        equivalentSquare()
    }
    
    @IBAction func addWidths2(_ sender: DecimalMinusTextField) {
        let width1 = NSString(string: Y1.text!).doubleValue
        let width2 = NSString(string: Y2.text!).doubleValue
        if(width1 != 0.0 || width2 != 0.0) {
            width.text = String(width1 + width2)
            width.textColor = UIColor.black

        } else {
            width.text = ""
            width.textColor = UIColor.black

        }
        globalWidth = width1 + width2
        equivalentSquare()
    }
    
    //Calculates the equivalent square according to the hospital formula of (2ab)/(a+b) and rounds to the nearest .5
    func equivalentSquare() {
        
        if(equivSqr.text == "Value too small" || equivSqr.text == "Value too large") {
            equivSqr.text = ""
            equivSqr.textColor = UIColor.black
        }
        
        var result: String = String((2 * globalWidth * globalLength)/(globalWidth + globalLength))
        if(result != "nan" && globalLength != 0.0 && globalWidth != 0.0) {
            let temp = round(10*Double(result)!)/10
            result = String(round(temp * 2.0)/2)
            equivSqr.text = result
        } else {
            equivSqr.text = ""
        }
        
        equivalentSquareResult = NSString(string: result).doubleValue
        
    }
    
    //These two methods update the equivalent square field if the length or width field is edited
    @IBAction func lengthChanged(_ sender: DecimalMinusTextField) {
        let fieldInput = String((NSString(string: length.text!).doubleValue)/2.0)
        if(NSString(string: length.text!).doubleValue != 0.0) {
            X1.text = fieldInput
            X2.text = fieldInput
        } else {
            X1.text = ""
            X2.text = ""
        }
        globalLength = NSString(string: length.text!).doubleValue
        equivalentSquare()
    }
    
    @IBAction func widthChanged(_ sender: DecimalMinusTextField) {
        let fieldInput1 = String((NSString(string: width.text!).doubleValue)/2.0)
        if(NSString(string: width.text!).doubleValue != 0.0) {
            Y1.text = fieldInput1
            Y2.text = fieldInput1
        } else {
            Y1.text = ""
            Y2.text = ""
        }
        globalWidth = NSString(string: width.text!).doubleValue
        equivalentSquare()
    }
    
    //Instance data not already assigned at the top
    @IBOutlet weak var script: DecimalMinusTextField!
    @IBOutlet weak var depth: DecimalMinusTextField!
    @IBOutlet weak var energy: UITextField!
    @IBOutlet weak var ssd: DecimalMinusTextField!
    
    //These two methods will affect each other as they correpond (Only for SAD calculation)
    @IBAction func ssdChanged(_ sender: DecimalMinusTextField) {
        if(Main.whichCalcSelected == "sad") {
            let result = String(iso - NSString(string: ssd.text!).integerValue)
            depth.textColor = UIColor.black
            depth.text = result
            if(ssd.text == "" ) { depth.text = "" }
        }
    }
    @IBAction func depthChanged(_ sender: DecimalMinusTextField) {
        if(Main.whichCalcSelected == "sad") {
            let result = String(iso - NSString(string: depth.text!).integerValue)
            ssd.textColor = UIColor.black
            ssd.text = result
            if(depth.text == "" ) { ssd.text = "" }
        }

    }
    
    //This method will round depth to the nearest half
    @IBAction func roundDepth(_ sender: DecimalMinusTextField) {
        let temp = NSString(string: depth.text!).doubleValue
        depth.text = String(round(temp * 2.0)/2)
    }
    
    //Assigns correct values for the results screen
    @IBAction func enterPressed(_ sender: Any) {
        let sqrVal = NSString(string: equivSqr.text!).doubleValue
        let depthVal = NSString(string: depth.text!).doubleValue
        
        //Obnoxiously specific conditional
        if((length.text != "" && width.text != "" && script.text != "" && scriptType.text != "" && (depth.text != "" && (depthVal <= 30.0 && depthVal >= 0.5)) && energy.text != "" && scriptType.text != "Field Required" && ssd.text != "" && (sqrVal <= 30.0 && sqrVal >= 5.0)) && (length.text != "Field Required" && width.text != "Field Required" && script.text != "Field Required" && (depth.text != "Field Required" || depth.text != "Value too small" || depth.text != "Value too large") && energy.text != "Field Required" && ssd.text != "Field Required" && (equivSqr.text != "Value too large" || equivSqr.text != "Value too small"))) {
        
            InputPage.calcResults = Calcs(patientInput: patientID.text!, siteInput: treatSite.text!, scriptInput: script.text!, scriptChoiceInput: scriptType.text!, depthInput: depth.text!, length: length.text!, width: width.text!, squareInput: equivSqr.text!, energyInput: energy.text!, ssdInput: ssd.text!)
            
                //Enter button only works if conditions are met in the above if statement
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "SSDSegue", sender: self) }
            
        } else {
            self.view.endEditing(true) //Deselect textfield if enter key pressed (Not required... just a quality of life thing)
            if(script.text == "") { script.text = "Field Required"; script.textColor = UIColor.red; }
            if(depth.text == "") { depth.text = "Field Required"; depth.textColor = UIColor.red }
            if(depthVal > 30.0) { depth.text = "Too Large"; depth.textColor = UIColor.red }
            if(depthVal < 0.5) { depth.text = "Too Small"; depth.textColor = UIColor.red }
            if(length.text == "") { length.text = "Field Required"; length.textColor = UIColor.red }
            if(width.text == "") { width.text = "Field Required"; width.textColor = UIColor.red }
            if(energy.text == "") { energy.text = "Field Required"; energy.textColor = UIColor.red }
            if(ssd.text == "") {ssd.text = "Required"; ssd.textColor = UIColor.red }
            if(scriptType.text == "") {scriptType.text = "Field Required"; scriptType.textColor = UIColor.red}
            
            if(equivSqr.textColor != UIColor.red) { //Stops the value from changing itself when it shouldn't
                if(sqrVal > 30.0) { equivSqr.text = "Value too large"; equivSqr.textColor = UIColor.red }
                if(sqrVal < 5.0) {equivSqr.text = "Value too small"; equivSqr.textColor = UIColor.red }
            }
        }
        
    }
   
    //These methods reset the text color and erase the value of the field on edit if it was previously empty when enter key was pressed
    @IBAction func scriptModified(_ sender: DecimalMinusTextField) {
        if(script.text == "Field Required") {
            script.text = ""
            script.textColor = UIColor.black
        }
    }
    @IBAction func scriptChanged(_ sender: DecimalMinusTextField) {
        //Doesn't do anything at the moment
    }
    @IBAction func scriptTypeModified(_ sender: UITextField) {
        if(scriptType.text == "Field Required") {
            scriptType.text = ""
            scriptType.textColor = UIColor.black
        }
    }
    @IBAction func scriptTypeChange(_ sender: UITextField) {
        //Doesn't do anything at the moment
    }
    @IBAction func depthModified(_ sender: DecimalMinusTextField) {
        if(depth.text == "Field Required" || depth.text == "Too Large" || depth.text == "Too Small") {
            depth.text = ""
            depth.textColor = UIColor.black
        }
    }
    @IBAction func lengthModified(_ sender: DecimalMinusTextField) {
        if(length.text == "Field Required") {
            length.text = ""
            length.textColor = UIColor.black
        }
    }
    @IBAction func widthModified(_ sender: DecimalMinusTextField) {
        if(width.text == "Field Required") {
            width.text = ""
            width.textColor = UIColor.black
        }
    }
    @IBAction func ssdModified(_ sender: DecimalMinusTextField) {
        if(ssd.text == "Required") {
            ssd.text = ""
            ssd.textColor = UIColor.black
        }
    }
    @IBAction func energyModified(_ sender: UITextField) {
        if(energy.text == "Field Required") {
            energy.text = ""
            energy.textColor = UIColor.black
        }
    }
    @IBAction func sqrModified(_ sender: Any) {
        //This method does nothing at the moment... may more may not use later
    }
    
    //Assigns placeholder values for the results screens
    static public var calcResults = Calcs(patientInput: "Error: Wrong struct values", siteInput: "Error", scriptInput: "", scriptChoiceInput: "", depthInput: "", length: "", width: "", squareInput: "", energyInput: "", ssdInput: "")
    
}

//Stores the data taken from the user input fields
struct Calcs {
    var patientInput: String = ""
    var siteInput: String = ""
    var scriptInput: String = ""
    var scriptChoiceInput: String = ""
    var depthInput: String = ""
    var length: String = ""
    var width: String = ""
    var squareInput: String = ""
    var energyInput: String = ""
    var ssdInput: String = ""
}
