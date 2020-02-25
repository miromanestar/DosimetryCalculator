//
//  Tables.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 2/28/18.
//  Copyright © 2018 Miro Manestar. All rights reserved.
//

import Foundation
import UIKit

class Tables: UIViewController {

    //SCP button references
    @IBOutlet weak var sixSCP: UIButton!
    @IBOutlet weak var tenSCP: UIButton!
    @IBOutlet weak var eighttSCP: UIButton!
    
    //PDD button references
    @IBOutlet weak var sixPDD: UIButton!
    @IBOutlet weak var tenPDD: UIButton!
    @IBOutlet weak var eighttPDD: UIButton!
    
    //TPR button references
    @IBOutlet weak var sixTPR: UIButton!
    @IBOutlet weak var tenTPR: UIButton!
    @IBOutlet weak var eighttTPR: UIButton!
    
    //What button did you select?
    static public var selection: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //SCP button pressed functions
    @IBAction func sixSCPTap(_ sender: UIButton) {
        Tables.selection = 1
        viewTable()
    }
    @IBAction func tenSCPTap(_ sender: UIButton) {
        Tables.selection = 2
        viewTable()
    }
    @IBAction func eighttSCPTap(_ sender: UIButton) {
        Tables.selection = 3
        viewTable()
    }
    
    //PDD button pressed functions
    @IBAction func sixPDDTap(_ sender: UIButton) {
        Tables.selection = 4
        viewTable()
    }
    @IBAction func tenPDDTap(_ sender: UIButton) {
        Tables.selection = 5
        viewTable()
    }
    @IBAction func eighttPDDTap(_ sender: UIButton) {
        Tables.selection = 6
        viewTable()
    }
    
    //TPR button button pressed functions
    @IBAction func sixTPRTap(_ sender: UIButton) {
        Tables.selection = 7
        viewTable()
    }
    @IBAction func tenTPRTap(_ sender: UIButton) {
        Tables.selection = 8
        viewTable()
    }
    @IBAction func eighttTPRTap(_ sender: UIButton) {
        Tables.selection = 9
        viewTable()
    }
    
    //Go to next page when segue is good
    func viewTable() {
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "viewTable", sender: self) }
        
    }
    
}
