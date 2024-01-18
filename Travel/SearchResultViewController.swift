//
//  SearchResultViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import SDWebImage
import GooglePlaces

class SearchResultViewController: UIViewController {
    
    var searchResult = [Result]()
    var photos = [UIImage]()
    
    lazy var resultTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), style: .grouped)
    
    private var placesClient: GMSPlacesClient!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupResultTableView()

        placesClient = GMSPlacesClient.shared()
       
        
    }
    
    func setupNav() {
        self.navigationItem.title = "Result"
    }

    func setupUI() {
        view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    func setupResultTableView() {
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.resultTableView.reloadData()
    }
    
    func foo(completion: @escaping ((Swift.Result<Data, Error>) -> Void)) {
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))

        placesClient?.fetchPlace(fromPlaceID: "foo",
                                 placeFields: fields,
                                 sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
          if let place = place {
            // Get the metadata for the first photo in the place photo metadata list.
            let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

            // Call loadPlacePhoto to display the bitmap and attribution.
              self.placesClient?.loadPlacePhoto(photoMetadata, callback: { [self] (photo, error) -> Void in
              if let error = error {
                // TODO: Handle the error.
                print("Error loading photo metadata: \(error.localizedDescription)")
                  
                  completion(.failure(error))
                return
              } else {
                // Display the first image and its attributions.
                  self.photos.append(photo!)
                  print("photos.count:",photos.count)
                  
                  let imageData: Data = photo?.pngData() ?? Data()
                  completion(.success(imageData))
              }
            })
          }
        })
    }
    
    func getIPlace() {
        foo { result in
            switch result {
            case .success(let data):
                break
            case .failure(let error):
                break
            }
        }
    }
    
//    func foo(completion: @escaping ((Data?, Error?) -> Void)) {
//        
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))
//
//        placesClient?.fetchPlace(fromPlaceID: "foo",
//                                 placeFields: fields,
//                                 sessionToken: nil, callback: {
//          (place: GMSPlace?, error: Error?) in
//          if let error = error {
//            print("An error occurred: \(error.localizedDescription)")
//            return
//          }
//          if let place = place {
//            // Get the metadata for the first photo in the place photo metadata list.
//            let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
//
//            // Call loadPlacePhoto to display the bitmap and attribution.
//              self.placesClient?.loadPlacePhoto(photoMetadata, callback: { [self] (photo, error) -> Void in
//              if let error = error {
//                // TODO: Handle the error.
//                print("Error loading photo metadata: \(error.localizedDescription)")
//                  completion(nil, error)
//                return
//              } else {
//                // Display the first image and its attributions.
//                  self.photos.append(photo!)
//                  print("photos.count:",photos.count)
//                  
//                  let imageData: Data? = photo?.pngData()
//                  completion(imageData, nil)
//              }
//            })
//          }
//        })
//    }
    
    func preparePhoto(placeID: String) {
        // Specify the place data types to return (in this case, just photos).
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))

        placesClient?.fetchPlace(fromPlaceID: placeID,
                                 placeFields: fields,
                                 sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
          if let place = place {
            // Get the metadata for the first photo in the place photo metadata list.
            let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

            // Call loadPlacePhoto to display the bitmap and attribution.
              self.placesClient?.loadPlacePhoto(photoMetadata, callback: { [self] (photo, error) -> Void in
              if let error = error {
                // TODO: Handle the error.
                print("Error loading photo metadata: \(error.localizedDescription)")
                return
              } else {
                // Display the first image and its attributions.
                  self.photos.append(photo!)
                  print("photos.count:",photos.count)
                  
                 
              }
            })
          }
        })
    }

}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
        
//        cell.backGroundImageView.image = photos[index]
        cell.nameLabel.text = searchResult[index].name
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1
    }
}
