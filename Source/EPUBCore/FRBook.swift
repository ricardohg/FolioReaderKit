//
//  FRBook.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 09/04/15.
//  Extended by Kevin Jantzer on 12/30/15
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

open class FRBook: NSObject {
    var metadata = FRMetadata()
    var spine = FRSpine()
    var smils = FRSmils()
    var version: Double?
    
    public var opfResource: FRResource!
    public var tocResource: FRResource?
    public var uniqueIdentifier: String?
    public var coverImage: FRResource?
    public var name: String?
    public var resources = FRResources()
    public var tableOfContents: [FRTocReference]!
    public var flatTableOfContents: [FRTocReference]!
    public var categories: [String]?

    var hasAudio: Bool {
        return smils.smils.count > 0
    }

    var title: String? {
        return metadata.titles.first
    }

    var authorName: String? {
        return metadata.creators.first?.name
    }

    // MARK: - Media Overlay Metadata
    // http://www.idpf.org/epub/301/spec/epub-mediaoverlays.html#sec-package-metadata

    var duration: String? {
        return metadata.find(byProperty: "media:duration")?.value
    }

    var activeClass: String {
        guard let className = metadata.find(byProperty: "media:active-class")?.value else {
            return "epub-media-overlay-active"
        }
        return className
    }

    var playbackActiveClass: String {
        guard let className = metadata.find(byProperty: "media:playback-active-class")?.value else {
            return "epub-media-overlay-playing"
        }
        return className
    }
    
    /**
     Calculates the viewPortSize coming in the meta tag on the html
     */
    lazy var viewPortSize: CGSize? = {
        guard let html = spine.spineReferences.first?.html?.lowercased() else {
            return nil
        }
        
        guard let viewPortStartIndex = html.lowercased().range(of: "<meta name=\"viewport\"")?.lowerBound,
            let viewPortEndIndex = html[viewPortStartIndex..<html.endIndex].firstIndex(of: ">") else {
                return nil
        }
        
        let viewPortTag = html[viewPortStartIndex...viewPortEndIndex]
        
        
        guard let contentStartIndex = viewPortTag.range(of: "content=\"")?.upperBound,
            let contentEndIndex = viewPortTag[contentStartIndex..<viewPortTag.endIndex].firstIndex(of: "\"") else {
                return nil
        }
        let range = contentStartIndex..<contentEndIndex
        let regex = "[^\\d.,+]"
        let viewPortSizeString = viewPortTag[range].replacingOccurrences(of: regex, with: "", options: .regularExpression, range: nil)
        let viewPortSizeComponents = viewPortSizeString.split(separator: ",").compactMap{( Double($0) )}
        if viewPortSizeComponents.count > 1 {
            let width = viewPortSizeComponents[0]
            let height = viewPortSizeComponents[1]
            return CGSize(width: width, height: height)
        }
        
        return nil
    }()

    // MARK: - Media Overlay (SMIL) retrieval

    /**
     Get Smil File from a resource (if it has a media-overlay)
     */
    func smilFileForResource(_ resource: FRResource?) -> FRSmilFile? {
        guard let resource = resource, let mediaOverlay = resource.mediaOverlay else { return nil }

        // lookup the smile resource to get info about the file
        guard let smilResource = resources.findById(mediaOverlay) else { return nil }

        // use the resource to get the file
        return smils.findByHref(smilResource.href)
    }

    func smilFile(forHref href: String) -> FRSmilFile? {
        return smilFileForResource(resources.findByHref(href))
    }

    func smilFile(forId ID: String) -> FRSmilFile? {
        return smilFileForResource(resources.findById(ID))
    }
    
    // @NOTE: should "#" be automatically prefixed with the ID?
    func duration(for ID: String) -> String? {
        return metadata.find(byProperty: "media:duration", refinedBy: ID)?.value
    }
}
