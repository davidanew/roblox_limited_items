//  Copyright © 2019 David New. All rights reserved.

import UIKit
import SwiftyJSON

class ItemDetailVC: UIViewController, setLatestCollectablesDelegate{
    var apiInterface = ApiInterface()
    var rowInData : Int?
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    @IBOutlet weak var Label5: UILabel!
    @IBOutlet weak var Label6: UILabel!
    @IBOutlet weak var Label8: UILabel!
    
    func setLatestCollectablesData (latestCollectablesData: JSON, detailsForRow: Int) {
        apiInterface.setLatestCollectablesData(latestCollectablesData: latestCollectablesData)
        rowInData = detailsForRow
 //       if let row = rowInData {
 //           if let name = apiInterface.getName(index: row) {
 //               print("\(name)")
 //           }
 //       }
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
