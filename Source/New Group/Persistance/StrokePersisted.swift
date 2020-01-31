//
//  StrokePersisted.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 7/1/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

/// struct to persist strokes

public struct StrokeCollectionPersisted: Codable {
    public var strokes: [StrokePersisted] = []
    
    init(strokeCollection: StrokeCollection) {
        
        self.strokes = strokeCollection.strokes.map { StrokePersisted(stroke: $0) }
    }
    
    public init(strokes: [StrokePersisted]) {
        self.strokes = strokes
    }
    
    func strokeCollection() -> StrokeCollection? {
        let strokeCollection = StrokeCollection()
        strokeCollection.strokes = strokes.map { $0.stroke() }
        return strokeCollection
    }
    
}

public struct StrokePersisted: Codable {
    
    var samples: [StrokeSamplePersisted] = []
    var colorHexValue: String
    var shapePersisted: ShapePersisted?
    
    init(stroke: Stroke) {
        self.samples = stroke.samples.map { StrokeSamplePersisted(sample: $0) }
        self.colorHexValue = stroke.color?.hexString(false) ?? ""
        if let shape = stroke.shape {
            self.shapePersisted = ShapePersisted(shape: shape)
        }
    }
    
    func stroke() -> Stroke {
        let stroke: Stroke
        if let shapePersisted = self.shapePersisted,
            let data = Data(base64Encoded: shapePersisted.pathData),
            let path = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIBezierPath {
            let shape = Shape(
                path: path,
                backgroundColor: UIColor.hexStringToUIColor(hex: shapePersisted.backgroundColorHexValue),
                borderColor: UIColor.hexStringToUIColor(hex: shapePersisted.borderColorHexValue),
                borderWidth: shapePersisted.borderWidth
            )
            stroke = Stroke(shape: shape)
        } else {
            stroke = Stroke()
        }
        
        stroke.samples = samples.map { $0.strokeSample() }
        stroke.color = UIColor.hexStringToUIColor(hex: colorHexValue)
        
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
    
    public func save(bookId: String, page: Int) throws {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(self)
            let key = bookId + "_" + "\(page)"
            UserDefaults.standard.set(encoded, forKey: key)
        }
        catch {
            throw error
        }
    }
    
    static func retreiveStrokes(for bookId: String, page: Int) throws -> StrokeCollectionPersisted? {
        
        let key = bookId + "_" + "\(page)"
        
        if let stroke = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(StrokeCollectionPersisted.self, from: stroke)
            return decoded
        }
        
        return nil
    }
}
