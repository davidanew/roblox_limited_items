//  Copyright © 2019 David New. All rights reserved.

import UIKit
import os.log


class LatestCollectablesVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    // object to handle API calles
    let apiInterface = ApiInterface()
    // object to handle HTTP calls to get image
    let imageInterface = ImageInterface()
    // need to store selected row as prepare for segue is asyncronous
    var selectedRow : Int?
    //Add refresh control so pulling down refreshes the view
    let refreshControl = UIRefreshControl()
    // How long we wait to see if a refresh is done
//    let refreshTimerInterval : TimeInterval = 5
    // Timer that checks that the table has been updated
//    var refreshTimer : Timer?
    // These two variables track the refresh operation
//    var requestedRefreshAt : Date?
//    var successfulRefreshAt : Date?
    // when app enters foreground refresh data after this timer
//    var enteredForegroundTimer : Timer?
    // delay for enteredForegroundTimer
//    let enteredForegroundTimerInterval : TimeInterval = 1
    //    var notificationCenterAuthStatus : Bool?

    // need this outlet so we can force refreshes
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    /*
    @IBAction func configButton(_ sender: Any) {
        var titleText = "Error"
        var messageText = "Error"
        print ("pressed button")
        //print ("notification status is \(String(describing: notificationCenterAuthStatus))")
        
        if notificationCenterAuthStatus == true {
            titleText = "Notifications are enabled"
            messageText = "go to settings -> notifications - Roblox Collectibles to disable them"
        }
        else if notificationCenterAuthStatus == false {
            titleText = "Notifications are disabled"
            messageText = "go to settings -> notifications - Roblox Collectibles to enable them"
        }
        
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
 */
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //add refresh control
        tableView.refreshControl = refreshControl
        let attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: #selector(refreshControlRefresh), for: .valueChanged)
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //This notification is used to trigger a refresh when the app goes into foregrouns
        NotificationCenter.default.addObserver(self, selector:#selector(viewWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        //This notification is used to trigger removal of tasks that should not be run in backgroun
 //       NotificationCenter.default.addObserver(self, selector:#selector(viewDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        //when we trasistion back from the detail VC sometimes the cell is still selected
        //fix this here
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        refreshTableView()
    }
    
    //triggers a delayed refresh whe the app enters foreground
    @objc func viewWillEnterForeground () {
        //refresh needs to be delayed or there is an error - see bug below
        //https://github.com/AFNetworking/AFNetworking/issues/4279
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshTableView()
        }
//        enteredForegroundTimer = Timer.scheduledTimer(withTimeInterval: enteredForegroundTimerInterval, repeats: false, block: { timer in
//        })
    }
 
 /*
    //when app goes to backround we remove the timers
    @objc func viewDidEnterBackground() {
//        refreshTimer?.invalidate()
        enteredForegroundTimer?.invalidate()
    }
*/
    //when the VC is closed we don't need any notifications
    //or timers
    //These will be re-intantiated when the view is appears again
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
 //       refreshTimer?.invalidate()
//        enteredForegroundTimer?.invalidate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
 //       enteredForegroundTimer?.invalidate()
 //       refreshTimer?.invalidate()
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
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "catalogCell")
        //let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath)
        //had to add here as doesn't seem to work when set on storyboard
        cell.accessoryType = .disclosureIndicator
        // populate name of the item
        if let name = apiInterface.getName(index: (indexPath.row)){
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = "error"
        }
        cell.imageView?.image = UIImage(named: "white110")
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
                //self.tableView.reloadRows(at: [indexPath], with: .fade)
                //thumbnailUrl = ""
                image = self.imageInterface.getImage(url: thumbnailUrl, row: indexPath.row, closure: {
                    row in
                    os_log("Error in retrieving image", log: Log.general, type: .debug)
                })
                if let image = image {
                    self.tableView.cellForRow(at: indexPath)?.imageView?.image = image
                }
            }
            // display image in cell if valid
            if let image = image {
                cell.imageView?.image = image
            }
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
    
    //This run when:
    //The view loads - first time or return from detail view
    //refresh is requested by the user pulling down on the table view
    //The refresh timer dialog box for when all cells are empty
    //when the app returns from background (with delay)
    func refreshTableView(){
        //log the time that the refresh was requested for use with the request timer
 //       requestedRefreshAt = Date()
        //stop any running refresh timer otherwise we will get multiple calls to refreshTimerHandler
//        refreshTimer?.invalidate()
        //start refresh timer
        // after refreshTimerInterval the funtion refreshTimerHandler will be called to make sure
        // the table is refreshed
 //       refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshTimerInterval, repeats: false, block: { timer in self.refreshTimerHandler(timer: timer)})
        //start refresh indicator if not already running
        if (!refreshControl.isRefreshing)  {refreshControl.beginRefreshing()}
        
        apiInterface.retrieveLatestCollectablesData{ (success) in
            if success {
                print ("refresh table view success")
                // remove the refresh animation
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
                // reload data will make all cells request their data from apiIterface
                // which should all now be valid
                self.tableView.reloadData()
                //log the time that the refresh was completed for use with the request timer
//                self.successfulRefreshAt = Date()
              
            }
            else {
                print ("refresh table view fail")
                self.handleAFTimeout()
            }
        }
    }
    
    func handleAFTimeout() {
        let alert = UIAlertController(title: "Problem getting data from Roblox", message: "Please check internet connection", preferredStyle: .alert)
        //"refresh" button will start a new refresh cycle
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: {alert in
            self.refreshTableView()
        }))
//
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {alert in
  //          if (!self.refreshControl.isRefreshing)  {self.refreshControl.endRefreshing()}
            self.refreshControl.endRefreshing()
        }))
        self.present(alert, animated: true)
    }
    
    //called by refreshControl
    @objc func refreshControlRefresh(_ sender: Any) {
        //when refresh control is triggered we need to refresh the table view
        refreshTableView()
    }
    
    
    /*
    //This function is called by the refresh timer
    //There could be no data returned by apiinterface
    //This function handles that situation
    func refreshTimerHandler(timer: Timer){
        //dont't need this variable
        _ = timer
        let numberOfRowsDisplayed = tableView.numberOfRows(inSection: 0)
        //If there is no data displayed the call tableviewIsEmpty
        if numberOfRowsDisplayed < 1 {
            tableviewIsEmpty()
        }
            //else check that the refresh has been done after the refresh was requested
        else if let thisSuccessfulRefreshAt = successfulRefreshAt {
            if let thisRequestedRefreshAt = requestedRefreshAt {
                //if request is after the call tableviewIsOutOfDate
                if thisSuccessfulRefreshAt.timeIntervalSince(thisRequestedRefreshAt) < 0 {
                    tableviewIsOutOfDate()
                }
            }
        }
    }
 */
    
    /*
    
    //called if getting initial data failed
    func tableviewIsEmpty(){
        let alert = UIAlertController(title: "Problem getting data from Roblox", message: "Please select Refresh or Wait", preferredStyle: .alert)
        //"refresh" button will start a new refresh cycle
        alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: {alert in
            self.refreshTableView()
        }))
        //"Wait" button will not do a refresh but will restary the timer so
        //the situation can be checked again later
        alert.addAction(UIAlertAction(title: "Wait", style: .default, handler: {alert in
            self.refreshTimer?.invalidate()
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: self.refreshTimerInterval, repeats: false, block: { timer in
                self.refreshTimerHandler(timer: timer)
            })
        }))
        self.present(alert, animated: true)
    }
 
 */
    //Called if there is data on the screen but a refersh has failed
    //Less agressive than tableviewIsEmpty as the user already has data to
    // look at, and lots of pop ups will be annoying
    /*
    func tableviewIsOutOfDate(){
        let alert = UIAlertController(title: "Could not refresh data from Roblox", message: nil, preferredStyle: .alert)

        //"Wait" button will not do a refresh but will restary the timer so
        //the situation can be checked again later
        alert.addAction(UIAlertAction(title: "Wait", style: .default, handler: {alert in
            self.refreshTimer?.invalidate()
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: self.refreshTimerInterval, repeats: false, block: { timer in
                self.refreshTimerHandler(timer: timer)
            })
        }))
        //Dismiss will remove the refresh indicator otherwide it stays there and can't be removed
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { alert in
            self.refreshControl.endRefreshing()
            
        }))
        self.present(alert, animated: true)
    }
 */
 
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if we are using the segue that goes to the detail VC
        if segue.identifier == "ShowItemDetail" {
            //
            if let destinationVC = segue.destination as?  setLatestCollectablesDelegate {
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
    }
}
