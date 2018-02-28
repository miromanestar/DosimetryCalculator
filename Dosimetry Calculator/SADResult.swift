//
//  SADResult.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 12/30/17.
//  Copyright © 2017 Miro Manestar. All rights reserved.
//

import UIKit
class SADResult: UIViewController {
    
    @IBOutlet weak var SADPatientRef: UILabel!
    @IBOutlet weak var SADSiteRef: UILabel!
    @IBOutlet weak var SADScriptRef: UILabel!
    @IBOutlet weak var SADDepthRef: UILabel!
    @IBOutlet weak var SADLengthRef: UILabel!
    @IBOutlet weak var SADWidthRef: UILabel!
    @IBOutlet weak var SADSquareRef: UILabel!
    @IBOutlet weak var SADEnergy: UILabel!
    @IBOutlet weak var SADIso: UILabel!
    @IBOutlet weak var dpf: UILabel!
    @IBOutlet weak var scp: UILabel!
    @IBOutlet weak var tmr: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var isflabel: UILabel!
    
    var interpolateHeader: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Make sure name gets updated if user changes name from the results page
        name.text = "Calculated by: " + Settings.userName
    }
    override func didReceiveMemoryWarning() {
        
    }
    
    
    func setValues() {
        
        //Sets current date
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        
        let SADCalcs = SADCalculation.SADcalcResults
        if(SADCalcs.scriptInput != "" && SADCalcs.depthInput != "" && SADCalcs.length != "" && SADCalcs.width != "") {
            self.SADPatientRef.text = "Patient ID: " + SADCalcs.patientInput
            self.SADSiteRef.text = "Treatment Site: " + SADCalcs.siteInput
            self.SADScriptRef.text = "Script (cGy): " + SADCalcs.scriptInput
            self.SADDepthRef.text = "Depth: " + SADCalcs.depthInput
            self.SADLengthRef.text = "Length: " + SADCalcs.length
            self.SADWidthRef.text = "Width: " + SADCalcs.width
            self.SADSquareRef.text = "Equivalent Square: " + SADCalcs.squareInput
            self.SADEnergy.text = "Energy: " + SADCalcs.energyInput + "MV"
            self.SADIso.text = "ISO: " + String(Settings.machineISO)
            self.name.text = "Calculated by: " + Settings.userName
            self.time.text = formatter.string(from: currentDateTime)
            
            let doubleSCP = calculateSCP()
            let doubleTMR = calculateTMR()
            var isf = 0.0
            switch SADCalcs.energyInput {
                case "6": isf = 1.0323
                case "10": isf = 1.0445
                case "18": isf = 1.0671
                default: isf = 0.0
            }
            self.scp.text = "Sc,p: " + String(doubleSCP)
            self.tmr.text = "TPR: " + String(doubleTMR)
            self.dpf.text = "Dose per fraction: " + SADCalcs.scriptInput
            self.isflabel.text = "Inverse Square Factor: " + String(isf)
            
            if(doubleSCP != 0.0 && doubleTMR != 0.0 && isf != 0.0) {
                self.result.textColor = UIColor.black
                self.result.text = "Result: " + String(Int(round(Double(SADCalcs.scriptInput)!/(doubleSCP * doubleTMR * isf)))) + " mu's"
            } else {
                result.textColor = UIColor.red
                self.result.text = "One or more inputs are invalid."
            }
            
         } else {
            self.SADPatientRef.text = "One or more required fields is empty"; SADPatientRef.textColor = UIColor.red
            self.SADSiteRef.text = ""
            if(SADCalcs.scriptInput == "") { self.SADScriptRef.text = "Script is required"; SADScriptRef.textColor = UIColor.red } else { self.SADScriptRef.text = "Script (cGy): " + SADCalcs.scriptInput }
            if(SADCalcs.depthInput == "") { self.SADDepthRef.text = "Depth is required"; SADDepthRef.textColor = UIColor.red } else { self.SADDepthRef.text = "Depth: " + SADCalcs.depthInput }
            if(SADCalcs.length == "") { self.SADLengthRef.text = "Length is required"; SADLengthRef.textColor = UIColor.red } else { self.SADLengthRef.text = "Length: " + SADCalcs.length }
            if(SADCalcs.width == "" ) { self.SADWidthRef.text = "Width is required"; SADWidthRef.textColor = UIColor.red } else { self.SADWidthRef.text = "Width: " + SADCalcs.width }
            if(SADCalcs.squareInput == "" ) { self.SADSquareRef.text = "Equivalent Square not calcuable"; SADSquareRef.textColor = UIColor.red } else { self.SADSquareRef.text = " Equivalent Square: " + SADCalcs.squareInput }
        }
    }
    
    func calculateSCP() -> Double {
        let sixSCP = sixMVTables.sixMvSCP
        let tenSCP = tenMVTables.tenMvSCP
        let eighttSCP = eighttMVTables.eighttMvSCP
        let SADCalcs = SADCalculation.SADcalcResults
        var result: Double = 0
        var lines = sixSCP.components(separatedBy: "\n")
        
        if(SADCalcs.energyInput == "6") {
            lines = sixSCP.components(separatedBy: "\n")
        }
        if(SADCalcs.energyInput == "10") {
            lines = tenSCP.components(separatedBy: "\n")
        }
        if(SADCalcs.energyInput == "18") {
            lines = eighttSCP.components(separatedBy: "\n")
        }
        
        //For each line(row) of this csv table, determine if the field size matches the square input, and then return the scp value
        for line in lines[1...] {
            let columns = line.components(separatedBy: ",")
            let fieldSize = Double(columns[0])!
            let scp = Double(columns[1])!
            
            if(fieldSize == Double(SADCalcs.squareInput)) { result = scp }
        }
        return result
    }
    
    func calculateTMR() -> Double {
        let sixTMR = sixMVTables.sixMVTMR
        let tenTMR = tenMVTables.tenMvTMR
        let eighttTMR = eighttMVTables.eighttMvTMR
        let SADCalcs = SADCalculation.SADcalcResults
        var result: Double = 0
        
        var index1: Int = 0
        var finalIndex: Int = 0
        var lines = sixTMR.components(separatedBy: "\n")
        let headers = lines[0].components(separatedBy: ",")
        
        if(SADCalcs.energyInput == "6") {
            lines = sixTMR.components(separatedBy: "\n")
        }
        if(SADCalcs.energyInput == "10") {
            lines = tenTMR.components(separatedBy: "\n")
        }
        if(SADCalcs.energyInput == "18") {
            lines = eighttTMR.components(separatedBy: "\n")
        }
        
        //Determine which column has the right depth and size it as an index
        for header in headers[0...] {
            if(header != "Depth") {
                if(header == SADCalcs.squareInput) {
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
            let sqr = Double(SADCalcs.squareInput)!
            let depthInput = Double(SADCalcs.depthInput)!
            
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
                            if(Double(depth!) == Double(SADCalcs.depthInput)! && resultFound != true) {
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
                            if(Double(depth!) == Double(SADCalcs.depthInput)! && resultFound != true) {
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
            var localIndex: Int = 0
            var resultFound = false
            let depthInput = Double(SADCalcs.depthInput)!
            var testIndex: Int = 0
            
            for line in lines[1...] {
                let columns = line.components(separatedBy: ",") //Doesn't actually do "columns"... instead breaks every value in the current row into a separate value
                let depth = Double(columns[0]) //Isolates the first item of column... which are the fields below "depth"
                var nextColumn = lines[0].components(separatedBy: ",")
                var nextDepth = Double(nextColumn[1])
                
                //If depth matches input, go to item in column
                if(Double(depth!) == Double(SADCalcs.depthInput)) {
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
