//
//  Drawing.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 3/27/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import RealmSwift

/// A Drawing object
open class Drawing: Object {
    
    
    /// drawID is a combination of bookId + page number
    @objc open dynamic var drawId: String!
    @objc open dynamic var scale: Double = 1.0
    
    override open class func primaryKey() -> String {
        return "drawId"
    }
    
}

extension Drawing {
    
    
    /// Saves an image (drawing) in realm
    ///
    /// - Parameters:
    ///   - page: page number
    ///   - bookId: book unique identifier (name)
    ///   - configuration: realm configuration
    static func store(pageId: String, bookId: String, configuration: FolioReaderConfig) {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            let drawing = Drawing()
            drawing.drawId = bookId + "_" + pageId            
            
            try realm.write {
                realm.add(drawing, update: .modified)
            }
        }
        catch {
            print(error)
        }
    }
    
    /// returns a drawing object for a given page
    ///
    /// - Parameters:
    ///   - bookId: book unique identifier
    ///   - page: page number
    ///   - configuration: realm configuration
    /// - Returns: a drawing object
    static func drawing(bookId: String, pageId: String, configuration: FolioReaderConfig) -> Drawing? {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            let drawId = bookId + "_" + pageId
            let predicate = NSPredicate(format:"drawId = %@", drawId)
            
            let drawing = realm.objects(Drawing.self).filter(predicate).first
            return drawing
            
        }
        
        catch {
            print(error)
        }
       
        return nil
    }
}
