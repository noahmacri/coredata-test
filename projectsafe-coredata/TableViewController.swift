import Foundation
import CoreData
import UIKit

public class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate
{
    //var container: NSPersistentContainer!
    let container = AppDelegate().persistentContainer
    let headers = ["activity","severity","year","location"]
    
    var fetchedResultsController: NSFetchedResultsController<Incident>!
    var predicate: NSPredicate?
    var filters = [[String]]()
    
    
    public override func viewDidLoad() {
        loadFilters()
    }
    
    // Populate table view
    func loadFilters()
    {
        let request: NSFetchRequest<NSFetchRequestResult> = Incident.createFetchRequest() as! NSFetchRequest<NSFetchRequestResult>  // Problem when type is NSFetchRequest<Incident>, <NSFetchRequestResult> fixes
        
        request.resultType = NSFetchRequestResultType.dictionaryResultType  // Return dictionary
        request.returnsDistinctResults = true   // Return distinct
        
        for header in headers
        {
            var options = [String]()
            request.propertiesToFetch = [header]
            
            do
            {
                let records = try container.viewContext.fetch(request)
                for i in 0 ..< records.count
                {
                    if let dic = (records[i] as? [String : String])
                    {
                        options.append(dic[header]!)
                    }
                }
            }
            catch
            {
                print("Error: \(error.localizedDescription)")
            }
            
            filters.append(options)
        }
    }
    
    // Number of sections in the fetched results
    override public func numberOfSections(in tableView: UITableView) -> Int
    {
        return headers.count
    }
    
    // Title for each section
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return headers[section]
    }
    
    // Number of rows in each section
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filters[section].count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)

        cell.textLabel!.text = filters[indexPath.section][indexPath.row]
        return cell
    }
}
