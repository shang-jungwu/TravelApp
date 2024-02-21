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


class ScheduleConcourseViewController: UIViewController {
    
    let ref: DatabaseReference = Database.database(url: "https://travel-1f72e-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    var userJourneyList = [String]()
    let uid = Auth.auth().currentUser!.uid
    
    lazy var journeyVC = JourneyViewController()
    lazy var createScheduleVC = CreateScheduleViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var scheduleTableView = UITableView(frame: .zero, style: .insetGrouped)
    var userSchedules = [UserSchedules]()
    let dateUtility = DateUtility()
    
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
        //
        createScheduleVC.userJourneyList = self.userJourneyList
        //
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
        // ref.child("journeys").observeSingleEvent(of: .value)
        
        ref.child("users/\(uid)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            // 取得行程筆數並設定 table header view
            if snapshot.hasChild("journeys") {
            // 存在行程時，將已存行程數量傳出去
                let journeyCount = snapshot.childSnapshot(forPath: "journeys").childrenCount // UInt type
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
    
    func getJourneyNumberOfDays(journeyID: String, completion: @escaping (Int) -> Void) {
        ref.removeAllObservers()
        ref.child("journeys/journeyID/\(journeyID)/info/numberOfDays").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else { return }
            if let num = value as? Int {
                completion(num)
            }
        }
    }
    
    func fetchAllJourneyList(completion: @escaping () -> Void) {
        // 為了製作包含所有已創行程列表的table view，取得ref裡面儲存的每一筆行程
        userSchedules.removeAll()
        ref.removeAllObservers()
        ref.child("users/\(uid)/journeys").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            if snapshot.exists() {
                for journeyID in self.userJourneyList {
                    var userSchedule = UserSchedules(createrID: "", journeyID: "", scheduleTitle: "", destination: "", departureDate: 0, numberOfDays: 0, dayByDaySchedule: [DayByDaySchedule]())
                    var createrUID = "", destination = "", scheduleTitle = "", numberOfDays:Int = 0, departureDate:Double = 0
                    var dbdArr = [DayByDaySchedule]()
                    
                    self.ref.child("journeys/journeyID/\(journeyID)").observeSingleEvent(of: .value) { (journeyIDsnapshot) in
                        for journey in journeyIDsnapshot.children {
                            if let journeySnapshot = journey as? DataSnapshot {
                                switch journeySnapshot.key {
                                case "info":
                                    createrUID = journeySnapshot.childSnapshot(forPath: "createrUID").value as! String
                                    departureDate = journeySnapshot.childSnapshot(forPath: "departureDate").value as! Double
                                    destination = journeySnapshot.childSnapshot(forPath: "destination").value as! String
                                    numberOfDays = journeySnapshot.childSnapshot(forPath: "numberOfDays").value as! Int
                                    scheduleTitle = journeySnapshot.childSnapshot(forPath: "scheduleTitle").value as! String
  
                                case "dayByDay":
                                    // 先給一個空白日程，cell被點擊的時候再抓取每日地點資料
                                    break
//                                    self.getJourneyNumberOfDays(journeyID: journeyID) { num in
//                                        print("num:\(num)")
//                                        for i in 1...num {
//                                            if let date = journeySnapshot.childSnapshot(forPath: "Day\(i)/date").value as? Double {
//                                                dbdArr.append(DayByDaySchedule(date: date))
//                                            }
//                                        }
//                                    }

                                default:
                                   break
                                }
                            }
                        }
                        userSchedule = UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: scheduleTitle, destination: destination, departureDate: departureDate, numberOfDays: numberOfDays, dayByDaySchedule: dbdArr)
                        print("@concourse fetchAllJourneyList ~~~ journeyID:\(journeyID), userSchedule:\(userSchedule)")
                        self.userSchedules.append(userSchedule)
                        self.ref.removeAllObservers()
                        completion()
                    }
                }
            } else {
                print("user dont have any journey yet")
                ref.removeAllObservers()
                completion()
            }
        }

    }
    
    
    func fetchDayByDayDataOfSelectedJourney(indexPath: IndexPath, completion: @escaping ((Int,[DayByDayPlace])) -> Void) {
        let journeyID = userSchedules[indexPath.section].journeyID //userJourneyList[indexPath.section]

        ref.child("journeys/journeyID/\(journeyID)/dayByDay").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            for i in 1...self.userSchedules[indexPath.section].numberOfDays {
                let daySnap = snapshot.childSnapshot(forPath: "Day\(i)")
                let placeSnap = daySnap.childSnapshot(forPath: "places")

                if let placeValue = placeSnap.value {
                    do {
                        let model = try FirebaseDecoder().decode([DayByDayPlace].self, from: placeValue)
                        print("存在已儲存的地點資料")
                        self.ref.removeAllObservers()
                        completion((i-1,model))
                    } catch {
                        // if 沒有地點資料，傳一個 timeInterval 為 0 的 fake place data，用該 timeInterval 判斷何時發動 completion
                        print("行程\(userSchedules[indexPath.section].scheduleTitle), Day\(i)沒有已存地點")
                        self.ref.removeAllObservers()
                        completion((i-1,[DayByDayPlace(time: 0, place: "")]))
//                        print(error)
                    }
                   
                }

            }

        }
        ref.removeAllObservers()

    }
 
    
    func fetchUserSavedJourneyList(completion: @escaping ([String]) -> Void) {
        // 取得使用者所有已存行程 JourneyID
        ref.child("users/\(uid)").observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild("journeys") {
                let journeyChildrenSnap = snapshot.childSnapshot(forPath: "journeys")
                if let value = journeyChildrenSnap.value {
                    do {
                        let journeyIDArr = try FirebaseDecoder().decode([String].self, from: value)
                        self.ref.removeAllObservers()
                        completion(journeyIDArr)
                    } catch let error {
                        self.ref.removeAllObservers()
                        print(error)
                    }
                }
                
            } else {
                print("no JourneyID exists")
                let emptyArr = [String]()
                self.ref.removeAllObservers()
                completion(emptyArr)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchUserSavedJourneyList { journeyIDArr in
            self.userJourneyList = journeyIDArr
            print("@concourseVC viewWillAppear current user journey list:\(journeyIDArr)")
            self.fetchAllJourneyList {
                self.scheduleTableView.reloadData()
            }
        }
        
        // 取得使用者行程筆數後，依照回傳 count 設定 table header view
        getUserJourneyCount { [weak self] journeyCount in
            guard let self = self else { return }
            self.setupTableHeaderView(journeyCount: journeyCount)
        }
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
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            
            // realtime db - journeys
            self.ref.child("journeys/journeyID/\(self.userSchedules[section].journeyID)").removeValue()
            // realtime db - users
            print("@concourseVC self.userJourneyList:\(self.userJourneyList)")
            self.userJourneyList.remove(at: section)
            self.ref.child("users/\(uid)/journeys").setValue(userJourneyList)
            
            // local
            self.userSchedules.remove(at: section)
            
            // table view
            self.scheduleTableView.deleteSections([indexPath.section], with: .automatic)
            
            // update header view
            self.getUserJourneyCount { count in
                self.tableHeaderView.countLabel.text = "\(self.userSchedules.count)"
            }
            completion(true)
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
            print("self.userSchedules[indexPath.section].dayByDaySchedule[index].places",self.userSchedules[indexPath.section].dayByDaySchedule)
            if dbdPlace[0].time != 0 {
                print("@concourse  prepareSelectedJourneyData dbdPlace:",dbdPlace)
//                for place in dbdPlace {
//                    self.userSchedules[indexPath.section].dayByDaySchedule[index].places.append(place)
//                }
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

            if let nav = self.navigationController {
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
