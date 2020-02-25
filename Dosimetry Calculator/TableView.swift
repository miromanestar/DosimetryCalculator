//
//  TableView.swift
//  Dosimetry Calculator
//
//  Created by Miro Manestar on 2/28/18.
//  Copyright © 2018 Miro Manestar. All rights reserved.
//

import UIKit
import SwiftSpreadsheet

class DefaultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var infoLabel: UILabel!
}

class SpreadsheetCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var infoLabel: UILabel!
}

class ViewController: UIViewController {
    
    let defaultCellIdentifier = "DefaultCellIdentifier"
    let defaultSupplementaryViewIdentifier = "DefaultSupplementaryViewIdentifier"
    
    struct DecorationViewNames {
        static let topLeft = "SpreadsheetTopLeftDecorationView"
        static let topRight = "SpreadsheetTopRightDecorationView"
        static let bottomLeft = "SpreadsheetBottomLeftDecorationView"
        static let bottomRight = "SpreadsheetBottomRightDecorationView"
    }
    
    struct SupplementaryViewNames {
        static let left = "SpreadsheetLeftRowView"
        static let right = "SpreadsheetRightRowView"
        static let top = "SpreadsheetTopColumnView"
        static let bottom = "SpreadsheetBottomColumnView"
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var lines = ["You, shouldn't, be, seeing, this."]
    var xAxis: [String] = ["Nil"]
    var yAxis: [String] = ["Nil"]
    let dataArray: [[String]]
    let numberFormatter = NumberFormatter()
    var selection = Tables.selection
    let lightGreyColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    
    required init?(coder aDecoder: NSCoder) {
        var tableName = "Nil"
        
        switch selection {
        case 1: lines = sixMVTables.sixMvSCP.components(separatedBy: "\n"); tableName = "6MV SCP"
        case 2: lines = tenMVTables.tenMvSCP.components(separatedBy: "\n"); tableName = "10MV SCP"
        case 3: lines = eighttMVTables.eighttMvSCP.components(separatedBy: "\n"); tableName = "18MV SCP"
        case 4: lines = sixMVTables.sixMvPDD.components(separatedBy: "\n"); tableName = "6MV PDD"
        case 5: lines = tenMVTables.tenMvPDD.components(separatedBy: "\n"); tableName = "10MV PDD"
        case 6: lines = eighttMVTables.eighttMvPDD.components(separatedBy: "\n"); tableName = "18MV PDD"
        case 7: lines = sixMVTables.sixMVTMR.components(separatedBy: "\n"); tableName = "6MV TPR"
        case 8: lines = tenMVTables.tenMvTMR.components(separatedBy: "\n"); tableName = "10MV TPR"
        case 9: lines = eighttMVTables.eighttMvTMR.components(separatedBy: "\n"); tableName = "18MV TPR"
        default: lines = [ "Unable to, retrive table" ]
        }
        
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.minimumFractionDigits = 1
        
        //Setting up the data
        
        //Set x and y axis first
        let tempAxis = lines[0].components(separatedBy: ",")
        xAxis = Array<String>(tempAxis[1...])
        
        for line in lines[1...] {
            let columns = line.components(separatedBy: ",")
            let axis = columns[0]
            self.yAxis.append(axis)
        }
        
        //Then set the "meat" of the array
        var finalArray = [[String]]()
        
        for line in lines[1...] {
            let columns = line.components(separatedBy: ",")
            let noYAxis = columns[1...]
            let tempArr = Array<String>(noYAxis)
            //let testArray = columns.map { NSString(string: $0).doubleValue } //This would convert the strings to numbers
            finalArray.append(tempArr)
        }
        
        self.dataArray = finalArray
        super.init(coder: aDecoder)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: tableName, style: .plain, target: self, action: #selector(infoPage)) //Set button
    }
    
    @objc func infoPage() { //Go to info page 
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "goInfo", sender: self) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DecorationView Nibs
        let topLeftDecorationViewNib = UINib(nibName: DecorationViewNames.topLeft, bundle: nil)
        let topRightDecorationViewNib = UINib(nibName: DecorationViewNames.topRight, bundle: nil)
        let bottomLeftDecorationViewNib = UINib(nibName: DecorationViewNames.bottomLeft, bundle: nil)
        let bottomRightDecorationViewNib = UINib(nibName: DecorationViewNames.bottomRight, bundle: nil)
        
        //SupplementaryView Nibs
        let topSupplementaryViewNib = UINib(nibName: SupplementaryViewNames.top, bundle: nil)
        let bottomSupplementaryViewNib = UINib(nibName: SupplementaryViewNames.bottom, bundle: nil)
        let leftSupplementaryViewNib = UINib(nibName: SupplementaryViewNames.left, bundle: nil)
        let rightSupplementaryViewNib = UINib(nibName: SupplementaryViewNames.right, bundle: nil)
        
        //Setup Layout
        let layout = SpreadsheetLayout(delegate: self, topLeftDecorationViewNib: topLeftDecorationViewNib, topRightDecorationViewNib: topRightDecorationViewNib)
        
        /**        let layout = SpreadsheetLayout(delegate: self,
        topLeftDecorationViewNib: topLeftDecorationViewNib,
        topRightDecorationViewNib: topRightDecorationViewNib,
        bottomLeftDecorationViewNib: bottomLeftDecorationViewNib,
        bottomRightDecorationViewNib: bottomRightDecorationViewNib)
         */ //I don't want the big .xibs!
        
        //Default is true, set false here if you do not want some of these sides to remain sticky
        layout.stickyLeftRowHeader = true
        layout.stickyRightRowHeader = false
        layout.stickyTopColumnHeader = true
        layout.stickyBottomColumnFooter = false
        
        self.collectionView.collectionViewLayout = layout
        
        
        //Register Supplementary-Viewnibs for the given ViewKindTypes
        self.collectionView.register(leftSupplementaryViewNib, forSupplementaryViewOfKind: SpreadsheetLayout.ViewKindType.leftRowHeadline.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier)
        self.collectionView.register(rightSupplementaryViewNib, forSupplementaryViewOfKind: SpreadsheetLayout.ViewKindType.rightRowHeadline.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier)
        self.collectionView.register(topSupplementaryViewNib, forSupplementaryViewOfKind: SpreadsheetLayout.ViewKindType.topColumnHeader.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier)
        self.collectionView.register(bottomSupplementaryViewNib, forSupplementaryViewOfKind: SpreadsheetLayout.ViewKindType.bottomColumnFooter.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier)
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.defaultCellIdentifier, for: indexPath) as? DefaultCollectionViewCell else { fatalError("Invalid cell dequeued") }
        
        let value = self.dataArray[indexPath.section][indexPath.item]
        
        //Check if data contains digits or not
        let numbersRange = value.rangeOfCharacter(from: .decimalDigits)
        let lettersRange = value.rangeOfCharacter(from: .letters)
        let hasNumber = (numbersRange != nil)
        let hasLetters = (lettersRange != nil)
        let pureString = (hasLetters && hasNumber)
        
        switch pureString {
            case false: cell.infoLabel.text = value
            case true: cell.infoLabel.text = self.numberFormatter.string(from: NSNumber(value: NSString(string: value).doubleValue))
        }
        
        cell.backgroundColor = indexPath.item % 2 == 1 ? self.lightGreyColor : UIColor.white
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let viewKind = SpreadsheetLayout.ViewKindType(rawValue: kind) else { fatalError("View Kind not available for string: \(kind)") }
        
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: viewKind.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier, for: indexPath) as! SpreadsheetCollectionReusableView
        
        switch viewKind {
        case .leftRowHeadline:
            supplementaryView.infoLabel.text = yAxis[indexPath.section + 1]
        case .rightRowHeadline:
            supplementaryView.infoLabel.text = yAxis[indexPath.section + 1]
        case .topColumnHeader:
            supplementaryView.infoLabel.text = xAxis[indexPath.item]
            supplementaryView.backgroundColor = indexPath.item % 2 == 1 ? self.lightGreyColor : UIColor.white
        case .bottomColumnFooter:
            supplementaryView.infoLabel.text = xAxis[indexPath.item]
            supplementaryView.backgroundColor = indexPath.item % 2 == 1 ? self.lightGreyColor : UIColor.white
        default:
            break
        }
        
        return supplementaryView
    }
    
}

//MARK: - Spreadsheet Layout Delegate

extension ViewController: SpreadsheetLayoutDelegate {
    func spreadsheet(layout: SpreadsheetLayout, heightForRowsInSection section: Int) -> CGFloat {
        return 50
    }
    
    func widthsOfSideRowsInSpreadsheet(layout: SpreadsheetLayout) -> (left: CGFloat?, right: CGFloat?) {
        return (50, 50)
    }
    
    func spreadsheet(layout: SpreadsheetLayout, widthForColumnAtIndex index: Int) -> CGFloat {
        return 110
    }
    
    func heightsOfHeaderAndFooterColumnsInSpreadsheet(layout: SpreadsheetLayout) -> (headerHeight: CGFloat?, footerHeight: CGFloat?) {
        return (50, 50)
    }
}
