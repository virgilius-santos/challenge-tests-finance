//
//  URLSessionHttpClient.swift
//  Core
//
//  Created by Willian Policiano on 01/04/22.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

class URLSessionHttpClient: HttpClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
        let request = URLRequest(url: url)

        session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (statusCode: response.statusCode, data: data)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
    }
}
