//
//  LatestItemsVC.swift
//  roblox_limited_items
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import UIKit
import Kingfisher

class LatestCollectablesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    let apiInterface = ApiInterface()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    apiInterface.getLatestCollectables(getLatestCollectablesCompletionHandler: getLatestCollectablesHandler)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiInterface.getLatestCollectables(getLatestCollectablesCompletionHandler: getLatestCollectablesHandler)
    }
    
    func getLatestCollectablesHandler(returnArray : [String]) {
//        print ("got here")
        tableView.reloadData()
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numEntries = apiInterface.getNumEntries(){
            return numEntries
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "catalogCell")
        if let name = apiInterface.getName(index: (indexPath.row)){
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = "error"
        }
        if let updated = apiInterface.getUpdated(index: indexPath.row) {
            cell.detailTextLabel?.text = updated
        }
        else {
            cell.detailTextLabel?.text = "error"
        }
        if let thumbnailUrl = apiInterface.getThumbnailUrl(index: indexPath.row) {
            cell.imageView?.kf.setImage(with: URL(string: thumbnailUrl), placeholder: nil)
        }
        else {
            cell.imageView?.image = UIImage(named: "egg")
        }
        return cell
    }

}


//let url = URL(string: "https://example.com/image.png")
//imageView.kf.setImage(with: url)
