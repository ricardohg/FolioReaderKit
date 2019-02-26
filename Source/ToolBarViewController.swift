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
    }
    
    var toolSelected: (() -> (Tool))?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    private func setupView() {
        
        view.backgroundColor = UIColor(rgba: "#2BB2AC")
        
        let pencilButton = UIButton(type: .custom)
        
        pencilButton.setImage(UIImage(readerImageNamed: "pencil"), for: .normal)
        pencilButton.setImage(UIImage(readerImageNamed: "pencil-selected"), for: .selected)
        
        view.addSubview(pencilButton)
        pencilButton.translatesAutoresizingMaskIntoConstraints = false
        
        pencilButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pencilButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
    }

}
