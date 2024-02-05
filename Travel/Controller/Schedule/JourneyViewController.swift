//
//  ScheduleViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit
import SnapKit
import SDWebImage

class JourneyViewController: UIViewController {

    // 整包資料 & 要顯示第幾筆的index
    var userSchedules = [UserSchedules]()
    var scheduleIndex = 0
    //
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
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
        print("schedule：\(userSchedules[scheduleIndex].dayByDaySchedule)")
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
        journeyTableView.backgroundColor = UIColor(r: 239, g: 239, b: 244, a: 1)
    }

    func setupTableHeaderView() {
        tableHeaderView.backgroundColor = .white
        tableHeaderView.layer.cornerRadius = 10

        tableHeaderView.userImageView.isHidden = true
        tableHeaderView.countStack.isHidden = true
        
        tableHeaderView.scheduleTitleLabel.text = userSchedules[scheduleIndex].scheduleTitle
        tableHeaderView.destinationLabel.text = userSchedules[scheduleIndex].destination
        let dateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].departureDate)) //dateUtility.convertDateToString(date: userSchedules[scheduleIndex].departureDate)
        tableHeaderView.departureDayLabel.text = dateStr
        tableHeaderView.numberOfDaysLabel.text = "為期 \(userSchedules[scheduleIndex].numberOfDays) 天"
        tableHeaderView.editButton.addTarget(self, action: #selector(editScheduleInfo), for: .touchUpInside)
    }
    
    @objc func editScheduleInfo() {
        createScheduleVC.caller = "schedule"
        createScheduleVC.journeyVC = self
        
        // 設定為保留原資料的狀態方便修改
        createScheduleVC.schedultTitleTextField.text = userSchedules[scheduleIndex].scheduleTitle
        createScheduleVC.numberOfDaysTextField.text = "\(userSchedules[scheduleIndex].numberOfDays)"
        createScheduleVC.destinationTextField.text = userSchedules[scheduleIndex].destination
        let dateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].departureDate)) // dateUtility.convertDateToString(date: userSchedules[scheduleIndex].departureDate)
        createScheduleVC.departureDateTextField.text = dateStr
        
        
        let nav = UINavigationController(rootViewController: createScheduleVC)
        present(nav, animated: true)
        
    }
    
    func saveUserScheduleData(completion: () -> Void) {
        if let newScheduleData = try? encoder.encode(userSchedules.self) {
            defaults.set(newScheduleData, forKey: "UserSchedule")
            completion()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        journeyTableView.isEditing = false
        journeyTableView.reloadData()
        journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
        setupTableHeaderView()
        setupCustomTabBar()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        saveUserScheduleData {
            print("Schedule has been saved")
        }
    }

    
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
        cell.nameLabel.text = userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].placeData.name
        if let url = URL(string: userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].placeData.imageURL) {
            cell.placeImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "fork.knife"))
        }
        
        cell.timePicker.date = Date(timeIntervalSince1970: userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].time)// userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].time
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
        header.backgroundColor = UIColor(r: 239, g: 239, b: 244, a: 1)
        let titleLabel = UILabel()
        titleLabel.layer.cornerRadius = 5
        titleLabel.clipsToBounds = true
        titleLabel.text = "  \(dateUtility.convertDateToString(date: Date(timeIntervalSince1970: userSchedules[scheduleIndex].dayByDaySchedule[section].date)))  "// "  \(dateUtility.convertDateToString(date: userSchedules[scheduleIndex].dayByDaySchedule[section].date))  "
        uiSettingUtility.labelSettings(label: titleLabel, fontSize: 16, fontWeight: .semibold, color: .white, alignment: .left, numOfLines: 1)
        titleLabel.backgroundColor = .systemRed
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()//.offset(15)
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

                    // hope: 刪除時後一天的時間自動替換成-1天
                    // try:
                    let leftDays = self.userSchedules[scheduleIndex].dayByDaySchedule
                    print("left date", leftDays)
                    for i in sender.tag..<leftDays.count {
                        let newDate = leftDays[i].date - 86400// dateUtility.getYesterday(date: leftDays[i].date)
                        
                        self.userSchedules[scheduleIndex].dayByDaySchedule[i].date = newDate
             
                    }
                    
                    self.saveUserScheduleData {
                        self.journeyTableView.reloadData()
                        self.setupTableHeaderView()
                        self.setupCustomTabBar()
                    }

                } else {
                    // 天數為1時，僅清空單日行程
                    self.userSchedules[scheduleIndex].dayByDaySchedule[0].places.removeAll()
                    self.saveUserScheduleData {
                        self.journeyTableView.reloadData()
                    }
                }

            }
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        })
        
        let editOrderAction = UIAction(title: "編輯順序", image: UIImage(systemName: "line.3.horizontal"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: self.journeyTableView.isEditing == true ? .on : .off, handler: { [weak self] action in
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
        let section = indexPath.section
        let index = indexPath.row
        if let nav = self.navigationController {
            detailVC.placeInfoData = self.userSchedules[scheduleIndex].dayByDaySchedule[section].places
            detailVC.dataIndex = index
            nav.pushViewController(detailVC, animated: true)
        }
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
        let movedPlace = self.userSchedules[scheduleIndex].dayByDaySchedule[section].places[index]
        self.userSchedules[scheduleIndex].dayByDaySchedule[section].places.remove(at: index)
        self.userSchedules[scheduleIndex].dayByDaySchedule[destinationSection].places.insert(movedPlace, at: destinationIndex)
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除地點") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            self.userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places.remove(at: indexPath.row)
            self.saveUserScheduleData {
                self.journeyTableView.deleteRows(at: [indexPath], with: .automatic)
            }
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
                
                let newDate = currentLastDayDate + 86400// dateUtility.nextDay(startingDate: currentLastDayDate)
                userSchedules[scheduleIndex].dayByDaySchedule.append(DayByDaySchedule(date: newDate))
                currentLastDayDate = newDate
            }
            
            customTabBar.tabNames.removeLast()
            customTabBar.tabNames.append("Day\(count)")
            customTabBar.tabNames.append("+")
            customTabBar.tabButtons.removeAll()
            customTabBar.initialTabButtons()
            
            saveUserScheduleData {
                customTabBar.setSelectedTab(index: index)
                journeyTableView.reloadData()
                journeyTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)
                setupTableHeaderView()
            }
            
        }


    }
    
    
}

extension JourneyViewController: JourneyTableViewCellTableViewCellDelegate {
    func timeChange(indexPath: IndexPath, time: TimeInterval) {
        let section = indexPath.section
        let index = indexPath.row
        self.userSchedules[scheduleIndex].dayByDaySchedule[section].places[index].time = time
        saveUserScheduleData {
            print("new data saved")
    
            self.journeyTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}
