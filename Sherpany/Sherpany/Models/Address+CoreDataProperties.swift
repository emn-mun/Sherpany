//
//  Address+CoreDataProperties.swift
//  Sherpany
//
//  Created by Emanuel Munteanu on 30.05.17.
//  Copyright © 2017 Emanuel Munteanu. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var street: String?
    @NSManaged public var suite: String?
    @NSManaged public var city: String?
    @NSManaged public var zipcode: String?
    @NSManaged public var geo: Geolocation?

}
