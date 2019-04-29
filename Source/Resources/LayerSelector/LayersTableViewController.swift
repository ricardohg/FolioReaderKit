//
//  LayersTableViewController.swift
//  FolioReaderKit
//
//  Created by ricardo hernandez  on 2/28/19.
//  Copyright © 2019 FolioReader. All rights reserved.
//

import UIKit

public class LayersTableViewController: UITableViewController {
    
    var itemsSelected: (([Item]?) -> ())?
    
    enum Item: Int, CaseIterable {
        case all
        case pens
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView()
        doSelectAll()
    }
    
   private func doSelectAll() {
    let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            tableView.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = super.tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .checkmark
        
        selectItems(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let cell = super.tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .none
        
        selectItems(in: tableView)
        
    }
    
    private func selectItems(in tableView: UITableView) {
        
        let selectedIndexes = tableView.indexPathsForSelectedRows
        
        let selectedItems = selectedIndexes?.map { Item(rawValue: $0.row) }.compactMap { $0 }
        
        itemsSelected?(selectedItems)
        
    }




}
