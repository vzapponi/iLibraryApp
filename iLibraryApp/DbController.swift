//
//  DbController.swift
//  iLibraryApp
//
//  Created by Angelo Vittorio Zapponi on 29/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class DbController: NSObject {
    var dataBase:DatabaseReference?
    override init() {
        
    }
    
    // MARK: metodi per DB
    func clearBooks(){

    }
    func getBookVuoto() -> Book{
        /*
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
 */
        return Book()
    }
    func findAllBooks(){
        print(">>>>>>>>>>>>  CHIAMO CARICA TUTTI")
        var all:[Book] = []
        dataBase!.child("books").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
//                let key = snap.key
                let value = snap.value
 //               print("dati \(key) kiave \(value) libro")
                let book = Book()
                book.setValori(values: value as! Dictionary<String, Any>)
//                print(book.toString())
                all.append(book)
            }
            all = all.sorted(by: { $0.titolo < $1.titolo })
            NotificationCenter.default.post(name:Notification.Name(rawValue: MyNotificationKeys.addObserver), object: self, userInfo:["dati":all])
        })
    }
    func removeBook(_ book: Book){
        
    }
    func saveContext() throws{
        
    }
   
}
