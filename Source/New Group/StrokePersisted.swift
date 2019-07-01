//
//  StrokePersisted.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 7/1/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation

/// struct to persist strokes

public struct StrokeCollectionPersisted: Codable {
    var strokes: [StrokePersisted] = []
    
    init(strokeCollection: StrokeCollection) {
        
        self.strokes = strokeCollection.strokes.map { StrokePersisted(stroke: $0) }
    }
    
    func strokeCollection() -> StrokeCollection? {
        let strokeCollection = StrokeCollection()
        strokeCollection.strokes = strokes.map { $0.stroke() }
        return strokeCollection
    }
    
}

public struct StrokePersisted: Codable {
    
    var samples: [StrokeSamplePersisted] = []
    
    init(stroke: Stroke) {
        
        self.samples = stroke.samples.map { StrokeSamplePersisted(sample: $0) }
        
    }
    
    func stroke() -> Stroke {
        let stroke = Stroke()
        stroke.samples = samples.map { $0.strokeSample() }
        return stroke
    }
}

public struct StrokeSamplePersisted: Codable {
    
    let timestamp: TimeInterval
    let location: CGPoint
    
    init(sample: StrokeSample) {
        self.timestamp = sample.timestamp
        self.location = sample.location
    }
    
    func strokeSample() -> StrokeSample {
        return StrokeSample(timestamp: self.timestamp, location: self.location, coalesced: false)
    }
}

extension StrokeCollectionPersisted {
    
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
    
    static func retreiveStrokes(for bookId: String) throws -> StrokeCollectionPersisted? {
        
        if let stroke = UserDefaults.standard.data(forKey: bookId) {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(StrokeCollectionPersisted.self, from: stroke)
            return decoded
        }
        
        return nil
    }
}
