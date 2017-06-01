import Foundation

class Manager {
    
    enum ManagerError: Error {
        case FailedToSaveCoreDataError
    }
    
    static let shared = Manager(apiClient: APIClient(), dbCache: DBCache(managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext))
    let apiClient: APIClient
    let dbCache: DBCache
    
    init(apiClient: APIClient, dbCache: DBCache) {
        self.apiClient = apiClient
        self.dbCache = dbCache
    }
    
    func fetchAllDataWithCompletion(fetchCompletion: @escaping () -> ()) {
        getUsers { users in
            if case .success(let users) = users {
                self.getPostsFromUsers(users, completion: { posts in

                })
                self.getAlbumsFromUsers(users, completion: { albums in
                    if case .success(let albums) = albums {
                        self.getPhotosFromAlbums(albums, completion: { photos in
                            fetchCompletion()
                        })
                    }
                })
            }
        }
    }
    
    func getPostsFromUsers(_ users: [User], completion: @escaping (Result<[Post]>) -> ()) {
        guard let postsEndPoint = URL(string: URLPaths.posts.rawValue) else { return }
        apiClient.fetchFromPath(postsEndPoint) { result in
                switch result {
                case .success(let data):
                    self.dbCache.updatePostsWith(data: data, usingUsers: users, completion: { posts in
                        if let posts = posts {
                            return completion(.success(posts))
                        } else {
                            return completion(.failure(ManagerError.FailedToSaveCoreDataError))
                        }
                    })
                case .failure(let error):
                    return completion(.failure(error))
                }
            }?.resume()
    }
    
    func getUsers(completion: @escaping (Result<[User]>) -> ()) {
        guard let usersEndPoint = URL(string: URLPaths.users.rawValue) else { return }
        apiClient.fetchFromPath(usersEndPoint) { result in
                switch result {
                case .success(let data):
                    self.dbCache.updateUsersWith(data: data, completion: { users in
                        if let users = users {
                            return completion(.success(users))
                        } else {
                            return completion(.failure(ManagerError.FailedToSaveCoreDataError))
                        }
                    })
                case .failure(let error):
                    return completion(.failure(error))
                }
            }?.resume()
    }
    
    func getAlbumsFromUsers(_ users: [User], completion: @escaping (Result<[Album]>) -> ()) {
        guard let albumsEndPoint = URL(string: URLPaths.albums.rawValue) else { return }
        apiClient.fetchFromPath(albumsEndPoint) { result in
                switch result {
                case .success(let data):
                    self.dbCache.updateAlbumsWith(data: data, usingUsers: users, completion: { albums in
                        if let albums = albums {
                            return completion(.success(albums))
                        } else {
                            return completion(.failure(ManagerError.FailedToSaveCoreDataError))
                        }
                    })
                case .failure(let error):
                    return completion(.failure(error))
                }
            }?.resume()
    }
    
    func getPhotosFromAlbums(_ albums: [Album], completion: @escaping (Result<[Photo]>) -> ()) {
        guard let photosEndPoint = URL(string: URLPaths.photos.rawValue) else { return }
        apiClient.fetchFromPath(photosEndPoint) { result in
                switch result {
                case .success(let data):
                    self.dbCache.updatePhotosWith(data: data, usingAlbums: albums, completion: { photos in
                        if let photos = photos {
                            return completion(.success(photos))
                        } else {
                            return completion(.failure(ManagerError.FailedToSaveCoreDataError))
                        }
                    })
                case .failure(let error):
                    return completion(.failure(error))
                }
            }?.resume()
    }
}
