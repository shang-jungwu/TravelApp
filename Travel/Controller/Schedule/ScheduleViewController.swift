//
//  ScheduleViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit
import SnapKit

class ScheduleViewController: UIViewController {

    // 整包資料 & 要顯示第幾筆的index
    var userSchedules = [UserSchedules]()
    var scheduleIndex = 0
    //
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    lazy var favoriteVC = FavoriteViewController()
    lazy var createScheduleVC = CreateScheduleViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    var tabNames = [String]()
    lazy var customTabBar = CustomGroupTabBar(tabNames: prepareTabBarButton(), style: .init())
   
    lazy var scheduleTableView = UITableView(frame: .zero, style: .grouped)

    let uiSettingUtility = UISettingUtility()
    let dateUtility = DateUtility()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupScheduleTableView()
        
//        print("userSchedules:",userSchedules)
        
    }
    
//    func getUserScheduleData(completion: () -> Void) {
//        let decoder = JSONDecoder()
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

    func setupUI() {
        view.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        setupTableHeaderView()
        
        setupCustomTabBar()
        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.top.equalTo(tableHeaderView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(44)

        }
        
        
        view.addSubview(scheduleTableView)
        scheduleTableView.snp.makeConstraints { make in
            make.top.equalTo(customTabBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

    }
    
    func prepareTabBarButton() -> [String] {
        var count = 1
        while tabNames.count < userSchedules[scheduleIndex].numberOfDays {
            tabNames.append("Day\(count)")
            count += 1
        }
//        tabNames.append("+")
        return tabNames
    }
    
    func setupCustomTabBar() {
        customTabBar.delegate = self
        customTabBar.setSelectedTab(index: 0)
    }

    func setupScheduleTableView() {
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")

    }

    func setupTableHeaderView() {
        tableHeaderView.backgroundColor = .systemYellow
        tableHeaderView.userImageView.isHidden = true
        tableHeaderView.countStack.isHidden = true
        tableHeaderView.scheduleTitleLabel.text = userSchedules[scheduleIndex].scheduleTitle
        tableHeaderView.destinationLabel.text = userSchedules[scheduleIndex].destination
        let dateStr = dateUtility.convertDateToString(date: userSchedules[scheduleIndex].departureDate)
        tableHeaderView.departureDayLabel.text = dateStr
        tableHeaderView.numberOfDaysLabel.text = "為期 \(userSchedules[scheduleIndex].numberOfDays) 天"
        tableHeaderView.editButton.addTarget(self, action: #selector(editScheduleInfo), for: .touchUpInside)
    }
    
    @objc func editScheduleInfo() {
        createScheduleVC.caller = "schedule"
        createScheduleVC.scheduleVC = self
        
        // 設定為保留原資料的狀態方便修改
        createScheduleVC.schedultTitleTextField.text = userSchedules[scheduleIndex].scheduleTitle
        createScheduleVC.numberOfDaysTextField.text = "\(userSchedules[scheduleIndex].numberOfDays)"
        createScheduleVC.destinationTextField.text = userSchedules[scheduleIndex].destination
        let dateStr = dateUtility.convertDateToString(date: userSchedules[scheduleIndex].departureDate)
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
        setupTableHeaderView()
 
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveUserScheduleData {
            print("Schedule has been saved")
        }
    }

    
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        userSchedules[scheduleIndex].dayByDaySchedule[section].places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as? ScheduleTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = userSchedules[scheduleIndex].dayByDaySchedule[indexPath.section].places[indexPath.row].placeData.name
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        userSchedules[scheduleIndex].numberOfDays
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .systemMint
        return footer
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .systemGray
        let titleLabel = UILabel()
        titleLabel.text = "Day - \(section + 1)"
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }

        let addButton = UIButton(type: .custom)
        addButton.tag = section
        setupMenuButton(sender: addButton)
        
        header.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.bottom.equalToSuperview().offset(-10)
        }

        return header
    }

    @objc func addPlace(sender: UIButton) {
//        print("add place @ day \(sender.tag + 1)")
//        favoriteVC.caller = "ScheduleVC"
//        favoriteVC.calledButtonTag = sender.tag
//        favoriteVC.scheduleVC = self
//        
//        let nav = UINavigationController(rootViewController: favoriteVC)
//        if let sheetPresentationController = nav.sheetPresentationController {
//            sheetPresentationController.prefersGrabberVisible = true
//            sheetPresentationController.detents = [.large()]
//            sheetPresentationController.preferredCornerRadius = 10
//            
//        }
//        self.present(nav, animated: true, completion: nil)

    }

    func setupMenuButton(sender: UIButton) {
        sender.setImage(UIImage(systemName: "ellipsis"), for: [])
        sender.showsMenuAsPrimaryAction = true
        sender.menu = UIMenu(children: [
            UIAction(title: "新增地點", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] action in
                guard let self = self else { return }
                print("add place @ day \(sender.tag + 1)")
                self.favoriteVC.caller = "ScheduleVC"
                self.favoriteVC.calledButtonTag = sender.tag
                self.favoriteVC.scheduleVC = self
                
                let navOfFavoriteVC = UINavigationController(rootViewController: self.favoriteVC)
                if let sheetPresentationController = navOfFavoriteVC.sheetPresentationController {
                    sheetPresentationController.prefersGrabberVisible = true
                    sheetPresentationController.detents = [.large()]
                    sheetPresentationController.preferredCornerRadius = 10
                    
                }
                self.present(navOfFavoriteVC, animated: true, completion: nil)
            }),
            UIAction(title: "刪除整日", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { action in
                print("刪除整日")
                let alert = UIAlertController(title: "確定刪除本日？", message: nil, preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Y", style: .destructive) { [weak self] action in
                    guard let self = self else { return }
                    self.userSchedules[scheduleIndex].numberOfDays -= 1
                    self.userSchedules[scheduleIndex].dayByDaySchedule.remove(at: sender.tag)
                    
                    saveUserScheduleData {
                        self.scheduleTableView.reloadData()
                        self.setupTableHeaderView()
                    }
                    
                    print("已刪除")
                }
                let cancelAction = UIAlertAction(title: "N", style: .cancel)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
                
            })

        ])
    }
    
    
} // ex table view end

extension ScheduleViewController: CustomPageTabBarDelegate {
    func clickTab(index: Int) {
        customTabBar.setSelectedTab(index: index)

        let count = userSchedules[scheduleIndex].numberOfDays
        if index < count {
            print("滾動到Day\(index+1)")
            self.scheduleTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)

        } 
//        else if index == count {
//            print("加一天")
//            count += 1
//            userSchedules[0].numberOfDays = count
//            customTabBar.tabNames.removeLast()
//            customTabBar.tabNames.append("Day\(count)")
//            customTabBar.tabNames.append("+")
//            print(customTabBar.tabNames)
//            customTabBar.initialTabButtons()
//            customTabBar.initialSeprateLine()
//            
//            self.scheduleTableView.reloadData()
//
//        }

//        customTabBar.initialSeprateLine()
    }
    
    
}
