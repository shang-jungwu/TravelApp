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
        setupTableHeaderView()
        
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
        journeyTableView.rowHeight = UITableView.automaticDimension
        journeyTableView.estimatedRowHeight = 100
    }

    func setupTableHeaderView() {
        tableHeaderView.backgroundColor = .white
        tableHeaderView.layer.cornerRadius = 10
        tableHeaderView.userImageView.isHidden = true
        tableHeaderView.countStack.isHidden = true
        tableHeaderView.editButton.addTarget(self, action: #selector(editScheduleInfo), for: .touchUpInside)
    }
    
    @objc func editScheduleInfo() {
        createScheduleVC.caller = "journeyVC"
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
    
    func updateTableHeaderViewInfo() {
        tableHeaderView.scheduleTitleLabel.text = userSchedules[scheduleIndex].scheduleTitle
        tableHeaderView.destinationLabel.text = userSchedules[scheduleIndex].destination
        let dateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].departureDate))
        tableHeaderView.departureDayLabel.text = dateStr
        tableHeaderView.numberOfDaysLabel.text = "為期 \(userSchedules[scheduleIndex].numberOfDays) 天"
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

            updateTableHeaderViewInfo()
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
    
    
    func getUserJourneyInfoData(completion: @escaping () -> Void) {
        ref.removeAllObservers()
        userSchedules = []

        ref.child("journeys/journeyID/\(journeyID)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            
            let infoSnapshot = snapshot.childSnapshot(forPath: "info")
            let createrUID = infoSnapshot.childSnapshot(forPath: "createrUID").value as! String
            let departureDate = infoSnapshot.childSnapshot(forPath: "departureDate").value as! Double
            let destination = infoSnapshot.childSnapshot(forPath: "destination").value as! String
            let numberOfDays = infoSnapshot.childSnapshot(forPath: "numberOfDays").value as! Int
            let scheduleTitle = infoSnapshot.childSnapshot(forPath: "scheduleTitle").value as! String
            
            let dbdSnapshot = snapshot.childSnapshot(forPath: "dayByDay")
            var dbdDateArr = [DayByDaySchedule]()
            for i in 1...numberOfDays {
                let dbdDate = dbdSnapshot.childSnapshot(forPath: "Day\(i)/date").value as! Double
                dbdDateArr.append(DayByDaySchedule(date: dbdDate))
            }

            let journey = UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: scheduleTitle, destination: destination, departureDate: departureDate, numberOfDays: numberOfDays, dayByDaySchedule: dbdDateArr)
            self.userSchedules.append(journey)
            print("journeyVC getUserJourneyInfoData:\(userSchedules)")
            self.ref.removeAllObservers()
            completion()
        }

    }
    
    func fetchJourneyDayByDayData(completion: @escaping() -> Void) {
        var currentPlaces = [DayByDayPlace]()
        ref.removeAllObservers()
        for i in 1...userSchedules[0].numberOfDays {
            self.ref.child("journeys/journeyID/\(self.journeyID)/dayByDay/Day\(i)").observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                if snapshot.hasChild("places") {
                    let childSnapShot = snapshot.childSnapshot(forPath: "places")
                    if let childSnapShotValue = childSnapShot.value {
                        do {
                            let decodedData = try FirebaseDecoder().decode([DayByDayPlace].self, from: childSnapShotValue)

                            currentPlaces = decodedData
                            self.userSchedules[scheduleIndex].dayByDaySchedule[i-1].places = currentPlaces
                            self.ref.removeAllObservers()
                            completion()
                        } catch let error {
                            self.ref.removeAllObservers()
                            print(error)
                        }
                    }

                } else {
                    // no place saved
                    print("journeyVC check: no place saved")
                    self.ref.removeAllObservers()
                    completion()
                }
            }
        }

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
                    
                    // local
                    self.userSchedules[scheduleIndex].numberOfDays = numberOfDays
                    self.userSchedules[scheduleIndex].dayByDaySchedule.remove(at: sender.tag)

                    // realtime db
                    // delete all days in dbd node
                    self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay").removeValue()
                    // update numberOfDays
                    self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/info/numberOfDays").setValue(numberOfDays)
                    
                    // hope: 刪除時 後一天的時間自動替換成-1天
                    // try:
                    // 刪掉某天之後剩下的幾天
                    var leftDays = self.userSchedules[scheduleIndex].dayByDaySchedule
                    // 處理遞補 to do
                    for i in sender.tag..<leftDays.count {
                        leftDays[i].date -= 86400
                        let newDate = leftDays[i].date
                        self.userSchedules[scheduleIndex].dayByDaySchedule[i].date = newDate
                        for j in 0..<self.userSchedules[scheduleIndex].dayByDaySchedule[i].places.count {
                            self.userSchedules[scheduleIndex].dayByDaySchedule[i].places[j].time -= 86400
                        }
                    }
                    
                    let newDbdSchedule = self.userSchedules[scheduleIndex].dayByDaySchedule
                    for (i,newDbd) in newDbdSchedule.enumerated() {
                        self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(i+1)/date").setValue(newDbd.date)
                        if let newPlacesData = try? FirebaseEncoder().encode(newDbd.places) {
                            self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(i+1)/places").setValue(newPlacesData)
                        } else {
                            print("fail to encode")
                        }
                    }
 
                    self.journeyTableView.reloadData()
                    self.updateTableHeaderViewInfo()
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
        // 移動後調整時間
        userSchedules[scheduleIndex].dayByDaySchedule[destinationSection].places[destinationIndex].time += 86400 * numberOfDayChange
        
        // realtime db
        // source
        let updatedSourceDbdPlaces = userSchedules[scheduleIndex].dayByDaySchedule[section].places
        if let updatedSourceDbdPlacesData = try? FirebaseEncoder().encode(updatedSourceDbdPlaces) {
            ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(section+1)/places").setValue(updatedSourceDbdPlacesData)
        } else {
            print("fail to encode")
        }
        
        
        // destination
        let updatedDestinationDbdPlaces = userSchedules[scheduleIndex].dayByDaySchedule[destinationSection].places
        if let updatedDestinationDbdPlacesData = try? FirebaseEncoder().encode(updatedDestinationDbdPlaces) {
            ref.child("journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(destinationSection+1)/places").setValue(updatedDestinationDbdPlacesData)
        } else {
            print("fail to encode")
        }
    
        tableView.reloadData()

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除地點") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            // local
            userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places.remove(at: indexPath.row)
            // realtime
            let updatedPlaces = userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places
            if let updatedPlacesData = try? FirebaseEncoder().encode(updatedPlaces) {
                // 刪掉當筆地點資料後，覆寫 Day\(indexPath.section+1)/places
                self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(indexPath.section+1)/places/\(indexPath.row)").removeValue()
                self.ref.child("journeys/journeyID/\(self.userSchedules[self.scheduleIndex].journeyID)/dayByDay/Day\(indexPath.section+1)/places").setValue(updatedPlacesData)
            } else {
                print("fail to encode")
            }

            // table view
            tableView.deleteRows(at: [indexPath], with: .automatic)

//            self.saveUserScheduleData {
//                self.journeyTableView.deleteRows(at: [indexPath], with: .automatic)
//            }
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
       
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func updateTime(_ cell: JourneyTableViewCell, time: TimeInterval) {
        cell.timePicker.date = Date(timeIntervalSince1970: time)
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
            // local
            userSchedules[scheduleIndex].numberOfDays = count
            
            if var currentLastDayDate =  userSchedules[scheduleIndex].dayByDaySchedule.last?.date {
                
                // local
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
            
            customTabBar.setSelectedTab(index: index)
            journeyTableView.reloadData()
            journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)
            updateTableHeaderViewInfo()
            
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
        // realtime db
        ref.child("/journeys/journeyID/\(userSchedules[scheduleIndex].journeyID)/dayByDay/Day\(section+1)/places/\(index)/time").setValue(time)
        // local
        userSchedules[scheduleIndex].dayByDaySchedule[section].places[index].time = time
        // table view
        journeyTableView.reloadRows(at: [indexPath], with: .automatic)

        
//        saveUserScheduleData {
//            print("new data saved")
//            self.journeyTableView.reloadRows(at: [indexPath], with: .automatic)
//        }
    }
    
    
}
