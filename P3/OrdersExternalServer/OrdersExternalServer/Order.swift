//
//  Order.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class Order {
    
    var idOrder = ""
    var idCustomer = ""
    var idProduct = ""
    var customerName = ""
    var productName = ""
    var code = ""
    var price = ""
    var quantity = ""
    var date = ""
    
    init(idOrder: String, idCustomer: String, idProduct: String, customerName: String, productName: String, code: String, price: String, quantity: String, date: String) {
        
        self.idOrder = idOrder
        self.idCustomer = idCustomer
        self.idProduct = idProduct
        self.customerName = customerName
        self.productName = productName
        self.code = code
        self.price = price
        self.quantity = quantity
        self.date = date
    }
}
