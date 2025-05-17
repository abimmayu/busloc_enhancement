//
//  MapView.swift
//  busloc
//
//  Created by Abim on 09/04/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    private let mapView = MKMapView()
    private var markers: [MKPointAnnotation] = []
    private let searchButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupSearchButton()
        addMarkers()
    }
    
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.delegate = self
        view.addSubview(mapView)
        
        let initialLocation = CLLocationCoordinate2D(latitude: -6.3015445, longitude: 106.65247)
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        mapView.backgroundColor = .white
    }
    
    private func setupSearchButton() {
        searchButton.setTitle("Search", for: .normal)
        searchButton.backgroundColor = .blue
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 10
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(openSearchModal), for: .touchUpInside)
        
        view.addSubview(searchButton)
        
        NSLayoutConstraint.activate([
            searchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 100),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func openSearchModal() {
        let searchVC = SearchViewController()
        searchVC.onLocationSelected = { [weak self] coordinate, name in
            self?.addNewMarker(at: coordinate, title: name)
        }
        present(searchVC, animated: true, completion: nil)
    }
    
    private func addMarkers() {
        let locations = [
            (title: "The Breeze", latitude: -6.30137, longitude: 106.65314),
            (title: "SML Plaza", latitude: -6.30229, longitude: 106.65125),
            (title: "GOP 1", latitude: -6.30175, longitude: 106.64918)
        ]
        
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            markers.append(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func addNewMarker(at coordinate: CLLocationCoordinate2D, title: String?) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        if(markers.count >= 4) {
            
        }
        mapView.addAnnotation(annotation)
        drawPath(to: coordinate)
    }
    
    private func drawPath(to newLocation: CLLocationCoordinate2D) {
        guard let nearestMarker = markers.min(by: {
            CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
                .distance(from: CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude))
            <
            CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
                .distance(from: CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude))
        }) else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: nearestMarker.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: newLocation))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            
            self.mapView.addOverlay(route.polyline)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    var onLocationSelected: ((CLLocationCoordinate2D, String?) -> Void)?
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var searchResults: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupTableView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for a location"
        searchBar.sizeToFit()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            self.searchResults = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = searchResults[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.placemark.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchResults[indexPath.row]
        let coordinate = item.placemark.coordinate
        
        onLocationSelected?(coordinate, item.name)
        dismiss(animated: true, completion: nil)
    }
}


#Preview {
    MapViewController()
}
