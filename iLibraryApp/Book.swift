//
//  Book.swift
//  iLibraryApp
//
//  Created by Angelo Vittorio Zapponi on 29/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Foundation


class Book: Codable {

    var titolo: String = ""
    var autore: String = ""
    var id: String?
    var collocazione: String = ""
    var volumi: Int = 0
    var prestatoA: String = ""
    var dataCreazione: Double = 0.0
    {
        didSet{
            dCreazione = Date(timeIntervalSince1970: dataCreazione/1000)
        }
    }
    var dataModifica: Double = 0.0
    {
        didSet{
            dModifica = Date(timeIntervalSince1970: dataModifica/1000)
        }
    }
    var dataPrestito: Double = 0.0
    {
        didSet{
            dPrestito = Date(timeIntervalSince1970: dataPrestito/1000)
        }
    }
    var barCode: String = ""
    var dCreazione:Date?
        /*
    {
 //       didSet{
 //           dataCreazione = dCreazione!.timeIntervalSince1970*1000
 //       }
    }
 */
    var dModifica:Date?
    /*{
 //       didSet{
  //          dataModifica = dModifica!.timeIntervalSince1970*1000
  //      }
    }
 */
    var dPrestito:Date?
    /*{
//        didSet{
//            dataPrestito = dPrestito!.timeIntervalSince1970*1000
//        }
    }
    */
    func toString() -> String{
        return self.titolo + " " + self.autore + " " + self.collocazione
    }
    func setValori(values:Dictionary<String,Any>){
        autore = values["autore"] as! String
        collocazione = values["collocazione"] as! String
        dataCreazione = Double(values["dataCreazione"]! as! Double)
        dataModifica = Double(values["dataModifica"]!as! Double)
        if let dp = values["dataPrestito"]{
            dataPrestito = Double(dp as! Double)
        }
        id = values["id"] as? String
        prestatoA = values["prestatoA"] as! String
        titolo = values["titolo"] as! String
        volumi = Int(values["volumi"]! as! Int)
    }
    func getValori()->[String: Any]{
        var values = [String: Any]()
        values["autore"] = autore
        values["collocazione"] = collocazione
        values["dataCreazione"] = dataCreazione
        values["dataModifica"] = dataModifica
        values["dataPrestito"] = dataPrestito
        values["id"] = id
        values["prestatoA"] = prestatoA
        values["titolo"] = titolo
        values["volumi"] = volumi
        return values
    }

}
