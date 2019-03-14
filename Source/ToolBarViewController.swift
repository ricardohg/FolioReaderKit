//
//  ToolBarViewController.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 2/26/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

class ToolBarViewController: UIViewController {
    
    enum Tool {
        case pencil
        case none
    }
    
    let pencilButton = UIButton(type: .custom)
    let undoButton = UIButton(type: .system)
    let redoButton = UIButton(type: .system)
    
    var toolSelected: ((Tool) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    private func setupView() {
        
        view.backgroundColor = UIColor(rgba: "#2BB2AC")
        
        pencilButton.setImage(UIImage(readerImageNamed: "pencil"), for: .normal)
        pencilButton.setImage(UIImage(readerImageNamed: "pencil-selected"), for: .selected)
        
        undoButton.setTitle("undo", for: .normal)
        redoButton.setTitle("redo", for: .normal)
        
        pencilButton.addTarget(self, action: #selector(pencilPressed), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(undoPressed), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(redoPressed), for: .touchUpInside)
        
        view.addSubview(pencilButton)
        view.addSubview(undoButton)
        view.addSubview(redoButton)
        
        pencilButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leftPadding: CGFloat = 20
        
        undoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftPadding).isActive = true
        undoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        redoButton.leadingAnchor.constraint(equalTo: undoButton.trailingAnchor, constant: leftPadding).isActive = true
        redoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        pencilButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pencilButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
    }
    
    // MARK - Actions
    
    @objc func pencilPressed() {
        self.toolSelected?(.pencil)
    }

    @objc func undoPressed() {
        NotificationCenter.default.post(name: .undoAction, object: nil)
    
    }
    
    @objc func redoPressed() {
        NotificationCenter.default.post(name: .redoAction, object: nil)

    }
}
