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
    lazy var detailVC = DetailViewController()
    lazy var favoriteTableView = UITableView(frame: .zero, style: .grouped)
    var favoriteListData = [TravelData]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupTableView()

    }
    

    func setupNav() {
        self.navigationItem.title = "Favorite"
    }
    
    func setupUI() {
        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
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
        if let nav = self.navigationController {
            // passing data
            detailVC.placeInfoData = self.favoriteListData
            detailVC.dataIndex = index // 被點擊的那一格index
            
            nav.pushViewController(detailVC, animated: true)
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
