//
//  SelectTableViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class SelectTableViewController: UITableViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_CUSTOMERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryCustomers")
    let URL_FOR_GET_PRODUCTS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryProducts")
    
    // MARK: - Program Variables
    var forCustomers = false
    var forProducts = false
    var orderID = ""
    var customerID = ""
    var productID = ""
    var customerName = ""
    var productName = ""
    var code = ""
    var price = ""
    var quantity = ""
    var date = ""
    var customers = [Customer]()
    var resultCustomers = [Customer]()
    var products = [Product]()
    var resultProducts = [Product]()
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (forCustomers) {
            customers = []
            getCustomers()
        }
        if (forProducts) {
            products = []
            getProducts()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (forCustomers) {
            return customers.count
        }
        if (forProducts) {
            return products.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if (forCustomers == true) {
            let object : Customer = customers[indexPath.row]
            cell.textLabel!.text = object.name
        }
        if (forProducts == true) {
            let object : Product = products[indexPath.row]
            cell.textLabel!.text = object.name
        }
        
    }
    
    // MARK: - Getters
    
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
     Retrieves the data of the products stored in the database
     */
    func getProducts() {
        let request = URLRequest(url: self.URL_FOR_GET_PRODUCTS!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                print (error)
                return
            }
            
            if let data = data {
                self.deserializeGetProducts(data)
                self.products.insert(contentsOf: self.resultProducts, at: 0)
                self.resultProducts = []
                
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                })
                
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
     Collects the data it receives in JSON from the products and adds it to the results vector
     */
    func deserializeGetProducts(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            var productID = ""
            var productName = ""
            var productPrice = ""
            var productDescription = ""
            
            if let results = jsonResult["data"] as? [NSDictionary] {
                for result in results {
                    if let id = result["IDProduct"] as? String {
                        productID = id
                    }
                    if let name = result["name"] as? String {
                        productName = name
                    }
                    if let price = result["price"] as? String {
                        productPrice = price
                    }
                    if let description = result["description"] as? String {
                        productDescription = description
                    }
                    self.resultProducts.append(
                        Product(
                            id: productID,
                            name: productName,
                            price: productPrice,
                            description: productDescription)
                    )
                }
            }
        } catch {
            
        }
    }

    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DoneSegue"){
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if (forCustomers == true){
                    let controller = segue.destination as! OrderViewController
                    
                    controller.orderID = self.orderID
                    controller.customerID = customers[indexPath.row].id
                    controller.productID = self.productID
                    controller.customerName = customers[indexPath.row].name
                    controller.productName = self.productName
                    controller.code = self.code
                    controller.price = self.price
                    controller.quantity = self.quantity
                    controller.date = self.date
                }
                if (forProducts == true){
                    let controller = segue.destination as! OrderViewController
                    
                    controller.orderID = self.orderID
                    controller.customerID = self.customerID
                    controller.productID = products[indexPath.row].id
                    controller.customerName = self.customerName
                    controller.productName = products[indexPath.row].name
                    controller.code = self.code
                    controller.price = products[indexPath.row].price
                    controller.quantity = self.quantity
                    controller.date = self.date
                }
                
            }
        }
    }
    
}
