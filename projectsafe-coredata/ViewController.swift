//
//  ViewController.swift
//  projectsafe-coredata
//
//  Created by noah macri on 5/10/2016.
//  Copyright © 2016 noah macri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let database = ProjectSafeDatabase()
    
    @IBAction func wipeDB(_ sender: AnyObject) {
        print("Wipe DB")
        database.wipeSavedData()
    }
    @IBAction func updateDB(_ sender: AnyObject) {
        print("Update DB")
        database.spawnRecords()
    }
    @IBAction func loadDB(_ sender: AnyObject) {
        print("Load DB")
        database.loadSavedData()
    }
    @IBAction func loadTable(_ sender: AnyObject) {
        print("Load for Table")
        database.loadForTable()
    }
    @IBAction func distinctDB(_ sender: AnyObject) {
        print("Distinct Test")
        database.testQuery()
    }
    @IBAction func predicates(_ sender: AnyObject) {
        print("Multiple predicates Test")
        database.testStackedPredicates()
    }
    @IBAction func listDistinct(_ sender: AnyObject) {
        print("Listing distinct values")
        database.testAllOptions(headers: ["activity","severity","year","location"])
    }
    @IBAction func tableTest(_ sender: AnyObject) {
        print("Table Test")
        database.tableTest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //database.loadForTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

