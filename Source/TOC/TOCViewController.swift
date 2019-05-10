//
//  TOCViewController.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 5/9/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class TOCViewController: UIViewController {

    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var bookTItleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var drawerView: UIView!
    
    private var pageController: PageViewController!
    
    var swipeInteractionController: SwipeInteractionController?

    var index = 0
    
    var book: FRBook?
    var config: FolioReaderConfig?
    var reader: FolioReader?
    var chapterDelegate: FolioReaderChapterListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        index = reader?.currentMenuIndex ?? 0
    
        segmentedControl.addTarget(self, action: #selector(didSwitchMenu(_:)), for: UIControl.Event.valueChanged)
        segmentedControl.selectedSegmentIndex = index
        
        embedPageViewController()
        loadBookInfo()
        
        segmentedControl.removeBorders()
        
        swipeInteractionController = SwipeInteractionController(viewController: self)
    }
    
    private func loadBookInfo() {
        
        guard let book = book else { return }
        
        bookTItleLabel.text = book.title
        authorLabel.text = book.authorName
        categoryLabel.text = "Category"

        
        if let coverImage = book.coverImage, let artwork = UIImage(contentsOfFile: coverImage.fullHref) {
            
           bookCoverImageView.image = artwork
        }
        
    }
    
    private func embedPageViewController() {
        
        guard let config = config, let reader = reader, let delegate = chapterDelegate, let book = book else { return }
    
        let chapter = FolioReaderChapterList(folioReader: reader, readerConfig: config, book: book, delegate: delegate)
        let highlight = FolioReaderHighlightList(folioReader: reader, readerConfig: config)
        pageController = PageViewController(folioReader: reader, readerConfig: config)
        
        pageController.viewControllerOne = chapter
        pageController.viewControllerTwo = highlight
        
        addChild(pageController)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageContainerView.addSubview(pageController.view)
        
        NSLayoutConstraint.activate([
            pageController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor),
            pageController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor)
            ])
        
        pageController.didMove(toParent: self)
        
    }
    
    @objc func didSwitchMenu(_ sender: UISegmentedControl) {
        
        pageController.didSwitchMenu(sender)

    }

    
    // storyboard init
    
    static func create(with reader: FolioReader,
                       config:FolioReaderConfig,
                       book: FRBook,
                       chapterDelegate: FolioReaderChapterListDelegate
        ) -> TOCViewController {
        
        guard let tocViewController = UIStoryboard(name: "TOC", bundle: Bundle(for: TOCViewController.self)).instantiateInitialViewController() as? TOCViewController
            else {
                assertionFailure("cannot initialize view controller from storyboard")
                return TOCViewController()
        }
        
        tocViewController.reader = reader
        tocViewController.book = book
        tocViewController.config = config
        tocViewController.chapterDelegate = chapterDelegate
        
        return tocViewController
        
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

/// https://stackoverflow.com/questions/31651983/how-to-remove-border-from-segmented-control

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
