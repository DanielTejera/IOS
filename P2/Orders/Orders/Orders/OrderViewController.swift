//
//  OrderViewController.swift
//  Orders
//
//  Created by Alumno on 22/03/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit
import CoreData

class OrderViewController: UIViewController {

    // MARK: - Program Variables
    var context: NSManagedObjectContext? = nil
    var entity: NSEntityDescription? = nil
    var customerName: String = ""
    var productName: String = ""
    var code = ""
    var date: Date?
    var quantity: Int16?
    var totalPrice: NSDecimalNumber?
    
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

        stepper.wraps = true
        stepper.autorepeat = true
        stepper.maximumValue = 10
        
        customerField.isEnabled = false
        productField.isEnabled = false
        quantityField.isEnabled = false
        totalPriceField.isEnabled = false
        
        totalPriceField.text = "0.0"
        quantityField.text = "0"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (code != "") {
            codeField.text = self.code
        }
        
        if (date != nil){
            datePicker.date = (self.date)! as Date
        }
        
        if (quantity != nil) {
            quantityField.text = String.init(describing: self.quantity!)
        }
        
        if (totalPrice != nil) {
            totalPriceField.text = self.totalPrice?.stringValue
        }
        
        if (customerName != ""){
            customerField.text = self.customerName
        }
        
        if (productName != ""){
            productField.text = self.productName
        }
    }
    
    // MARK: - Buttons Control
    
    /**
     Controls the use of the stepper, increasing or decreasing the field that reflects the quantity of product
     */
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        quantityField.text = Int(sender.value).description
        calculatePrice()
    }
    
    /**
     Records the press of a button. If the label of the button is zero, the saving of the object is started, then to make a transcription to the view of the table of customers
     */
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        if (sender.tag == 0) {
            addOrder();
        }
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Insert Order
    
    /**
     Add a order to the database, saved with the values entered by the user
     */
    func addOrder() {
        
        let customer = findCustomer(name: self.customerField.text!)
        
        let product = findProduct(name: self.productField.text!)
        
        let entity = NSEntityDescription.entity(forEntityName: "Order", in: context!)
        let order = NSManagedObject(entity: entity!, insertInto: context)
        
        order.setValue(self.codeField.text, forKey: "code")
        order.setValue(self.datePicker.date, forKey: "date")
        order.setValue(Int16(self.quantityField.text!), forKey: "quantity")
        order.setValue(NSDecimalNumber.init(string: self.totalPriceField.text), forKey: "totalPrice")
        order.setValue(customer, forKey: "customer")
        order.setValue(product, forKey: "product")

        do {
            try context?.save()
        } catch {
            abort()
        }
    }
    
    // MARK: - Calculate Price
    
    /**
     Calculate the total price of the order by the price of an individual product
     */
    func calculatePrice(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        let predicate = NSPredicate(format: "name == %@", self.productField.text!)
        
        fetchRequest.predicate = predicate
        
        do {
            
            let result = try context?.fetch(fetchRequest) as! [Product]
            let price = Double(result[0].price!) * Double(self.quantityField.text!)!
            
            self.totalPriceField.text = String(describing: price)
        } catch {
            
        }
    }
    
    // MARK: - Find Functions
    
    /**
     Look for the customer in the database, as long as it contains the name in its attributes
     
     - Parameter name: Name of the product to be searched.
     */
    func findCustomer(name: String) -> Customer {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Customer")
        let predicate = NSPredicate(format: "name == %@", name)
        
        fetchRequest.predicate = predicate
        
        do {
            
            let result = try context?.fetch(fetchRequest) as! [Customer]
            return result[0]
        } catch {
            
        }
        return Customer()
    }
    
    /**
     Look for the product in the database, as long as it contains the name in its attributes
     
     - Parameter name: Name of the product to be searched.
     */
    func findProduct(name: String) -> Product {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        let predicate = NSPredicate(format: "name == %@", name)
        
        fetchRequest.predicate = predicate
        
        do {
            
            let result = try context?.fetch(fetchRequest) as! [Product]
            return result[0]
        } catch {
            
        }
        return Product()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectCustomerSegue"){
            
            let controller = segue.destination as! SelectTableViewController
            
            controller.forCustomers = true
            
            controller.code = codeField.text!
            controller.date = datePicker.date
            controller.quantity = NSDecimalNumber.init(string: self.quantityField.text!, locale: nil) as Int16?
            controller.totalPrice = NSDecimalNumber.init(string: self.totalPriceField.text!, locale: nil)
            controller.customerName = customerField.text!
            controller.productName = productField.text!
            
        }
        
        if (segue.identifier == "SelectProductSegue"){
            let controller = segue.destination as!  SelectTableViewController
            
            controller.forProducts = true
            
            controller.code = codeField.text!
            controller.date = datePicker.date
            controller.quantity = NSDecimalNumber.init(string: self.quantityField.text!, locale: nil) as Int16?
            controller.totalPrice = NSDecimalNumber.init(string: self.totalPriceField.text!, locale: nil)
            controller.customerName = customerField.text!
            controller.productName = productField.text!
        }
    }

    // MARK: - Preservation
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
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
        
        codeField.text = coder.decodeObject(forKey: "codeField") as? String
        datePicker.date = (coder.decodeObject(forKey: "date") as? Date)!
        quantityField.text = coder.decodeObject(forKey: "quantityField") as? String
        totalPriceField.text = coder.decodeObject(forKey: "totalPriceField") as? String
        customerField.text = coder.decodeObject(forKey: "customerField") as? String
        productField.text = coder.decodeObject(forKey: "productField") as? String
    }
}
