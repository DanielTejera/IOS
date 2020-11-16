//
//  ProductViewController.swift
//  Orders
//
//  Created by Alumno on 22/03/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Program Variables
    var context: NSManagedObjectContext? = nil
    var entity: NSEntityDescription? = nil
    var index: IndexPath?
    var product: Product?
    
    // MARK: - Interface Variables
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (index != nil){
            product = self.fetchedResultsController.object(at: self.index!)
            nameField.text = self.product?.name
            descriptionField.text = self.product?.productDescription
            priceField.text = self.product?.price?.stringValue
        }
    }
    
    // MARK: - Buttons Control
    
    /**
     Records the press of a button. If the label of the button is zero, the saving of the object is started, then to make a transcription to the view of the table of customers
     */
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        if (sender.tag == 0) {
            addProduct();
        }
        
        _ = self.navigationController?.popToRootViewController(animated: true)
        
    }

    // MARK: - Insert Product
    
    /**
     Add a product to the database, saved with the values entered by the user
     */
    func addProduct() {
        if (product == nil) {
            let entity = NSEntityDescription.entity(forEntityName: "Product", in: context!)
            product = (NSManagedObject(entity: entity!, insertInto: context) as! Product)
        }
        
        product?.setValue(self.nameField.text, forKey: "name")
        product?.setValue(self.descriptionField.text, forKey: "productDescription")
        product?.setValue(NSDecimalNumber.init(string: self.priceField.text!, locale: nil), forKey: "price")
        
        do {
            try product?.managedObjectContext?.save()
        } catch {
            abort()
        }
    }
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Product> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
        
        _fetchedResultsController.delegate = self
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Product>!
    
    // MARK: - Preservation
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(nameField.text, forKey: "nameField")
        coder.encode(descriptionField.text, forKey: "descriptionField")
        coder.encode(priceField.text, forKey: "priceField")
    }
    
    // MARK: - Restoration
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        nameField.text = coder.decodeObject(forKey: "nameField") as? String
        descriptionField.text = coder.decodeObject(forKey: "descriptionField") as? String
        priceField.text = coder.decodeObject(forKey: "priceField") as? String
    }
}
