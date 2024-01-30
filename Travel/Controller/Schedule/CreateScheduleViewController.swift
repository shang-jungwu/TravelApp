//
//  CreateScheduleViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/28.
//

import UIKit
import SnapKit

class CreateScheduleViewController: UIViewController {

    let uiSettingUtility = UISettingUtility()
    let dateUtility = DateUtility()

    var caller: String = ""
    weak var scheduleVC: ScheduleViewController!
    weak var concourseVC: ScheduleConcourseViewController!
    lazy var schedultTitleTextField = TravelCustomTextField()
    lazy var destinationTextField = TravelCustomTextField()
    lazy var departureDateTextField = TravelCustomTextField()
    lazy var numberOfDaysTextField = TravelCustomTextField()
    lazy var datePicker = UIDatePicker()
    lazy var transluctentPickDateButton = UIButton(type: .custom)
    lazy var addScheduleButton: UIButton = {
        let button = UIButton()
        if caller == "schedule" {
            button.setTitle("Edit", for: [])
        } else {
            button.setTitle("創建", for: [])
        }
        button.setTitleColor(.systemRed, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.addTarget(self, action: #selector(createSchedule), for: .touchUpInside)
        return button
    }()

    @objc func createSchedule() {
        print("創建行程")
        var dayByday:[DayByDaySchedule] = []
        var date = datePicker.date
        while dayByday.count < Int(numberOfDaysTextField.text!)! {
            dayByday.append(DayByDaySchedule(date: date))
            date = dateUtility.nextDay(startingDate: date)
        }
        
        let newSchedule = UserSchedules(scheduleTitle: schedultTitleTextField.text ?? "", destination: destinationTextField.text ?? "", departureDate: datePicker.date, numberOfDays: Int(numberOfDaysTextField.text!) ?? 0, dayByDaySchedule: dayByday)
        
        concourseVC.userSchedules.append(newSchedule)
        concourseVC.tableHeaderView.countLabel.text = "\(concourseVC.userSchedules.count)"
        concourseVC.scheduleTableView.reloadData()
        
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
        setupTextField()
        setupButton()
    }

    func setupNav() {
        switch caller {
        case  "schedule":
            self.navigationItem.title = "編輯行程資訊"
           break
        case "concourse":
            self.navigationItem.title = "創建行程"
        default:
            print("break")
            break
        }
        
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissVC))
        self.navigationItem.rightBarButtonItem = rightBarButton
    
    }

    @objc func dismissVC() {
        self.dismiss(animated: true)
    }

    func setupUI() {
        view.addSubview(schedultTitleTextField)
        schedultTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        view.addSubview(destinationTextField)
        destinationTextField.snp.makeConstraints { make in
            make.top.equalTo(schedultTitleTextField.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        view.addSubview(departureDateTextField)
        departureDateTextField.snp.makeConstraints { make in
            make.top.equalTo(destinationTextField.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        view.addSubview(transluctentPickDateButton)
        transluctentPickDateButton.snp.makeConstraints { make in
            make.edges.equalTo(departureDateTextField)
//            make.top.equalTo(destinationTextField.snp.bottom).offset(30)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(50)
        }

        view.addSubview(numberOfDaysTextField)
        numberOfDaysTextField.snp.makeConstraints { make in
            make.top.equalTo(departureDateTextField.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        view.addSubview(addScheduleButton)
        addScheduleButton.snp.makeConstraints { make in
            make.top.equalTo(numberOfDaysTextField.snp.bottom).offset(80)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

    }

    func setupButton() {
        transluctentPickDateButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
    }

    @objc private func showDatePicker() {
        print("show Date Picker")
        setupDatePickerActionSheet()
    }

    func setupTextField() {
        uiSettingUtility.textFieldSetting(schedultTitleTextField, placeholder: "輸入行程名稱", keyboard: .default, autoCapitalize: .sentences)
        uiSettingUtility.textFieldSetting(destinationTextField, placeholder: "輸入目的地", keyboard: .default, autoCapitalize: .sentences)
        uiSettingUtility.textFieldSetting(departureDateTextField, placeholder: "出發日期", keyboard: .default, autoCapitalize: .sentences)
        uiSettingUtility.textFieldSetting(numberOfDaysTextField, placeholder: "天數", keyboard: .numberPad, autoCapitalize: .sentences)

       

       
    }

    func setupDatePickerActionSheet() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline

        let alert = UIAlertController(title: "Choose a Date", message: nil, preferredStyle: .actionSheet)

        alert.view.snp.makeConstraints { make in
            make.height.equalTo(self.view.bounds.height*0.57)
        }
        alert.view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view.bounds.width*0.8)
        }

        let addAction = UIAlertAction(title: "新增", style: .default) { [self] _ in
            print("add Date")
            departureDateTextField.text = dateUtility.convertDateToString(date: datePicker.date)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(addAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)

    }

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        switch caller {
        case  "schedule":
           break
        case "concourse":
//            schedultTitleTextField.text = ""
//            departureDateTextField.text = ""
//            destinationTextField.text = ""
//            numberOfDaysTextField.text = ""
            
            // 方便測試
            schedultTitleTextField.text = "台南Go"
            departureDateTextField.text = "\( dateUtility.convertDateToString(date: Date()))"
            destinationTextField.text = "台南"
            numberOfDaysTextField.text = "3"
            ///
        default:
            print("break")
            break
            
        }
        
    }


}

extension CreateScheduleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
