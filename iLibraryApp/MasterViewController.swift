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
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var detailViewController: DetailViewController? = nil
    var books = [Book]()
    var filtered = [Book]()
    var searchController = UISearchController(searchResultsController: nil)
    var selectedBook: Book?
    var moc:NSManagedObjectContext!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        
    }

    override func viewDidLoad() {
//        print("viewDidLoad")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(showData(_:)), name: Notification.Name(rawValue:MyNotificationKeys.addObserver), object: nil)
        self.searchController = ({
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            searchController.searchBar.searchBarStyle = UISearchBarStyle.default
            searchController.searchBar.showsScopeBar = false
            searchController.searchBar.scopeButtonTitles = ["titolo", "autore", "collocaz.", "prestato"]
            self.tableView.tableHeaderView = searchController.searchBar
            self.definesPresentationContext = true
            return searchController
        })()
        
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showData(_:)), name: Notification.Name(rawValue:MyNotificationKeys.updateDati), object: nil)
//        print("viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print("viewDidAppear")
        
        DispatchQueue.main.async(execute: {
  //          self.initializeListener()
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
//        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func showData(_ notification:Notification){
        let userInfo = notification.userInfo
        books = userInfo!["dati"] as! [Book]
//        print("IN SHOW DATA \(books.count)")
        tableView.reloadData()
    }
    // MARK: - Search bar methods
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResults")
        let idx = searchController.searchBar.selectedScopeButtonIndex
        filtered.removeAll(keepingCapacity: false)
        let con = searchController.searchBar.text?.lowercased()
        switch idx{
        case 0:
            if let myCon = con{
                filtered = books.filter{(book) in (book).titolo.lowercased().starts(with: myCon)}
            }
//            ricerca = "titolo BEGINSWITH[c] %@"
        case 1:
            if let myCon = con{
                filtered = books.filter{(book) in (book).autore.lowercased().starts(with: myCon)}
            }
//            ricerca = "autore BEGINSWITH[c] %@"
        case 2:
            if let myCon = con{
                filtered = books.filter{(book) in (book).collocazione.lowercased().starts(with: myCon)}
            }
//            ricerca = "collocazione BEGINSWITH[c] %@"
        case 3:
            if let myCon = con{
                filtered = books.filter{(book) in (book).prestatoA.lowercased().starts(with: myCon)}
            }
//            ricerca = "prestatoA != %@"
        default:
            if let myCon = con{
                filtered = books.filter{(book) in (book).titolo.lowercased().starts(with: myCon)}
            }
//            ricerca = "titolo BEGINSWITH[c] %@"
        }
//
//        filtered = array as! [Book]
        self.tableView.reloadData()
        
    }

    // MARK: - Segues
    @objc func insertNewObject(_ sender: AnyObject){
        selectedBook = nil
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.book = selectedBook
//            if (selectedBook == nil){
//                controller.configureView()
//            }
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive){
            return filtered.count
        }
        else{
            return books.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (searchController.isActive){
            selectedBook = filtered[(indexPath as NSIndexPath).row]
        }
        else{
            selectedBook = books[(indexPath as NSIndexPath).row]
        }
        return indexPath
    }

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        var book:Book?
        if searchController.isActive{
            book = filtered[(indexPath as NSIndexPath).row]
        }
        else{
            book = books[(indexPath as NSIndexPath).row]
        }
        
        cell.textLabel?.text = book!.titolo
        cell.detailTextLabel?.text = book!.autore
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let book = books[(indexPath as NSIndexPath).row]
            let ref = self.appDel.database!.child("books").child((book.id!))
            ref.removeValue(completionBlock: { (error, refer) in
                if error != nil {
                    print(error!)
                } else {
                    print(refer)
                    print("Child Removed Correctly")
                }
            })
//            dbController.findAllBooks()
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
 
    // MARK: - messages
    func statusICloud(){
        DispatchQueue.main.async(execute: { () -> Void in
            let message = "ICloud OK!"
            let alert = UIAlertController(title: "ATTENZIONE", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        })
        
    }
 */
    // MARK: - ritorno da detail
    @IBAction func ritornoDaDetail(_ segue: UIStoryboardSegue){
        resignFirstResponder()
   //     dbController.findAllBooks()
        tableView.reloadData()
    }
    
    @IBAction func ritornoDaDetailConRicaricaDati(_ segue: UIStoryboardSegue){
        resignFirstResponder()
//        appDel.dbController.findAllBooks()
        tableView.reloadData()
    }

}

