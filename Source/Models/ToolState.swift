//
//  ToolState.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 4/23/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation
import RealmSwift

open class ToolState: Object {
    
    @objc open dynamic var colorHex: String!
    @objc open dynamic var thickness: Double = 1
    @objc open dynamic var bookId: String!
    
    override open class func primaryKey() -> String {
        return "bookId"
    }
    
}

extension ToolState {
    
    static func store(color: UIColor, thickness: Double, bookId: String, configuration: FolioReaderConfig) {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            let toolState = ToolState()
            toolState.colorHex = color.hexString(false)
            toolState.thickness = thickness
            toolState.bookId = bookId
            
            try realm.write {
                realm.add(toolState, update: .modified)
            }
            
        }
        catch {
            print(error)
        }
        
    }
    
    
    
    static func toolState(for bookId: String, configuration: FolioReaderConfig) -> ToolState? {
        
        do {
            let realm = try Realm(configuration: configuration.realmConfiguration)
            
            let predicate = NSPredicate(format:"bookId = %@", bookId)
            
            let toolState = realm.objects(ToolState.self).filter(predicate).first
            return toolState
            
        }
            
        catch {
            print(error)
        }
        
        return nil
    }
}
