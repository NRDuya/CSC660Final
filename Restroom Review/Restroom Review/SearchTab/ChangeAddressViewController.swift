//
//  AddAddressViewController.swift
//  Restroom Review
//

import UIKit
import MapKit

protocol AddAddressDelegate: AnyObject {
    func addAddress(address: MKMapItem)
}

class ChangeAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    weak var delegate: AddAddressDelegate? = nil
    var address: String?
    var addressCompleter = MKLocalSearchCompleter()
    var addressResults = [MKLocalSearchCompletion]()
    
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressCompleter.delegate = self
        addressSearchBar.delegate = self
        addressTableView.delegate = self
        addressTableView.dataSource = self
        
        if let address = address {
            addressSearchBar.text = address
        }
        addressSearchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        addressCompleter.queryFragment = searchText
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        addressResults = completer.results
        addressTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addressResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = addressResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = addressResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let add = response?.mapItems[0] else {
                return
            }
            self.delegate?.addAddress(address: add)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
