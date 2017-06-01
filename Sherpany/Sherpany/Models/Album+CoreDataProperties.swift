//
//  Album+CoreDataProperties.swift
//  Sherpany
//
//  Created by Emanuel Munteanu on 30.05.17.
//  Copyright © 2017 Emanuel Munteanu. All rights reserved.
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var user: User?
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension Album {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
