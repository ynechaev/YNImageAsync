//
//  ListViewModel.swift
//  Demo
//
//  Created by Yuri Nechaev on 20.07.2023.
//  Copyright © 2023 Yury Nechaev. All rights reserved.
//

import Foundation

struct ListViewModel {
    let images: [ItemViewModel]?
    
    init(response: ListResponse) {
        self.images = response.images?.compactMap { ItemViewModel(imageUrl: $0.url, imageTitle: $0.title) }
    }
}

struct ItemViewModel {
    let imageUrl: String
    let imageTitle: String
}
