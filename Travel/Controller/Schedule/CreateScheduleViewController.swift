//
//  CreateScheduleViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/28.
//

import UIKit
import SnapKit
import SPAlert
import FirebaseDatabase
import FirebaseAuth

class CreateScheduleViewController: UIViewController {

    let uiSettingUtility = UISettingUtility()
    let dateUtility = DateUtility()
    let ref: DatabaseReference = Database.database(url: "https://travel-1f72e-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    var caller: String = ""
    weak var journeyVC: JourneyViewController!
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
            button.addTarget(self, action: #selector(editScheduleInfo), for: .touchUpInside)
        } else {
            button.setTitle("創建", for: [])
            button.addTarget(self, action: #selector(createSchedule), for: .touchUpInside)
        }
        button.setTitleColor(.systemRed, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
      
        return button
    }()

    @objc func createSchedule() {
        print("創建行程")
        guard Int(numberOfDaysTextField.text!)! > 0 else {
            let alertView = AlertAppleMusic16View(title: "天數必須大於0", subtitle: nil, icon: .error)
            alertView.present(on: self.view)
            return }
        var dayByday:[DayByDaySchedule] = []

        let morning8Date = dateUtility.get8amDate(date: datePicker.date)
        
        var dbdDate = morning8Date
        while dayByday.count < Int(numberOfDaysTextField.text!)! {
            dayByday.append(DayByDaySchedule(date: dbdDate))
            dbdDate = dateUtility.nextDay(startingDate: dbdDate)
        }
       
        
        let newSchedule = UserSchedules(scheduleTitle: schedultTitleTextField.text ?? "", destination: destinationTextField.text ?? "", departureDate: morning8Date, numberOfDays: Int(numberOfDaysTextField.text!)!, dayByDaySchedule: dayByday)
        
        
        let createrID = Auth.auth().currentUser?.uid
        let newJourneyRef = self.ref.child("journeys").childByAutoId() //讓系統自動產生一個唯一的 journeyID value
        let journeyID = newJourneyRef.key
        let newJourneyData = [
            "createrID":createrID,
            "journeyID":journeyID,
            "scheduleTitle":schedultTitleTextField.text!,
            "destination":destinationTextField.text!,
            "departureDate": morning8Date.timeIntervalSince1970,
            "dayByDaySchedule": dayByday
        ] as [String : Any]
        ref.child("journeys").childByAutoId().setValue(newJourneyData)
        
        
        
        concourseVC.userSchedules.append(newSchedule)
        concourseVC.tableHeaderView.countLabel.text = "\(concourseVC.userSchedules.count)"
        concourseVC.scheduleTableView.reloadData()
        
        self.dismiss(animated: true)
    }
    
    func prepareNewDBD() {
        let newNumberOfDays = Int(numberOfDaysTextField.text!)!
        // 準備新的dbd陣列，清空所有資訊
        var dayByday:[DayByDaySchedule] = []
        let morning8Date = dateUtility.get8amDate(date: self.journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate)
        var date = morning8Date
        while dayByday.count < newNumberOfDays {
            dayByday.append(DayByDaySchedule(date: date))
            date = self.dateUtility.nextDay(startingDate: date)
        }
        
        self.journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule = dayByday
    }
    func updateOriginDBD() {
        // 更新原有的dbd陣列時間，保留地點
        var dayByday:[DayByDaySchedule] = journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule
        
        let morning8Date = dateUtility.get8amDate(date: self.journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate)
        
        var date = morning8Date
        
        for i in 0...dayByday.count-1 {
            dayByday[i].date = date
            if !dayByday[i].places.isEmpty {
                for j in 0...dayByday[i].places.count-1 {
                    // 每一天的細節也同時更新，但已調整的時間會重置
                    dayByday[i].places[j].time = date
                }
            }
            
            date = self.dateUtility.nextDay(startingDate: date)
        }
        
        self.journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule = dayByday
    }
    
    
    
    func updateInfoStatus(completion: @escaping () -> Void) {
        // 新資料
        let newTitle = schedultTitleTextField.text
        let newDestination = destinationTextField.text
        let newDepartureDay = departureDateTextField.text
        let newNumberOfDays = Int(numberOfDaysTextField.text!)!
        // 原始資料
        let originDepartureDay = dateUtility.convertDateToString(date: journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate)
        let originNumberOfDays = journeyVC.userSchedules[journeyVC.scheduleIndex].numberOfDays
        
        guard newTitle != "", newDestination != "", newDepartureDay != "", newNumberOfDays > 0 else {
            let alert = UIAlertController(title: "Warning!", message: "資料不可為空/0", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        // 欄位套用新值
        journeyVC.userSchedules[journeyVC.scheduleIndex].scheduleTitle = newTitle!
        journeyVC.userSchedules[journeyVC.scheduleIndex].destination = newDestination!
        
        if newDepartureDay != originDepartureDay {
            journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate = dateUtility.get8amDate(date: datePicker.date)
            updateOriginDBD()
            print("updated:\( journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule)")
        }
        
        // 天數更動時作出相應處理並賦值
        if newNumberOfDays < originNumberOfDays {
            journeyVC.userSchedules[journeyVC.scheduleIndex].numberOfDays = newNumberOfDays
            
            let alert = UIAlertController(title: "Warning!", message: "縮減天數將重置已排行程", preferredStyle: .alert)
            let resetScheduleAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
                guard let self = self else { return }
    
                self.prepareNewDBD()
                completion()
            }
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel) {  [weak self] action in
                guard let self = self else { return }
                self.journeyVC.userSchedules[self.journeyVC.scheduleIndex].numberOfDays = originNumberOfDays
                self.numberOfDaysTextField.text = "\(originNumberOfDays)"
                completion()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(resetScheduleAction)
            self.present(alert, animated: true)
            
        } else if newNumberOfDays > originNumberOfDays {
            self.journeyVC.userSchedules[journeyVC.scheduleIndex].numberOfDays = newNumberOfDays
            let count = newNumberOfDays - originNumberOfDays
            if var currentLastDayDate =  journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule.last?.date {
                
                for _ in 1...count {
                    let newDate = dateUtility.nextDay(startingDate: currentLastDayDate)
                    journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule.append(DayByDaySchedule(date: newDate))
                    currentLastDayDate = newDate
                }
            }

            completion()
        } else {
            // if newNumberOfDays == originNumberOfDays
            completion()
        }
        
    }
    
    @objc func editScheduleInfo() {
        updateInfoStatus { [self] in
            // 更新資料庫
            saveUserScheduleData {
                journeyVC.journeyTableView.reloadData()
                journeyVC.setupTableHeaderView() // 更新 header view
                journeyVC.setupCustomTabBar() // 更新 custom tabbar
                dismiss(animated: true)
            }
        }
    
    }
    

    
    func saveUserScheduleData(completion: () -> Void) {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let newScheduleData = try? encoder.encode(journeyVC.userSchedules.self) {
            defaults.set(newScheduleData, forKey: "UserSchedule")
            completion()
        } else {
            print("Edit encode 失敗")
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
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
        schedultTitleTextField.delegate = self
        uiSettingUtility.textFieldSetting(schedultTitleTextField, placeholder: "輸入行程名稱", keyboard: .default, autoCapitalize: .sentences)
        
        destinationTextField.delegate = self
        uiSettingUtility.textFieldSetting(destinationTextField, placeholder: "輸入目的地", keyboard: .default, autoCapitalize: .sentences)
        
        departureDateTextField.delegate = self
        uiSettingUtility.textFieldSetting(departureDateTextField, placeholder: "出發日期", keyboard: .default, autoCapitalize: .sentences)
        
        numberOfDaysTextField.delegate = self
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

        let addAction = UIAlertAction(title: "選擇日期", style: .default) { [self] _ in
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
   }

}

