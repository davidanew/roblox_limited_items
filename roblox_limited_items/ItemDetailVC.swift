//  Copyright © 2019 David New. All rights reserved.

import UIKit

class ItemDetailVC: UIViewController, setLatestCollectablesDelegate{
    //need API interface to hold data and use functions for retieval
    var apiInterface = ApiInterface()
    //need image interface to get large thumbnail
    var imageInterface = ImageInterface()
    // This is the row in the collectables data that the item is at
    var rowInData : Int?
    

    
    // Data is displayed in an imageview and labels
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // if there is a valid row number (which should have been set by
        // setLatestCollectablesData called from the source segue)
        //image1.image = UIImage(named: "RC420")
        if let row = rowInData {
            //call apiInterface to request the data and fill it's buffer
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
                            //If image does not load we will just leave it blank
                            print("double image cache miss")
                        })
                    })
                    
                }
            }
            // Set uilabels with the information
            // uses getAttributedString to get attributed text with bold title
            if let name = apiInterface.getName(index: row) {label1.attributedText = getAttributedString(title: "Name", body: name)}
            if let updated = apiInterface.getUpdated(index: row) {label2.attributedText = getAttributedString(title: "Updated", body: updated)}
            // Get price from ROblox or set to N/A if not available
            if let price = apiInterface.getPrice(index: row) {
                if price != "" {
                    label3.attributedText = getAttributedString(title: "Roblox Price", body: price)
                }
                else {
                    label3.attributedText = getAttributedString(title: "Roblox Price", body: "N/A")
                }
            }
            //use getAvailability to work out if item is available from roblox
            if let availability = getAvailability(row: row) {label4.attributedText = getAttributedString(title: "Roblox Availability", body: availability)}
            if let sales = apiInterface.getSales(index: row) {label5.attributedText = getAttributedString(title: "Roblox Sales", body: sales)}
            //Get resellet price or set to N/A if not available from reseller
            if let bestPrice = apiInterface.getBestPrice(index: row) {
                if bestPrice != "" {
                    label6.attributedText = getAttributedString(title: "Best Reseller Price", body: bestPrice)
                }
                else {
                    label6.attributedText = getAttributedString(title: "Best Reseller Price", body: "N/A")
                }
            }
            if let limitedAltText = apiInterface.getLimitedAltText(index: row) {label7.attributedText = getAttributedString(title: "Collectible type", body: limitedAltText)}
        }
    }
    
    // This function used to send JSON data into this instance of apiInterface
    // after segue from collectables VC
    // Also need row for the item of interest
    func setLatestCollectablesData (latestCollectablesData: ApiInterfaceData, detailsForRow: Int) {
        //Set the new data in apiInterface
        apiInterface.setLatestCollectablesData(latestCollectablesData: latestCollectablesData)
        //Keep the row number as a property
        rowInData = detailsForRow
    }
    
    // Looks at "isForSale" and "remaining" JSON data to work out if the item is available from roblox
    func getAvailability(row : Int) -> String? {
        if let isForSale = apiInterface.getIsForSale(index: row) {
            if isForSale == "true" {
                if let numRemaining = apiInterface.getRemaining(index: row) {
                    if numRemaining != "" && numRemaining != "0"{
                        //this is only returned if "isForSale" and "remaining" are valid, else later returns are done
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
    
    //Puts two strings in attributed text
    //The tile string is put in bold
    //the body string is on a new line in normal text
    func getAttributedString(title : String , body : String) -> NSMutableAttributedString {
        //attributes used for bold text
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        //add carraige return to tile so body is on new line
        let titleCr = title + "\n"
        // body text as Attributed String
        let bodyAs = NSMutableAttributedString(string:body)
        // title as attribted string
        let titleAs = NSMutableAttributedString(string: titleCr, attributes:attrs)
        // first part of text
        let textAs = titleAs
        // add second part
        textAs.append(bodyAs)
        // return constucted text
        return textAs
    }
}

