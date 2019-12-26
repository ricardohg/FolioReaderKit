//
//  FRSpine.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

struct Spine {
    var linear: Bool
    var resource: FRResource
    var html: String?

    init(resource: FRResource, linear: Bool = true) {
        self.resource = resource
        self.linear = linear
        self.html = try? String(contentsOfFile: resource.fullHref, encoding: String.Encoding.utf8)
    }
}

class FRSpine: NSObject {
    var pageProgressionDirection: String?
    var spineReferences = [Spine]()

    var isRtl: Bool {
        if let pageProgressionDirection = pageProgressionDirection , pageProgressionDirection == "rtl" {
            return true
        }
        return false
    }

    func nextChapter(_ href: String) -> FRResource? {
        var found = false;

        for item in spineReferences {
            if(found){
                return item.resource
            }

            if(item.resource.href == href) {
                found = true
            }
        }
        return nil
    }
}
