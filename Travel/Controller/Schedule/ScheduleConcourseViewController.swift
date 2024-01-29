//
//  ScheduleConcourseViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/26.
//

import UIKit
import SnapKit

class ScheduleConcourseViewController: UIViewController {
    

    lazy var scheduleVC = ScheduleViewController()
    lazy var createScheduleVC = CreateScheduleViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var scheduleTableView = UITableView(frame: .zero, style: .grouped)
    var userSchedules = [UserSchedules]()
    let dateUtility = DateUtility()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupTableView()
    }

    func setupNav() {
        self.navigationItem.title = "已建立的行程"
        let rightBarButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(showCreateScheduleVC))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupUI() {
     
        view.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        tableHeaderView.countLabel.text = "\(userSchedules.count)"
        tableHeaderView.scheduleInfoStack.isHidden = true
        tableHeaderView.editButton.isHidden = true
        tableHeaderView.userImageView.image = UIImage(systemName: "person.crop.circle.fill")
        tableHeaderView.userImageView.tintColor = .systemOrange

        view.addSubview(scheduleTableView)
        scheduleTableView.snp.makeConstraints { make in
            make.top.equalTo(tableHeaderView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

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

    }


}

extension ScheduleConcourseViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleConcourseTableViewCell", for: indexPath) as? ScheduleConcourseTableViewCell else { return UITableViewCell() }

        cell.scheduleTitleLabel.text = userSchedules[indexPath.section].scheduleTitle
        cell.placeImageView.image = UIImage(systemName: "globe.central.south.asia")
        let startDateStr = dateUtility.convertDateToString(date: userSchedules[indexPath.section].departureDate)
        let endDate = dateUtility.nextSomeDay(startingDate: userSchedules[indexPath.section].departureDate, countOfDays: userSchedules[indexPath.section].numberOfDays)
        let endDateStr = dateUtility.convertDateToString(date: endDate)
        
        cell.dateRangeLabel.text = "\(startDateStr) ~ \(endDateStr)"

        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        userSchedules.count
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
   
            scheduleVC.userSchedules = [self.userSchedules[section]]
            nav.pushViewController(scheduleVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100

    }
}
