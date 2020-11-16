//
//  CustomerTableViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class CustomerTableViewController: UITableViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_CUSTOMERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryCustomers")
    let URL_FOR_DELETE_CUSTOMER = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?DeleteCustomer")
    let URL_FOR_GET_ORDERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryOrders")
    
    // MARK: - Program Variables
    var customers = [Customer]()
    var resultCustomers = [Customer]()
    var orders = [Order]()
    var resultOrders = [Order]()
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.customers = []
        self.orders = []
        
        getCustomers()
        getOrders()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCustomer(customerID: customers[indexPath.row].id)
        }
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object : Customer = customers[indexPath.row]
        cell.textLabel!.text = object.name
        cell.detailTextLabel?.text = object.address
    }
    
    // MARK: - Operation With Customers
    
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
                self.customers.insert(contentsOf: self.resultCustomers, at: 0)
                self.resultCustomers = []
                
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                })

            }
        })
        task.resume()
    }
    
    /**
     Deletes a customer from the database, as long as it does not have associated orders
     */
    func deleteCustomer(customerID: String) {
        if (canDeleteCustomer(customerID: customerID)) {
            let params: NSDictionary = ["IDCustomer": Int(customerID)!]
            
            var request = URLRequest(url: self.URL_FOR_DELETE_CUSTOMER!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {}
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                //print("response code:")
                //print((response as! HTTPURLResponse).statusCode)
                
                self.deserializeDeleteCustomer(data!)
                self.customers = []
                OperationQueue.main.addOperation({
                    self.getCustomers()
                })
                
            })
            
            task.resume()

        } else {
            makeDeleteAlert()
        }
    }
    
    // MARK: - Can Delete Customer
    
    /**
     Verify that the customer can be deleted
     */
    func canDeleteCustomer(customerID : String) -> Bool {
        var count = 0
        
        for order in orders{
            if (order.idCustomer == customerID) {
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
    
    // MARK: - Delete Alert
    
    /**
     Creates and displays the alert to warn the user that the client can not be deleted
     */
    func makeDeleteAlert(){
        let nameAlert = UIAlertController(title: "Error",
                                          message: NSLocalizedString("This customer has associated orders", comment: "Delete Customer Alert Message"),
                                          preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            
        }
        
        nameAlert.addAction(acceptAction)
        
        self.present(nameAlert, animated: true, completion: nil)
    }
    
    // MARK: - Operations with Orders
    
    /**
     Retrieves the data of the orders stored in the database
     */
    func getOrders() {
        let request = URLRequest(url: self.URL_FOR_GET_ORDERS!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                print (error)
                return
            }
            
            if let data = data {
                self.deserializeGetOrders(data)
                self.orders.insert(contentsOf: self.resultOrders, at: 0)
                self.resultOrders = []
                
            }
        })
        task.resume()
    }
    
    // MARK: - Deserialization
    
    /**
     Collects the data it receives in JSON from the customers and adds it to the results vector
     */
    func deserializeGetCustomers(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

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
                    self.resultCustomers.append(
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
     Collects the data it receives in JSON from the orders and adds it to the results vector
     */
    func deserializeGetOrders(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            var orderID = ""
            var customerID = ""
            var productID = ""
            var customerName = ""
            var productName = ""
            var code = ""
            var price = ""
            var quantity = ""
            var date = ""
            
            if let results = jsonResult["data"] as? [NSDictionary] {
                for result in results {
                    if let IDOrder = result["IDOrder"] as? String {
                        orderID = IDOrder
                    }
                    if let IDCustomer = result["IDCustomer"] as? String {
                        customerID = IDCustomer
                    }
                    if let IDProduct = result["IDProduct"] as? String {
                        productID = IDProduct
                    }
                    if let nameCustomer = result["customerName"] as? String {
                        customerName = nameCustomer
                    }
                    if let nameProduct = result["productName"] as? String {
                        productName = nameProduct
                    }
                    if let orderCode = result["code"] as? String {
                        code = orderCode
                    }
                    if let orderPrice = result["price"] as? String {
                        price = orderPrice
                    }
                    if let orderQuantity = result["quantity"] as? String {
                        quantity = orderQuantity
                    }
                    if let orderDate = result["date"] as? String {
                        date = orderDate
                    }
                    self.resultOrders.append(
                        Order(
                            idOrder: orderID,
                            idCustomer: customerID,
                            idProduct: productID,
                            customerName: customerName,
                            productName: productName,
                            code: code,
                            price: price,
                            quantity: quantity,
                            date: date)
                    )
                }
            }
        } catch {
            
        }
    }

    /**
     It collects the data that it receives in JSON from the request to delete a customer
     */
    func deserializeDeleteCustomer(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            _ = jsonResult["data"] as? Bool
            
        } catch {
            
        }
    }


    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CustomerCellSegue"){
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! CustomerViewController
                
                controller.customerID = customers[indexPath.row].id
                controller.customerName = customers[indexPath.row].name
                controller.customerAddress = customers[indexPath.row].address
                
            }
        }
    }
    
}
