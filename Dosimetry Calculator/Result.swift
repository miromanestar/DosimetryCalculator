//
//  SSDResult.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 12/29/17.
//  Copyright © 2017 Miro Manestar. All rights reserved.
//

import UIKit

//These are soley for the history tab...
struct FinalResults: Codable {
    var calcType: String = ""
    var patientID: String = ""
    var treatSite: String = ""
    var totalScript: String = ""
    var isf: String = ""
    var depth: String = ""
    var length: String = ""
    var width: String = ""
    var sqr: String = ""
    var energy: String = ""
    var iso: String = ""
    var dpf: String = ""
    var scp: String = ""
    var bigTable: String = ""
    var result: String = ""
    var date: String = ""
    var name: String = ""
}

class Result: UIViewController {
    
    //Placeholder values for history struct
    static public var finalResults = FinalResults(calcType: "Error", patientID: "", treatSite: "", totalScript: "", isf: "", depth: "", length: "", width: "", sqr: "", energy: "", iso: "", dpf: "", scp: "", bigTable: "", result: "", date: "", name: "")
    
    //Modify the labels
    @IBOutlet weak var labelRef: UILabel!
    @IBOutlet weak var PatientRef: UILabel!
    @IBOutlet weak var SiteRef: UILabel!
    @IBOutlet weak var ScriptRef: UILabel!
    @IBOutlet weak var isfRef: UILabel!
    @IBOutlet weak var DepthRef: UILabel!
    @IBOutlet weak var LengthRef: UILabel!
    @IBOutlet weak var WidthRef: UILabel!
    @IBOutlet weak var SqrRef: UILabel!
    @IBOutlet weak var Energy: UILabel!
    @IBOutlet weak var Iso: UILabel!
    @IBOutlet weak var dpf: UILabel!
    @IBOutlet weak var scp: UILabel!
    @IBOutlet weak var pdd: UILabel!
    @IBOutlet weak var mu: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    
    //These are for the little example
    @IBOutlet weak var dpfExam: UILabel!
    @IBOutlet weak var den: UILabel!
    
    var interpolateHeader: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValues()
        
        //Set the values for history struct now but only if there've been changes since the last input
        let testResult = Result.finalResults
        if(testResult.patientID != PatientRef.text! || testResult.treatSite != SiteRef.text! || testResult.totalScript != ScriptRef.text! || testResult.iso != Iso.text! || testResult.depth != DepthRef.text! || testResult.energy != Energy.text! || testResult.length != LengthRef.text! || testResult.width != WidthRef.text!) {
        
            Result.finalResults = FinalResults(calcType: labelRef.text!, patientID: PatientRef.text!, treatSite: SiteRef.text!, totalScript: ScriptRef.text!, isf: isfRef.text!, depth: DepthRef.text!, length: LengthRef.text!, width: WidthRef.text!, sqr: SqrRef.text!, energy: Energy.text!, iso: Iso.text!, dpf: dpf.text!, scp: scp.text!, bigTable: pdd.text!, result: mu.text!, date: date.text!, name: name.text!)
            History.historyArr.append(Result.finalResults)
        }
        
        if(Main.whichCalcSelected == "ssd") {
            self.dpfExam.text = "Dose per field"
            self.den.text = "PDD * Sc,p"
            self.labelRef.text = "Calculation Type: Source Surface Distance"
        }
        if(Main.whichCalcSelected == "sad") {
            self.dpfExam.text = "Dose per field"
            self.den.text = "TPR * ISF * Sc,p"
            self.labelRef.text = "Calculation Type: Source Axis Distance"
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Make sure name gets updated if user changes name from the results page
        name.text = "Calculated by: " + Settings.userName
    }
    
    //Does nothing
    override func didReceiveMemoryWarning() {
        
    }
    
    //Sets the value of the text on the results page
    func setValues() {
        
        //Sets the current date
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short //Stylizes the time to be displayed without seconds
        formatter.dateStyle = .long //Ensures a full date display i.e. January 28, 2018
        
        let calcInputs = InputPage.calcResults
        if(calcInputs.scriptInput != "" && calcInputs.depthInput != "" && calcInputs.length != "" && calcInputs.width != "") {
            self.PatientRef.text = "Patient ID: " + calcInputs.patientInput
            self.SiteRef.text = "Treatment Site: " + calcInputs.siteInput
            self.ScriptRef.text = "Total Script: " + calcInputs.scriptInput + "cGy" + " " + calcInputs.scriptChoiceInput
            self.DepthRef.text = "Depth: " + calcInputs.depthInput
            self.LengthRef.text = "Length: " + calcInputs.length
            self.WidthRef.text = "Width: " + calcInputs.width
            self.SqrRef.text = "Equivalent Square: " + calcInputs.squareInput
            self.Energy.text = "Energy: " + calcInputs.energyInput + "MV"
            self.Iso.text = "ISO: " + String(Settings.machineISO)
            self.name.text = "Calculated by: " + Settings.userName
            self.date.text = formatter.string(from: currentDateTime)
            
            let doubleSCP = calculateSCP()
            let doubleTable = calculateBigTables()
            
            var isf: Double = 0
            switch calcInputs.energyInput {
                case "6": isf = 1.0323
                case "10": isf = 1.0445
                case "18": isf = 1.0671
                default: isf = 0.0
            }
            self.isfRef.text = "Inverse Square Factor: " + String(isf)

            self.scp.text = "Sc,p: " + String(doubleSCP)
            if(Main.whichCalcSelected == "ssd") { self.pdd.text = "PDD: " + String(doubleTable); self.isfRef.text = "Inverse Square Factor: Not Applicable" }
            if(Main.whichCalcSelected == "sad") { self.pdd.text = "TPR: " + String(doubleTable); self.isfRef.text = "Inverse Square Factor: " + String(isf) }
            
            self.dpf.text = "Dose per field: " + calcInputs.scriptInput
            
            //If "opposed field" is chosen, use script divided by half
            var script: Double = 0
            if(calcInputs.scriptChoiceInput == "Single Field") {
                script = Double(calcInputs.scriptInput)!
                self.dpf.text = "Dose per field: " + calcInputs.scriptInput
            }
            if(calcInputs.scriptChoiceInput == "Opposed Field") {
                script = Double(calcInputs.scriptInput)!/2.0
                self.dpf.text = "Dose per field: " + String(Double(calcInputs.scriptInput)!/2.0)
            }
            //Ensures "zero" does not get returned as an answer
            if(doubleTable != 0 && doubleSCP != 0) {
                self.mu.textColor = UIColor.black
                switch Main.whichCalcSelected {
                    case "ssd": self.mu.text = "Result: " + String(Int(round(Double(calcInputs.scriptInput)!/(doubleSCP * doubleTable)))) + " mu's"
                    case "sad": self.mu.text = "Result: " + String(Int(round(script/(doubleSCP * doubleTable * isf)))) + " mu's"
                    default: self.mu.text = "Failure to calculate result"
                }
            } else {
                mu.textColor = UIColor.red
                self.mu.text = "One or more inputs are invalid."
            }
            
        } else {
            self.PatientRef.text = "One or more required fields is empty"; PatientRef.textColor = UIColor.red
            self.SiteRef.text = ""
            if(calcInputs.scriptInput == "") { self.ScriptRef.text = "Script is required"; ScriptRef.textColor = UIColor.red } else { self.ScriptRef.text = "Script (cGy): " + calcInputs.scriptInput }
            if(calcInputs.depthInput == "") { self.DepthRef.text = "Depth is required"; DepthRef.textColor = UIColor.red } else { self.DepthRef.text = "Depth: " + calcInputs.depthInput }
            if(calcInputs.length == "") { self.LengthRef.text = "Length is required"; LengthRef.textColor = UIColor.red } else { self.LengthRef.text = "Length: " + calcInputs.length }
            if(calcInputs.width == "" ) { self.WidthRef.text = "Width is required"; WidthRef.textColor = UIColor.red } else { self.WidthRef.text = "Width: " + calcInputs.width }
            if(calcInputs.squareInput == "" ) { self.SqrRef.text = "Equivalent Square not calcuable"; SqrRef.textColor = UIColor.red } else { self.SqrRef.text = " Equivalent Square: " + calcInputs.squareInput }
        }
    }
    
    func calculateSCP() -> Double {
        let sixSCP = sixMVTables.sixMvSCP
        let tenSCP = tenMVTables.tenMvSCP
        let eighttSCP = eighttMVTables.eighttMvSCP
        let calcInputs = InputPage.calcResults
        var result: Double = 0
        var lines = sixSCP.components(separatedBy: "\n")

        if(calcInputs.energyInput == "6") {
            lines = sixSCP.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "10") {
             lines = tenSCP.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "18") {
             lines = eighttSCP.components(separatedBy: "\n")
        }
        
        //For each line(row) of this csv table, determine if the field size matches the square input, and then return the scp value
        for line in lines[1...] {
            let columns = line.components(separatedBy: ",")
            let fieldSize = Double(columns[0])!
            let scp = Double(columns[1])!
            
            if(fieldSize == Double(calcInputs.squareInput)) { result = scp }
        }
         return result
    }
    
    func calculateBigTables() -> Double {
        let sixPDD = sixMVTables.sixMvPDD
        let tenPDD = tenMVTables.tenMvPDD
        let eighttPDD = eighttMVTables.eighttMvPDD
        let sixTPR = sixMVTables.sixMVTMR
        let tenTPR = tenMVTables.tenMvTMR
        let eighttTPR = eighttMVTables.eighttMvTMR
        let calcInputs = InputPage.calcResults
        var result: Double = 0
        
        var index1: Int = 0
        var finalIndex: Int = 0
        var lines = sixPDD.components(separatedBy: "\n")
        let headers = lines[0].components(separatedBy: ",")
        
        if(calcInputs.energyInput == "6" && Main.whichCalcSelected == "ssd") {
            lines = sixPDD.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "10" && Main.whichCalcSelected == "ssd") {
            lines = tenPDD.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "18" && Main.whichCalcSelected == "ssd") {
            lines = eighttPDD.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "6" && Main.whichCalcSelected == "sad") {
            lines = sixTPR.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "10" && Main.whichCalcSelected == "sad") {
            lines = tenTPR.components(separatedBy: "\n")
        }
        if(calcInputs.energyInput == "18" && Main.whichCalcSelected == "sad") {
            lines = eighttTPR.components(separatedBy: "\n")
        }
        
        //Determine which column has the right depth and size it as an index
        for header in headers[0...] {
            if(header != "Depth") {
                if(header == calcInputs.squareInput) {
                        finalIndex = index1 //Will use finalIndex to state which variable in the array is the correct one
                }
            }
            index1 += 1
        }
        
        //This if statement controls interpolation
        if(finalIndex == 0) {
            interpolateHeader = true
            
            var localIndex: Int = 0
            var nextValue: Double = 0
            var fieldSize: Double = 0
            var resultFound = false
            let sqr = Double(calcInputs.squareInput)!
            let depthInput = Double(calcInputs.depthInput)!
            
            if(resultFound != true) {
                for header in headers[0...] {
                    if(header != "Depth") {
                        fieldSize = Double(header)!
                    }
                    if(headers.count > localIndex + 1) { //Stops out of bounds exception
                        nextValue = Double(headers[localIndex + 1])!
                    }
                    
                    //Determines if we have arrived at the correct value for interpolation
                    if(nextValue - fieldSize == 1 && sqr == fieldSize + 0.5) {
                        
                        var testIndex: Int = 0 //Purely for depth interpolation
                        
                        for line in lines[1...] {
                            let columns = line.components(separatedBy: ",")
                            let depth = Double(columns[0])
                            
                            //Add the two values together and interpolate
                            if(Double(depth!) == Double(calcInputs.depthInput)! && resultFound != true) {
                                result = (Double(columns[localIndex])! + Double(columns[localIndex + 1])!)/2.0
                                resultFound = true
                            }
                        }
                        for line in lines[1...] {
                            let columns = line.components(separatedBy: ",")
                            let depth = Double(columns[0])
                            var nextColumn = lines[0].components(separatedBy: ",")
                            var nextDepth = Double(nextColumn[1])
                            //Ensure no out of bounds error is reached
                            if(lines.count > testIndex + 2) {
                                nextColumn = lines[testIndex + 2].components(separatedBy: ",")
                            }
                            
                            //Stop swift from trying to assign "Depth" to double value nextDepth
                            if(nextColumn[0] != "Depth") {nextDepth = Double(nextColumn[0])! }
                            
                            if(nextDepth! - depth! == 1 && depthInput == depth! + 0.5 && resultFound != true) {
                                let interpolatedVal1 = (Double(columns[localIndex])! + Double(columns[localIndex + 1])!)/2.0
                                let interpolatedVal2 = (Double(nextColumn[localIndex])! + Double(nextColumn[localIndex + 1])!)/2.0
                                result = (interpolatedVal1 + interpolatedVal2)/2.0
                                resultFound = true
                            }
                            if(nextDepth! - depth! == 2 && resultFound != true) {
                                if(depthInput == depth! + 1) {
                                    result = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    resultFound = true
                                } else if(depthInput == depth! + 0.5) {
                                    let interpolatedVal1 = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    let interpolatedVal2 = (Double(columns[localIndex])! + interpolatedVal1)/2.0
                                    result = (interpolatedVal2 + interpolatedVal1)/2.0
                                    resultFound = true
                                } else if(depthInput == depth! + 1.5) {
                                    let interpolatedVal1 = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    let interpolatedVal2 = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    result = (interpolatedVal1 + interpolatedVal2)/2.0
                                    resultFound = true
                                }
                            }
                            testIndex += 1
                        }
                    //More complicated interpolation since multiple interpolations are required to reach down to the exact half due to data gaps.
                    } else if(nextValue - fieldSize == 2 && (sqr == fieldSize + 1 || sqr == fieldSize + 0.5 || sqr == fieldSize + 1.5)) {
                        
                        var testIndex: Int = 0 //Purely for interpolation of the depth... and no real reason to change the name
                        
                        for line in lines[1...] {
                            let columns = line.components(separatedBy: ",")
                            let depth = Double(columns[0])
                            
                            //Determine whether we have arrived at the correct depth array
                            if(Double(depth!) == Double(calcInputs.depthInput)! && resultFound != true) {
                                //One interpolation
                                if(sqr == fieldSize + 1) {
                                    result = (Double(columns[localIndex])! + Double(columns[localIndex + 1])!)/2.0
                                    resultFound = true
                                    //Result gained from using interpolated value of interpolated value
                                } else if(sqr == fieldSize + 0.5) {
                                    let interpolatedValue = (Double(columns[localIndex])! + Double(columns[localIndex + 1])!)/2.0
                                    result = (Double(columns[localIndex])! + interpolatedValue)/2.0
                                    resultFound = true
                                    //Same as the "else if" statement just before, except if the value is on the higher end of the data gap (See #7 PDD table under tables to see the data gap
                                } else if(sqr == fieldSize + 1.5) {
                                    let interpolatedValue = (Double(columns[localIndex])! + Double(columns[localIndex + 1])!)/2.0
                                    result = (Double(columns[localIndex + 1])! + interpolatedValue)/2.0
                                    resultFound = true
                                }
                            }
                        }
                        for line in lines[1...] { //Interpolates depth if there are three possible + 0.5, + 1.5, or + 1
                            let columns = line.components(separatedBy: ",")
                            let depth = Double(columns[0])
                            var nextColumn = lines[0].components(separatedBy: ",")
                            var nextDepth = Double(nextColumn[1])
                            
                            //Ensure no out of bounds error is reached
                            if(lines.count > testIndex + 2) {
                                nextColumn = lines[testIndex + 2].components(separatedBy: ",")
                            }
                            
                            //Stop swift from trying to assign "Depth" to double value nextDepth
                            if(nextColumn[0] != "Depth") {nextDepth = Double(nextColumn[0])! }
                            
                            if(nextDepth! - depth! == 1 && depthInput == depth! + 0.5 && resultFound != true) {
                                let interpolatedVal1 = (Double(columns[localIndex])! + Double(columns[localIndex + 1])!)/2.0
                                let interpolatedVal2 = (Double(nextColumn[localIndex])! + Double(nextColumn[localIndex + 1])!)/2.0
                                result = (interpolatedVal1 + interpolatedVal2)/2.0
                                resultFound = true
                            }
                            
                            if(nextDepth! - depth! == 2 && resultFound != true) {
                                
                                if(depthInput == depth! + 1) {
                                    result = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    resultFound = true
                                } else if(depthInput == depth! + 0.5) {
                                    let interpolatedVal1 = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    let interpolatedVal2 = (Double(columns[localIndex])! + interpolatedVal1)/2.0
                                    result = (interpolatedVal2 + interpolatedVal1)/2.0
                                    resultFound = true
                                } else if(depthInput == depth! + 1.5) {
                                    let interpolatedVal1 = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    let interpolatedVal2 = (Double(columns[localIndex])! + Double(nextColumn[localIndex])!)/2.0
                                    result = (interpolatedVal1 + interpolatedVal2)/2.0
                                    resultFound = true
                                }
                            }
                            testIndex += 1
                        }
                    }
                    localIndex += 1 //What index iteration are we at? ~Didn't want to figure out how to use enumerator so... just used this.
                }
            }
        } else {
            //If no interpolation of fieldSize is required
            interpolateHeader = false
            var resultFound = false
            let depthInput = Double(calcInputs.depthInput)!
            var testIndex: Int = 0
            
            for line in lines[1...] {
                let columns = line.components(separatedBy: ",") //Doesn't actually do "columns"... instead breaks every value in the current row into a separate value
                let depth = Double(columns[0]) //Isolates the first item of column... which are the fields below "depth"
                var nextColumn = lines[0].components(separatedBy: ",")
                var nextDepth = Double(nextColumn[1])
                
                //If depth matches input, go to item in column
                if(Double(depth!) == Double(calcInputs.depthInput)) {
                    result = Double(columns[finalIndex])!
                }
                
                //Ensure no out of bounds error is reached
                if(lines.count > testIndex + 2) {
                    nextColumn = lines[testIndex + 2].components(separatedBy: ",")
                }
                
                //Stop swift from trying to assign "Depth" to double value nextDepth
                if(nextColumn[0] != "Depth") {nextDepth = Double(nextColumn[0])! }
                
                if(nextDepth! - depth! == 1 && depthInput == depth! + 0.5 && resultFound != true) {
                    let interpolatedVal1 = (Double(columns[finalIndex])! + Double(columns[finalIndex + 1])!)/2.0
                    let interpolatedVal2 = (Double(nextColumn[finalIndex])! + Double(nextColumn[finalIndex + 1])!)/2.0
                    result = (interpolatedVal1 + interpolatedVal2)/2.0
                    resultFound = true
                }
                
                if(nextDepth! - depth! == 2 && resultFound != true) {
                    
                    if(depthInput == depth! + 1) {
                        result = (Double(columns[finalIndex])! + Double(nextColumn[finalIndex])!)/2.0
                        resultFound = true
                    } else if(depthInput == depth! + 0.5) {
                        let interpolatedVal1 = (Double(columns[finalIndex])! + Double(nextColumn[finalIndex])!)/2.0
                        let interpolatedVal2 = (Double(columns[finalIndex])! + interpolatedVal1)/2.0
                        result = (interpolatedVal2 + interpolatedVal1)/2.0
                        resultFound = true
                    } else if(depthInput == depth! + 1.5) {
                        let interpolatedVal1 = (Double(columns[finalIndex])! + Double(nextColumn[finalIndex])!)/2.0
                        let interpolatedVal2 = (Double(columns[finalIndex])! + Double(nextColumn[finalIndex])!)/2.0
                        result = (interpolatedVal1 + interpolatedVal2)/2.0
                        resultFound = true
                    }
                }
                
                testIndex += 1
            }
        }
        return result
    }
}
