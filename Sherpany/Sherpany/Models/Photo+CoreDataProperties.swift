//
//  Photo+CoreDataProperties.swift
//  Sherpany
//
//  Created by Emanuel Munteanu on 30.05.17.
//  Copyright © 2017 Emanuel Munteanu. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var album: Album?

}
