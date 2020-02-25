//
//  Main.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 3/7/18.
//  Copyright © 2018 Miro Manestar. All rights reserved.
//

import Foundation
import UIKit

class Main: UIViewController {
    @IBOutlet weak var ssdSelect: UIButton!
    @IBOutlet weak var sadSelect: UIButton!
    
    static public var whichCalcSelected: String = "None"
    static public var eula: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = UserDefaults.standard
        
        if(Main.eula == false) { //Only open during first launch (User Agreement)
            let alert = UIAlertController(title: "User Agreement", message: "This app is strictly for personal use.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: nil))
            self.present(alert, animated: true)
            Main.eula = true
            defaults.set(Main.eula, forKey: "eula")
        }
        
        
    }
    @IBAction func ssdClicked(_ sender: UIButton) {
        Main.whichCalcSelected = "ssd"
        viewTable()
    }
    
    @IBAction func sadClicked(_ sender: UIButton) {
        Main.whichCalcSelected = "sad"
        viewTable()
    }
    
    func viewTable() {
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "selectCalc", sender: self)
        }
    }
}
