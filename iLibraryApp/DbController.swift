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
        var request:NSFetchRequest<Book>
        if #available(iOS 10.0, *) {
            request = Book.fetchRequest() as! NSFetchRequest<Book>
        } else {
            // Fallback on earlier versions
            request = NSFetchRequest(entityName: "Book")
            
        }
        request.returnsObjectsAsFaults = false
        request.includesPropertyValues = false
        do{
            let results:[Book] = try context!.fetch(request)
            if results.count > 0{
                for dsp in results{
                    let myDsp = dsp 
                    context!.delete(myDsp)
                }
                try context!.save()
            }
        }
        catch{
            NSLog("Errore nella generazione di un book vuoto")
        }
    }
    func getBookVuoto() -> Book{
        let entLis = NSEntityDescription.entity(forEntityName: "Book", in: context!)
        let book = Book(entity: entLis!, insertInto: context!)
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
        var request:NSFetchRequest<Book>
        if #available(iOS 10.0, *) {
            request = Book.fetchRequest() as! NSFetchRequest<Book>
        } else {
            // Fallback on earlier versions
            request = NSFetchRequest(entityName: "Book")
            
        }
        let sortDesc:Array = [NSSortDescriptor(key: "titolo", ascending: true)]
        request.sortDescriptors = sortDesc
        do{
            let results:[Book] = try context!.fetch(request) 
            return results
        }
        catch{
            return []
        }
        
    }
    func removeBook(_ book: Book){
        context!.delete(book)
    }
    func saveContext() throws{
        try context.save()
    }
   
}
