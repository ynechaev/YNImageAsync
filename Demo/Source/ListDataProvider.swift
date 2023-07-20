//
//  YNDataProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

let url = URL(string:"https://s3.amazonaws.com/work-project-image-loading/images.json")!

class ListDataProvider {
    private(set) var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadList(_ url: URL = url) async throws -> ListResponse? {
        let (data, response) = try await session.data(from: url)
        guard let code = (response as? HTTPURLResponse)?.statusCode, code == 200 else {
            return nil
        }
        
        return try JSONDecoder().decode(ListResponse.self, from: data)
    }
    
}
