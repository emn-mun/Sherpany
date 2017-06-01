import Foundation
import CoreData

public struct Entity {
    static let Post = "Post"
    static let User = "User"
    static let Address = "Address"
    static let Geolocation = "Geolocation"
    static let Company = "Company"
    static let Album = "Album"
    static let Photo = "Photo"
}

class DBCache {
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func updatePostsWith(data: JSON, usingUsers users: [User], completion: @escaping ([Post]?) -> ()) {
        CoreDataStack.sharedInstance.privateMoc.perform {
            let posts = data.flatMap{self.createPostEntityFrom(dictionary: $0, usingUsers: users)}
            do {
                try CoreDataStack.sharedInstance.privateMoc.save()
                CoreDataStack.sharedInstance.privateMoc.performAndWait({
                    do {
                        try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                        print("Done Posts")
                        return completion(posts)
                    } catch {
                        return completion(nil)
                    }
                })
            } catch {
                return completion(nil)
            }
        }
    }
    
    func updateUsersWith(data: JSON, completion: @escaping ([User]?) -> ()) {
        CoreDataStack.sharedInstance.privateMoc.perform {
            let users = data.flatMap{self.createUserEntityFrom(dictionary: $0)}
            do {
                try CoreDataStack.sharedInstance.privateMoc.save()
                CoreDataStack.sharedInstance.privateMoc.performAndWait({
                    do {
                        try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                        print("Done Users")
                        return completion(users)
                    } catch {
                        return completion(nil)
                    }
                })
            } catch {
                return completion(nil)
            }
        }
    }
    
    func updateAlbumsWith(data: JSON, usingUsers users: [User], completion: @escaping ([Album]?) -> ()) {
        CoreDataStack.sharedInstance.privateMoc.perform {
            let albums = data.flatMap{self.createAlbumEntityFrom(dictionary: $0)}
            do {
                try CoreDataStack.sharedInstance.privateMoc.save()
                CoreDataStack.sharedInstance.privateMoc.performAndWait({
                    do {
                        try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                        print("Done Albums")
                        return completion(albums)
                    } catch {
                        return completion(nil)
                    }
                })
            } catch {
                return completion(nil)
            }
        }
    }
    
    func updatePhotosWith(data: JSON, usingAlbums albums: [Album], completion: @escaping ([Photo]?) -> ()) {
        CoreDataStack.sharedInstance.privateMoc.perform {
            let photos = data.flatMap{self.createPhotoEntityFrom(dictionary: $0, usingAlbums: albums)}
            do {
                try CoreDataStack.sharedInstance.privateMoc.save()
                CoreDataStack.sharedInstance.privateMoc.performAndWait({
                    do {
                        try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                        print("Done Photos")
                        return completion(photos)
                    } catch {
                        return completion(nil)
                    }
                })
            } catch {
                return completion(nil)
            }
        }
    }
    
    private func createPostEntityFrom(dictionary: [String: Any], usingUsers users: [User]) -> Post? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.User)
            let users = try context.fetch(userFetchRequest) as! [User]

            let postFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Post)
            postFetchRequest.predicate = NSPredicate(format: "id == %d", dictionary["id"] as! Int32)
            postFetchRequest.fetchLimit = 1
            let post = (try context.fetch(postFetchRequest) as! [Post]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.Post, into: context) as! Post
            
            post.id = dictionary["id"] as! Int32
            post.user?.id = dictionary["userId"] as! Int32
            post.title = dictionary["title"] as? String
            post.body = dictionary["body"] as? String
            post.user = users.filter{$0.id == (dictionary["userId"] as! Int32)}.first
            return post
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func createUserEntityFrom(dictionary: [String: Any]) -> User? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.User)
            userFetchRequest.predicate = NSPredicate(format: "id == %d", dictionary["id"] as! Int32)
            userFetchRequest.fetchLimit = 1
            let user = (try context.fetch(userFetchRequest) as! [User]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.User, into: context) as! User
            
            user.id = dictionary["id"] as! Int32
            user.name = dictionary["name"] as? String
            user.username = dictionary["username"] as? String
            user.email = dictionary["email"] as? String
            if let addressData = dictionary["address"] as? [String : Any] {
                user.address = createAddressEntityFrom(dictionary: addressData)
            }
            user.phone = dictionary["phone"] as? String
            user.website = dictionary["website"] as? String
            if let companyData = dictionary["company"] as? [String : Any] {
                user.company = createCompanyEntityFrom(dictionary: companyData)
            }
            return user
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func createAddressEntityFrom(dictionary: [String: Any]) -> Address? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            let addressFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Address)
            addressFetchRequest.predicate = NSPredicate(format: "street == %@ AND suite == %@", dictionary["street"] as! String, dictionary["suite"] as! String)
            addressFetchRequest.fetchLimit = 1
            let address = (try context.fetch(addressFetchRequest) as! [Address]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.Address, into: context) as! Address
            
            address.street = dictionary["street"] as? String
            address.suite = dictionary["suite"] as? String
            address.city = dictionary["city"] as? String
            address.zipcode = dictionary["zipcode"] as? String
            if let geo = dictionary["geo"] as? [String : Any] {
                address.geo = createGeolocationEntityFrom(dictionary: geo)
            }
            return address
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func createGeolocationEntityFrom(dictionary: [String: Any]) -> Geolocation? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            guard let latString = dictionary["lat"] as? String, let lat = Double(latString) else { return nil }
            guard let lngString = dictionary["lng"] as? String, let lng = Double(lngString) else { return nil }
            
            let geolocationFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Geolocation)
            geolocationFetchRequest.predicate = NSPredicate(format: "lat == %lf AND lng == %lf", lat, lng)
            geolocationFetchRequest.fetchLimit = 1
            let geolocation = (try context.fetch(geolocationFetchRequest) as! [Geolocation]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.Geolocation, into: context) as! Geolocation
            
            geolocation.lat = lat
            geolocation.lng = lng
            
            return geolocation
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func createCompanyEntityFrom(dictionary: [String: Any]) -> Company? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            let companyFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Company)
            companyFetchRequest.predicate = NSPredicate(format: "name == %@", dictionary["name"] as! String)
            companyFetchRequest.fetchLimit = 1
            let company = (try context.fetch(companyFetchRequest) as! [Company]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.Company, into: context) as! Company
            
            company.name = dictionary["name"] as? String
            company.catchPhrase = dictionary["catchPhrase"] as? String
            company.bs = dictionary["bs"] as? String
            return company
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func createAlbumEntityFrom(dictionary: [String: Any]) -> Album? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.User)
            let users = try context.fetch(userFetchRequest) as! [User]
            
            let albumFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Album)
            albumFetchRequest.predicate = NSPredicate(format: "id == %d", dictionary["id"] as! Int32)
            albumFetchRequest.fetchLimit = 1
            let album = (try context.fetch(albumFetchRequest) as! [Album]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.Album, into: context) as! Album
            
            album.id = dictionary["id"] as! Int32
            album.title = dictionary["title"] as? String
            album.user = users.filter{$0.id == (dictionary["userId"] as! Int32)}.first
            return album
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func createPhotoEntityFrom(dictionary: [String: Any], usingAlbums albums: [Album]) -> Photo? {
        let context = CoreDataStack.sharedInstance.privateMoc
        do {
            let photoFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Photo)
            photoFetchRequest.predicate = NSPredicate(format: "id == %d", dictionary["id"] as! Int32)
            photoFetchRequest.fetchLimit = 1
            let photo = (try context.fetch(photoFetchRequest) as! [Photo]).first ?? NSEntityDescription.insertNewObject(forEntityName: Entity.Photo, into: context) as! Photo
            
            photo.id = dictionary["id"] as! Int32
            photo.title = dictionary["title"] as? String
            photo.url = dictionary["url"] as? String
            photo.thumbnailUrl = dictionary["thumbnailUrl"] as? String
            photo.album = albums.filter{$0.id == (dictionary["albumId"] as! Int32)}.first
            return photo
        } catch let error {
            print(error)
        }
        return nil
    }
}
