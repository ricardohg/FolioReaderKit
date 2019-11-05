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
        case pen
        case penOptions(button: UIButton)
        case eraser
        case eraseOptions(button: UIButton)
        case highlighter
        case highlightOptions(button: UIButton)
        case shape
        case shapeOptions(button: UIButton)
        case none
    }
    
    let pencilButton = UIButton(type: .custom)
    let eraserButton = UIButton(type: .custom)
    let highlightButton = UIButton(type: .custom)
    let shapeButton = UIButton(type: .custom)
    
    let undoButton = UIButton(type: .custom)
    let redoButton = UIButton(type: .custom)
    
    static let toolbarHeight: CGFloat = 50
    var strokeViewController: StrokeFormatMenuTableViewController?
    
    var toolSelected: ((Tool) -> ())?
    
    var currentTool: Tool = .none {
        didSet {
            
            switch self.currentTool {
            case .pen:
                self.pencilButton.isSelected = true
                self.eraserButton.isSelected = false
                self.highlightButton.isSelected = false
            case .eraser:
                self.eraserButton.isSelected = true
                self.pencilButton.isSelected = false
                self.highlightButton.isSelected = false
            case .highlighter:
                self.highlightButton.isSelected = true
                self.pencilButton.isSelected = false
                self.eraserButton.isSelected = false
            case .none:
                self.pencilButton.isSelected = false
                self.eraserButton.isSelected = false
                self.highlightButton.isSelected = false
            case .shape:
                self.pencilButton.isSelected = false
                self.eraserButton.isSelected = false
                self.highlightButton.isSelected = false
                self.shapeButton.isSelected = true
            default:
                break
            }
            
        }
    }
    
    let leftPadding: CGFloat = 20
    
    // MARK: - Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        strokeViewController?.selectedStrokeStyle = { style in
            print(style)
        }
    }
    
    // MARK: - Methods -
    private func setupView() {
        view.addSubview(undoButton)
        view.addSubview(redoButton)
        view.backgroundColor = UIColor(rgba: "#2BB2AC")
        setupPencilButton()
        setupEraserButton()
        setupHighlightButton()
        setupShapeButton()
        setupUndoButton()
        setupRedoButton()
        setupStackView()
    }
    
    private func setupPencilButton() {
        pencilButton.setBackgroundImage(UIImage(readerImageNamed: "pencil"), for: .normal)
        pencilButton.setBackgroundImage(UIImage(readerImageNamed: "pencil-selected"), for: .selected)
        pencilButton.setBackgroundImage(UIImage(readerImageNamed: "pencil-selected"), for: .highlighted)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pencilOptionsGesture))
        pencilButton.addGestureRecognizer(longPressGestureRecognizer)
        pencilButton.addTarget(self, action: #selector(pencilPressed), for: .touchUpInside)
    }
    
    private func setupEraserButton() {
        eraserButton.setBackgroundImage(UIImage(readerImageNamed: "eraser-icon"), for: .normal)
        eraserButton.setBackgroundImage(UIImage(readerImageNamed: "eraser-selected"), for: .selected)
        eraserButton.setBackgroundImage(UIImage(readerImageNamed: "eraser-selected"), for: .highlighted)
        
        let longPressEraseGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(eraserOptionsGesture(_:)))
        eraserButton.addGestureRecognizer(longPressEraseGestureRecognizer)
        eraserButton.addTarget(self, action: #selector(eraserPressed), for: .touchUpInside)
    }
    
    private func setupHighlightButton() {
        highlightButton.setBackgroundImage(UIImage(readerImageNamed: "highlight-icon"), for: .normal)
        highlightButton.setBackgroundImage(UIImage(readerImageNamed: "highlight-icon-selected"), for: .selected)
        highlightButton.setBackgroundImage(UIImage(readerImageNamed: "highlight-icon-selected"), for: .highlighted)
        highlightButton.addTarget(self, action: #selector(highlighterPressed(_:)), for: .touchUpInside)
    }
    
    private func setupShapeButton() {
        shapeButton.setBackgroundImage(UIImage(readerImageNamed: "shape-icon"), for: .normal)
        shapeButton.setBackgroundImage(UIImage(readerImageNamed: "shape-icon-selected"), for: .selected)
        shapeButton.setBackgroundImage(UIImage(readerImageNamed: "shape-icon-selected"), for: .highlighted)
        shapeButton.addTarget(self, action: #selector(shapePressed), for: .touchUpInside)
    }
    
    private func setupUndoButton() {
        undoButton.setBackgroundImage(UIImage(readerImageNamed: "undo-icon"), for: .normal)
        undoButton.addTarget(self, action: #selector(undoPressed), for: .touchUpInside)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.trailingAnchor.constraint(equalTo: redoButton.leadingAnchor, constant: -leftPadding).isActive = true
        undoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    private func setupRedoButton() {
        redoButton.setBackgroundImage(UIImage(readerImageNamed: "redo-icon"), for: .normal)
        redoButton.addTarget(self, action: #selector(redoPressed), for: .touchUpInside)
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -leftPadding).isActive = true
        redoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupStackView() {
        let spacing: CGFloat = 0
               
        let stackView = UIStackView(arrangedSubviews: [pencilButton, highlightButton, eraserButton, shapeButton])
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
    
    @objc func pencilPressed(_ sender: UIButton) {
        currentTool = .pen
        self.toolSelected?(.pen)
    }
    
    @objc func pencilOptionsGesture(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            currentTool = .pen
            self.toolSelected?(.penOptions(button: pencilButton))
            
        }
    }
    
    @objc func eraserPressed(_ sender: UIButton) {
        currentTool = .eraser
        self.toolSelected?(.eraser)
    }
    
    @objc func eraserOptionsGesture(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            currentTool = .eraser
            self.toolSelected?(.eraseOptions(button: eraserButton))
            
        }
    }
    
    @objc func highlighterPressed(_ sender: UIButton) {
        currentTool = .highlighter
        self.toolSelected?(.highlightOptions(button: highlightButton))
    }
    
    @objc private func shapePressed(_ sender: UIButton) {
        currentTool = .shape
        self.toolSelected?(.shapeOptions(button: shapeButton))
    }

    @objc func undoPressed() {
        NotificationCenter.default.post(name: .undoAction, object: nil)
    
    }
    
    @objc func redoPressed() {
        NotificationCenter.default.post(name: .redoAction, object: nil)
    }
}
