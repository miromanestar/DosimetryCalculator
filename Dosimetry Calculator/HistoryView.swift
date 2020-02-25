//
//  HistoryView.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 3/8/18.
//  Copyright © 2018 Miro Manestar. All rights reserved.
//

import Foundation
import UIKit

class HistoryView: UIViewController {
    
    @IBOutlet weak var calcType: UILabel!
    @IBOutlet weak var patientID: UILabel!
    @IBOutlet weak var treatSite: UILabel!
    @IBOutlet weak var totalScript: UILabel!
    @IBOutlet weak var isf: UILabel!
    @IBOutlet weak var depth: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var width: UILabel!
    @IBOutlet weak var sqr: UILabel!
    @IBOutlet weak var energy: UILabel!
    @IBOutlet weak var iso: UILabel!
    @IBOutlet weak var dpf: UILabel!
    @IBOutlet weak var scp: UILabel!
    @IBOutlet weak var bigTable: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValues()
    }
    
    func setValues() {
        let finalValues = History.historyArr[History.arrSelected]
        
        self.calcType.text = finalValues.calcType
        self.patientID.text = finalValues.patientID
        self.treatSite.text = finalValues.treatSite
        self.totalScript.text = finalValues.totalScript
        self.isf.text = finalValues.isf
        self.depth.text = finalValues.depth
        self.length.text = finalValues.length
        self.width.text = finalValues.width
        self.sqr.text = finalValues.sqr
        self.energy.text = finalValues.energy
        self.iso.text = finalValues.iso
        self.dpf.text = finalValues.dpf
        self.scp.text = finalValues.scp
        self.bigTable.text = finalValues.bigTable
        self.result.text = finalValues.result
        self.date.text = finalValues.date
        self.name.text = finalValues.name
    }

}
