//
//  FolioReaderChapterList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

/// Table Of Contents delegate
@objc protocol FolioReaderChapterListDelegate: class {
    /**
     Notifies when the user selected some item on menu.
     */
    func chapterList(_ chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference)

    /**
     Notifies when chapter list did totally dismissed.
     */
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList)
}

class FolioReaderChapterList: UITableViewController {

    weak var delegate: FolioReaderChapterListDelegate?
    fileprivate var tocItems = [FRTocReference]()
    fileprivate var book: FRBook
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader
    
    private var didLayoutSubviews = false
    

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig, book: FRBook, delegate: FolioReaderChapterListDelegate?) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader
        self.delegate = delegate
        self.book = book

        super.init(style: UITableView.Style.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.tableView.register(FolioReaderChapterListCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        
        tableView.tableFooterView = UIView()

        // Create TOC list
        self.tocItems = self.book.flatTableOfContents
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tocItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath) as! FolioReaderChapterListCell

        cell.setup(withConfiguration: self.readerConfig)
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        let isSection = tocReference.children.count > 0

        cell.indexLabel?.text = tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.hexStringToUIColor(hex: "2BB2AC")
        
        cell.selectedBackgroundView = selectedView

        // Add audio duration for Media Ovelay
        if let resource = tocReference.resource {
            if let mediaOverlay = resource.mediaOverlay {
                let duration = self.book.duration(for: "#"+mediaOverlay)

                if let durationFormatted = (duration != nil ? duration : "")?.clockTimeToMinutesString() {
                    let text = cell.indexLabel?.text ?? ""
                    cell.indexLabel?.text = text + (duration != nil ? (" - " + durationFormatted) : "")
                }
            }
        }

        // Mark current reading chapter
        if
            let currentPageNumber = self.folioReader.readerCenter?.currentPageNumber,
            let reference = self.book.spine.spineReferences[safe: currentPageNumber - 1],
            (tocReference.resource != nil) {
            let resource = reference.resource
            cell.indexLabel?.textColor = (tocReference.resource == resource ? .white : UIColor.hexStringToUIColor(hex: "#939393"))
            cell.contentView.backgroundColor = (tocReference.resource == resource ? UIColor.hexStringToUIColor(hex: "2BB2AC") : .clear)
        }

        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        delegate?.chapterList(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
       
        if let cell = tableView.cellForRow(at: indexPath) as? FolioReaderChapterListCell {
            cell.indexLabel?.textColor = .white
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss { 
            self.delegate?.chapterList(didDismissedChapterList: self)
        }
    }
}
