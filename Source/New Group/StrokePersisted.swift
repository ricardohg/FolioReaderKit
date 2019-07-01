//
//  StrokePersisted.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 7/1/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation

/// struct to persist strokes

public class StrokePersisted: Codable {
    
    var samples: [StrokeSamplePersisted] = []
}

public struct StrokeSamplePersisted: Codable {
    
    let timestamp: TimeInterval
    let location: CGPoint
}

extension StrokePersisted {
    
    func save(for bookId: String) throws {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(self)
            UserDefaults.standard.set(encoded, forKey: bookId)
        }
        catch {
            throw error
        }
    }
    
    static func retreiveStrokes(for bookId: String) throws -> StrokePersisted? {
        
        if let stroke = UserDefaults.standard.data(forKey: bookId) {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(StrokePersisted.self, from: stroke)
            return decoded
        }
        
        return nil
    }
}
