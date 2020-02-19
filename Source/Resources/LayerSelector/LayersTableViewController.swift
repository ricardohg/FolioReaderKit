//
//  LayersTableViewController.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 2/28/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

public class LayersTableViewController: UITableViewController {
    
    // MARK: - Vars & Constants -
    struct Items: OptionSet {
        
        let rawValue: Int
        
        static let none = Items(rawValue: 1 << 0)
        static let all = Items(rawValue: 1 << 1)
        static let pens = Items(rawValue: 1 << 2)
        static let highlights = Items(rawValue: 1 << 3)
    }
    
    var itemsSelected: ((Items) -> ())?
    var items: Items = .all
    
    private let options: [Items] = [.all, .pens, .highlights]
    
    // MARK: - Life Cycle -
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView()
        proccessRowsWith(items: items)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row != 0 else {
            processAllRowsAndSelectItems(selection: true)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .checkmark
        
        selectItems(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard indexPath.row != 0 else {
            processAllRowsAndSelectItems(selection: false)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .none
        
        deselectAllItem(in: tableView)
        
        selectItems(in: tableView)
        
    }
    
    public override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard indexPath.row > 0 else {
            processAllRowsAndSelectItems(selection: false)
            return nil
        }
        
        return indexPath
    }
    
    // MARK : - Methods -
    
    private func proccessRowsWith(items: Items) {
        
        processAllRows(with: false)
    
        if items.contains(.all) {
            processAllRows(with: true)
        }
        else if items.contains(.none) {
            processAllRows(with: false)
        }
            
       if items.contains(.pens) {
            
            tableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
            guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) else { return }
            cell.accessoryType = .checkmark
            
        }
            
        if items.contains(.highlights) {
            tableView.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
            guard let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) else { return }
            cell.accessoryType = .checkmark
            
        }
    }
    
    private func processAllRows(with selection: Bool) {
        let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            
            if selection {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
                guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) else { return }
                cell.accessoryType = .checkmark
                
                items = .all
                
            }
            else {
                tableView.deselectRow(at: IndexPath(row: row, section: 0), animated: false)
                guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) else { return }
                cell.accessoryType = .none
                
                items = .none
            }
        }
    }
    
    // deselects "all" option
    
    private func deselectAllItem(in tableView: UITableView) {
        
        tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: false)
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else { return }
        cell.accessoryType = .none
        
        items.remove(.all)
        
    }
    
    private func selectItems(in tableView: UITableView) {
        
        items = .none
        
        let selectedIndexes = tableView.indexPathsForSelectedRows
        
        selectedIndexes?.forEach { index in
            
            items.remove(.none)
            items.insert(options[index.row])
            
        }
        
        itemsSelected?(items)
        
    }
    
    private func processAllRowsAndSelectItems(selection: Bool) {
        processAllRows(with: selection)
        selectItems(in: tableView)
    }
    
}
