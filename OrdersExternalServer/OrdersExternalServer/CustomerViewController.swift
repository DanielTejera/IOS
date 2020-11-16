//
//  CustomerViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class CustomerViewController: UIViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_CUSTOMERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryCustomers")
    let URL_FOR_INSERT_CUSTOMER = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?InsertCustomer")
    let URL_FOR_UPDATE_CUSTOMER = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?UpdateCustomer")
    
    // MARK: - Program Variables
    var customerID = ""
    var customerName = ""
    var customerAddress = ""
    var customers = [Customer]()
    var result = [Customer]()
    
    // MARK: - Interface Variables
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    // MARK: - System funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (customerID != "") {
            nameField.text = self.customerName
            addressField.text = self.customerAddress
        }

        customers = []
        getCustomers()
    }
    
    // MARK: - Buttons Control
    
    /**
     Records the press of a button. If the label of the button is zero, the saving of the object is started, then a transcript is made in the view of the customer table whenever the insertion or updating of the customer has been completed
     */
    @IBAction func buttonPresed(_ sender: UIBarButtonItem) {
        
        if (sender.tag == 0) {
            addCustomer();
        }
        
    }
    
    // MARK: - Name Alert
    
    /**
     Creates and displays the alert to warn the user that the name for the customer already exists in the database.
     */
    func makeNameAlert(){
        let nameAlert = UIAlertController(title: "Error",
                                               message: NSLocalizedString("The name already exists", comment: "Customer Name Alert Message"),
                                               preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            
        }
        
        nameAlert.addAction(acceptAction)
        
        self.present(nameAlert, animated: true, completion: nil)
    }

    // MARK: - Operations With Customers
    
    /**
     Add a customer to the database, saved with the values entered by the user
     */
    func addCustomer() {
        if (customerID != ""){
            updateCustomer()
        } else{
            if(testName(customerName: self.nameField.text!)){

                let params: NSDictionary = ["name": nameField.text!, "address": addressField.text!]
                
                var request = URLRequest(url: self.URL_FOR_INSERT_CUSTOMER!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                } catch {}
 
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in

                    self.deserializeInsertCustomer(data!)
                    
                    OperationQueue.main.addOperation({
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    })
                    
                })
                
                task.resume()
            } else {
                makeNameAlert()
            }
        }
    }
    
    /**
     Updates the customer data with the data entered by the user
     */
    func updateCustomer() {
        if (testName(customerName: self.nameField.text!)) {

            let params: NSDictionary = ["IDCustomer": Int(self.customerID)!, "name": nameField.text!, "address": addressField.text!]
            
            var request = URLRequest(url: self.URL_FOR_UPDATE_CUSTOMER!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {}
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                self.deserializeUpdateCustomer(data!)
                
                OperationQueue.main.addOperation({
                    _ = self.navigationController?.popToRootViewController(animated: true)
                })
                
            })
            
            task.resume()
        } else {
            makeNameAlert()
        }
    }
    
    /**
     Retrieves the data of the customers stored in the database
     */
    func getCustomers() {
        let request = URLRequest(url: self.URL_FOR_GET_CUSTOMERS!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                print (error)
                return
            }
            
            if let data = data {
                self.deserializeGetCustomers(data)
                self.customers.insert(contentsOf: self.result, at: 0)
                self.result = []
                
            }
        })
        task.resume()
    }
    
    // MARK: - Test Name
    
    /**
     Check that the name chosen by the user is in the database
     */
    func testName(customerName : String) -> Bool {
        var count = 0
        
        for customer in customers{
            if (customer.name == customerName){
                count += 1
                break
            }
        }
        
        if (count != 0) {
            return false
        } else {
            return true
        }
        
    }

    
    // MARK: - Deserialization
    
    /**
     Collects the data it receives in JSON from the customers and adds it to the results vector
     */
    func deserializeGetCustomers(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            //print("jsonResult:")
            //print(jsonResult)
            
            var customerID = ""
            var customerName = ""
            var customerAddress = ""
            
            if let results = jsonResult["data"] as? [NSDictionary] {
                for result in results {
                    if let id = result["IDCustomer"] as? String {
                        customerID = id
                    }
                    if let name = result["name"] as? String {
                        customerName = name
                    }
                    if let address = result["address"] as? String {
                        customerAddress = address
                    }
                    self.result.append(
                        Customer(
                            id: customerID,
                            name: customerName,
                            address: customerAddress)
                    )
                }
            }
        } catch {
            
        }
    }
    
    /**
     It collects the data that it receives in JSON from the request to insert a customer
     */
    func deserializeInsertCustomer(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

            if let id = jsonResult["data"] as? String {
                customerID = id
            }
        } catch {
            
        }
    }
    
    /**
     It collects the data that it receives in JSON from the request to update a customer
     */
    func deserializeUpdateCustomer(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            _ = jsonResult["data"] as? Bool
            
        } catch {
            
        }
    }
    
    // MARK: - Preservation
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(self.customerID, forKey: "customerID")
        coder.encode(nameField.text, forKey: "nameField")
        coder.encode(addressField.text, forKey: "addressField")
    }
    
    // MARK: - Restoration
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        self.customerID = (coder.decodeObject(forKey: "customerID") as? String)!
        nameField.text = coder.decodeObject(forKey: "nameField") as? String
        addressField.text = coder.decodeObject(forKey: "addressField") as? String
    }
}
