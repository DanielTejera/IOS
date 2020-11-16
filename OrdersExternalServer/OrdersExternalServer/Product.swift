//
//  Product.swift
//  OrdersExternalServer
//
//  Created by Alumno on 10/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class Product {
    
    var id = ""
    var name = ""
    var description = ""
    var price = ""
    
    init(id: String, name: String, price: String, description: String) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
    }
}
