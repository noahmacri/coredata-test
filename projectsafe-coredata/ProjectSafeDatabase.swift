//
//  ProjectSafeDatabase.swift
//  projectsafe-coredata
//
//  Created by noah macri on 5/10/2016.
//  Copyright © 2016 noah macri. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class ProjectSafeDatabase: UITableViewController, NSFetchedResultsControllerDelegate
{
    //var container: NSPersistentContainer!
    let container = AppDelegate().persistentContainer   // Main coredata container

    var fetchedResultsController: NSFetchedResultsController<Incident>!
    //var predicate: NSPredicate?
    
    public override func viewDidLoad() {
        loadForTable()  //Does this do anything???
    }
    
    // Saves any chanes to the coredata store
    func saveContext()
    {
        if container.viewContext.hasChanges
        {
            do
            {
                try container.viewContext.save()
            }
            catch
            {
                print("Error occured while saving: \(error)")
            }
        }
    }
    
    // Inserting new records into database
    func spawnRecords()
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print(path)
        let update = try! String(contentsOfFile: "\(path)/update.csv")  // Does not catch error if not exist
        
        let rows = CSwiftV(with: update)
        
        // Insert asynchronously - like openmp
        DispatchQueue.main.async {
            [unowned self] in
            for row in rows.keyedRows!
            {
                // This creates a new object inside the coredata database
                let incident = Incident(context: self.container.viewContext)
                self.configure(incident: incident, row: row, headers: rows.headers)
            }
            
            // Saved into database
            self.saveContext()
            self.loadSavedData()
        }
    }
    
    // Load values into incident object
    func configure(incident: Incident, row: [String: String], headers: [String])
    {
        incident.id = row["ID"]
        incident.title = row["Title"]
        incident.activity = row["Activity"]
        incident.severity = row["Severity"]
        incident.year = row["Year"]
        incident.location = row["Location"]
        
        //var consequences = [String]()
        
        // Bad way to load things in
        for i in 1...3
        {
            if row["Consequence\(i)"] != nil
            {
                //consequences.append(row["Consequence\(i)"]!)
                let tag = Tags(context: self.container.viewContext)
                tag.name = row["Consequence\(i)"]
                incident.addToTags(tag)
            }
        }
        print(incident.tags?.count)
        
        //incident.hazards = consequences
    }
    
    // Wipe incidents + tags in database
    func wipeSavedData()
    {
        let incidents = Incident.createFetchRequest()

        if let records = try? container.viewContext.fetch(incidents)
        {
            for record in records
            {
                container.viewContext.delete(record)
            }
        }
        
        let tags = Tags.createFetchRequest()
        
        if let records = try? container.viewContext.fetch(tags)
        {
            for record in records
            {
                container.viewContext.delete(record)
            }
        }
        self.saveContext()// ??
    }
    
    // Load all the records in the database
    func loadSavedData()
    {
        let request = Incident.createFetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true) // Sort results by id
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        do
        {
            let records = try container.viewContext.fetch(request)
            print("Records in db in db: \(records.count)")
            for record in records
            {
                print(record.toString())
            }
        }
        catch
        {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Load a table view
    func loadForTable()
    {
        let request = Incident.createFetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        request.predicate = NSPredicate(format: "tags.name CONTAINS[cd] %@", "Noise/Chemical/Biological/Radiation")
        
        // sectionNameKeyPath is the variable that denotes the sections in tables.
        // e.g. If it is Year, it groups results by 2013, 2014... etc.
        // Cache has serious effect on filtering which results in predicates being fetched with a request
        // are cached inside rather than displayed.
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "year", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do
        {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch
        {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Find distinct list of values for a given attribute
    func testQuery()
    {
        let request: NSFetchRequest<NSFetchRequestResult> = Incident.createFetchRequest() as! NSFetchRequest<NSFetchRequestResult>  // Problem when type is NSFetchRequest<Incident>, <NSFetchRequestResult> fixes
        
        request.resultType = NSFetchRequestResultType.dictionaryResultType  // Return dictionary
        request.propertiesToFetch = ["year"]   // Select Year property
        request.returnsDistinctResults = true   // Return distinct
        
        do
        {
            let records = try container.viewContext.fetch(request)
            print(records.count)
            for i in 0 ..< records.count {
                // Convert to dictionary to use value
                if let dic = (records[i] as? [String : String]){
                    if let yearString = dic["year"]{
                        print(yearString)
                    }
                }
            }
        }
        catch
        {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    /*
     Multiple predicates on a single attribute:
     e.g. Year == 2013, Year == 2014
     Need to be stacked as an OR
     
     Multiple predicates across multiple attributes:
     e.g. Year == 2013, Location == Vessel
     Need to be stacked as an AND
     */
    
    // Test Multiple predicates ie multiple SELECTS
    func testStackedPredicates()
    {
        let request = Incident.createFetchRequest()
        
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(format: "year = %@", "2014"))
        predicates.append(NSPredicate(format: "location = %@", "Vessel"))
        
        // Add stacked predicates
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do
        {
            let records = try container.viewContext.fetch(request)
            print(records.count)
            for record in records
            {
                print(record.toString())
            }
        }
        catch
        {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Find all possible distinct options for every attribute
    func testAllOptions(headers: [String])
    {
        let request: NSFetchRequest<NSFetchRequestResult> = Incident.createFetchRequest() as! NSFetchRequest<NSFetchRequestResult>  // Problem when type is NSFetchRequest<Incident>, <NSFetchRequestResult> fixes
        
        request.resultType = NSFetchRequestResultType.dictionaryResultType  // Return dictionary
        request.returnsDistinctResults = true   // Return distinct
        
        for header in headers
        {
            request.propertiesToFetch = [header]
            
            do
            {
                let records = try container.viewContext.fetch(request)
                print(records.count)
                for i in 0 ..< records.count
                {
                    if let dic = (records[i] as? [String : String])
                    {
                        print(dic[header])
                    }
                }
                //print(records as? [[String: String]]) // Alternative to above if wanting dictionaries
            }
            catch
            {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Display table information
    func tableTest()
    {
        if (fetchedResultsController != nil)
        {
            print(fetchedResultsController.sections?.count ?? 0)
            for i in 0..<(fetchedResultsController.sections?.count ?? 0)
            {
                print(fetchedResultsController.sections![i].name)
                print(fetchedResultsController.sections![i].numberOfObjects)
            }
        }
    }
        
    // Number of sections in the table
    override public func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    // Title for each section in the table
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return fetchedResultsController.sections![section].name
    }
    
    // Number of rows in each section of the table
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    // What each cell looks like in the table
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentCell", for: indexPath)

        let incident = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = "ID: \(incident.id!) - \(incident.title!)"
        return cell
    }
}
