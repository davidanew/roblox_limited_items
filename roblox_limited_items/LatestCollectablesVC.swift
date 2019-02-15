//
//  LatestItemsVC.swift
//  roblox_limited_items
//
//  Created by David New on 11/02/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import UIKit
//import Kingfisher

class LatestCollectablesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    // object to handle API calles
    let apiInterface = ApiInterface()
    // object to handle HTTP calls to get image
    let imageInterface = ImageInterface()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //trigger gtiing get the list of latest collectables. This is ansync operation with
        //callback of getLatestCollectablesHandler
        apiInterface.getLatestCollectables(completionHandler: getLatestCollectablesHandler)
    }
    
    //TODO please look at closures and put this in viewWillAppear
    func getLatestCollectablesHandler(returnArray : [String]) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //on refresh get number of entries according to apiInterface
        if let numEntries = apiInterface.getNumEntries(){
            return numEntries
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //on refresh update the current cell
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "catalogCell")
        // populate name with one held by apiInterface
        if let name = apiInterface.getName(index: (indexPath.row)){
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = "error"
        }
//        // populate the detailed text with the "Updated" field
//        if let updated = apiInterface.getUpdated(index: indexPath.row) {
//            cell.detailTextLabel?.text = updated
//        }
//        else {
//            cell.detailTextLabel?.text = "error"
//        }
        if let price = apiInterface.getPrice(index: (indexPath.row)) {
            if let remaining = apiInterface.getRemaining(index: (indexPath.row)) {
                if (price != "" && remaining != "") {
                    cell.detailTextLabel?.text = "\(remaining) available @ \(price) Robux"
                }
                else if remaining == "" {
                    cell.detailTextLabel?.text = "None available"
                }
                else if let isForSale = apiInterface.getIsForSale(index: indexPath.row) {
                    if isForSale == "false" {
                        cell.detailTextLabel?.text = "Not for sale"
                    }
                }
            }
        }
            
        
        if let thumbnailUrl = apiInterface.getThumbnailUrl(index: indexPath.row) {
            var image : UIImage?

            image = imageInterface.getImage(url : thumbnailUrl, row: indexPath.row ) {row in
                let indexPath = IndexPath(item: row, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .left)
            }
            
            if let thisImage = image {
                cell.imageView?.image = thisImage
                
            }
            //cell.imageView?.image = UIImage(named: "egg")
        }
        return cell
    }

}


//let url = URL(string: "https://example.com/image.png")
//imageView.kf.setImage(with: url)
