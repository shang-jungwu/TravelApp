//
//  MKMapViewTableViewCell.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/24.
//

import UIKit
import SnapKit
import GoogleMaps

class MapViewTableViewCell: UITableViewCell {

    lazy var mapView = GMSMapView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 生成cell的時候發動?
    func setupMapView(lat: Double, lon: Double, zoom: Float, title: String, snippet: String?) {
        // 設定地圖座標
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: zoom)
        options.frame = .zero
        mapView = GMSMapView.init(options: options)

        // 加入標記
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView

        self.contentView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(300)
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
