//
//  ViewController.swift
//  NewsApp
//
//  Created by Nirmal Koirala on 24/08/2022.
//

import UIKit
import SafariServices

//Table View
//custom Cell
//API caller
//Open the news story
//search the news story

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        
        return table
    }()
    private let searchVC = UISearchController(searchResultsController: nil)
    private var viewModels = [NewsTableViewCellViewModel]()
    private var articles = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .systemBackground
        
        
        fetchTopStories()
        createSearchBar()
        
        
    }
     
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    private func fetchTopStories() {
        APICaller.shared.getTopStories { [weak self] result in
        switch result {
        case.success(let articles):
            self?.articles = articles
            self?.viewModels = articles.compactMap({
                NewsTableViewCellViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURl: URL(string: $0.urlToImage ?? ""))
            })
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
                        case.failure(let error):
            print(error)
        }
    }
    }
    
//    table view function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
           debugPrint("Error here")
           return UITableViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
  
  
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case.success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURl: URL(string: $0.urlToImage ?? ""))
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.searchVC.dismiss(animated: true, completion: nil)
                }
                            case.failure(let error): 
                print(error)
            }
        }
       
    }
}

