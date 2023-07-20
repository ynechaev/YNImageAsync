//
//  ListResponseModel.swift
//  Demo
//
//  Created by Yuri Nechaev on 20.07.2023.
//  Copyright © 2023 Yury Nechaev. All rights reserved.
//

import Foundation

struct ListResponse: Codable {
    let images: [ListObject]?
}

struct ListObject: Codable {
    let url: String
    let title: String
}
