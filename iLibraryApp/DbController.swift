//
//  DbController.swift
//  iLibraryApp
//
//  Created by Angelo Vittorio Zapponi on 29/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import UIKit
import CoreData

class DbController: NSObject {
    var context: NSManagedObjectContext!{
        didSet{
            print("NSManagedObjectContext")
//            NSNotificationCenter.defaultCenter().postNotificationName(MyNotificationKeys.addObserver, object: nil)
        }
    }

    
    // MARK: metodi per DB
    func clearBooks(){
        let request = NSFetchRequest(entityName: "Book")
        request.returnsObjectsAsFaults = false
        request.includesPropertyValues = false
        do{
            let results:NSArray = try context!.executeFetchRequest(request)
            if results.count > 0{
                for dsp in results{
                    let myDsp = dsp as! Book
                    context!.deleteObject(myDsp)
                }
                try context!.save()
            }
        }
        catch{
            NSLog("Errore nella generazione di un book vuoto")
        }
    }
    func getBookVuoto() -> Book{
        let entLis = NSEntityDescription.entityForName("Book", inManagedObjectContext: context!)
        let book = Book(entity: entLis!, insertIntoManagedObjectContext: context!)
        book.titolo = ""
        book.autore = ""
        book.collocazione = ""
        book.dataCreazione = ""
        book.dataModifica = ""
        book.prestatoA = ""
        book.volumi = 1
        book.dataPrestito = ""
        book.barCode = ""
        return book
    }
    func findAllBooks() -> [Book]{
        let request = NSFetchRequest(entityName: "Book")
        let sortDesc:Array = [NSSortDescriptor(key: "titolo", ascending: true)]
        request.sortDescriptors = sortDesc
        do{
            let results:[Book] = try context!.executeFetchRequest(request) as! Array<Book>
            return results
        }
        catch{
            return []
        }
        
    }
    func removeBook(book: Book){
        context!.deleteObject(book)
    }
    func saveContext() throws{
        try context.save()
    }
   
}
