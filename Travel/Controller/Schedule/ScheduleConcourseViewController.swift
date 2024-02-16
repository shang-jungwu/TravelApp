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
        
//        let leftBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveUserScheduleData))
//        self.navigationItem.leftBarButtonItem = leftBarButton
    }

    func setupUI() {
        view.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(120)
        }
//        setupTableHeaderView(journeyCount: <#Int#>)

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
        ref.child("journeys").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            // 取得行程筆數
            if !snapshot.hasChild("journeyID") {
                self.tableHeaderView.countLabel.text = "0"
                completion(0)
            } else {
                let journeyCount = snapshot.childSnapshot(forPath: "journeyID").childrenCount
                self.tableHeaderView.countLabel.text = "\(journeyCount)"
                completion(Int(journeyCount))
            }
            
        }
        
    }
    
    func getUserJourneyInfoData(completion: @escaping () -> Void) {
//        ref.removeAllObservers()
        userSchedules.removeAll()
        var journey = [UserSchedules]()
        ref.child("journeys/journeyID").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            for child in snapshot.children {
                // 把取得的snapshot轉換回DataSnapshot型別，再取得子節點的值
                if let childSnapShot = child as? DataSnapshot {
                    let journeyID = childSnapShot.key
                    let createrUID = childSnapShot.childSnapshot(forPath: "info/createrUID").value as! String
                    let departureDate = childSnapShot.childSnapshot(forPath: "info/departureDate").value as! Double
                    let destination = childSnapShot.childSnapshot(forPath: "info/destination").value as! String
                    let numberOfDays = childSnapShot.childSnapshot(forPath: "info/numberOfDays").value as! Int
                    let scheduleTitle
 = childSnapShot.childSnapshot(forPath: "info/scheduleTitle").value as! String
                    var dbdArr = [DayByDaySchedule]()
                    for i in 1...numberOfDays {
                        let dbdDate = childSnapShot.childSnapshot(forPath: "dayByDay/Day\(i)/date").value as! Double
                        journeyVC.fetchJourneyDayByDayData {
                            <#code#>
                        }
                        journeyVC.fetchCurrentPlaces(indexPath: <#T##IndexPath#>, completion: <#T##(Result<[DayByDayPlace], Error>) -> Void#>)
                        dbdArr.append(DayByDaySchedule(date: dbdDate,places: <#T##[DayByDayPlace]#>))
                    }
                    
                    journey = [UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: scheduleTitle, destination: destination, departureDate: departureDate, numberOfDays: numberOfDays, dayByDaySchedule: dbdArr)]
//                    self.userSchedules.append(UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: scheduleTitle, destination: destination, departureDate: departureDate, numberOfDays: numberOfDays, dayByDaySchedule: dbdArr))

                   
                }
                self.userSchedules.append(journey[0])
                ref.removeAllObservers()
                completion()
            }
            
        }
        
        
    }
 
//    @objc func saveUserScheduleData() {
//        if let newScheduleData = try? encoder.encode(userSchedules.self) {
//            defaults.set(newScheduleData, forKey: "UserSchedule")
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // 取得使用者行程筆數
        getUserJourneyCount { [self] journeyCount in
            setupTableHeaderView(journeyCount: journeyCount)
            if journeyCount > 0 {
                // 取得使用者行程info
                getUserJourneyInfoData { [self] in
                    print(userSchedules)
                    scheduleTableView.reloadData()
                }
            }
           
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
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            self.userSchedules.remove(at: section)
            // realtime db
            self.ref.child("journeys/journeyID/\(userSchedules[section].journeyID)").removeValue()
            self.getUserJourneyInfoData {
                self.scheduleTableView.reloadData()
//                self.scheduleTableView.deleteSections([indexPath.section], with: .automatic)
            }
            ///

//            self.tableHeaderView.countLabel.text = "\(self.userSchedules.count)"
//            self.scheduleTableView.deleteSections([indexPath.section], with: .automatic)
            
            completionHandler(true)

        }
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false // 滑到底直接刪除
        return config

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        getUserJourneyInfoData { [self] in
            if let nav = self.navigationController {
    //            journeyVC.scheduleIndex = section
                journeyVC.userSchedules = [self.userSchedules[section]]
                nav.pushViewController(journeyVC, animated: true)
            }
        }
//        if let nav = self.navigationController {
////            journeyVC.scheduleIndex = section
//            journeyVC.userSchedules = [self.userSchedules[section]]
//            nav.pushViewController(journeyVC, animated: true)
//        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100

    }
}
