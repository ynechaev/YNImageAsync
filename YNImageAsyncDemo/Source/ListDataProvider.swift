//
//  YNDataProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation
import Combine

let url = URL(string:"https://s3.amazonaws.com/work-project-image-loading/images.json")!

enum APIError: Error, CustomStringConvertible {
    case network
    case decodingError
    case unknown(Error)
    
    var description: String {
        switch self {
        case .network:
            return "Network error"
        case .decodingError:
            return "Decoding error"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    init(error: Error) {
        switch error {
        case is URLError:
            self = .network
        case is DecodingError:
            self = .decodingError
        default:
            self = .unknown(error)
        }
    }
}

class ListDataProvider {
    private(set) var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadList(_ url: URL = url) -> AnyPublisher<ListResponse, APIError> {
        session.objectTaskPublisher(url)
    }
  
}

extension URLSession {
    
    func objectTaskPublisher<T: Decodable>(_ url: URL) -> AnyPublisher<T, APIError> {
        dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { APIError.init(error: $0) }
            .eraseToAnyPublisher()
    }
    
}
