//
//  OrderTableViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_ORDERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryOrders")
    let URL_FOR_DELETE_ORDER = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?DeleteOrder")
    
    
    // MARK: - Program Variables
    var orders = [Order]()
    var result = [Order]()
    
    // MARK: - Section variables
    var numberOfSections = 0
    var nameOfSections = [String]()
    var numberOfElementsBySection = [Int]()
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.orders = []
        getOrders()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.orders.count == 0) {
            return 1
        } else {
            self.getSectionsInfo()
            return self.numberOfSections
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.orders.count == 0) {
            return 0
        } else {
            return self.numberOfElementsBySection[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = getIndex(section: indexPath.section, row: indexPath.row)
            deleteOrder(orderID: orders[index].idOrder)
        }
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if (self.orders.count == 0) {
            cell.textLabel!.text = ""
            cell.detailTextLabel?.text = ""
        } else {
            let index = getIndex(section: indexPath.section, row: indexPath.row)
            let object : Order = orders[index]
            cell.textLabel!.text = object.code
            cell.detailTextLabel?.text = object.productName
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (orders.count == 0) {
            return ""
        } else {
            return nameOfSections[section]
        }
    }
    
    // MARK: - Sections Info
    
    /**
     Generates the information necessary for the table view to handle the sections
     */
    func getSectionsInfo() {
        var aux = [String]()
        var count = 0
        self.numberOfElementsBySection = []
        self.nameOfSections = []
        
        for i in 0..<orders.count{
            aux.append(orders[i].customerName)
        }
        self.nameOfSections = Array(Set(aux))

        self.nameOfSections = nameOfSections.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        for j in 0..<nameOfSections.count {
            for order in orders{
                if (nameOfSections[j] == order.customerName) {
                    count = count + 1
                }
            }
            self.numberOfElementsBySection.append(count)
            count = 0
        }
        
        self.numberOfSections = self.nameOfSections.count
    }
    
    /**
     Calculate the index in the orders vector based on the section and the row that occupies the cell in the table.
     
        - Parameter section: Represents the position of the name of the customer at nameOfSections[]
        - Parameter row: Represents which order corresponds to the customer
     */
    func getIndex(section: Int, row: Int) -> Int {
        var count = 0
        let rowToCompare = row + 1
        
        for i in 0..<orders.count {
            if (nameOfSections[section] == orders[i].customerName){
                count = count + 1
            }
            if(count == rowToCompare){
                return i
            }
        }
        
        return 0
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
                self.orders.insert(contentsOf: self.result, at: 0)
                self.result = []
                
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                })
                
            }
        })
        task.resume()
    }
    
    // MARK: - Delete Order
    
    /**
     Deletes a order from the database
     */
    func deleteOrder(orderID : String) {
        let params: NSDictionary = ["IDOrder": Int(orderID)!]
        
        var request = URLRequest(url: self.URL_FOR_DELETE_ORDER!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {}
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            self.deserializeDeleteOrder(data!)
            self.orders = []
            OperationQueue.main.addOperation({
                self.getOrders()
            })
            
        })
        
        task.resume()
    }
    

    
    // MARK: - Deserialization
    
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
                    self.result.append(
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
     It collects the data that it receives in JSON from the request to delete a order
     */
    func deserializeDeleteOrder(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            _ = jsonResult["data"] as? Bool
            
        } catch {
            
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "OrderCellSegue"){
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! OrderViewController

                let index = getIndex(section: indexPath.section, row: indexPath.row)
                
                controller.orderID = orders[index].idOrder
                controller.customerID = orders[index].idCustomer
                controller.productID = orders[index].idProduct
                controller.customerName = orders[index].customerName
                controller.productName = orders[index].productName
                controller.code = orders[index].code
                controller.price = orders[index].price
                controller.quantity = orders[index].quantity
                controller.date = orders[index].date
            }
        }
    }
    

    
}
