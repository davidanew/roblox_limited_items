//  Copyright © 2019 David New. All rights reserved.

import UIKit
import SwiftyJSON

class ItemDetailVC: UIViewController, setLatestCollectablesDelegate{
    //need API interface to hold data and use functions for retieval
    var apiInterface = ApiInterface()
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
    // Also need row for the item of interest
    func setLatestCollectablesData (latestCollectablesData: JSON, detailsForRow: Int) {
        //Set the new data in apiInterface
        apiInterface.setLatestCollectablesData(latestCollectablesData: latestCollectablesData)
        //Keep the row number
        rowInData = detailsForRow
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // try out putting the value sin the labels
        if let row = rowInData {
 /*           if let imageUrl = apiInterface.getLargeThumbnailData(index: row){
                //row could be optional here as not needed for non table view
                image1.image = imageInterface.getImage(url: imageUrl, row: row, closure: { (row) in
                    self.image1.image = self.imageInterface.getImage(url: imageUrl, row: row, closure: { (row) in
                        print("double image cache miss")
                    })
                })
            } */
            
            // TODO: put this code in test!
            // may need to daisy chain with expectations
            apiInterface.retrieveLargeThumbnailData(index: row) { (success) in
                // if success
                if let imageUrl = self.apiInterface.getLargeThumbnailUrl() {
                    self.image1.image = self.imageInterface.getImage(url: imageUrl, row: row, closure: { (row) in
                        self.image1.image = self.imageInterface.getImage(url: imageUrl, row: row, closure: { (row) in
                            print("double image cache miss")
                        })
                    })
                    
                }
            }
            
            label1.text = apiInterface.getName(index: row)
            label2.text = apiInterface.getDescription(index: row)
            label3.text = apiInterface.getPrice(index: row)
            label4.text = apiInterface.getUpdated(index: row)
            label5.text = apiInterface.getIsForSale(index: row)
            
            
        }
    }
}

/*
func getIsForSale(index : Int) -> String?{

func getIsLimitedUnique(index : Int) -> String?{
 
func getIsLimited(index : Int) -> String?{
 
func getName(index : Int) -> String?{
 
func getUpdated(index : Int) -> String?{

func getRemaining(index : Int) -> String?{

func getPrice(index : Int) -> String?{
 
func getNumEntries() -> Int?{
 
func getThumbnailUrl(index : Int) -> String?{
 
*/
