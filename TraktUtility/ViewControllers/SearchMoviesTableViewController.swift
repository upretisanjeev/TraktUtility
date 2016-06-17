//
//  SearchMoviesTableViewController.swift
//  TraktUtility
//
//  Created by Sanjeev Upreti on 03/06/16.
//  Copyright © 2016 Sanjeev Upreti. All rights reserved.
//

// MARK: - Class Imports
import UIKit

// MARK: - search movies page limit
private let SEARCH_PAGE_LIMIT = 10

// MARK: - View-controller class for Searched movies
class SearchMoviesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    // MARK: Properties
    private let reuseIdentifier = "SearchedMoviesTableCellIdentifier"
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchedResults = [TraktSearchedMovieResult]()
    private var searchListExhausted = false
    private var isSearchingInProgress = false
    private var currentPage = 0
    private var searchQuery = ""
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search Movies"
        
        // Add activityIndicator to the view
        self.view.addSubview(self.activityIndicator)
        
        // Configure the activity indicator
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = UIColor.whiteColor()
        
        // Use the current view controller to update the search results. // configure searchController and searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.searchController.searchBar.barTintColor = UIColor(red: 50/250, green: 50/250, blue: 50/250, alpha: 1)
         self.searchController.searchBar.returnKeyType = UIReturnKeyType.Done
        
        // Install the search bar as the table header.
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.searchBar.becomeFirstResponder()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedResults.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SearchedMovieTableCell

        // Configure the cell...
        cell.layoutMargins = UIEdgeInsetsZero
        cell.movieTitleLabel.text = ""
        cell.movieYearLabel.text = ""
        cell.overviewLabel.text = ""
        cell.picture?.image = UIImage(named: "placeholder")
        
        let searchedResult = searchedResults[indexPath.row]
        if let movie = searchedResult.movie {
            cell.movieTitleLabel.text = movie.title ?? ""
            cell.overviewLabel.text = movie.overview ?? ""
            if let year = movie.year { cell.movieYearLabel.text = "Released: " + String(year) }
            if let thumbImgUrl = movie.imageUrls?.poster?.thumb {
                cell.picture.af_setImageWithURL(thumbImgUrl,
                                                placeholderImage: UIImage(named: "placeholder"),
                                                filter: nil,
                                                imageTransition: .None,
                                                runImageTransitionIfCached: false,
                                                completion: nil)
            }

        }
        return cell
    }

    // MARK: Scroll delegates
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView.tracking && !searchListExhausted && !isSearchingInProgress else {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height && searchQuery.characters.count > 0 {
            // User has dragged till bottom, fetch more movies.
            // Request to the API should be paginated as user scrolls.
            self.searchMoviesForQuery(searchQuery, page: currentPage+1)
        }
    }
    
    /// Method of UISearchResultsUpdating protocol. Called when the search bar's text or scope has changed or when the search bar becomes first responder.
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchedResults = [TraktSearchedMovieResult]()
        tableView.reloadData()
        guard let searchString = searchController.searchBar.text else {
            searchQuery = ""
            return
        }
        searchQuery = searchString.trim()
        guard searchQuery.characters.count > 0 else {
            return
        }
        
        searchListExhausted = false
        currentPage = 0
        self.searchMoviesForQuery(searchQuery, page: currentPage+1)
    }
    
    // MARK: Method for searching movies
    func searchMoviesForQuery(query: NSString?, page: Int?) {
        self.activityIndicator.startAnimating()
        self.isSearchingInProgress = true
        let sharedTraktManager = TraktManager.sharedTraktManager
        sharedTraktManager.searchMoviesForQuery(query, forPage: page,
                                              limit: SEARCH_PAGE_LIMIT,
                                              
                                              failure: { (failureMessage) in
                                                self.activityIndicator.stopAnimating()
                                                self.isSearchingInProgress = false
                                                self.searchController.searchBar.resignFirstResponder()
                                                self.showAlert(failureMessage)},
                                              
                                              completion: { (searchedResults) in
                                                self.activityIndicator.stopAnimating()
                                                self.isSearchingInProgress = false
                                                
                                                guard let searchedResults = searchedResults else {
                                                    return
                                                }
                                                
                                                guard searchedResults.count != 0 else {
                                                    print("search List exhausted")
                                                    self.searchListExhausted = true
                                                    return
                                                }
                                                
                                                self.currentPage += 1
                                                self.searchedResults.appendContentsOf(searchedResults)
                                                // reload data in tableView
                                                self.tableView!.reloadData()})
    }
    
}


// MARK: - Class SearchedMovieTableCell is a custom table cell to display searched movie details
class SearchedMovieTableCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieYearLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
}

