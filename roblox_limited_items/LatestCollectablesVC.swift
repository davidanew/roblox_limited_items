//
//  LatestItemsVC.swift
//  roblox_limited_items
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import UIKit

class LatestCollectablesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    let apiInterface = ApiInterface()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiInterface.getLatestCollectablesList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default , reuseIdentifier: "catalogCell")
        cell.textLabel?.text = apiInterface.getLatestCollectablesList()[indexPath.row]
        return cell
    }

}


