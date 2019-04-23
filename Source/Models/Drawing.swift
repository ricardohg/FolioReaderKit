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
    @objc open dynamic var imageData: Data!
    @objc open dynamic var scale: Double = 1.0
    
    override open class func primaryKey() -> String {
        return "drawId"
    }
    
    var image: UIImage? {
        return UIImage(data: imageData, scale: CGFloat(scale))
    }
    
}

extension Drawing {
    
    
    /// Saves an image (drawing) in realm
    ///
    /// - Parameters:
    ///   - image: the image to be save
    ///   - page: page number
    ///   - bookId: book unique identifier (name)
    ///   - configuration: realm configuration
    static func store(image: UIImage, page: Int, bookId: String, configuration: FolioReaderConfig) {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            if let imageData = image.pngData() {
                
                let drawing = Drawing()
                drawing.drawId = bookId + "_" + "\(page)"
                drawing.imageData = imageData
                drawing.scale = Double(image.scale)
                
                try realm.write {
                    realm.add(drawing, update: true)
                }
            }
            else {
                print("cannot convert image to data")
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
    static func drawing(bookId: String, page: Int, configuration: FolioReaderConfig) -> Drawing? {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            let drawId = bookId + "_" + "\(page)"
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
