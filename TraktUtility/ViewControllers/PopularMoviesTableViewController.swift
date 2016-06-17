//
//  PopularMoviesTableViewController.swift
//  TraktUtility
//
//  Created by Sanjeev Upreti on 03/06/16.
//  Copyright © 2016 Sanjeev Upreti. All rights reserved.
//

// MARK: - Class Imports
import UIKit

// MARK: - popular movies page limit
private let POPULAR_PAGE_LIMIT = 10

// MARK: - View-controller class for Popular movies
class PopularMoviesTableViewController: UITableViewController {

    // MARK: - Properties
    private let reuseIdentifier = "PopularMoviesTableCellIdentifier"
    private var movies = [TraktMovie]()
    private var fetchingMoviesInProgress = false
    private var movieListExhausted = false
    private var currentPage = 0
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Popular Movies"

        // Add activityIndicator to the view
        self.view.addSubview(self.activityIndicator)
        
        // Configure the activity indicator
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = UIColor.whiteColor()
        
        // fetch movies
        self.fetchPopularMoviesForPage(currentPage+1);
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
        return movies.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PopularMovieTableCell

        // Configure the cell...
        cell.layoutMargins = UIEdgeInsetsZero
        cell.movieTitleLabel.text = ""
        cell.movieYearLabel.text = ""
        
        let movie = movies[indexPath.row]
        cell.movieTitleLabel.text = movie.title ?? ""
        if let year = movie.year { cell.movieYearLabel.text = "Released: " + String(year) }
        cell.traktUrl = movie.traktUrl()
        cell.imdbUrl = movie.imdbUrl()
        cell.tmdbUrl = movie.tmdbUrl()
        
        return cell
    }

    // MARK: Scroll delegates
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView.tracking && !movieListExhausted && !fetchingMoviesInProgress else {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            // User has dragged till bottom, fetch more movies.
            // Request to the API should be paginated as user scrolls.
            self.fetchPopularMoviesForPage(currentPage+1)
        }
    }

    // MARK: Method for fetching Popular movies
    func fetchPopularMoviesForPage(page: Int?) {
        guard !movieListExhausted && !fetchingMoviesInProgress else {
            return
        }

        self.fetchingMoviesInProgress = true
        self.activityIndicator.startAnimating()

        let sharedTraktManager = TraktManager.sharedTraktManager
        sharedTraktManager.fetchPopularMovies(forPage: page,
                                              limit: POPULAR_PAGE_LIMIT,
                                              
                                              failure: { (failureMessage) in
                                                self.fetchingMoviesInProgress = false
                                                self.activityIndicator.stopAnimating()
                                                self.showAlert(failureMessage)},
                                              
                                              completion: { (movies) in
                                                self.fetchingMoviesInProgress = false
                                                self.activityIndicator.stopAnimating()

                                                guard let movies = movies else {
                                                    return
                                                }
                                                
                                                guard movies.count != 0 else {
                                                    print("movie List exhausted")
                                                    self.movieListExhausted = true
                                                    return
                                                }

                                                self.currentPage += 1
                                                self.movies.appendContentsOf(movies)
                                                // reload data in tableView
                                                self.tableView!.reloadData()

                                                })
    }

}


// MARK: - Class PopularMovieTableCell is a custom table cell to display movie details
class PopularMovieTableCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieYearLabel: UILabel!
    @IBOutlet weak var traktButton: UIButton!
    @IBOutlet weak var imdbButton: UIButton!
    @IBOutlet weak var tmdbButton: UIButton!
    
    private var traktUrl: NSURL?;
    private var imdbUrl: NSURL?;
    private var tmdbUrl: NSURL?;

    override func awakeFromNib() {
        self.traktButton.layer.cornerRadius = 5.0
        self.imdbButton.layer.cornerRadius = 5.0
        self.tmdbButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func traktButtonTapped(sender: UIButton) {
        guard let traktUrl = self.traktUrl else {
            return
        }
        if UIApplication.sharedApplication().canOpenURL(traktUrl) {
            UIApplication.sharedApplication().openURL(traktUrl)
        }
    }
    
    @IBAction func imdbButtonTapped(sender: UIButton) {
        guard let imdbUrl = self.imdbUrl else {
            return
        }
        if UIApplication.sharedApplication().canOpenURL(imdbUrl) {
            UIApplication.sharedApplication().openURL(imdbUrl)
        }
    }
    
    @IBAction func tmdbButtonTapped(sender: UIButton) {
        guard let tmdbUrl = self.tmdbUrl else {
            return
        }
        if UIApplication.sharedApplication().canOpenURL(tmdbUrl) {
            UIApplication.sharedApplication().openURL(tmdbUrl)
        }

    }
}

