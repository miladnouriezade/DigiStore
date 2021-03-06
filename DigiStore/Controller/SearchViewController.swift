//
//  SearchViewController.swift
//  DigiStore
//
//  Created by Milad Nourizade on 7/11/18.
//  Copyright © 2018 Milad Nourizade. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var dataTask:URLSessionDataTask?
    var searchResults = [SearchResult]()
    var hasSearched:Bool = false
    var isLoading = false
    
    var landscapeViewController : LandscapeViewController?
    
    
    struct TableViewCellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)

        
    }
    
    //Landscape mode detection
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with:coordinator)
        case .regular, .unspecified:
            hideLandscape(with:coordinator)
        }
    }
    
    
    func iTuensUrl(searchText:String, category: Int) -> URL {
        let entityName:String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default:entityName = ""
        }
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format:
                        "https://itunes.apple.com/search?term=%@&entity=%@", escapedSearchText, entityName)
        let url = URL(string: urlString)
        
        return url!
    }
    
    func parse(json data:Data) -> [String:Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
        }catch  {
            print("Json Error:\(error)")
            return nil
        }
    }
    
    func parse(dictionary:[String:Any]) -> [SearchResult]{
        guard let array = dictionary["results"] as? [Any] else{
            print("Expected 'result' array")
            return []
        }
        var searchResults : [SearchResult] = []
        for resultDict in array{
            if let resultDict = resultDict as? [String:Any]{
                var searchResult:SearchResult?
                if let wrapperType = resultDict["wrapperType"] as? String{
                    switch wrapperType{
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audioBook":
                        searchResult = parse(audioBook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                        
                    default:
                        break
                    }
                }else if let kind = resultDict["kind"] as? String, kind == "ebook"{
                    searchResult = parse(ebook: resultDict)
                }
                if let result = searchResult{
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    func parse(track dictionary:[String:Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double{
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String{
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parse(audioBook dictionary:[String:Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }
    
    func showError(){
        let alert = UIAlertController(title: "Whoops...", message:
            "There was an error reading from iTuens store.",preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            
            searchResults = []
            hasSearched = true
            
            dataTask?.cancel()
            
            isLoading = true
            tableView.reloadData()
            
            let url = iTuensUrl(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url){
                data, response, error in
                
                if let error = error as NSError?, error.code == -999 {
                    return
                    
                }else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
                    if let data = data, let jsonDict = self.parse(json: data){
                        
                        self.searchResults = self.parse(dictionary: jsonDict)
                        self.searchResults.sort{
                            result1, result2 in
                            result1.name.localizedCompare(result2.name) == .orderedAscending
                        }
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                }else{
                    print("Failure!\(response)")
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showError()
                }
            }
            dataTask?.resume()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let selectedSearchResult = searchResults[indexPath.row]
            
            detailViewController.searchResult = selectedSearchResult
        }
    }
    
    //MARK: - LandscapeVC
    
    func showLandscape(with coordinator:UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else{ return}
        
        landscapeViewController = storyboard!.instantiateViewController(
            withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            coordinator.animate(alongsideTransition: { _ in
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                self.searchBar.resignFirstResponder()
                controller.view.alpha = 1
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscape(with coordinator:UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil)

            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion:{ _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }
    
    
    
}
//MARK: - serachVC extentions

extension SearchViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }else{
            return indexPath
        }
    }
    
}
extension SearchViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched{
            return 0
        }else if searchResults.count == 0{
            return 1
        }else{
            return searchResults.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        }else if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell,
                                                     for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
       
    }
    
}



