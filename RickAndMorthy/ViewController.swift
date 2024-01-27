//
//  ViewController.swift
//  RickAndMorthy
//
//  Created by Alex Silva on 27/12/24.
//

import UIKit

class ViewController: UIViewController {
    
    var actualPage: Int = 1
    var nextPage: [String: String] = ["page": "2"]
    
    let restClient = RESTClient<PaginatedResponse<Character>>(client: Client(baseUrl: "https://rickandmortyapi.com"))
    
    var characters: [Character]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.dataSource = self
        restClient.show("/api/character/") { response in
            self.characters = response.results
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = characters?[indexPath.row].name
        cell.detailTextLabel?.text = characters?[indexPath.row].species
        
        return cell
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let characters = characters else { return }
        let loadParameter = indexPaths.contains { $0.row >= characters.count - 5 }
        
        if loadParameter {
            restClient.show("/api/character/",queryParams: nextPage) { response in
                self.characters?.append(contentsOf: response.results)
            }
            actualPage += 1
            nextPage = ["page":"\(actualPage)"]
        }
    }
}
