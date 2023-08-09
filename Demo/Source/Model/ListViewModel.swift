//
//  ListViewModel.swift
//  Demo
//
//  Created by Yuri Nechaev on 20.07.2023.
//  Copyright © 2023 Yury Nechaev. All rights reserved.
//

import Foundation
import Combine

final class ListViewModel: ObservableObject {
    @Published private(set) var images = [ItemViewModel]()
    @Published private(set) var error: APIError?
    
    private let api: ListDataProvider
    
    init(api: ListDataProvider = ListDataProvider()) {
        self.api = api
    }
    
    func fetch() {
        api.loadList()
            .map(\.images)
            .map { $0.map { ItemViewModel(imageUrl: $0.url, imageTitle: $0.title) } }
            .catch { [weak self] error -> AnyPublisher<[ItemViewModel], Never> in
                print("API Error occured: \(error)")
                self?.error = error
                return Just([])
                    .eraseToAnyPublisher()
            }
            .assign(to: &$images)
    }
}

struct ItemViewModel {
    let imageUrl: String
    let imageTitle: String
}
