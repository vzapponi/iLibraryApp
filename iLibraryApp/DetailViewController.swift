//
//  DetailViewController.swift
//  iLibraryApp
//
//  Created by Angelo Vittorio Zapponi on 29/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UITextFieldDelegate {
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet weak var txtTitolo: UITextField!
    @IBOutlet weak var txtAutore: UITextField!
    @IBOutlet weak var txtCollocazione: UITextField!
    @IBOutlet weak var txtVolumi: UITextField!
    @IBOutlet weak var txtDataCreazione: UITextField!
    @IBOutlet weak var txtDataModifica: UITextField!
    @IBOutlet weak var txtPrestato: UITextField!
    @IBOutlet weak var txtDataPrestito: UITextField!
    @IBOutlet weak var txtBarCode: UITextField!

    let dateForm = NSDateFormatter()

    var newBook = false
    
    
    
    
    
    
    var book:Book?

    func configureView() {
        // Update the user interface for the detail item.
        if let myBook = book {
            txtTitolo.text = myBook.titolo
            txtAutore.text = myBook.autore
            txtVolumi.text = myBook.volumi.stringValue
            txtCollocazione.text = myBook.collocazione
            txtDataCreazione.text = myBook.dataCreazione
            txtDataModifica.text = myBook.dataModifica
            txtPrestato.text = myBook.prestatoA
            txtDataPrestito.text = myBook.dataPrestito
            txtBarCode.text = myBook.barCode
        }
        else{
            reset(UIButton())
            if (newBook){
                txtVolumi.text = "1"
                txtDataCreazione?.text = dateForm.stringFromDate(NSDate())
                txtDataModifica?.text = dateForm.stringFromDate(NSDate())
                
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateForm.locale = NSLocale.currentLocale()
        dateForm.dateFormat = "yyyy/MMM/dd HH:mm"
        txtCollocazione.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Actions
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func salva(sender: UIButton) {
        if (!checkBook()){
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertController(title: "ATTENZIONE", message: "Mancano dati in\nTITOLO,\nAUTORE,\nCOLLOCAZIONE", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action) in
                    
                }))
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            })
        }
        resignFirstResponder()
        if (book == nil){
            book = appDel.dbController.getBookVuoto()
            newBook = false
        }
        saveDati(book!)
        do{
            try appDel.dbController.saveContext()
        }
        catch{
            print(error)
        }
        self.reset(sender)
//        appDel.navContoller?.popViewControllerAnimated(true)
        performSegueWithIdentifier("ritornoAMaster", sender: nil)
    }
    @IBAction func reset(sender: UIButton) {
        txtTitolo?.text = ""
        txtAutore?.text = ""
        txtVolumi?.text = ""
        txtCollocazione?.text = ""
        txtDataCreazione?.text = ""
        txtDataModifica?.text = ""
        txtPrestato?.text = ""
        txtDataPrestito?.text = ""
        txtBarCode?.text = ""
        book = nil
    }
    @IBAction func deleteBook(sender: UIButton) {
        if (book == nil){
            return
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let message = "Confermi la cancellazione?"
            let alert = UIAlertController(title: "ATTENZIONE", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "SI", style: .Default, handler: {(action) in
                self.appDel.dbController.removeBook(self.book!)
                do{
                    try self.appDel.dbController.saveContext()
                }
                catch{
                    print(error)
                }
                self.reset(sender)
                self.performSegueWithIdentifier("ritornoAMaster", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .Default, handler: {(action) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func checkBook() -> Bool{
        if (txtTitolo.text!.isEmpty || txtAutore.text!.isEmpty || txtCollocazione.text!.isEmpty){
            return false
        }
        else{
            return true
        }
    }
    func saveDati(libro: Book){
        libro.titolo = txtTitolo.text!
        libro.autore = txtAutore.text!
        libro.volumi = Int(txtVolumi.text!)!
        libro.collocazione = txtCollocazione.text!
        if (libro.dataCreazione.isEmpty){
            libro.dataCreazione = dateForm.stringFromDate(NSDate())
        }
        libro.dataModifica = dateForm.stringFromDate(NSDate())
        if (!txtPrestato.text!.isEmpty){
            // e stato prestato
            if (libro.prestatoA.isEmpty){
                // nuovo prestito
                libro.prestatoA = txtPrestato.text!
                libro.dataPrestito = dateForm.stringFromDate(NSDate())
            }
            else{
                // Gia prestato vdiamo se cambio la persona
                if (txtPrestato.text != libro.prestatoA){
                    libro.prestatoA = txtPrestato.text!
                    libro.dataPrestito = dateForm.stringFromDate(NSDate())
                }
            }
        }
        libro.barCode = txtBarCode.text!
    }


}

