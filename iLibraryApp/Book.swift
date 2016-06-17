//
//  Book.swift
//  iLibraryApp
//
//  Created by Angelo Vittorio Zapponi on 29/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Foundation
import CoreData

@objc(Book)
class Book: NSManagedObject {

    @NSManaged var titolo: String
    @NSManaged var autore: String
    @NSManaged var collocazione: String
    @NSManaged var volumi: NSNumber
    @NSManaged var prestatoA: String
    @NSManaged var dataCreazione: String
    @NSManaged var dataModifica: String
    @NSManaged var dataPrestito: String
    @NSManaged var barCode: String
    
    func toString() -> String{
        return self.titolo + " " + self.autore + " " + self.collocazione
    }

}
