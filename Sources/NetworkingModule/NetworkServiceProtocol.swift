//
//  NetworkServiceProtocol.swift
//  ArchPatternsLectureExample
//
//  Created by Sandro Maraneli on 11.11.24.
//

public protocol NetworkServiceProtocol {
    func fetchData<T: Decodable>(urlString: String, modelType: T.Type, completion: @escaping @Sendable (T?, Error?) -> Void)
}

