//
//  ProductTableViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_PRODUCTS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryProducts")
    let URL_FOR_DELETE_PRODUCT = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?DeleteProduct")
    let URL_FOR_GET_ORDERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryOrders")
    
    // MARK: - Program Variables
    var products = [Product]()
    var resultProducts = [Product]()
    var orders = [Order]()
    var resultOrders = [Order]()
    
    // MARK: - System funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.products = []
        self.orders = []
        getProducts()
        getOrders()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteProduct(productID: products[indexPath.row].id)
        }
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object : Product = products[indexPath.row]
        cell.textLabel!.text = object.name
        cell.detailTextLabel?.text = object.description
    }
    
    // MARK: - Operation with Products
    
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
    
    /**
     Deletes a product from the database, as long as it does not have associated orders
     */
    func deleteProduct(productID : String) {
        if(canDeleteProduct(productID: productID)){
            let params: NSDictionary = ["IDProduct": Int(productID)!]
            
            var request = URLRequest(url: self.URL_FOR_DELETE_PRODUCT!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {}
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in

                self.deserializeDeleteProduct(data!)
                self.products = []
                OperationQueue.main.addOperation({
                    self.getProducts()
                })
                
            })
            
            task.resume()
        } else {
            makeDeleteAlert()
        }
    }
    
    // MARK: - Can Delete Product
    
    /**
     Verify that the product can be deleted
     */
    func canDeleteProduct(productID : String) -> Bool {
        var count = 0
        
        for order in orders{
            if (order.idProduct == productID) {
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
     Creates and displays the alert to warn the user that the product can not be deleted
     */
    func makeDeleteAlert(){
        let nameAlert = UIAlertController(title: "Error",
                                          message: NSLocalizedString("This product has associated orders", comment: "Delete Product Alert Message"),
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
     It collects the data that it receives in JSON from the request to delete a product
     */
    func deserializeDeleteProduct(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            _ = jsonResult["data"] as? Bool
            
        } catch {
            
        }
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductCellSegue"){
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! ProductViewController
                
                controller.productID = products[indexPath.row].id
                controller.productName = products[indexPath.row].name
                controller.productDescription = products[indexPath.row].description
                controller.productPrice = products[indexPath.row].price
            }
        }
    }
}
