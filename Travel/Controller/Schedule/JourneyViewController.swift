//
//  ScheduleViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit
import SnapKit
import SDWebImage
import CodableFirebase
import FirebaseDatabase

class JourneyViewController: UIViewController {

    let ref: DatabaseReference = Database.database(url: "https://travel-1f72e-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    var journeyID = ""
    
    // 整包資料 & 要顯示第幾筆的index
    var userSchedules = [UserSchedules]()
    var scheduleIndex = 0
    //
//    let defaults = UserDefaults.standard
//    let encoder = JSONEncoder()
    lazy var favoriteVC = FavoriteViewController()
    lazy var createScheduleVC = CreateScheduleViewController()
    lazy var detailVC = DetailViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var customTabBar = CustomGroupTabBar(tabNames: [""], style: .init())
   
    lazy var journeyTableView = UITableView(frame: .zero, style: .insetGrouped)

    let uiSettingUtility = UISettingUtility()
    let dateUtility = DateUtility()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        setupUI()
        setupJourneyTableView()

    }
    
    func setupUI() {
        view.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(120)
        }
//        setupTableHeaderView()
        
        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.top.equalTo(tableHeaderView.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        customTabBar.clipsToBounds = true
        
        view.addSubview(journeyTableView)
        journeyTableView.snp.makeConstraints { make in
            make.top.equalTo(customTabBar.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

    }
    
    func prepareTabBarButton() {
        // 每次都重新準備標題跟按鈕
        customTabBar.tabNames.removeAll()
        customTabBar.tabButtons.removeAll()
        
        var count = 1
        while customTabBar.tabNames.count < userSchedules[scheduleIndex].numberOfDays {
            customTabBar.tabNames.append("Day\(count)")
            count += 1
        }
        customTabBar.tabNames.append("+")

    }
    
    func setupCustomTabBar() {
        customTabBar.delegate = self
        prepareTabBarButton()
        customTabBar.initialTabButtons()
        customTabBar.setSelectedTab(index: 0)
        
    }

    func setupJourneyTableView() {
        journeyTableView.dataSource = self
        journeyTableView.delegate = self
        journeyTableView.register(JourneyTableViewCell.self, forCellReuseIdentifier: "JourneyTableViewCell")
        journeyTableView.isEditing = false
        journeyTableView.backgroundColor = TravelAppColor.lightGrayBackgroundColor
    }

    func setupTableHeaderView() {
        tableHeaderView.backgroundColor = .white
        tableHeaderView.layer.cornerRadius = 10

        tableHeaderView.userImageView.isHidden = true
        tableHeaderView.countStack.isHidden = true
        
//        tableHeaderView.scheduleTitleLabel.text = userSchedules[scheduleIndex].scheduleTitle
//        tableHeaderView.destinationLabel.text = userSchedules[scheduleIndex].destination
//        let dateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].departureDate))
//        tableHeaderView.departureDayLabel.text = dateStr
//        tableHeaderView.numberOfDaysLabel.text = "為期 \(userSchedules[scheduleIndex].numberOfDays) 天"
        tableHeaderView.editButton.addTarget(self, action: #selector(editScheduleInfo), for: .touchUpInside)
    }
    
    @objc func editScheduleInfo() {
        createScheduleVC.caller = "schedule"
        createScheduleVC.journeyVC = self
        
        // 設定為保留原資料的狀態方便修改
        createScheduleVC.schedultTitleTextField.text = userSchedules[scheduleIndex].scheduleTitle
        createScheduleVC.numberOfDaysTextField.text = "\(userSchedules[scheduleIndex].numberOfDays)"
        createScheduleVC.destinationTextField.text = userSchedules[scheduleIndex].destination
        let dateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].departureDate))
        createScheduleVC.departureDateTextField.text = dateStr
        
        let nav = UINavigationController(rootViewController: createScheduleVC)
        present(nav, animated: true)
        
    }
    
//    func saveUserScheduleData(completion: () -> Void) {
//        if let newScheduleData = try? encoder.encode(userSchedules.self) {
//            defaults.set(newScheduleData, forKey: "UserSchedule")
//            completion()
//        }
//        
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        // MARK: - realtime database
        fetchJourneyDayByDayData { [self] in
            
            print("journeyVC",userSchedules)
            journeyTableView.reloadData()
        }
        
//        fetchJourneyDayByDayData { [self] in
//            journeyTableView.reloadData()
//            setupTableHeaderView()
//            journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
//        }
        ///
        
        
        journeyTableView.isEditing = false
//        journeyTableView.reloadData()
//        journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
//        setupTableHeaderView()
        setupCustomTabBar()

    }
    
    func getNumberOfDays(completion: @escaping(Int) -> Void) {
        var numberOfDays = 0
        ref.child("journeys/journeyID/\(journeyID)/info/numberOfDays").observe(.value) { snapshot in
            numberOfDays = snapshot.value as! Int
            completion(numberOfDays)
        }
    }
    
    func getUserJourneyInfoData(completion: @escaping () -> Void) {
        userSchedules.removeAll()
        print("getUserJourneyInfoData")
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
                        dbdArr.append(DayByDaySchedule(date: dbdDate))
                    }
                    
                    let journey = UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: scheduleTitle, destination: destination, departureDate: departureDate, numberOfDays: numberOfDays, dayByDaySchedule: dbdArr)
                    self.userSchedules.append(journey)
                    
                    // header view
                    tableHeaderView.scheduleTitleLabel.text = userSchedules[scheduleIndex].scheduleTitle
                    tableHeaderView.destinationLabel.text = userSchedules[scheduleIndex].destination
                    let dateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].departureDate))
                    tableHeaderView.departureDayLabel.text = dateStr
                    tableHeaderView.numberOfDaysLabel.text = "為期 \(userSchedules[scheduleIndex].numberOfDays) 天"
                    
                }
            }
            ref.removeAllObservers()
            completion()
        }
        ref.removeAllObservers()
    }
    
    func fetchJourneyDayByDayData(completion: @escaping() -> Void) {
        var currentPlaces = [DayByDayPlace]()
        
        getNumberOfDays { numberOfDays in
            for i in 1...numberOfDays {
                self.ref.child("journeys/journeyID/\(self.journeyID)/dayByDay/Day\(i)").observe(.value) { [weak self] snapshot in
                    guard let self = self else { return }
                    if snapshot.hasChild("places") {
                        let childSnapShot = snapshot.childSnapshot(forPath: "places")

                        if let childSnapShotValue = childSnapShot.value {
                            do {
                                let model = try FirebaseDecoder().decode([DayByDayPlace].self, from: childSnapShotValue)

                                currentPlaces = model
                                self.userSchedules[scheduleIndex].dayByDaySchedule[i-1].places = currentPlaces
                                completion()
                            } catch let error {
                                print(error)
                            }
                        }

                    }
                }
              
            }
        }

        ref.removeAllObservers()

        

    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        
//        saveUserScheduleData {
//            print("Schedule has been saved")
//        }
//    }

    
}

extension JourneyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     userSchedules[scheduleIndex].dayByDaySchedule[section].places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JourneyTableViewCell", for: indexPath) as? JourneyTableViewCell else { return UITableViewCell() }
        // delegate
        cell.delegate = self
        cell.indexPath = indexPath
        /////

        cell.nameLabel.text = userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].place
//        if let url = URL(string: userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].placeData.imageURL) {
//            cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "fork.knife"))
//        }
        
        cell.timePicker.date = Date(timeIntervalSince1970: userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].time)
        updateTime(cell, time: userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].time)
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        userSchedules[scheduleIndex].numberOfDays
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        return footer
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        let titleLabel = UILabel()
        titleLabel.layer.cornerRadius = 5
        titleLabel.clipsToBounds = true
        titleLabel.text = "  \(dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].dayByDaySchedule[section].date)))  "
        uiSettingUtility.labelSettings(label: titleLabel, fontSize: 16, fontWeight: .semibold, color: .white, alignment: .left, numOfLines: 1)
        titleLabel.backgroundColor = .systemRed
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        let menuButton = UIButton(type: .custom)
        menuButton.tag = section
        setupMenuButton(sender: menuButton)
        menuButton.tintColor = .systemGray
        header.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.bottom.equalToSuperview().offset(-10)
        }
        return header
    }
    
    func prepareMenuActions(sender: UIButton) -> [UIAction] {
        let addNewAction = UIAction(title: "新增地點", image: UIImage(systemName: "heart.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
            guard let self = self else { return }

            self.favoriteVC.caller = "JourneyVC"
            self.favoriteVC.calledButtonTag = sender.tag
            self.favoriteVC.journeyVC = self
            
            let navOfFavoriteVC = UINavigationController(rootViewController: self.favoriteVC)
            if let sheetPresentationController = navOfFavoriteVC.sheetPresentationController {
                sheetPresentationController.prefersGrabberVisible = true
                sheetPresentationController.detents = [.large()]
                sheetPresentationController.preferredCornerRadius = 10
                
            }
            self.present(navOfFavoriteVC, animated: true, completion: nil)
        })
        let deleteDayAction = UIAction(title: "刪除整日", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [weak self] action in
            guard let self = self else {return}
           
            let alert = UIAlertController(title: "確定刪除本日？", message: "行程天數為 1 時，僅清空單日行程", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                
                var numberOfDays = self.userSchedules[scheduleIndex].numberOfDays
                if numberOfDays > 1 {
                    numberOfDays -= 1
                    // 更新資料
                    self.userSchedules[scheduleIndex].numberOfDays = numberOfDays
                    self.userSchedules[scheduleIndex].dayByDaySchedule.remove(at: sender.tag)

                    // realtime db
                    self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(sender.tag)").removeValue()
                    
                    
                    // hope: 刪除時 後一天的時間自動替換成-1天
                    // try:
                    let leftDays = self.userSchedules[scheduleIndex].dayByDaySchedule
//                    print("left date", leftDays)
                    for i in sender.tag..<leftDays.count {
                        let newDate = leftDays[i].date - 86400
                        
                        self.userSchedules[scheduleIndex].dayByDaySchedule[i].date = newDate
                        
                        // realtime db
                        self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(i)/date").setValue(newDate)
                        
                    }
                        self.journeyTableView.reloadData()
                        self.setupTableHeaderView()
                        self.setupCustomTabBar()
//                    self.saveUserScheduleData {
//                        self.journeyTableView.reloadData()
//                        self.setupTableHeaderView()
//                        self.setupCustomTabBar()
//                    }

                } else {
                    // 天數為1時，僅清空單日行程
                    self.userSchedules[scheduleIndex].dayByDaySchedule[0].places.removeAll()
                    self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day1/places").removeValue()
                    self.journeyTableView.reloadData()
//                    self.saveUserScheduleData {
//                        self.journeyTableView.reloadData()
//                    }
                }

            }
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        })
        
//        let editOrderAction = UIAction(title: "編輯順序", image: UIImage(systemName: "line.3.horizontal"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: self.journeyTableView.isEditing == true ? .on : .off, handler: { [weak self] action in
//            guard let self = self else { return }
//            self.journeyTableView.isEditing = !self.journeyTableView.isEditing
//        })
        let editOrderAction = UIAction(title: "編輯順序", image: UIImage(systemName: "line.3.horizontal"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
            guard let self = self else { return }
            self.journeyTableView.isEditing = !self.journeyTableView.isEditing
        })

        return [addNewAction,editOrderAction,deleteDayAction]
    }

    func setupMenuButton(sender: UIButton) {
        sender.setImage(UIImage(systemName: "ellipsis"), for: [])
        sender.showsMenuAsPrimaryAction = true
        sender.menu = UIMenu(children: prepareMenuActions(sender: sender))

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let section = indexPath.section
//        let index = indexPath.row
//        if let nav = self.navigationController {
//            detailVC.placeInfoData = self.userSchedules[scheduleIndex].dayByDaySchedule[section].places
//            detailVC.dataIndex = index
//            nav.pushViewController(detailVC, animated: true)
//        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.journeyTableView.isEditing == true {
            return true
        }
        return false
    }
    
    // 停用編輯模式下的刪除功能
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let section = sourceIndexPath.section
        let index = sourceIndexPath.row
        let destinationSection = destinationIndexPath.section
        let destinationIndex = destinationIndexPath.row
        let numberOfDayChange = Double(destinationSection - section)
        
        // local
        let movedPlace = userSchedules[scheduleIndex].dayByDaySchedule[section].places[index]
        userSchedules[scheduleIndex].dayByDaySchedule[section].places.remove(at: index)
        userSchedules[scheduleIndex].dayByDaySchedule[destinationSection].places.insert(movedPlace, at: destinationIndex)
        userSchedules[scheduleIndex].dayByDaySchedule[destinationSection].places[destinationIndex].time += 86400 * numberOfDayChange
        
        // realtime db
//        var dbdSource = userSchedules[scheduleIndex].dayByDaySchedule
//        dbdSource[section].places.remove(at: index)
//        dbdSource[destinationSection].places.insert(movedPlace, at: destinationIndex)
//        dbdSource[destinationSection].places[destinationIndex].time += 86400 * numberOfDayChange
        
        // MARK: - 暫時鎖掉
//        let dbdSourceUpdatedData = try! FirebaseEncoder().encode(userSchedules[scheduleIndex].dayByDaySchedule[section].places)
//        let dbdDestinationUpdatedData = try! FirebaseEncoder().encode(userSchedules[scheduleIndex].dayByDaySchedule[destinationSection].places)
//        
//        ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(section+1)/places").setValue(dbdSourceUpdatedData)
//        
//        ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(destinationSection+1)/places").setValue(dbdDestinationUpdatedData)
        
//        fetchJourneyDayByDayData {
//            tableView.reloadData()
//        }
        

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除地點") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            // realtime
            self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(indexPath.section+1)/places/\(indexPath.row)").removeValue()
            self.journeyTableView.deleteRows(at: [indexPath], with: .automatic)
//            var placeArr = [DayByDayPlace]()
//            fetchCurrentPlaces(indexPath: indexPath) { result in
//                switch result {
//                case .success(let currentPlaces):
//                    placeArr = currentPlaces
//                    print(placeArr)
//                    placeArr.remove(at: indexPath.row)
//                    print("update:",placeArr)
//                case .failure(_):
//                    break
//                }
//                
//                let placeUpdatedData = try! FirebaseEncoder().encode(placeArr.self)
//                self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(indexPath.section+1)").setValue(placeUpdatedData)
//            }
           
            ///
//            self.userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places.remove(at: indexPath.row)
//            self.saveUserScheduleData {
//                self.journeyTableView.deleteRows(at: [indexPath], with: .automatic)
//            }
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
       
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func updateTime(_ cell: JourneyTableViewCell, time: TimeInterval) {
        cell.timePicker.date = Date(timeIntervalSince1970: time)
    }
    
    
    
    func fetchCurrentPlaces(indexPath: IndexPath, completion: @escaping (Result<[DayByDayPlace],Error>) -> Void) {
        // MARK: - realtime database
        ref.removeAllObservers()
        ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(indexPath.section+1)").observeSingleEvent(of: .value) { [self] snapshot, result in
            guard let value = snapshot.value else { return }
            do {
                let currentPlaces = try FirebaseDecoder().decode([DayByDayPlace].self, from: value)
                ref.removeAllObservers()
                completion(.success(currentPlaces))
            } catch let error {
                print("error:",error.localizedDescription)
                completion(.failure(error))
            }
        }
        ref.removeAllObservers()
    }
    
} // ex table view end

extension JourneyViewController: CustomPageTabBarDelegate {
    
    func clickTab(index: Int) {
        
        customTabBar.setSelectedTab(index: index)
        
        var count = userSchedules[scheduleIndex].numberOfDays
        if index < count {
            print("滾動到Day\(index+1)")
            journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)

        } else if index == count {
            print("加一天")
            count += 1
            userSchedules[scheduleIndex].numberOfDays = count
            
            if var currentLastDayDate =  userSchedules[scheduleIndex].dayByDaySchedule.last?.date {
                
                let newDate = currentLastDayDate + 86400
                userSchedules[scheduleIndex].dayByDaySchedule.append(DayByDaySchedule(date: newDate))
                currentLastDayDate = newDate
                //realtime db
                ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(count)/date").setValue(newDate)

            }
            
            customTabBar.tabNames.removeLast()
            customTabBar.tabNames.append("Day\(count)")
            customTabBar.tabNames.append("+")
            customTabBar.tabButtons.removeAll()
            customTabBar.initialTabButtons()
            
            // realtime db
            ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/info/numberOfDays").setValue(count)
           
            ///
            
            customTabBar.setSelectedTab(index: index)
            journeyTableView.reloadData()
            journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)
            setupTableHeaderView()
            
//            saveUserScheduleData {
//                customTabBar.setSelectedTab(index: index)
//                journeyTableView.reloadData()
//                journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)
//                setupTableHeaderView()
//            }
            
        }

    }
    
}

extension JourneyViewController: JourneyTableViewCellTableViewCellDelegate {
    func timeChange(indexPath: IndexPath, time: TimeInterval) {
        let section = indexPath.section
        let index = indexPath.row
        
        ref.child("/journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(section+1)/places/\(index)/time").setValue(time)
        userSchedules[scheduleIndex].dayByDaySchedule[section].places[index].time = time
        
        fetchJourneyDayByDayData { [self] in
            journeyTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        

//        saveUserScheduleData {
//            print("new data saved")
//            self.journeyTableView.reloadRows(at: [indexPath], with: .automatic)
//        }
    }
    
    
}
