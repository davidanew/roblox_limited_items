//  Copyright © 2019 David New. All rights reserved.

import UIKit
import SwiftyJSON

class ItemDetailVC: UIViewController, setLatestCollectablesDelegate{
    //need API interface to hold data and use functions for retieval
    var apiInterface = ApiInterface()
    // This is the row in the collectables data that the item is at
    var rowInData : Int?
    
    // At the moment just output data to labels
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    @IBOutlet weak var Label5: UILabel!
    @IBOutlet weak var Label6: UILabel!
    @IBOutlet weak var Label8: UILabel!
    
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
            Label1.text = apiInterface.getName(index: row)
            Label2.text = apiInterface.getRemaining(index: row)
            Label3.text = apiInterface.getPrice(index: row)
            Label4.text = apiInterface.getUpdated(index: row)
            Label5.text = apiInterface.getIsForSale(index: row)
            
            
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
