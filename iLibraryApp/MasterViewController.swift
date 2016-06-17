//
//  MasterViewController.swift
//  iLibraryApp
//
//  Created by Angelo Vittorio Zapponi on 29/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, UISearchResultsUpdating {
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    var detailViewController: DetailViewController? = nil
    var books = [Book]()
    var filtered = [Book]()
    var searchController:UISearchController!
    var selectedBook: Book?
    var moc:NSManagedObjectContext!
    var dbController:DbController!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = UISearchBarStyle.Default
            controller.searchBar.showsScopeBar = false
            controller.searchBar.scopeButtonTitles = ["tit.", "aut.", "coll.", "prest."]
            self.tableView.tableHeaderView = controller.searchBar
            
            self.definesPresentationContext = true
            return controller
        })()
        
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(initializeListener), name: MyNotificationKeys.addObserver, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue(), {
            self.initializeListener()
        })
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Persitence notification
    func initializeListener(){
        if let mocH = appDel.dbController.context{
            print("HO IL MOC")
            self.moc = mocH
            self.dbController = appDel.dbController
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.persisteStoreDidChange), name:NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.persistenceStoreWillChange(_:)), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.receiveICloudChanges(_:)), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
            
            books = dbController.findAllBooks()
            print("LIBRI N \(books.count)")
            tableView.reloadData()
            
        }
    }
    func persisteStoreDidChange() {
        print("persisteStoreDidChange")
        books = dbController.findAllBooks()
        if (books.count > 0){
            self.tableView.reloadData()
        }
        
    }
    func persistenceStoreWillChange(notification: NSNotification){
        print("persistenceStoreWillChange")
        statusICloud()
        moc.performBlock{() -> Void in
            if (self.moc.hasChanges){
                do{
                    try self.dbController.saveContext()
                }
                catch{
                    print(error)
                    return
                }
                self.moc.reset()
            }
        }
    }
    func receiveICloudChanges(notification: NSNotification){
        print("receiveICloudChanges")
        moc.performBlock({() -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            self.books = self.dbController.findAllBooks()
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Search bar methods
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let idx = searchController.searchBar.selectedScopeButtonIndex
        filtered.removeAll(keepCapacity: false)
        var ricerca = ""
        var con = searchController.searchBar.text
        switch idx{
        case 0:
            ricerca = "titolo BEGINSWITH[c] %@"
        case 1:
            ricerca = "autore BEGINSWITH[c] %@"
        case 2:
            ricerca = "collocazione BEGINSWITH[c] %@"
        case 3:
            ricerca = "prestatoA != %@"
            con = ""
        default:
            ricerca = "titolo BEGINSWITH[c] %@"
        }
        let searchPredicate = NSPredicate(format: ricerca, con!)
        let array = (books as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filtered = array as! [Book]
        self.tableView.reloadData()
        
    }

    // MARK: - Segues
    func insertNewObject(sender: AnyObject){
        selectedBook = nil
        performSegueWithIdentifier("showDetail", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            controller.book = selectedBook
            if (selectedBook == nil){
                controller.newBook = true
                controller.configureView()
            }
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = searchController {
            if (searchController.active){
                return filtered.count
            }
            else{
                return books.count
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (searchController.active){
            selectedBook = filtered[indexPath.row]
        }
        else{
            selectedBook = books[indexPath.row]
        }
        return indexPath
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        var book:Book?
        if searchController.active{
            book = filtered[indexPath.row]
        }
        else{
            book = books[indexPath.row]
        }
        
        cell.textLabel?.text = book!.titolo
        cell.detailTextLabel?.text = book!.autore
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let book = books[indexPath.row]
            dbController.removeBook(book)
            do{
                try dbController.saveContext()
            }
            catch{
                print(error)
                return
            }
            books = dbController.findAllBooks()
            tableView.reloadData()
        }
    }

//    // MARK: - Fetched results controller
//
//    var fetchedResultsController: NSFetchedResultsController {
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
//        
//        let fetchRequest = NSFetchRequest()
//        // Edit the entity name as appropriate.
//        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
//        fetchRequest.entity = entity
//        
//        // Set the batch size to a suitable number.
//        fetchRequest.fetchBatchSize = 20
//        
//        // Edit the sort key as appropriate.
//        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
//        let sortDescriptors = [sortDescriptor]
//        
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        // Edit the section name key path and cache name if appropriate.
//        // nil for section name key path means "no sections".
//        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
//        aFetchedResultsController.delegate = self
//        _fetchedResultsController = aFetchedResultsController
//        
//    	var error: NSError? = nil
//    	if !_fetchedResultsController!.performFetch(&error) {
//    	     // Replace this implementation with code to handle the error appropriately.
//    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//             //println("Unresolved error \(error), \(error.userInfo)")
//    	     abort()
//    	}
//        
//        return _fetchedResultsController!
//    }    
//    var _fetchedResultsController: NSFetchedResultsController? = nil
//
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.beginUpdates()
//    }
//
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//            case .Insert:
//                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//            case .Delete:
//                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//            default:
//                return
//        }
//    }
//
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//            case .Insert:
//                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            case .Delete:
//                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            case .Update:
//                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
//            case .Move:
//                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            default:
//                return
//        }
//    }
//
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.endUpdates()
//    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
    // MARK: - messages
    func statusICloud(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let message = "ICloud OK!"
            let alert = UIAlertController(title: "ATTENZIONE", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    // MARK: - ritorno da detail
    @IBAction func ritornoDaDetail(segue: UIStoryboardSegue){
        resignFirstResponder()
        books = dbController.findAllBooks()
        tableView.reloadData()
    }

}

