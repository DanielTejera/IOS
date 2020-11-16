//
//  ProductViewController.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {
    
    // MARK: - URLS
    let URL_FOR_GET_PRODUCTS = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?QueryProducts")
    let URL_FOR_INSERT_PRODUCT = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?InsertProduct")
    let URL_FOR_UPDATE_PRODUCT = URL(string: "http://tip.dis.ulpgc.es/ventas/server.php?UpdateProduct")
    
    // MARK: - Program Variables
    var productID = ""
    var productName = ""
    var productDescription = ""
    var productPrice = ""
    var products = [Product]()
    var result = [Product]()
    
    // MARK: - Interface Variables
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (productID != "") {
            self.nameField.text = self.productName
            self.descriptionField.text = self.productDescription
            self.priceField.text = self.productPrice
        }
        
        products = []
        getProducts()
    }
    
    // MARK: - Buttons Control
    
    /**
     Records the press of a button. If the label of the button is zero, the saving of the object is started, then to make a transcription to the view of the table of products
     */
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        if (sender.tag == 0) {
            addProduct();
        }
        
    }
    
    // MARK: - Name Alert
    
    /**
     Creates and displays the alert to warn the user that the name for the product already exists in the database.
     */
    func makeNameAlert(){
        let nameAlert = UIAlertController(title: "Error",
                                          message: NSLocalizedString("The name already exists", comment: "Product Name Alert Message"),
                                          preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            
        }
        
        nameAlert.addAction(acceptAction)
        
        self.present(nameAlert, animated: true, completion: nil)
    }
    
    // MARK: - Operations with Products
    
    /**
     Add a product to the database, saved with the values entered by the user
     */
    func addProduct() {
        if (productID != ""){
            updateProduct()
        } else{
            if(testName(productName: self.nameField.text!)){

                let params: NSDictionary = ["name": nameField.text!, "description": descriptionField.text!, "price": Float(priceField.text!)!]
                
                var request = URLRequest(url: self.URL_FOR_INSERT_PRODUCT!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                } catch {}
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                    
                    self.deserializeInsertProduct(data!)
                    
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
     Updates the product data with the data entered by the user
     */
    func updateProduct(){
        if (testName(productName: self.nameField.text!)) {
            let params: NSDictionary = ["IDProduct": Int(self.productID)!, "name": nameField.text!, "description": descriptionField.text!, "price": Float(priceField.text!)!]
            
            var request = URLRequest(url: self.URL_FOR_UPDATE_PRODUCT!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {}
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                self.deserializeUpdateProduct(data!)
                
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
                self.products.insert(contentsOf: self.result, at: 0)
                self.result = []
                
            }
        })
        task.resume()
    }
    
    // MARK: - Test Name
    
    /**
     Check that the name chosen by the user is in the database
     */
    func testName(productName : String) -> Bool {
        var count = 0
        
        for product in products{
            if (product.name == productName){
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
                    self.result.append(
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
     It collects the data that it receives in JSON from the request to insert a product
     */
    func deserializeInsertProduct(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            if let id = jsonResult["data"] as? String {
                self.productID = id
            }
        } catch {
            
        }
    }
    
    /**
     It collects the data that it receives in JSON from the request to update a product
     */
    func deserializeUpdateProduct(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            _ = jsonResult["data"] as? Bool
            
        } catch {
            
        }
    }
    
    // MARK: - Preservation
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(productID, forKey:"productID")
        coder.encode(nameField.text, forKey: "nameField")
        coder.encode(descriptionField.text, forKey: "descriptionField")
        coder.encode(priceField.text, forKey: "priceField")
    }
    
    // MARK: - Restoration
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        productID = (coder.decodeObject(forKey: "productID") as? String)!
        nameField.text = coder.decodeObject(forKey: "nameField") as? String
        descriptionField.text = coder.decodeObject(forKey: "descriptionField") as? String
        priceField.text = coder.decodeObject(forKey: "priceField") as? String
    }
}
