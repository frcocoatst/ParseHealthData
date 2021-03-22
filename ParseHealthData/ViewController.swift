//
//  ViewController.swift
//  ParseHealthData
//
//  Created by Friedrich HAEUPL on 06.01.21.
//  Copyright © 2021 Friedrich HAEUPL. All rights reserved.
//

import Cocoa

class BloodGlucose{
    var endDate:String = String()
    var unit:String = String()
    var value:String = String()
}

/*
class StepCount{
    var endDate:String = String()
    var unit:String = String()
    var value:String = String()
}

class DistanceWalkingRunning{
    var endDate:String = String()
    var unit:String = String()
    var value:String = String()
}
*/

var BGs: [BloodGlucose] = []
var eName: String = String()
var bgType: String = String()
var bgDate: String = String()
var bgUnit = String()
var bgValue = String()

var record_glucose_found:Bool = false


class ViewController: NSViewController, XMLParserDelegate, NSTableViewDataSource   {
    
    // ---- Table View ---
    @IBOutlet weak var tableView:NSTableView!
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // return count
        return BGs.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if (tableColumn?.identifier)!.rawValue == "date" {
            return BGs[row].endDate
        }
        else if (tableColumn?.identifier)!.rawValue == "value" {
            return BGs[row].value
        }
        else if (tableColumn?.identifier)!.rawValue == "units" {
            return BGs[row].unit
        }
        else{
            return BGs[row].endDate
        }
    }
    
    // Blood Glucose Format:
    //  <Record type="HKQuantityTypeIdentifierBloodGlucose" sourceName="Health" sourceVersion="14.3" unit="mg/dL" creationDate="2020-12-20 13:38:59 +0100" startDate="2020-12-20 13:38:00 +0100" endDate="2020-12-20 13:38:00 +0100" value="104">
    //      <MetadataEntry key="HKWasUserEntered" value="1"/>
    //  </Record>
    //  <Record with attributes[key:value, ...] >
    //  </Record>
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        eName = elementName
        // print(eName)            // Record
        // print(attributeDict)    // Arributes
        
        if(elementName == "Record")
        {
            for string in attributeDict {
               
                switch string.key {
                
                case "type":
                    bgType = string.value
                    if (bgType == "HKQuantityTypeIdentifierBloodGlucose") {
                        record_glucose_found = true
                        print("HKQuantityTypeIdentifierBloodGlucose")
                    } else {
                        record_glucose_found = false
                    }
                    // print("type = \(bgType)")
                    break;
                
                case "unit":
                    if (record_glucose_found == true) {
                        bgUnit = string.value
                        print("unit = \(bgUnit)")
                    }
                    break
                case "endDate":
                    if (record_glucose_found == true) {
                        bgDate = string.value
                        print("endDate = \(bgDate)")
                    }
                    break
                case "value":
                    if (record_glucose_found == true) {
                        bgValue = string.value
                        print("value = \(bgValue)")
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        /* print(elementName) */
        if elementName == "Record" {
            if (record_glucose_found == true) {
                let bg = BloodGlucose()
                bg.endDate = bgDate
                bg.value = bgValue
                bg.unit = bgUnit
                
                BGs.append(bg)
            }
        }
        
        // print("elementName = \(elementName)")
        
    }
    
    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
         /*
         if (!data.isEmpty) {
            if (record_glucose_found == true) {
            if eName == "unit" {
                bgUnit += data
                // print(bgUnit)
            } else if eName == "endDate" {
                bgDate += data
                // print(bgDate)
            } else if eName == "value" {
                bgValue += data
                // print(bgValue)
            }
            }
         }
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self as? NSTableViewDelegate
        self.tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
        //
        guard let urlPath = Bundle.main.path(forResource: "Export", ofType: "xml") else {
            print("Can't load file")
            return
        }
        let url:URL = URL(fileURLWithPath: urlPath)
        
        if let parser = XMLParser(contentsOf: url) {
            print("XMLParser ")
            
            parser.delegate = self
            
            if !parser.parse(){
                print("Data Errors Exist:")
                let error = parser.parserError!
                print("Error Description:\(error.localizedDescription)")
                print("Line number: \(parser.lineNumber)")
            }
            else
            {
                print("Values:")
                // printout each book of books array
                for b in BGs
                {
                    print(b.endDate + " - " + b.unit + " - " + b.value)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

