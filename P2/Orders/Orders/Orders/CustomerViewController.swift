//
//  CustomerViewController.swift
//  Orders
//
//  Created by Alumno on 22/03/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit
import CoreData


class CustomerViewController: UIViewController, NSFetchedResultsControllerDelegate{

    // MARK: - Program Variables
    var context: NSManagedObjectContext?
    var entity: NSEntityDescription?
    var index : IndexPath? = nil
    var customer: Customer? = nil
    
    // MARK: - Interface Variables
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    // MARK: - System funcs
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
            customer = self.fetchedResultsController.object(at: self.index!)
            
            nameField.text = self.customer?.name
            addressField.text = self.customer?.address
        }
    }
    
    // MARK: - Buttons Control
    
    /**
     Records the press of a button. If the label of the button is zero, the saving of the object is started, then to make a transcription to the view of the table of customers
     */
    @IBAction func buttonPresed(_ sender: UIBarButtonItem) {
        
        if (sender.tag == 0) {
            addCustomer();
        }
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Insert Customer
    
    /**
     Add a customer to the database, saved with the values entered by the user
     */
    func addCustomer() {
        if (customer == nil) {
            let entity = NSEntityDescription.entity(forEntityName: "Customer", in: context!)
            
            customer = (NSManagedObject(entity: entity!, insertInto: context) as! Customer)
        }
        
        customer?.setValue(self.nameField.text, forKey: "name")
        customer?.setValue(self.addressField.text, forKey: "address")
        do {
            try context?.save()
        } catch {
            abort()
        }
    }
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Customer> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Customer>(entityName: "Customer")
        
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
    
    var _fetchedResultsController: NSFetchedResultsController<Customer>!
    
    // MARK: - Preservation
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(nameField.text, forKey: "nameField")
        coder.encode(addressField.text, forKey: "addressField")
    }
    
    // MARK: - Restoration
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        nameField.text = coder.decodeObject(forKey: "nameField") as? String
        addressField.text = coder.decodeObject(forKey: "addressField") as? String
    }
}
