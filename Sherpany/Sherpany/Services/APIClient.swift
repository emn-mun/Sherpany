import UIKit
import Foundation

public enum Result<ValueType> {
    case success(ValueType)
    case failure(Error)
    
    public var value:ValueType? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error:Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public enum URLPaths: String {
    case posts = "http://jsonplaceholder.typicode.com/posts"
    case users = "http://jsonplaceholder.typicode.com/users"
    case albums = "http://jsonplaceholder.typicode.com/albums"
    case photos = "http://jsonplaceholder.typicode.com/photos"
}

public typealias JSON = [Dictionary<String, Any>]

class APIClient {
    
    enum APIClientError: Error {
        case NoHTTPResponse
        case HTTPErro(statusCode: Int, errorDescription: String?)
        case NoData
        case JSONConversionFailed
    }
    
    
    let sesstion = URLSession(configuration: URLSessionConfiguration.default)
    
    private func requestTask(with urlRequest: URLRequest, completion: @escaping (Result<Data>, HTTPURLResponse?) -> ()) -> URLSessionTask {
        return sesstion.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                return completion(.failure(error!), response as? HTTPURLResponse)
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(APIClientError.NoHTTPResponse), response as? HTTPURLResponse)
            }
            guard let returnedData = data else {
                return completion(.failure(APIClientError.NoData), httpResponse)
            }
            guard(200...299).contains(httpResponse.statusCode) else {
                let responseBody: String?
                if let data = data {
                    responseBody = String(data: data, encoding: .utf8)
                } else {
                    responseBody = nil
                }
                return completion(.failure(APIClientError.HTTPErro(statusCode: httpResponse.statusCode, errorDescription: responseBody)), httpResponse)
            }
            completion(.success(returnedData), httpResponse)
        }
    }
    
    func fetchFromPath(_ url: URL, withResult completion: @escaping (Result<JSON>) -> ()) -> URLSessionTask? {
        
        return requestTask(with: URLRequest(url: url), completion: { result, response in
            switch result {
            case .success(let data):
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
                        throw APIClientError.JSONConversionFailed
                    }
                    completion(.success(json))
                } catch let error as APIClientError {
                    completion(.failure(error))
                } catch let error as NSError {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
