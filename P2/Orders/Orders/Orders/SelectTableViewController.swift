//
//  SelectTableViewController.swift
//  Orders
//
//  Created by Alumno on 04/04/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit
import CoreData

class SelectTableViewController: UITableViewController , NSFetchedResultsControllerDelegate{
    
    // MARK: - Program Variables
    var managedObjectContext: NSManagedObjectContext? = nil
    var forCustomers = false
    var forProducts = false
    var code = ""
    var date: Date?
    var quantity: Int16?
    var totalPrice: NSDecimalNumber?
    var customerName = ""
    var productName = ""

    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (forCustomers == true) {
            let sectionInfo = self.customersFetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }else{
            let sectionInfo = self.productsFetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (forCustomers == true) {
                let context = self.customersFetchedResultsController.managedObjectContext
                context.delete(self.customersFetchedResultsController.object(at: indexPath) as NSManagedObject)
                do {
                    try context.save()
                } catch {
                    abort()
                }
            }
            if (forProducts == true) {
                let context = self.productsFetchedResultsController.managedObjectContext
                context.delete(self.productsFetchedResultsController.object(at: indexPath) as NSManagedObject)
                do {
                    try context.save()
                } catch {
                    abort()
                }
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if (forCustomers == true) {
            let object = self.customersFetchedResultsController.object(at: indexPath)
            cell.textLabel!.text = (object.value(forKey: "name")! as AnyObject).description
        }
        if (forProducts == true) {
            let object = self.productsFetchedResultsController.object(at: indexPath)
            cell.textLabel!.text = (object.value(forKey: "name")! as AnyObject).description
        }
        
    }
    
    // MARK: - Fetched results controller
    var customersFetchedResultsController: NSFetchedResultsController<Customer> {
        if _customersFetchedResultsController != nil {
            return _customersFetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Customer>(entityName: "Customer")
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        _customersFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        _customersFetchedResultsController.delegate = self
        
        do {
            try _customersFetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _customersFetchedResultsController!
    }
    
    var _customersFetchedResultsController: NSFetchedResultsController<Customer>!
    
    var productsFetchedResultsController: NSFetchedResultsController<Product> {
        if _productsFetchedResultsController != nil {
            return _productsFetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        _productsFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        _productsFetchedResultsController.delegate = self
        
        do {
            try _productsFetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _productsFetchedResultsController!
    }
    
    var _productsFetchedResultsController: NSFetchedResultsController<Product>!
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DoneSegue"){
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if (forCustomers == true) {
                    let selectedCustomer = self.customersFetchedResultsController.object(at: indexPath)
                    let controller = segue.destination as! OrderViewController
                    
                    controller.code = self.code
                    controller.date = self.date
                    controller.quantity = self.quantity
                    controller.totalPrice = self.totalPrice
                    controller.customerName = selectedCustomer.name!
                    controller.productName = self.productName
                    
                    controller.context = self.customersFetchedResultsController.managedObjectContext
                    controller.entity = self.customersFetchedResultsController.fetchRequest.entity!
                    
                }else{
                    let selectedProduct = self.productsFetchedResultsController.object(at: indexPath)
                    let controller = segue.destination as! OrderViewController
                    
                    controller.code = self.code
                    controller.date = self.date
                    controller.quantity = self.quantity
                    controller.totalPrice = self.totalPrice
                    controller.customerName = self.customerName
                    controller.productName = selectedProduct.name!
                    
                    controller.context = self.productsFetchedResultsController.managedObjectContext
                    controller.entity = self.productsFetchedResultsController.fetchRequest.entity!
                }
            }
        }
    }

}
