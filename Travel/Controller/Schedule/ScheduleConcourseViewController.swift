//
//  ScheduleConcourseViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/26.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseAuth
import CodableFirebase

struct JourneyInfo: Codable {
    let createrUID: String
    var departureDate: String
    var destination: String
    var numberOfDays: Int
    var scheduleTitle: String
}

class ScheduleConcourseViewController: UIViewController {
    
    let ref: DatabaseReference = Database.database(url: "https://travel-1f72e-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    lazy var journeyVC = JourneyViewController()
    lazy var createScheduleVC = CreateScheduleViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var scheduleTableView = UITableView(frame: .zero, style: .insetGrouped)
    var userSchedules = [UserSchedules]()
    let dateUtility = DateUtility()
//    let defaults = UserDefaults.standard
//    let encoder = JSONEncoder()
//    let decoder = JSONDecoder()
    
    var goingToSend = [UserSchedules]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        setupNav()
        setupUI()
        setupTableView()

    }

    func setupNav() {
        self.navigationItem.title = "我的行程"
        let rightBarButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(showCreateScheduleVC))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupUI() {
        view.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(120)
        }

        view.addSubview(scheduleTableView)
        scheduleTableView.snp.makeConstraints { make in
            make.top.equalTo(tableHeaderView.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setupTableHeaderView(journeyCount: Int) {
        tableHeaderView.backgroundColor = .white
        tableHeaderView.layer.cornerRadius = 10
        tableHeaderView.countLabel.text = "\(journeyCount)"
        tableHeaderView.scheduleInfoStack.isHidden = true
        tableHeaderView.editButton.isHidden = true
        tableHeaderView.userImageView.image = UIImage(systemName: "person.crop.circle.fill")
        tableHeaderView.userImageView.tintColor = .systemOrange
    }

    @objc func showCreateScheduleVC() {
        createScheduleVC.caller = "concourse"
        createScheduleVC.concourseVC = self
        let createScheduleVCNav = UINavigationController.init(rootViewController: createScheduleVC)
        present(createScheduleVCNav, animated: true)
    }

    func setupTableView() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(ScheduleConcourseTableViewCell.self, forCellReuseIdentifier: "ScheduleConcourseTableViewCell")
        scheduleTableView.backgroundColor = TravelAppColor.lightGrayBackgroundColor

    }
    
//    func getUserScheduleData(completion: @escaping () -> Void) {
//        if let defaultData = defaults.data(forKey: "UserSchedule") {
//            if let decodedData = try? decoder.decode([UserSchedules].self, from: defaultData) {
//                self.userSchedules = decodedData
//                completion()
//            } else {
//                print("Fail to decode")
//            }
//            
//        } else {
//            print("UserScheduleData不存在")
//        }
//    }
    
    func getUserJourneyCount(completion: @escaping (Int) -> Void) {
        ref.removeAllObservers()
        ref.child("journeys").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            // 取得行程筆數並設定 table header view
            if snapshot.hasChild("journeyID") {
            // 存在行程時，將已存行程數量傳出去
                let journeyCount = snapshot.childSnapshot(forPath: "journeyID").childrenCount // UInt type
                print("run has child, journeyCount:\(journeyCount)")
                self.ref.removeAllObservers()
                completion(Int(journeyCount))
            } else {
                // if 沒有已存行程，傳出 0
                print("run has no child")
                self.ref.removeAllObservers()
                completion(0)
            }
        }

    }
    
    func fetchAllJourneyList(completion: @escaping () -> Void) {
        // 為了製作包含所有已創行程列表的table view，取得ref裡面儲存的每一筆行程

        userSchedules.removeAll()
        ref.removeAllObservers()
        ref.child("journeys/journeyID").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            for child in snapshot.children {
                // 把取得的 snapshot 轉換回 DataSnapshot 型別 -> 取得子節點的值 -> 將 value 填入 userSchedules
                if let childDataSnapshot = child as? DataSnapshot {
                    let journeyID = childDataSnapshot.key
                    let createrUID = childDataSnapshot.childSnapshot(forPath: "info/createrUID").value as! String
                    let departureDate = childDataSnapshot.childSnapshot(forPath: "info/departureDate").value as! Double
                    let destination = childDataSnapshot.childSnapshot(forPath: "info/destination").value as! String
                    let numberOfDays = childDataSnapshot.childSnapshot(forPath: "info/numberOfDays").value as! Int
                    let scheduleTitle
 = childDataSnapshot.childSnapshot(forPath: "info/scheduleTitle").value as! String
                    // 依序取得第 n 天行程的時間
                    var dbdArr = [DayByDaySchedule]()
                    for nthDay in 1...numberOfDays {
                        let dbdDate = childDataSnapshot.childSnapshot(forPath: "dayByDay/Day\(nthDay)/date").value as! Double
                        dbdArr.append(DayByDaySchedule(date: dbdDate))
                    }
                    // 將每一筆讀出來的 journey 資料存進 userSchedules
                    let journey = UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: scheduleTitle, destination: destination, departureDate: departureDate, numberOfDays: numberOfDays, dayByDaySchedule: dbdArr)
                    self.userSchedules.append(journey)
                }
            }
            self.ref.removeAllObservers()
            completion()
        }

    }
    
//    func getNumberOfDaysOfSelectedJourney(indexPath: IndexPath, completion: @escaping(Int) -> Void) {
//        var numberOfDays = 0
//        ref.child("journeys/journeyID/\(userSchedules[indexPath.section].journeyID)/info/numberOfDays").observe(.value) { snapshot in
//            numberOfDays = snapshot.value as! Int
//            completion(numberOfDays)
//        }
//    }
    
    func fetchDayByDayDataOfSelectedJourney(indexPath: IndexPath, completion: @escaping ((Int,[DayByDayPlace])) -> Void) {
        let journeyID = self.userSchedules[indexPath.section].journeyID
       
        ref.child("journeys/journeyID/\(journeyID)/dayByDay").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            for i in 1...self.userSchedules[indexPath.section].numberOfDays {
                let daySnap = snapshot.childSnapshot(forPath: "Day\(i)")
                let placeSnap = daySnap.childSnapshot(forPath: "places")
                if let placeValue = placeSnap.value {
                    do {
                        let model = try FirebaseDecoder().decode([DayByDayPlace].self, from: placeValue)
                        self.ref.removeAllObservers()
                        completion((i-1,model))
                    } catch {
                        // when 沒有地點資料，傳一個 timeInterval 為 0 的 fake data，之後用該 timeInterval 判斷何時發動 completion
                        print("行程Day\(i)沒有已存地點")
                        self.ref.removeAllObservers()
                        completion((i-1,[DayByDayPlace(time: 0, place: "沒有已存地點")]))
//                        print(error)
                    }
                   
                }

            }

        }
        ref.removeAllObservers()

    }
 
//    @objc func saveUserScheduleData() {
//        if let newScheduleData = try? encoder.encode(userSchedules.self) {
//            defaults.set(newScheduleData, forKey: "UserSchedule")
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // 取得使用者行程筆數後，依照回傳 count 設定 table header view
        getUserJourneyCount { [weak self] journeyCount in
            guard let self = self else { return }
            self.setupTableHeaderView(journeyCount: journeyCount)
        }
        // 取得各行程 info
        self.fetchAllJourneyList {
            self.scheduleTableView.reloadData()
        }
//        getUserScheduleData {
//            // 更新 header view
//            self.tableHeaderView.countLabel.text = "\(self.userSchedules.count)"
//            // 更新 table view
//            self.scheduleTableView.reloadData()
//        }
    }
    
//    func checkIfScheduleDataChanged(completion: () -> Void) {
//        if let defaultData = defaults.data(forKey: "UserSchedule") {
//            if let decodedData = try? decoder.decode([UserSchedules].self, from: defaultData) {
//                if !decodedData.elementsEqual(self.userSchedules) {
//                    print("資料改變 please save new data")
//                    completion()
//                }
//            }
//        }
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

//        checkIfScheduleDataChanged {
//            // show alert and save data
//            let alert = UIAlertController(title: "更動已儲存", message: nil, preferredStyle: .alert)
//            let saveAction = UIAlertAction(title: "OK", style: .default) { action in
//                self.saveUserScheduleData()
//            }
//            alert.addAction(saveAction)
//            self.present(alert, animated: true)
//        }
        
    }
    
   

} // class end

extension ScheduleConcourseViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleConcourseTableViewCell", for: indexPath) as? ScheduleConcourseTableViewCell else { return UITableViewCell() }
        let section = indexPath.section
        cell.scheduleTitleLabel.text = userSchedules[section].scheduleTitle
        cell.placeImageView.image = UIImage(systemName: "globe.central.south.asia")
        
        let startDateTimeInterval = userSchedules[section].departureDate
        let startDateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: startDateTimeInterval))
        let countOfDays = userSchedules[section].numberOfDays
        let endDateTimeInterval = userSchedules[section].departureDate + Double(86400*(countOfDays-1))
        let endDateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: endDateTimeInterval))
        
        cell.dateRangeLabel.text = "\(startDateStr) ~ \(endDateStr)"

        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        userSchedules.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        return footer
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let section = indexPath.section
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            // realtime db
            self.ref.child("journeys/journeyID/\(self.userSchedules[section].journeyID)").removeValue()
            
            // local
            self.userSchedules.remove(at: section)
            
            // table view
            self.scheduleTableView.deleteSections([indexPath.section], with: .automatic)
            
            // update header view
            self.getUserJourneyCount { count in
                self.tableHeaderView.countLabel.text = "\(self.userSchedules.count)"
            }
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false // 滑到底直接刪除
        return config
    }
    
    func prepareSelectedJourneyData(indexPath: IndexPath, completion: @escaping() -> Void) {
        print("prepareSelectedJourneyData when selected")
        fetchDayByDayDataOfSelectedJourney(indexPath: indexPath) { [weak self]
            (index,dbdPlace) in
            guard let self = self else { return }

//            print("\(index)~~fetchJourneyDayByDayData")
            if dbdPlace[0].time != 0 {
                for place in dbdPlace {
                    self.userSchedules[indexPath.section].dayByDaySchedule[index].places.append(place)
                }
            }
           
//             傳入之 index = 行程最後一天時，發動 completion
            if index == self.userSchedules[indexPath.section].numberOfDays-1 {
                // passing data: 將被點擊的行程 journeyID 傳給 journeyVC，之後用於抓取 db 資料
                self.journeyVC.journeyID = self.userSchedules[indexPath.section].journeyID
                ref.removeAllObservers()
                completion()
            }
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        prepareSelectedJourneyData(indexPath: indexPath) { [weak self] in
            print("prepared SelectedJourneyData ")
            
            guard let self = self else { return }
//            print("self.journeyVC.journeyID:\(self.journeyVC.journeyID)")
            if let nav = self.navigationController {
                // 還是要view will appear才發動??
                self.journeyVC.getUserJourneyInfoData {
                    self.journeyVC.updateTableHeaderViewInfo()
                    self.journeyVC.journeyTableView.reloadData()
                    nav.pushViewController(self.journeyVC, animated: true)
                }
            }
        }
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100

    }
}
