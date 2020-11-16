//
//  Order+CoreDataProperties.swift
//  Orders
//
//  Created by Alumno on 05/04/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order");
    }

    @NSManaged public var code: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var quantity: Int16
    @NSManaged public var totalPrice: NSDecimalNumber?
    @NSManaged public var customer: Customer?
    @NSManaged public var product: Product?

}
