//
//  FakeHomeLoader.swift
//  Core
//
//  Created by Willian Policiano on 30/03/22.
//

import Foundation

public class FakeHomeLoader: HomeLoader {
    public init() {}
    
    public func getHome(completion: @escaping (HomeLoader.Result) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(Home(balance: 123, savings: 321, spending: 213)))
        }
    }
}
