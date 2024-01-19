//
//  DetailViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import GoogleMaps

class DetailViewController: UIViewController {
    
    lazy var placeImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var addressLabel = UILabel()
    lazy var phoneLabel = UILabel()
    lazy var heartButton = UIButton(type: .system)
    var mapView: GMSMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        setupUI()
    }
    
    func setupNav() {
        self.navigationItem.title = "Detail"
    }

    func setupUI() {
        
        view.addSubview(placeImageView)

        view.addSubview(nameLabel)
        view.addSubview(addressLabel)
        view.addSubview(phoneLabel)
        view.addSubview(heartButton)
        
        
        setupMapView()
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
       
    }
    
    func setupMapView() {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 12)
        mapView = GMSMapView.init(options: options)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
       
    }

}

