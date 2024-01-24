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
    lazy var detailVC = DetailViewController()
    
    lazy var resultTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
            make.leading.equalToSuperview()//.offset(15)
            make.trailing.equalToSuperview()//.offset(-15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    func setupResultTableView() {
        resultTableView.backgroundColor = .systemMint
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultTableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.resultTableView.reloadData()
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
        
        print("travelData[index]:\(travelData[index])")
        
        if placeSavedStatus == true {
            print("收藏")
        } else {
            print("退出")
        }
        
        resultTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}
