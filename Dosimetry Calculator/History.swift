//
//  SecondViewController.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 12/13/17.
//  Copyright © 2017 Miro Manestar. All rights reserved.
// Basically none of the code in here is mine... collected from various sources to achieve something that I have no idea how to do (Apple documentation is pretty bad)

import UIKit

class History: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Will store the history
    static public var historyArr = [FinalResults]()
    static public var arrSelected: Int = 0
    
    private var myArray = History.historyArr
    private var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myArray = History.historyArr
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        }
    
    //Clears and refreshes the view
    @IBAction func clear(_ sender: UIBarButtonItem) {
        History.historyArr = [FinalResults]()
        self.viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        myArray = (History.historyArr.reversed())
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        //Custom header
        headerView()
    }
    
    func headerView() {
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        let headerView: UIView = UIView.init(frame: CGRect(x: 1, y: 50, width: displayWidth, height: 40))
        headerView.backgroundColor = .none
        
        let labelView1: UILabel = UILabel.init(frame: CGRect(x: 10, y: 5, width: displayWidth/2, height: 24))
        labelView1.text = "Patient ID:"
        
        let labelView2: UILabel = UILabel.init(frame: CGRect(x: 4 + displayWidth/2, y: 5, width: displayWidth/2, height: 24))
        labelView2.text = "Treatment Site:"
        
        headerView.addSubview(labelView1)
        headerView.addSubview(labelView2)
        self.myTableView.tableHeaderView = headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Num: \(indexPath.row)")
        //print("Value: \(myArray[indexPath.row])")
        History.arrSelected = (History.historyArr.count - 1) - indexPath.row //Invert the index so that it selects the correct one in the reversed array
        viewSelection()
    }
    
    func viewSelection() {
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "viewHistory", sender: self) }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        if(cell.textLabel!.text == "") { cell.backgroundColor = .white }
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        let labelView1: UILabel = UILabel.init(frame: CGRect(x: 10, y: 5, width: displayWidth/2, height: 24))
        labelView1.text = "\(myArray[indexPath.row].patientID[11...])"
        
        let labelView2: UILabel = UILabel.init(frame: CGRect(x: 4 + displayWidth/2, y: 5, width: displayWidth/2, height: 24))
        labelView2.text = "\(myArray[indexPath.row].treatSite[16...])"
        
        cell.addSubview(labelView1)
        cell.addSubview(labelView2)
        return cell
    }
    
    //This function removes the additional lines in the table view
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let customView = UIView()
        let label = UILabel()
        label.text = "You shouldn't be seeing this"
        
        customView.addSubview(label)
        return customView
    }
}

extension String {
    func index(at offset: Int, from start: Index? = nil) -> Index? {
        return index(start ?? startIndex, offsetBy: offset, limitedBy: endIndex)
    }
    func character(at offset: Int) -> Character? {
        precondition(offset >= 0, "offset can't be negative")
        guard let index = index(at: offset) else { return nil }
        return self[index]
    }
    subscript(_ range: CountableRange<Int>) -> Substring {
        precondition(range.lowerBound >= 0, "lowerbound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        return self[start..<(index(at: range.count, from: start) ?? endIndex)]
    }
    subscript(_ range: CountableClosedRange<Int>) -> Substring {
        precondition(range.lowerBound >= 0, "lowerBound can't be negative")
        let start = index(at: range.lowerBound) ?? endIndex
        return self[start..<(index(at: range.count, from: start) ?? endIndex)]
    }
    subscript(_ range: PartialRangeUpTo<Int>) -> Substring {
        return prefix(range.upperBound)
    }
    subscript(_ range: PartialRangeThrough<Int>) -> Substring {
        return prefix(range.upperBound + 1)
    }
    subscript(_ range: PartialRangeFrom<Int>) -> Substring {
        return suffix(max(0, count-range.lowerBound))
    }
}

extension Substring {
    var string: String { return String(self) }
}
