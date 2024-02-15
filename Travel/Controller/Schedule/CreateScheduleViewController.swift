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
import CodableFirebase

class CreateScheduleViewController: UIViewController {
    
    enum InfoChangeStatus {
//        case departureDateChange
//        case numberOfDaysChange
        case depOrNumBothChange
        case otherChange
        case none
    }

    let uiSettingUtility = UISettingUtility()
    let dateUtility = DateUtility()
    // realtime database
    let ref: DatabaseReference = Database.database(url: "https://travel-1f72e-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    var createrUID = ""
    var journeyID = ""
    //
    var changeStatus = InfoChangeStatus.none
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
        var dayByDay:[DayByDaySchedule] = []
//        var dbdTimeArr = [TimeInterval]()
        var placeArr = [DayByDayPlace]()
        
        let morning8DateTimeInterval = dateUtility.get8amDateTimeInterval(date: datePicker.date)
        
        var dbdDateTimeInterval = morning8DateTimeInterval
        while dayByDay.count < Int(numberOfDaysTextField.text!)! {
            dayByDay.append(DayByDaySchedule(date: dbdDateTimeInterval))
//            dbdTimeArr.append(dbdDateTimeInterval)
            placeArr.append(DayByDayPlace(time: dbdDateTimeInterval, place: ""))
            dbdDateTimeInterval += 86400

        }
        
        createrUID = Auth.auth().currentUser!.uid
//        newJourneyRef = self.ref.child("journeys").childByAutoId()
        
        // 自動產生一個唯一的 journeyID
        journeyID = self.ref.child("journeys").childByAutoId().key ?? ""
       
        
        let newSchedule = UserSchedules(createrID: createrUID, journeyID: journeyID, scheduleTitle: schedultTitleTextField.text ?? "", destination: destinationTextField.text ?? "", departureDate: morning8DateTimeInterval, numberOfDays: Int(numberOfDaysTextField.text!)!, dayByDaySchedule: dayByDay)
        
//        let data = try! FirebaseEncoder().encode(placeArr)
        
        let newJourneyData = [
            "createrUID":createrUID,
            "scheduleTitle":schedultTitleTextField.text!,
            "destination":destinationTextField.text!,
            "departureDate": morning8DateTimeInterval,
            "numberOfDays":Int(numberOfDaysTextField.text!)!
            ] as [String : Any]

        ref.child("journeys").child("journeyID").child("\(journeyID)").child("info").setValue(newJourneyData)
        
        
        concourseVC.userSchedules.append(newSchedule)
        concourseVC.tableHeaderView.countLabel.text = "\(concourseVC.userSchedules.count)"
        concourseVC.scheduleTableView.reloadData()
        
        self.dismiss(animated: true)
    }
    
    func prepareNewDBD(newNumberOfDays: Int) {
        // 準備新的dbd陣列，清空所有資訊
        var dayByday:[DayByDaySchedule] = []
        let morning8DateTimeInverval = journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate
        var date = morning8DateTimeInverval
        while dayByday.count < newNumberOfDays {
            dayByday.append(DayByDaySchedule(date: date))
            date += 86400
        }
        
        journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule = dayByday
    }
    func updateOriginDBD() {
        // 更新原有的dbd陣列時間，保留地點
        var dayByday:[DayByDaySchedule] = journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule
        
        let morning8DateTimeInterval = self.journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate
        
        var date = morning8DateTimeInterval
        
        for i in 0...dayByday.count-1 {
            dayByday[i].date = date
            if !dayByday[i].places.isEmpty {
                for j in 0...dayByday[i].places.count-1 {
                    // 每一天的細節也同時更新，但已調整的時間會重置
                    dayByday[i].places[j].time = date
                }
            }
            
            date += 86400
        }
        
        journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule = dayByday
    }
    
    
    
    func updateInfoStatus(completion: @escaping () -> Void) {
        // 新資料
        let newTitle = schedultTitleTextField.text
        let newDestination = destinationTextField.text
        let newDepartureDay = dateUtility.convertStringToDate(string: departureDateTextField.text!)//departureDateTextField.text
        let newNumberOfDays = Int(numberOfDaysTextField.text!)!
        
        let newDepDate = dateUtility.get8amDateTimeInterval(date: newDepartureDay)
        // 原始資料
        let originDepartureDay = journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate
        let originNumberOfDays = journeyVC.userSchedules[journeyVC.scheduleIndex].numberOfDays
        
        guard newTitle != "", newDestination != "", newNumberOfDays > 0 else {
            let alert = UIAlertController(title: "Warning!", message: "資料不可為空/0", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        if newDepartureDay.timeIntervalSince1970 != originDepartureDay || newNumberOfDays != originNumberOfDays {
            changeStatus = .depOrNumBothChange
        } else {
            changeStatus = .otherChange
        }
        
        switch changeStatus {
            
        case .depOrNumBothChange:
            // 只要出發日或天數有變化就把行程全部重置
            journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate = newDepDate
            prepareNewDBD(newNumberOfDays: newNumberOfDays)
            ref.child("/journeys/journeyID/\(journeyVC.userSchedules[journeyVC.scheduleIndex].journeyID)/dayByDay").removeValue()
           
            // 天數更動時作出相應處理並賦值
//            if newNumberOfDays < originNumberOfDays {
//                let alert = UIAlertController(title: "Warning!", message: "縮減天數將重置已排行程", preferredStyle: .alert)
//                let resetScheduleAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
//                    guard let self = self else { return }
//        
//                    self.prepareNewDBD(newNumberOfDays: newNumberOfDays)
//
//                }
//                
//                let cancelAction = UIAlertAction(title: "No", style: .cancel) {  [weak self] action in
//                    guard let self = self else { return }
//                    self.journeyVC.userSchedules[self.journeyVC.scheduleIndex].numberOfDays = originNumberOfDays
//                    self.numberOfDaysTextField.text = "\(originNumberOfDays)"
//                    newNumberOfDays = originNumberOfDays
//
//                }
//                
//                alert.addAction(cancelAction)
//                alert.addAction(resetScheduleAction)
//                present(alert, animated: true)
//                
//            } else if newNumberOfDays > originNumberOfDays {
//                journeyVC.userSchedules[journeyVC.scheduleIndex].numberOfDays = newNumberOfDays
//                let count = newNumberOfDays - originNumberOfDays
//                if var currentLastDayDate =  journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule.last?.date {
//                    
//                    for _ in 1...count {
//                        let newDate = currentLastDayDate + 86400
//                        journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule.append(DayByDaySchedule(date: newDate))
//                        currentLastDayDate = newDate
//                    }
//                }
//            } else {
//                // if newNumberOfDays == originNumberOfDays
//            }
        case .otherChange:
            // 除出發日/天數外的其他值改變的時候行程不動
            break
        case .none:
            break
        }
        
        // 欄位套用新值
//        journeyVC.userSchedules[journeyVC.scheduleIndex].scheduleTitle = newTitle!
//        journeyVC.userSchedules[journeyVC.scheduleIndex].destination = newDestination!
//                
//        if newDepartureDay != originDepartureDay {
//            journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate = dateUtility.get8amDateTimeInterval(date: datePicker.date)
//            updateOriginDBD()
//            print("updated:\( journeyVC.userSchedules[journeyVC.scheduleIndex].dayByDaySchedule)")
//        }
//        
        
        
        
        //  MARK: - realtime
        let infoDataUpdates = [
            "scheduleTitle":newTitle!,
            "destination":newDestination!,
            "departureDate":newDepDate,
            "createrUID":journeyVC.userSchedules[journeyVC.scheduleIndex].createrID,
            "numberOfDays":newNumberOfDays
        ] as [String : Any]
        
        let childUpdates = ["/journeys/journeyID/\(journeyVC.userSchedules[journeyVC.scheduleIndex].journeyID)/info":infoDataUpdates]
        
        ref.updateChildValues(childUpdates)

        
        // local
        journeyVC.userSchedules[journeyVC.scheduleIndex].scheduleTitle = newTitle!
        journeyVC.userSchedules[journeyVC.scheduleIndex].destination = newDestination!
        journeyVC.userSchedules[journeyVC.scheduleIndex].departureDate = newDepDate
        journeyVC.userSchedules[journeyVC.scheduleIndex].numberOfDays = newNumberOfDays
        
        
        print("updated schedule:",journeyVC.userSchedules[journeyVC.scheduleIndex])
        completion()
        ///
        
    }
    
    @objc func editScheduleInfo() {
        updateInfoStatus { [self] in
            journeyVC.journeyTableView.reloadData()
            journeyVC.setupTableHeaderView() // 更新 header view
            journeyVC.setupCustomTabBar() // 更新 custom tabbar
            dismiss(animated: true)
            // 更新 user defaults
//            saveUserScheduleData {
//                journeyVC.journeyTableView.reloadData()
//                journeyVC.setupTableHeaderView() // 更新 header view
//                journeyVC.setupCustomTabBar() // 更新 custom tabbar
//                dismiss(animated: true)
//            }
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
            print("select Date")
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

