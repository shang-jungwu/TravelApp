//
//  ScheduleViewController.swift
//  Travel
//
//  Created by 吳宗祐 on 2024/1/25.
//

import UIKit

class ScheduleViewController: UIViewController {

    lazy var tableHeaderView = ScheduleTableHeaderView()
    lazy var scheduleTableView = UITableView(frame: .zero, style: .grouped)


    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupUI()
        setupTableView()
    }

    func setupNav() {
        self.navigationItem.title = "Schedule"
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

    func setupTableView() {
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")

        scheduleTableView.tableHeaderView = tableHeaderView
        tableHeaderView.backgroundColor = .systemGreen
        tableHeaderView.snp.makeConstraints { make in
            make.top.equalTo(scheduleTableView.snp.top)
            make.centerX.equalTo(scheduleTableView.snp.centerX)
            make.width.equalTo(scheduleTableView.snp.width)
            make.height.equalTo(200)
        }

        scheduleTableView.tableHeaderView?.layoutIfNeeded()
    }


}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath)

        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Section Header - \(section)"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }


}
