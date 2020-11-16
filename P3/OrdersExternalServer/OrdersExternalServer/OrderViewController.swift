//
//  OrderViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_ORDERS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryOrders")
    let URL_FOR_INSERT_ORDER = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?InsertOrder")
    let URL_FOR_UPDATE_ORDER = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?UpdateOrder")
    
    // MARK: - Program Variables
    var orderID = ""
    var customerID = ""
    var productID = ""
    var customerName = ""
    var productName = ""
    var code = ""
    var price = ""
    var quantity = ""
    var date = ""
    var orders = [Order]()
    var result = [Order]()
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - Interface Variables
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var customerField: UITextField!
    @IBOutlet weak var productField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var totalPriceField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stepper.wraps = true
        self.stepper.autorepeat = true
        self.stepper.minimumValue = 0
        self.stepper.isEnabled = false
        
        self.customerField.isEnabled = false
        self.productField.isEnabled = false
        self.quantityField.isEnabled = false
        self.totalPriceField.isEnabled = false
        
        self.totalPriceField.text = "0.0"
        self.quantityField.text = "0"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (self.customerName != "") {
            self.customerField.text = self.customerName
        }
        
        if (self.productName != ""){
            self.productField.text = self.productName
            self.stepper.isEnabled = true
        }
        
        if (self.code != ""){
            self.codeField.text = code
        }
        
        if (self.quantity != "") {
            self.quantityField.text = self.quantity
            self.stepper.value = Double(self.quantity)!
            
            if (self.quantity != "0") {
                self.stepper.isEnabled = true
            }
        }
        
        if (self.price != "") {
            let totalPrice = calculateTotalPrice(price: self.price, quantity: self.quantity)
            self.totalPriceField.text = totalPrice
        }
        
        if (self.date != ""){
            let formatedDate = self.dateFormatter.date(from: self.date)
            self.datePicker.date = formatedDate!
        }

        getOrders()
    }
    
    // MARK: - Buttons Control
    
    /**
     Controls the use of the stepper, increasing or decreasing the field that reflects the quantity of product
     */
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        quantityField.text = Int(sender.value).description
        let totalPrice = calculateTotalPrice(price: self.price, quantity: self.quantityField.text!)
        self.totalPriceField.text = totalPrice
    }
    
    /**
     Records the press of a button. If the label of the button is zero, the saving of the object is started, then to make a transcription to the view of the table of customers
     */
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        if (sender.tag == 0) {
            addOrder();
        }

    }
    

    
    // MARK: - Operations with orders
    
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
                
            }
        })
        task.resume()
    }

    
    /**
     Add a order to the database, saved with the values entered by the user
     */
    func addOrder() {
        if (orderID != ""){
            updateOrder()
        } else{
            if(testCode(orderCode: self.codeField.text!)){
                
                let params: NSDictionary = ["code": self.codeField.text!,
                                            "date": self.dateFormatter.string(from: self.datePicker.date),
                                            "IDCustomer": Int(self.customerID)!,
                                            "IDProduct": Int(self.productID)!,
                                            "quantity": Int(self.quantityField.text!)!]
                
                var request = URLRequest(url: self.URL_FOR_INSERT_ORDER!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                } catch {}
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                    
                    self.deserializeInsertOrder(data!)
                    
                    OperationQueue.main.addOperation({
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    })
                    
                })
                
                task.resume()
            } else {
                makeCodeAlert()
            }
        }
    }
    
    /**
     Updates the order data with the data entered by the user
     */
    func updateOrder(){
        if (testCode(orderCode: self.codeField.text!)) {
            let params: NSDictionary = ["IDOrder": Int(self.orderID)!,
                                        "IDCustomer": Int(self.customerID)!,
                                        "IDProduct": Int(self.productID)!,
                                        "code": self.codeField.text!,
                                        "date": self.dateFormatter.string(from: self.datePicker.date),
                                        "quantity": Int(self.quantityField.text!)!]
            
            var request = URLRequest(url: self.URL_FOR_UPDATE_ORDER!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {}
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                self.deserializeUpdateOrder(data!)
                
                OperationQueue.main.addOperation({
                    _ = self.navigationController?.popToRootViewController(animated: true)
                })
                
            })
            
            task.resume()
        } else {
            makeCodeAlert()
        }
    }

    // MARK: - Code Alert
    
    /**
     Creates and displays the alert to warn the user that the code for the order already exists in the database.
     */
    func makeCodeAlert(){
        let nameAlert = UIAlertController(title: "Error",
                                          message: NSLocalizedString("The code already exists", comment: "Order Code Alert Message"),
                                          preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            
        }
        
        nameAlert.addAction(acceptAction)
        
        self.present(nameAlert, animated: true, completion: nil)
    }
    
    // MARK: - Calculate Price
    
    /**
     Calculate the total price of the order by the price of an individual product
     */
    func calculateTotalPrice(price: String, quantity: String) -> String {
        let doublePrice = Double(price)
        let doubleQuantity = Double(quantity)
        let totalPrice = doublePrice! * doubleQuantity!
        return String(totalPrice)
        
    }
    
    // MARK: - Test Code
    
    /**
     Check that the code chosen by the user is in the database
     */
    func testCode(orderCode : String) -> Bool {
        var count = 0
        
        for order in orders{
            if (order.code == orderCode){
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
     It collects the data that it receives in JSON from the request to insert a product
     */
    func deserializeInsertOrder(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            if let id = jsonResult["data"] as? String {
                self.orderID = id
            }
        } catch {
            
        }
    }
    
    /**
     It collects the data that it receives in JSON from the request to update a order
     */
    func deserializeUpdateOrder(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary

            _ = jsonResult["data"] as? Bool
            
        } catch {
            
        }
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: repasar segues
        if (segue.identifier == "SelectCustomerSegue"){
            
            let controller = segue.destination as! SelectTableViewController
            
            controller.forCustomers = true
            controller.orderID = self.orderID
            controller.productID = self.productID
            controller.productName = self.productField.text!
            controller.code = self.codeField.text!
            controller.price = self.price
            controller.quantity = self.quantityField.text!
            controller.date = self.dateFormatter.string(from: self.datePicker.date)
            
        }
        
        if (segue.identifier == "SelectProductSegue"){
            let controller = segue.destination as!  SelectTableViewController
            
            controller.forProducts = true
            
            controller.orderID = self.orderID
            controller.customerID = self.customerID
            controller.customerName = self.customerField.text!
            controller.code = self.codeField.text!
            controller.price = self.price
            controller.quantity = self.quantityField.text!
            controller.date = self.dateFormatter.string(from: self.datePicker.date)
        }
    }

    
    // MARK: - Preservation
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(self.orderID, forKey: "orderID")
        coder.encode(self.customerID, forKey: "customerID")
        coder.encode(self.productID, forKey: "productID")
        coder.encode(codeField.text, forKey: "codeField")
        coder.encode(datePicker.date, forKey: "date")
        coder.encode(quantityField.text, forKey: "quantityField")
        coder.encode(totalPriceField.text, forKey: "totalPriceField")
        coder.encode(customerField.text, forKey: "customerField")
        coder.encode(productField.text, forKey: "productField")
    }
    
    // MARK: - Restoration
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        self.orderID = coder.decodeObject(forKey: "orderID") as! String
        self.customerID = coder.decodeObject(forKey: "customerID") as! String
        self.productID = coder.decodeObject(forKey: "productID") as! String
        codeField.text = coder.decodeObject(forKey: "codeField") as? String
        datePicker.date = (coder.decodeObject(forKey: "date") as? Date)!
        quantityField.text = coder.decodeObject(forKey: "quantityField") as? String
        totalPriceField.text = coder.decodeObject(forKey: "totalPriceField") as? String
        customerField.text = coder.decodeObject(forKey: "customerField") as? String
        productField.text = coder.decodeObject(forKey: "productField") as? String
    }
}
