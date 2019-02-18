//  Copyright © 2019 David New. All rights reserved.

import UIKit
import SwiftyJSON

class LatestCollectablesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    // object to handle API calles
    let apiInterface = ApiInterface()
    // object to handle HTTP calls to get image
    let imageInterface = ImageInterface()
    var selectedRow : Int?
    
    // need this outlet so we can force refreshes
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //trigger getting get the list of latest collectables. This is ansync operation with
        //callback of getLatestCollectablesHandler
        apiInterface.getLatestCollectables(completionHandler: getLatestCollectablesHandler)
    }
    
    //TODO please look at closures and put this in viewWillAppear
    func getLatestCollectablesHandler(returnArray : [String]) {
        tableView.reloadData()
    }
    
    // Called by ios to get the number of cells in view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //on refresh get number of entries according to apiInterface
        if let numEntries = apiInterface.getNumEntries(){
            return numEntries
        }
        else {
            return 0
        }
    }
    
    // Called by ios to get information on a single cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "catalogCell")
        // populate name of the item
        if let name = apiInterface.getName(index: (indexPath.row)){
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = "error"
        }
        
        // This section updated the subtile (detail text)
        // We want the number of items remaining in here and also the price
        // But the API is not consistant
        // Still working out how to handle this
        /*
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
        */
        
        if let isForSale = apiInterface.getIsForSale(index: indexPath.row) {
            if isForSale == "true" {
                if let price = apiInterface.getPrice(index: indexPath.row) {
                    if let numRemaining = apiInterface.getRemaining(index: indexPath.row) {
                        if numRemaining != "" {
                            cell.detailTextLabel?.text = "\(numRemaining) available @ \(price) Robux"
                        }
                        else {
                            cell.detailTextLabel?.text = "\(price) Robux"
                        }
                    }
                    else {
                        cell.detailTextLabel?.text = "\(price) Robux"
                    }
                }
            }
            else {
                cell.detailTextLabel?.text = "Not for Sale"
            }
        }
        
        // Get the thumbnail URL image using imageInterface
        if let thumbnailUrl = apiInterface.getThumbnailUrl(index: indexPath.row) {
            var image : UIImage?
            
            // call getImage
            // This will return an image if it is in the cache
            // else getImage is passes a callback
            // getImage needs teh row as it is sent in the callback
            image = imageInterface.getImage(url : thumbnailUrl, row: indexPath.row ) {row in
                // the callback recieves the row
                let indexPath = IndexPath(item: row, section: 0)
                // refresh row
                self.tableView.reloadRows(at: [indexPath], with: .left)
            }
            // TODO, try dummy image (maybe just roblox symbol)
            // This will solve refresh animation problems
            // display image in cell if valid
            if let thisImage = image {
                cell.imageView?.image = thisImage
            }
            //cell.imageView?.image = UIImage(named: "egg")
        }
        return cell
    }
    
    // if row is tapped on then go to the detail VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        self.performSegue(withIdentifier: "ShowItemDetail", sender: self)
    }
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItemDetail" {
            let destinationVC = segue.destination as!  ItemDetailVC
            if let dataToSend : JSON = apiInterface.getLatestCollectablesData() {
                if let rowToSend = selectedRow {
                    destinationVC.setLatestCollectablesData(latestCollectablesData: dataToSend, detailsForRow: rowToSend)
                }
                else {
                    print("segue tried to send nil row")
                }
            }
            else {
                print ("segue tried to send nil JSON")
            }
        }
    }
}
