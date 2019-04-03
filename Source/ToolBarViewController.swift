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
        case eraser
        case none
    }
    
    let pencilButton = UIButton(type: .custom)
    let eraserButton = UIButton(type: .custom)
    
    let undoButton = UIButton(type: .custom)
    let redoButton = UIButton(type: .custom)
    
    static let toolbarHeight: CGFloat = 50
    var strokeViewController: StrokeFormatMenuTableViewController?
    
    var toolSelected: ((Tool) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        strokeViewController?.selectedStrokeStyle = { style in
            print(style)
        }
    }
    
    private func setupView() {
        
        view.backgroundColor = UIColor(rgba: "#2BB2AC")
        
        pencilButton.setBackgroundImage(UIImage(readerImageNamed: "pencil"), for: .normal)
        pencilButton.setBackgroundImage(UIImage(readerImageNamed: "pencil-selected"), for: .selected)
        pencilButton.setBackgroundImage(UIImage(readerImageNamed: "pencil-selected"), for: .highlighted)
        
        eraserButton.setBackgroundImage(UIImage(readerImageNamed: "eraser-icon"), for: .normal)
        
        
        undoButton.setBackgroundImage(UIImage(readerImageNamed: "undo-icon"), for: .normal)
        redoButton.setBackgroundImage(UIImage(readerImageNamed: "redo-icon"), for: .normal)
        
        pencilButton.addTarget(self, action: #selector(pencilPressed), for: .touchUpInside)
        eraserButton.addTarget(self, action: #selector(eraserPressed), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(undoPressed), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(redoPressed), for: .touchUpInside)
    
        view.addSubview(undoButton)
        view.addSubview(redoButton)
        
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leftPadding: CGFloat = 20
        
        redoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -leftPadding).isActive = true
        redoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        undoButton.trailingAnchor.constraint(equalTo: redoButton.leadingAnchor, constant: -leftPadding).isActive = true
        undoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // stack view
        
        let spacing: CGFloat = 31
        
        let stackView = UIStackView(arrangedSubviews: [pencilButton, eraserButton])
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
    }
    
    // MARK - Actions

    @objc func pencilPressed() {
    //sender.isSelected = !sender.isSelected
    self.toolSelected?(.pencil)
    }
    
    @objc func eraserPressed(_ sender: UIButton) {
        self.toolSelected?(.eraser)
    }

    @objc func undoPressed() {
        NotificationCenter.default.post(name: .undoAction, object: nil)
    
    }
    
    @objc func redoPressed() {
        NotificationCenter.default.post(name: .redoAction, object: nil)
    }
}
