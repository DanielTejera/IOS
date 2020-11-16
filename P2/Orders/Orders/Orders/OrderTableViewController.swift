//
//  OrderTableViewController.swift
//  Orders
//
//  Created by Alumno on 22/03/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit
import CoreData

class OrderTableViewController: UITableViewController, NSFetchedResultsControllerDelegate{

    // MARK: - Program Variables
    var managedObjectContext: NSManagedObjectContext? = nil
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
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
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as NSManagedObject)
            
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = self.fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = (object.value(forKey: "code")! as AnyObject).description
        cell.detailTextLabel?.text = (object.value(forKey: "product") as! Product).name
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = self.fetchedResultsController.sections?.count
        
        for i in 0 ..< sections!{
            let index = IndexPath(row: i, section: section)
            print(self.fetchedResultsController.object(at: index).customer?.name as Any)
            return self.fetchedResultsController.object(at: index).customer?.name
        }
        return nil
    }
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Order> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<Order>(entityName: "Order")
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true), NSSortDescriptor(key: "product", ascending: true)]
        
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "customer", cacheName: nil)
        
        _fetchedResultsController.delegate = self
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Order>!
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
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
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "OrderCellSegue"){
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedOrder = self.fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! OrderViewController
                
                controller.code = selectedOrder.code!
                controller.date = selectedOrder.date! as Date
                controller.quantity = selectedOrder.quantity
                controller.totalPrice = selectedOrder.totalPrice
                controller.customerName = (selectedOrder.customer?.name)!
                controller.productName = (selectedOrder.product?.name)!
                
                controller.context = self.fetchedResultsController.managedObjectContext
                controller.entity = self.fetchedResultsController.fetchRequest.entity!
            }
        }
        
        if (segue.identifier == "AddOrderSegue"){
            let controller = segue.destination as!  OrderViewController
            controller.context = self.fetchedResultsController.managedObjectContext
            controller.entity = self.fetchedResultsController.fetchRequest.entity!
        }
    }

}


