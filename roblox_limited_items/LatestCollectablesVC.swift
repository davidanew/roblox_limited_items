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
    // need this outlet so we can force refreshes
    @IBOutlet weak var tableView: UITableView!
    // Activity indicator for first time loading, so user does not wait on blank screen
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add refresh control
        tableView.refreshControl = refreshControl
        let attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: #selector(refreshControlRefresh), for: .valueChanged)
        //start activity indicator
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //This notification is used to trigger a refresh when the app goes into foregrouns
        NotificationCenter.default.addObserver(self, selector:#selector(viewWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
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
    }
 
    //when the VC is closed we don't need any notifications
    //These will be re-initiated when the view is appears again
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        //set default image. This ensures the cell has the correct layout for later
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
                //the callback should recieve an image now
                
                image = self.imageInterface.getImage(url: thumbnailUrl, row: indexPath.row, closure: {
                    row in
                    os_log("Error in retrieving image", log: Log.general, type: .debug)
                })
                //replace image without refresh to stop animation glitches
                if let image = image {
                    self.tableView.cellForRow(at: indexPath)?.imageView?.image = image
                }
                //self.tableView.reloadRows(at: [indexPath], with: .fade)

 
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
    
    func refreshTableView(){
        //start refresh indicator if not already running
        //this will be hidden if the refresh is not done by pulling down
        if (!refreshControl.isRefreshing)  {refreshControl.beginRefreshing()}
        //retrieve new data
        apiInterface.retrieveLatestCollectablesData{ (success) in
            if success {
                // remove the refresh animation and activity indicator
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
                // reload data will make all cells request their data from apiIterface
                // which should all now be valid
                self.tableView.reloadData()
            }
            else {
                self.handleAFTimeout()
            }
        }
    }
    
    func handleAFTimeout() {
        let alert = UIAlertController(title: "Problem getting data from Roblox", message: "Please check your internet connection", preferredStyle: .alert)
        //"try again" button will start a new refresh cycle
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: {alert in
            self.refreshTableView()
        }))
        //"cancel' button does nothing but stop refresh animations
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {alert in
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
        }))
        self.present(alert, animated: true)
    }
    
    //called by refreshControl
    @objc func refreshControlRefresh(_ sender: Any) {
        //when refresh control is triggered we need to refresh the table view
        refreshTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if we are using the segue that goes to the detail VC
        if segue.identifier == "ShowItemDetail" {
            //complying to setLatestCollectablesDelegate means we know the function can recieve
            //ApiInterfaceData
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
                    //segue tried to send nil row
                }
            }
        }
    }
}
