//
//  SearchResultViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import SDWebImage
import Alamofire

class SearchResultViewController: UIViewController {
    
    var travelData = [TravelData]()
    var favoriteListData = [TravelData]()
    lazy var detailVC = DetailViewController()
    
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    lazy var resultTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        setupNav()
        setupUI()
        setupResultTableView()
        
    }
    
    func setupNav() {
        self.navigationItem.title = "Result"

    }
    
    func setupUI() {
        view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    func setupResultTableView() {
        resultTableView.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
        resultTableView.rowHeight = UITableView.automaticDimension
        resultTableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkIfPlaceSaved()

    }
    
    func getUserFavoriteListData(completion: @escaping () -> Void) {
        let decoder = JSONDecoder()

        if let defaultData = defaults.data(forKey: "UserFavoriteList") {
            if let decodedData = try? decoder.decode([TravelData].self, from: defaultData) {
                self.favoriteListData = decodedData
                completion()
            } else {
                print("Fail to decode")
            }

        }
    }
    
    func checkIfPlaceSaved() {
        print("check if favorite list already contains place")
        getUserFavoriteListData {
            for (i,place) in self.travelData.enumerated() {
                // 檢查後發現存在於<3的地點isSaved值重設為true
                if self.favoriteListData.contains(where: { data in
                    data.placeData.name == place.placeData.name
                }) {
                    let index = self.favoriteListData.firstIndex {
                        $0.placeData.name == place.placeData.name
                    }
                    self.travelData[i].isSaved = self.favoriteListData[index!].isSaved
                    self.resultTableView.reloadData()
                    
                } else {
                    // 檢查後發現沒在<3的地點isSaved值重設為false
                    self.travelData[i].isSaved = false
                    self.resultTableView.reloadData()
                }

            }
        }
    }

} // class end

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        travelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell, travelData.indices.contains(0) else {
            return UITableViewCell()
        }

        // SearchResultTableViewCellDelegate
        cell.delegate = self
        cell.indexPath = indexPath
        /////////////////////////////////////
        
        if let url = URL(string: travelData[index].placeData.imageURL) {
            cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "fork.knife"))
        }
        
        cell.nameLabel.text = travelData[index].placeData.name
        
        updateHeartButtonUI(cell, placeIsSaved: travelData[index].isSaved)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1
    }
    
    
    private func updateHeartButtonUI(_ cell: SearchResultTableViewCell, placeIsSaved: Bool) {
        if placeIsSaved {
            cell.heartButton.isSelected = true

        } else {
            cell.heartButton.isSelected = false

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if let nav = self.navigationController {
            // passing data
            detailVC.placeInfoData = self.travelData
            detailVC.dataIndex = index // 被點擊的那一格index
            
            nav.pushViewController(detailVC, animated: true)
        }
    }
    
    
} // table view ex end

extension SearchResultViewController: SearchResultTableViewCellDelegate {

    func placeWasSaved(indexPath: IndexPath) {
        let index = indexPath.row
        guard travelData.indices.contains(index) else { return }
        
        var placeSavedStatus = travelData[index].isSaved
        placeSavedStatus = !placeSavedStatus // toggle
        travelData[index].isSaved = placeSavedStatus // 更新資料
        
//        print("travelData[index]:\(travelData[index])")
        
        let place = travelData[index]
        
        if placeSavedStatus == true {
            print("收藏")
            if let currentFavoriteList = defaults.data(forKey: "UserFavoriteList") {
                if var favoriteList = try? decoder.decode([TravelData].self, from: currentFavoriteList) {
                    favoriteList.append(place)
                    print("favoriteList:\(favoriteList)")
                    
                    if let newFavoriteList = try? encoder.encode(favoriteList) {
                        defaults.setValue(newFavoriteList, forKey: "UserFavoriteList")
                    } else {
                        print("encode失敗")
                    }
                }
            } else {
                // defaults無資料時
                if let newFavoriteList = try? encoder.encode([place].self) {
                    defaults.setValue(newFavoriteList, forKey: "UserFavoriteList")
                }
            }
        } else {
            print("退追")
            if let currentFavoriteList = defaults.data(forKey: "UserFavoriteList") {
                if var favoriteList = try?  decoder.decode([TravelData].self, from: currentFavoriteList) {
                    
                    for (i,item) in favoriteList.enumerated() {
                        if item.placeData.name == place.placeData.name {
                            favoriteList.remove(at: i)
                            print("favoriteList:\(favoriteList)")
                        }
                    }
                    
                    if let newFavoriteList = try? encoder.encode(favoriteList) {
                        defaults.setValue(newFavoriteList, forKey: "UserFavoriteList")
                    }
                    
                }
            } 
        }
        
        resultTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
