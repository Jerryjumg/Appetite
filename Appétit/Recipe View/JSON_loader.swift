//
//  JSON_loader.swift
//  Appétit
//
//  Created by Jerry Jung on 12/11/24.
//

import Foundation

class JSONLoader {
    static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T {
        let decoder = JSONDecoder()
        
        // Locate the JSON file
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        // Load the data
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            fatalError("Couldn't load \(filename) from main bundle: \(error)")
        }
    }
}
