//
//  ScheduleViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/25.
//

import UIKit

class ScheduleViewController: UIViewController {

    var userSchedules = [UserSchedules]()
    lazy var favoriteVC = FavoriteViewController()
    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var scheduleTableView = UITableView(frame: .zero, style: .grouped)

    let uiSettingUtility = UISettingUtility()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupScheduleTableView()

    }

    func setupUI() {
        view.addSubview(scheduleTableView)
        scheduleTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    func setupScheduleTableView() {
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(FavoriteListTableViewCell.self, forCellReuseIdentifier: "FavoriteListTableViewCell")

        scheduleTableView.tableHeaderView = tableHeaderView
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(scheduleTableView)
            make.centerX.equalTo(scheduleTableView)
            make.width.equalTo(scheduleTableView)
            make.height.equalTo(150)
        }
        setupTableHeaderView()
        scheduleTableView.tableHeaderView?.layoutIfNeeded()
    }

    func setupTableHeaderView() {
        tableHeaderView.backgroundColor = .systemYellow
        tableHeaderView.userImageView.isHidden = true
        tableHeaderView.countStack.isHidden = true
        tableHeaderView.scheduleTitleLabel.text = userSchedules[0].scheduleTitle
        tableHeaderView.destinationLabel.text = userSchedules[0].destination
//        tableHeaderView.departureDayLabel.text = "D"
        tableHeaderView.numberOfDaysLabel.text = "\(userSchedules[0].numberOfDays)"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupTableHeaderView()
    }

}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1//userSchedules[section].place.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteListTableViewCell", for: indexPath) as? FavoriteListTableViewCell else { return UITableViewCell() }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Day - \(section + 1)"
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }

        let addButton = UIButton(type: .contactAdd)
        addButton.tag = section
        addButton.addTarget(self, action: #selector(addPlace), for: .touchUpInside)
        header.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.bottom.equalToSuperview().offset(-10)
        }
        addButton.backgroundColor = .systemCyan
        return header
    }

    @objc func addPlace(sender: UIButton) {
        print("add place @ day \(sender.tag + 1)")
        if let nav = favoriteVC.navigationController {
            if let sheetPresentationController = nav.sheetPresentationController {
                sheetPresentationController.prefersGrabberVisible = true
                sheetPresentationController.detents = [.large()]
                sheetPresentationController.preferredCornerRadius = 10
            }
            self.present(nav, animated: true, completion: nil)
        }

    }

}
