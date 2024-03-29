//
//  File.swift
//  RickAndMorty
//
//  Created by Alex Silva on 27/12/24.
//

import Foundation

struct Client {
    let session = URLSession.shared
    let baseUrl: String
    private let contentType: String
    
    
    enum NetworkErrors: Error {
        case conection
        case invalidRequest
        case invalidResponse
        case client
        case server
    }
    
    init(baseUrl: String, contentType:String = "application/json") {
        self.baseUrl = baseUrl
        self.contentType = contentType
    }
    
    typealias requestHandler = ((Data?) -> Void)
    typealias errorHandler = ((NetworkErrors) -> Void)
    
    func get(_ path: String, queryParams: [String: String] = [:] , success: requestHandler?, failure: errorHandler? = nil) {
        request(method: "GET", path: path, body: nil, queryParams: queryParams, success: success, failure: failure)
        }
    
    func request(method: String, path: String, body: Data?,queryParams: [String: String] = [:], success: requestHandler?, failure: errorHandler? = nil) {
            guard let request = buildRequest(method: method, path: path, body: body, queryParams: queryParams) else {
                failure?(NetworkErrors.invalidRequest)
            
                return
            }
            
            let task = session.dataTask(with: request) { data, response, error in
                if let err = error {
                    #if DEBUG
                    debugPrint(err)
                    #endif
                    failure?(NetworkErrors.conection)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    failure?(NetworkErrors.invalidResponse)
                    return
                }
                
                let status = StatusCode(rawValue: httpResponse.statusCode)
                #if DEBUG
                print("Status: \(httpResponse.statusCode)")
                debugPrint(httpResponse)
                #endif
                switch status {
                case .success:
                    success?(data)
                case .clientError:
                    failure?(NetworkErrors.client)
                case .serverError:
                    failure?(NetworkErrors.server)
                default:
                    failure?(NetworkErrors.invalidResponse)
                }
            }
            task.resume()
        }
    
    private func buildRequest(method: String, path: String, body: Data?, queryParams: [String: String] = [:]) -> URLRequest? {
            var urlComp = URLComponents(string: baseUrl)!
            urlComp.path = path
            
            urlComp.queryItems = queryParams.map { (key , value ) in
             URLQueryItem(name: key, value: value)
            }
            
            guard let url = urlComp.url else { return nil }
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            #if DEBUG
            debugPrint(request)
            #endif
            return request
        }
}
