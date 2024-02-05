//
//  ScheduleConcourseViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/26.
//

import UIKit
import SnapKit

class ScheduleConcourseViewController: UIViewController {
    
    lazy var journeyVC = JourneyViewController()
    lazy var createScheduleVC = CreateScheduleViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var scheduleTableView = UITableView(frame: .zero, style: .insetGrouped)
    var userSchedules = [UserSchedules]()
    let dateUtility = DateUtility()
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 239, g: 239, b: 244, a: 1)
        setupNav()
        setupUI()
        setupTableView()
  
    }

    func setupNav() {
        self.navigationItem.title = "我的行程"
        let rightBarButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(showCreateScheduleVC))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveUserScheduleData))
        self.navigationItem.leftBarButtonItem = leftBarButton
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

        view.addSubview(scheduleTableView)
        scheduleTableView.snp.makeConstraints { make in
            make.top.equalTo(tableHeaderView.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setupTableHeaderView() {
        tableHeaderView.backgroundColor = .white
        tableHeaderView.layer.cornerRadius = 10
        tableHeaderView.countLabel.text = "\(userSchedules.count)"
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
    
    func getUserScheduleData(completion: () -> Void) {
        
        if let defaultData = defaults.data(forKey: "UserSchedule") {
            if let decodedData = try? decoder.decode([UserSchedules].self, from: defaultData) {
                self.userSchedules = decodedData
                completion()
            } else {
                print("Fail to decode")
            }
            
        } else {
            print("UserScheduleData不存在")
        }
    }
    
    
    @objc func saveUserScheduleData() {
        
        if let newScheduleData = try? encoder.encode(userSchedules.self) {
            defaults.set(newScheduleData, forKey: "UserSchedule")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // 取得使用者儲存資料
        getUserScheduleData {
            // 更新 header view
            self.tableHeaderView.countLabel.text = "\(self.userSchedules.count)"
            // 更新 table view
            self.scheduleTableView.reloadData()
        }
    }
    
    func checkIfScheduleDataChanged(completion: () -> Void) {
        if let defaultData = defaults.data(forKey: "UserSchedule") {
            if let decodedData = try? decoder.decode([UserSchedules].self, from: defaultData) {
                if !decodedData.elementsEqual(self.userSchedules) {
                    print("資料改變 please save new data")
                    completion()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        checkIfScheduleDataChanged {
            // show alert and save data
            let alert = UIAlertController(title: "更動已儲存", message: nil, preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "OK", style: .default) { action in
                self.saveUserScheduleData()
            }
            alert.addAction(saveAction)
            self.present(alert, animated: true)
        }
        
    }
    
   

} // class end

extension ScheduleConcourseViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleConcourseTableViewCell", for: indexPath) as? ScheduleConcourseTableViewCell else { return UITableViewCell() }

        cell.scheduleTitleLabel.text = userSchedules[indexPath.section].scheduleTitle
        cell.placeImageView.image = UIImage(systemName: "globe.central.south.asia")
        
        let startDateTimeInterval = userSchedules[indexPath.section].departureDate
        let startDateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: startDateTimeInterval)) // dateUtility.convertDateToString(date: userSchedules[indexPath.section].departureDate)
//        let endDate = dateUtility.nextSomeDay(startingDate: userSchedules[indexPath.section].departureDate, countOfDays: userSchedules[indexPath.section].numberOfDays)
        let countOfDays = userSchedules[indexPath.section].numberOfDays
        let endDateTimeInterval = userSchedules[indexPath.section].departureDate + Double(86400*(countOfDays-1))
        let endDateStr = dateUtility.convertDateToString(date: Date(timeIntervalSince1970: endDateTimeInterval))//dateUtility.convertDateToString(date: endDate)
        
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
            self.tableHeaderView.countLabel.text = "\(self.userSchedules.count)"
            self.scheduleTableView.deleteSections([indexPath.section], with: .automatic)

            completionHandler(true)

        }
        deleteAction.image = UIImage(systemName: "trash")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false // 滑到底直接刪除
        return config

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if let nav = self.navigationController {
            journeyVC.scheduleIndex = section
            journeyVC.userSchedules = self.userSchedules
            nav.pushViewController(journeyVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100

    }
}
