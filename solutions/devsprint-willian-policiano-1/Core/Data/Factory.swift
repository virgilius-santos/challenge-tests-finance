//
//  Factory.swift
//  Core
//
//  Created by Willian Policiano on 01/04/22.
//

import Foundation

public enum Factory {
    public static func makeService(url: URL) -> HomeLoader {
        HomeService(
            url: url,
            httpClient: URLSessionHttpClient(session: URLSession.shared)
        )
    }
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: request, completionHandler: completionHandler).resume()
    }
}
