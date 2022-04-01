//
//  HttpClient.swift
//  Core
//
//  Created by Willian Policiano on 22/03/22.
//

import Foundation

protocol HttpClient {
    typealias Response = (statusCode: Int, data: Data)
    typealias Result = Swift.Result<Response, Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
