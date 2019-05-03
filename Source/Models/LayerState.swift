//
//  LayerState.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 5/3/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import RealmSwift

class LayerState: Object {
    
    @objc open dynamic var rawValue: Int = 0
    @objc open dynamic var bookId: String!
    
    override open class func primaryKey() -> String {
        return "bookId"
    }
}

extension LayerState {
    
    static func store(items: LayersTableViewController.Items, bookId: String, configuration: FolioReaderConfig) {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)

            let layerState = LayerState()
            layerState.rawValue = items.rawValue
            layerState.bookId = bookId
            
            try realm.write {
                realm.add(layerState, update: true)
            }
            
        }
        catch {
            print(error)
        }
        
    }
    
    static func layerState(for bookId: String, configuration: FolioReaderConfig) -> LayersTableViewController.Items? {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            let predicate = NSPredicate(format:"bookId = %@", bookId)
            
            if let toolState = realm.objects(LayerState.self).filter(predicate).first {
                
                let item = LayersTableViewController.Items(rawValue: toolState.rawValue)
                return item
                
            }
            
            return nil
            
        }
            
        catch {
            print(error)
        }
        
        return nil
    }
}
