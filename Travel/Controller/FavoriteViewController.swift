//
//  FavoriteViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit
import SnapKit

class FavoriteViewController: UIViewController {

    let defaults = UserDefaults.standard
    var caller: String!
    var calledButtonTag = 0
    weak var scheduleVC: ScheduleViewController!
    lazy var detailVC = DetailViewController()
    var tempPlace = [TravelData]()
    
    lazy var favoriteTableView = UITableView(frame: .zero, style: .grouped)
    var favoriteListData = [TravelData]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        setupNav()
        setupUI()
        setupTableView()
        
        if caller == "ScheduleVC" {
            self.navigationItem.rightBarButtonItem?.isHidden = false
            self.favoriteTableView.isEditing = true
            self.favoriteTableView.allowsMultipleSelectionDuringEditing = true
        } else {
            self.favoriteTableView.allowsMultipleSelectionDuringEditing = false
        }
  

    }
    

    func setupNav() {
        self.navigationItem.title = "Favorite"
        let rightBarButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addPlaceFromFavorite))
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        self.navigationItem.rightBarButtonItem?.isHidden = true
    }
    
    @objc func addPlaceFromFavorite() {
        print("addPlaceFromFavorite")
        if let selectedIndexPath = self.favoriteTableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPath {
                let row = indexPath.row
                let tmpPlace = favoriteListData[row]
//                tempPlace.append(favoriteListData[row])
                scheduleVC.userSchedules[scheduleVC.scheduleIndex].dayByDaySchedule[calledButtonTag].places.append(tmpPlace)
                print("scheduleVC.userSchedules:\(scheduleVC.userSchedules)")
                scheduleVC.scheduleTableView.reloadData()
                self.dismiss(animated: true)
            }
        }
            
    }
    
    func setupUI() {
        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()//.offset(15)
            make.trailing.equalToSuperview()//.offset(-15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            
        }
    }
    
    func setupTableView() {
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.register(FavoriteListTableViewCell.self, forCellReuseIdentifier: "FavoriteListTableViewCell")
        favoriteTableView.backgroundColor = .white
        favoriteTableView.separatorStyle = .singleLine
//        favoriteTableView.layer.cornerRadius = 10
//        favoriteTableView.layer.borderColor = UIColor.green.cgColor
//        favoriteTableView.layer.borderWidth = 1
        
    }
    
    
    func getUserFavoriteListData(completion: () -> Void) {
        let decoder = JSONDecoder()

        if let defaultData = defaults.data(forKey: "UserFavoriteList") {
            if let decodedData = try? decoder.decode([TravelData].self, from: defaultData) {
                // on main thread, no need escaping
                self.favoriteListData = decodedData
                completion()
            } else {
                print("Fail to decode")
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserFavoriteListData {
            self.favoriteTableView.reloadData()
        }
        tempPlace.removeAll()
    }
    
} // class end

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteListTableViewCell", for: indexPath) as? FavoriteListTableViewCell else { return UITableViewCell() }
        
        if let url = URL(string: favoriteListData[index].placeData.imageURL) {
            cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "fork.knife"))
        }
        
        cell.nameLabel.text = favoriteListData[index].placeData.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if caller == "ScheduleVC" {
//            var selectedRows = self.favoriteTableView.indexPathsForSelectedRows
//            print(selectedRows!)
            
        } else {
            if let nav = self.navigationController {
                // passing data
                detailVC.placeInfoData = self.favoriteListData
                detailVC.dataIndex = index // 被點擊的那一格index
                
                nav.pushViewController(detailVC, animated: true)
            }
        }
        
       
    }

    // 右側刪除按鈕
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [unowned self] (action, view, completionHandler) in

            favoriteListData.remove(at: index)
            
            let encoder = JSONEncoder()
            if let newFavoriteListData = try? encoder.encode(favoriteListData) {
                defaults.set(newFavoriteListData, forKey: "UserFavoriteList")
            } else {
                print("encode失敗")
            }
            
            favoriteTableView.deleteRows(at: [indexPath], with: .automatic)

            completionHandler(true) // 告訴vc動作結束了
        }
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true // 滑到底直接刪除
        return config
    }
    
    
}
