//
//  ShapePersisted.swift
//  FolioReaderKit
//
//  Created by Santiago Carmona on 4/11/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import Foundation

public struct ShapePersisted: Codable {
    var pathData: String
    var backgroundColorHexValue: String
    var borderColorHexValue: String
    var borderWidth: CGFloat
    
    init(shape: Shape) {
        pathData = NSKeyedArchiver.archivedData(withRootObject: shape.path).base64EncodedString()    
        backgroundColorHexValue = shape.backgroundColor.hexString(false)
        borderColorHexValue = shape.borderColor.hexString(false)
        borderWidth = shape.borderWidth
    }
}
