//  Copyright © 2019 David New. All rights reserved.

import UIKit
//import SwiftyJSON

class LatestCollectablesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    // object to handle API calles
    let apiInterface = ApiInterface()
    // object to handle HTTP calls to get image
    let imageInterface = ImageInterface()
    // need to store selected row as prepare for segue is asyncronous
    var selectedRow : Int?
    
    @IBOutlet weak var refreshToastHeight: NSLayoutConstraint!
    @IBOutlet weak var refreshToast: UILabel!
    //   @IBAction func refreshButtonPressed(_ sender: Any) {
 //       refreshTableView()
 //   }
    // need this outlet so we can force refreshes
    @IBOutlet weak var tableView: UITableView!
    
    
    //Add refresh control so pulling down refreshes the view
    //TODO maybe add button for this as well?
    let refreshControl = UIRefreshControl()
    let refreshTimerInterval : TimeInterval = 5
    let refreshToastActiveInterval : TimeInterval = 5
    var requestedRefreshAt : Date?
    var successfulRefreshAt : Date?
    var refreshTimer : Timer?
    var refreshToastTimer : Timer?
    
    //func timerHandler (timerObject : Timer) {
    func refreshTimerHandler(timer: Timer){
        _ = timer
        print ("timer returned")
        let numberOfRowsDisplayed = tableView.numberOfRows(inSection: 0)
        if numberOfRowsDisplayed < 1 {
            tableviewIsEmpty()
        }
        else if let thisSuccessfulRefreshAt = successfulRefreshAt {
            if let thisRequestedRefreshAt = requestedRefreshAt {
                print (thisSuccessfulRefreshAt)
                print (thisRequestedRefreshAt)
                print (thisSuccessfulRefreshAt.timeIntervalSince(thisRequestedRefreshAt))
                if thisSuccessfulRefreshAt.timeIntervalSince(thisRequestedRefreshAt) < 0 {
                    tableviewIsOutOfDate()
                }
            }
        }
    }
        
 /*
        else {
            if successfulRefreshAt?.compare(requestedRefreshAt!) {
                
            }
 */
            
    
    
    override func viewDidLoad() {
        //add refresh control
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
    }
    
    //TODO rename this
    @objc func refresh(_ sender: Any) {
        //when refresh control is triggered we need to refresh the table view
        refreshTableView()
    }
    
    func refreshTableView(){
        requestedRefreshAt = Date()
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshTimerInterval, repeats: false, block: { timer in self.refreshTimerHandler(timer: timer)})
   //     refreshControl.endRefreshing()
   //     refreshControl.
        if (!refreshControl.isRefreshing)    {  refreshControl.beginRefreshing()}
        apiInterface.retrieveLatestCollectablesData{ (success) in
            if success {
                // reload data will make all cells request there data from apiIterface
                // which should all now be valid
                self.tableView.reloadData()
                self.successfulRefreshAt = Date()
                self.refreshControl.endRefreshing()
            }
   //         else {
   //             self.internetError()
   //         }
            // remove refresh control
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshToastTimer = Timer.scheduledTimer(withTimeInterval: refreshToastActiveInterval, repeats: false, block: {timer in
            self.refreshToastHeight.constant = 0
        })
        refreshTableView()
        //Get the list of latest collectables
        /*
        apiInterface.retrieveLatestCollectablesData{ (success) in
            if success {
                // reload data will make all cells request there data from apiIterface
                // which should all now be valid
                self.tableView.reloadData()
            }
            else {
                self.internetError()
            }
        }
        */
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
        // this is the cell that will be returned by the function
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "catalogCell")
        //had to add here as doesn't seem to work when set on storyboard
        cell.accessoryType = .disclosureIndicator
        // populate name of the item
        if let name = apiInterface.getName(index: (indexPath.row)){
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = "error"
        }
        //set the subtitle
        cell.detailTextLabel?.text = getSubtitleText(row : indexPath.row)
        // Get the thumbnail URL image using imageInterface
        if let thumbnailUrl = apiInterface.getThumbnailUrl(index: indexPath.row) {
            var image : UIImage?
            // call getImage
            // This will return an image if it is in the cache
            // else getImage is passed a callback
            // getImage needs the row as it is sent in the callback
            image = imageInterface.getImage(url : thumbnailUrl, row: indexPath.row ) {row in
                // the callback recieves the row
                let indexPath = IndexPath(item: row, section: 0)
                // refresh row
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            // display image in cell if valid
            if let thisImage = image {
                cell.imageView?.image = thisImage
            }
            //cell.imageView?.image = UIImage(named: "egg")
           // else {
           //     cell.imageView?.image = UIImage(named: "RC110")
           // }
            
        }
       
        return cell
    }
    
    // This function construct text for subtile (detail text)
    // We want the number of items remaining in here and also the price
    func getSubtitleText(row : Int) -> String? {
        if let isForSale = apiInterface.getIsForSale(index: row) {
            if isForSale == "true" {
                if let price = apiInterface.getPrice(index: row) {
                    if let numRemaining = apiInterface.getRemaining(index: row) {
                        if numRemaining != "" && numRemaining != "0"{
                            return ("\(numRemaining) available @ \(price) Robux")
                        }
                    }
                }
            }
        }
        // if we had valid data for everything the function would have exited by noy
        if let updated = apiInterface.getUpdated(index: row) {
            // just show when the item was updated if there is not valid data
            return "Updated \(updated)"
        }
        return nil
    }
    
    // if row is tapped on then go to the detail VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //save selected row for segue
        selectedRow = indexPath.row
        // go to detail VC
        self.performSegue(withIdentifier: "ShowItemDetail", sender: self)
    }
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if we are using the segue that goes to the detail VC
        if segue.identifier == "ShowItemDetail" {
            let destinationVC = segue.destination as!  ItemDetailVC
            //If we have valid data to send (which should always be true as the
            // user clicked on a cell)
            let dataToSend : ApiInterfaceData = apiInterface.getLatestCollectablesData()
            //also if row number is valid
            if let rowToSend = selectedRow {
                //send the data (Uses setLatestCollectablesDelegate)
                destinationVC.setLatestCollectablesData(latestCollectablesData: dataToSend, detailsForRow: rowToSend)
            }
            else {
                print("segue tried to send nil row")
            }
        }
    }
    
    //may not be being used any more
    /*
    func internetError(){
        let alert = UIAlertController(title: "Problem getting data from Roblox", message: "Swipe down to refresh to try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    */
    
    func tableviewIsEmpty(){
        let alert = UIAlertController(title: "Problem getting data from Roblox", message: "Please select Refresh or Wait", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: {alert in
            self.refreshTableView()
        }))
        alert.addAction(UIAlertAction(title: "Wait", style: .default, handler: {alert in
            self.refreshTimer?.invalidate()
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: self.refreshTimerInterval, repeats: false, block: { timer in
                self.refreshTimerHandler(timer: timer)
            })
        }))
        self.present(alert, animated: true)
    }
    
    func tableviewIsOutOfDate(){
        let alert = UIAlertController(title: "Could not refresh data from Roblox", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
