//  Copyright © 2019 David New. All rights reserved.

import UIKit
import SwiftyJSON

class ItemDetailVC: UIViewController, setLatestCollectablesDelegate{
    //need API interface to hold data and use functions for retieval
    var apiInterface = ApiInterface()
    //need image interface to get large thumbnail
    var imageInterface = ImageInterface()
    // This is the row in the collectables data that the item is at
    var rowInData : Int?
    
    // At the moment just output data to labels
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    
    // This function used to send JSON data into this instance of apiInterface
    // after segue from collectables VC
    // Also need row for the item of interest
    func setLatestCollectablesData (latestCollectablesData: JSON, detailsForRow: Int) {
        //Set the new data in apiInterface
        apiInterface.setLatestCollectablesData(latestCollectablesData: latestCollectablesData)
        //Keep the row number
        rowInData = detailsForRow
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // if there is a valid row number (which should have been set by
        // setLatestCollectablesData called from the source segue
        if let row = rowInData {
            apiInterface.retrieveLargeThumbnailData(index: row) { (success) in
                // when retrieveLargeThumbnailData finishes it will run this:
                // check that there is a url returned.
                if let imageUrl = self.apiInterface.getLargeThumbnailUrl() {
                    // attempt to set the image view. If image is valid the view will be updated and the closure will
                    // not be run. On the first run this will alays fail as the image is not in the cache
                    self.image1.image = self.imageInterface.getImage(url: imageUrl, row: row, closure: { (row) in
                        // this closure will run if the image is not in the cache. it should return the image
                        // and update the imageview
                        self.image1.image = self.imageInterface.getImage(url: imageUrl, row: row, closure: { (row) in
                            //If this closure is run it means that the image has still not been retrieved
                            //TODO think about error checking here
                            print("double image cache miss")
                        })
                    })
                    
                }
            }
            if let name = apiInterface.getName(index: row) {label1.attributedText = getAttributedString(title: "Name", body: name)}
            if let updated = apiInterface.getUpdated(index: row) {label2.attributedText = getAttributedString(title: "Updated", body: updated)}
            if let price = apiInterface.getPrice(index: row) {
                if price != "" {
                    label3.attributedText = getAttributedString(title: "Price", body: price)
                }
                else {
                    label3.attributedText = getAttributedString(title: "Price", body: "N/A")
                }
            }
            if let availability = getAvailability(row: row) {label4.attributedText = getAttributedString(title: "Availability", body: availability)}
            if let sales = apiInterface.getSales(index: row) {label5.attributedText = getAttributedString(title: "Sales", body: sales)}
            if let limitedAltText = apiInterface.getLimitedAltText(index: row) {label6.attributedText = getAttributedString(title: "Collectable type", body: limitedAltText)}
            
            
            label7.text = nil
        }
    }
    
    func getAvailability(row : Int) -> String? {
        if let isForSale = apiInterface.getIsForSale(index: row) {
            if isForSale == "true" {
                if let numRemaining = apiInterface.getRemaining(index: row) {
                    if numRemaining != "" && numRemaining != "0"{
                        return ("\(numRemaining) available from Roblox")
                    }
                    else {
                        return "Not available from Roblox"
                    }
                }
                else {
                    return nil
                }
            }
            else {
                return "Not available from Roblox"
            }
        }
        else {
            return nil
        }
    }
    
    func getAttributedString(title : String , body : String) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        let titleCr = title + "\n"
        let bodyAs = NSMutableAttributedString(string:body)
        let titleAs = NSMutableAttributedString(string: titleCr, attributes:attrs)
        let textAs = titleAs
        textAs.append(bodyAs)
        return textAs
    }
}

