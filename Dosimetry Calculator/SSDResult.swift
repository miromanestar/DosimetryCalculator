//
//  SSDResult.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 12/29/17.
//  Copyright © 2017 Miro Manestar. All rights reserved.
//

import UIKit
class SSDResult: UIViewController {
    
    @IBOutlet weak var SSDPatientRef: UILabel!
    @IBOutlet weak var SSDSiteRef: UILabel!
    @IBOutlet weak var SSDScriptRef: UILabel!
    @IBOutlet weak var SSDDepthRef: UILabel!
    @IBOutlet weak var SSDLengthRef: UILabel!
    @IBOutlet weak var SSDWidthRef: UILabel!
    @IBOutlet weak var SSDSqrRef: UILabel!
    @IBOutlet weak var SSDEnergy: UILabel!
    @IBOutlet weak var SSDIso: UILabel!
    @IBOutlet weak var dpf: UILabel!
    @IBOutlet weak var scp: UILabel!
    @IBOutlet weak var pdd: UILabel!
    @IBOutlet weak var mu: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    
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
        
        let SSDCalcs = SSDCalculation.SSDcalcResults
        if(SSDCalcs.scriptInput != "" && SSDCalcs.depthInput != "" && SSDCalcs.length != "" && SSDCalcs.width != "") {
            self.SSDPatientRef.text = "Patient ID: " + SSDCalcs.patientInput
            self.SSDSiteRef.text = "Treatment Site: " + SSDCalcs.siteInput
            self.SSDScriptRef.text = "Script: " + SSDCalcs.scriptInput + "cGy"
            self.SSDDepthRef.text = "Depth: " + SSDCalcs.depthInput
            self.SSDLengthRef.text = "Length: " + SSDCalcs.length
            self.SSDWidthRef.text = "Width: " + SSDCalcs.width
            self.SSDSqrRef.text = "Equivalent Square: " + SSDCalcs.squareInput
            self.SSDEnergy.text = "Energy: " + SSDCalcs.energyInput + "MV"
            self.SSDIso.text = "ISO: " + String(Settings.machineISO)
            self.name.text = "Calculated by: " + Settings.userName
            self.date.text = formatter.string(from: currentDateTime)
            
            let doubleSCP = calculateSCP()
            let doublePDD = calculatePDD()
            self.scp.text = "Sc,p: " + String(doubleSCP)
            self.pdd.text = "PDD: " + String(doublePDD)
            self.dpf.text = "Dose per fraction: " + SSDCalcs.scriptInput
            
            //Ensures "zero" does not get returned as an answer
            if(doublePDD != 0 && doubleSCP != 0) {
                self.mu.textColor = UIColor.black
                self.mu.text = "Result: " + String(Int(round(Double(SSDCalcs.scriptInput)!/(doubleSCP * doublePDD)))) + " mu's"
            } else {
                mu.textColor = UIColor.red
                self.mu.text = "One or more inputs are invalid."
            }
            
        } else {
            self.SSDPatientRef.text = "One or more required fields is empty"; SSDPatientRef.textColor = UIColor.red
            self.SSDSiteRef.text = ""
            if(SSDCalcs.scriptInput == "") { self.SSDScriptRef.text = "Script is required"; SSDScriptRef.textColor = UIColor.red } else { self.SSDScriptRef.text = "Script (cGy): " + SSDCalcs.scriptInput }
            if(SSDCalcs.depthInput == "") { self.SSDDepthRef.text = "Depth is required"; SSDDepthRef.textColor = UIColor.red } else { self.SSDDepthRef.text = "Depth: " + SSDCalcs.depthInput }
            if(SSDCalcs.length == "") { self.SSDLengthRef.text = "Length is required"; SSDLengthRef.textColor = UIColor.red } else { self.SSDLengthRef.text = "Length: " + SSDCalcs.length }
            if(SSDCalcs.width == "" ) { self.SSDWidthRef.text = "Width is required"; SSDWidthRef.textColor = UIColor.red } else { self.SSDWidthRef.text = "Width: " + SSDCalcs.width }
            if(SSDCalcs.squareInput == "" ) { self.SSDSqrRef.text = "Equivalent Square not calcuable"; SSDSqrRef.textColor = UIColor.red } else { self.SSDSqrRef.text = " Equivalent Square: " + SSDCalcs.squareInput }
        }
    }
    
    func calculateSCP() -> Double {
        let sixSCP = sixMVTables.sixMvSCP
        let tenSCP = tenMVTables.tenMvSCP
        let eighttSCP = eighttMVTables.eighttMvSCP
        let SSDCalcs = SSDCalculation.SSDcalcResults
        var result: Double = 0
        var lines = sixSCP.components(separatedBy: "\n")

        if(SSDCalcs.energyInput == "6") {
            lines = sixSCP.components(separatedBy: "\n")
        }
        if(SSDCalcs.energyInput == "10") {
             lines = tenSCP.components(separatedBy: "\n")
        }
        if(SSDCalcs.energyInput == "18") {
             lines = eighttSCP.components(separatedBy: "\n")
        }
        
        //For each line(row) of this csv table, determine if the field size matches the square input, and then return the scp value
        for line in lines[1...] {
            let columns = line.components(separatedBy: ",")
            let fieldSize = Double(columns[0])!
            let scp = Double(columns[1])!
            
            if(fieldSize == Double(SSDCalcs.squareInput)) { result = scp }
        }
         return result
    }
    
    func calculatePDD() -> Double {
        let sixPDD = sixMVTables.sixMvPDD
        let tenPDD = tenMVTables.tenMvPDD
        let eighttPDD = eighttMVTables.eighttMvPDD
        let SSDCalcs = SSDCalculation.SSDcalcResults
        var result: Double = 0
        
        var index1: Int = 0
        var finalIndex: Int = 0
        var lines = sixPDD.components(separatedBy: "\n")
        let headers = lines[0].components(separatedBy: ",")
        
        if(SSDCalcs.energyInput == "6") {
            lines = sixPDD.components(separatedBy: "\n")
        }
        if(SSDCalcs.energyInput == "10") {
            lines = tenPDD.components(separatedBy: "\n")
        }
        if(SSDCalcs.energyInput == "18") {
            lines = eighttPDD.components(separatedBy: "\n")
        }
        
        //Determine which column has the right depth and size it as an index
        for header in headers[0...] {
            if(header != "Depth") {
                if(header == SSDCalcs.squareInput) {
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
            let sqr = Double(SSDCalcs.squareInput)!
            let depthInput = Double(SSDCalcs.depthInput)!
            
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
                            if(Double(depth!) == Double(SSDCalcs.depthInput)! && resultFound != true) {
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
                            if(Double(depth!) == Double(SSDCalcs.depthInput)! && resultFound != true) {
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
            let depthInput = Double(SSDCalcs.depthInput)!
            var testIndex: Int = 0
            
            for line in lines[1...] {
                let columns = line.components(separatedBy: ",") //Doesn't actually do "columns"... instead breaks every value in the current row into a separate value
                let depth = Double(columns[0]) //Isolates the first item of column... which are the fields below "depth"
                var nextColumn = lines[0].components(separatedBy: ",")
                var nextDepth = Double(nextColumn[1])
                
                //If depth matches input, go to item in column
                if(Double(depth!) == Double(SSDCalcs.depthInput)) {
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
