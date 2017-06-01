//
//  Geolocation+CoreDataProperties.swift
//  Sherpany
//
//  Created by Emanuel Munteanu on 30.05.17.
//  Copyright © 2017 Emanuel Munteanu. All rights reserved.
//

import Foundation
import CoreData


extension Geolocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Geolocation> {
        return NSFetchRequest<Geolocation>(entityName: "Geolocation")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lng: Double

}
