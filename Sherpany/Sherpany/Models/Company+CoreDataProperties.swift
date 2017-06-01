//
//  Company+CoreDataProperties.swift
//  Sherpany
//
//  Created by Emanuel Munteanu on 30.05.17.
//  Copyright © 2017 Emanuel Munteanu. All rights reserved.
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var name: String?
    @NSManaged public var catchPhrase: String?
    @NSManaged public var bs: String?

}
