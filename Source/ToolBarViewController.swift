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
    
    enum EditDrawingType {
        case undo
        case redo
    }
    
    let pencilButton = UIButton(type: .custom)
    let undoButton = UIButton(type: .custom)
    let redoButton = UIButton(type: .custom)
    
    var toolSelected: ((Tool) -> ())?
    var undoRedoAction: ((EditDrawingType) -> ())?

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
//        view.addSubview(undoButton)
//        view.addSubview(redoButton)
        
        pencilButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        
        
//        undoButton.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
//        undoButton.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        pencilButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pencilButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
    }
    
    // MARK - Actions
    
    @objc func pencilPressed() {
        self.toolSelected?(.pencil)
    }

    @objc func undoPressed() {
        self.undoRedoAction?(.undo)
    }
    
    @objc func redoPressed() {
        self.undoRedoAction?(.undo)
    }
}
