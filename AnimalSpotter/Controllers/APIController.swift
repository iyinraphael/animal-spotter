//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

final class APIController {

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NetworkError: Error {
        case noData, failedSignUp, failedSignIn, noToken
    }
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()
    
    var bearer: Bearer?
    
    // create function for sign up *Result let you signal success or failure
    func signup(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        print("signUpURL = \(signUpURL.absoluteString)")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            //                                                      trailing closures
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                if let error = error {
                    print("Sign up failed with error: \(error)")
                    completion(.failure(.failedSignUp))
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Sign up  was unsuccessful")
                    completion(.failure(.failedSignUp))
                    return
                }
                completion(.success(true))
            }

            task.resume()
       
        }catch {
            print("Error encoding user: \(error)")
            completion(.failure(.failedSignUp))
        }
    }
    
    // create function for sign in
    func signIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        print("signIn = \(signInURL.absoluteString)")
        
        var request = URLRequest(url: signInURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            //                                                      trailing closures
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Sign in failed with error: \(error)")
                    completion(.failure(.failedSignIn))
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Sign in was unsuccessful")
                    completion(.failure(.failedSignIn))
                    return
                }
                
                guard let data = data else {
                    print("No data received during sign in")
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    self.bearer = try self.jsonDecoder.decode(Bearer.self, from: data)
                } catch {
                    print("Error decoding bearer data: \(error)")
                    completion(.failure(.noToken))
                }
                
                completion(.success(true))
            }
            
            task.resume()
        
        }catch {
            print("Error encoding user: \(error)")
            completion(.failure(.failedSignIn))
        }
    }
    
    
    
    // create function for fetching all animal names
    
    // create function for fetching animal details
    
    // create function to fetch image
}
