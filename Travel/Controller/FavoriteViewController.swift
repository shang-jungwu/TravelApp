//
//  FavoriteViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit
import SnapKit
import FirebaseDatabase
import CodableFirebase

struct DayByDayPlace: Codable {
    var time: TimeInterval
    let place: String
}

class FavoriteViewController: UIViewController {

    var currentFirebaseData = [DayByDayPlace]()
    
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let ref: DatabaseReference = Database.database(url: "https://travel-1f72e-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    var caller: String!
    var calledButtonTag = 0
    weak var journeyVC: JourneyViewController!
    lazy var detailVC = DetailViewController()
    var selectedPlaces = [TravelData]()
    
    lazy var favoriteTableView = UITableView(frame: .zero, style: .insetGrouped)
    var favoriteListData = [TravelData]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        setupNav()
        setupUI()
        setupTableView()
        
        if caller == "JourneyVC" {
            self.navigationItem.leftBarButtonItem?.isHidden = true
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
        
        let leftBarButton = UIBarButtonItem(title: "Remove all", style: .plain, target: self, action: #selector(removeAllFromFavorite))
        self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        
    }
    
    func fetchJourneyDayByDayData(completion: @escaping () ->Void) {
        currentFirebaseData.removeAll()
        let day = calledButtonTag
        ref.child("journeys").child("-Nq0hlmfJCMdbZydV7SG").child("dayByDayTimeStamp").child("\(day)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else { return }
            do {
                let model = try FirebaseDecoder().decode([DayByDayPlace].self, from: value)
                self.currentFirebaseData = model
                completion()
//                    print(model)
            } catch let error {
                print(error)
            }
        })
        

    }
    
    @objc func removeAllFromFavorite() {
        defaults.removeObject(forKey: "UserFavoriteList")
        favoriteListData.removeAll()
        favoriteTableView.reloadData()
        print("remove all")
    }
    
    @objc func addPlaceFromFavorite() {

        fetchJourneyDayByDayData { [self] in
            var placeArr = [DayByDayPlace]()
            if let selectedIndexPath = self.favoriteTableView.indexPathsForSelectedRows {
                for indexPath in selectedIndexPath {
                    let row = indexPath.row
                    var selectedPlace = favoriteListData[row]
                    
                    // hope顯示預設時間八點
                    selectedPlace.time =  journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule[calledButtonTag].date
                    
                    // 更新資料
                    journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule[calledButtonTag].places.append(selectedPlace)
                    
                   
                    placeArr.append(DayByDayPlace(time: selectedPlace.time, place: selectedPlace.placeData.name))
                    
                }
    //            print(placeArr)
                currentFirebaseData = placeArr

                let placeArrData = try! FirebaseEncoder().encode(currentFirebaseData.self)
                
                // realtime database
               
                ref.child("journeys").child("-Nq0hlmfJCMdbZydV7SG").child("dayByDayTimeStamp").child("\(calledButtonTag)").setValue(placeArrData)
        }

            
             //更新資料庫
//            saveUserScheduleData {
//                journeyVC.journeyTableView.reloadData()
//                self.dismiss(animated: true)
//            }
            
        }
            
    }
    
    
    func saveUserScheduleData(completion: () -> Void) {
        if let newScheduleData = try? encoder.encode(journeyVC.userSchedules.self) {
            defaults.set(newScheduleData, forKey: "UserSchedule")
            completion()
        }
        
    }
    
    func setupUI() {
        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            
        }
    }
    
    func setupTableView() {
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.register(FavoriteListTableViewCell.self, forCellReuseIdentifier: "FavoriteListTableViewCell")
        favoriteTableView.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        favoriteTableView.separatorStyle = .singleLine
        favoriteTableView.rowHeight = UITableView.automaticDimension
        favoriteTableView.estimatedRowHeight = 100
    }
    
    
    func getUserFavoriteListData(completion: () -> Void) {

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
        selectedPlaces.removeAll()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if caller == "JourneyVC" {
            return "選擇想加入行程的景點(可複選)"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if caller == "JourneyVC" {
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
        config.performsFirstActionWithFullSwipe = false // if true -> 滑到底直接刪除
        return config
    }
    
    
}
