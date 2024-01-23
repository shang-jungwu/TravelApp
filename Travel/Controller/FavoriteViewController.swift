//
//  FavoriteViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/23.
//

import UIKit
import SnapKit

class FavoriteViewController: UIViewController {
    
    lazy var favoriteTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        setupNav()
        setupUI()
        setupTableView()
    }
    

    func setupNav() {
        self.navigationItem.title = "Favorite"
    }
    
    func setupUI() {
        view.addSubview(favoriteTableView)
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            
        }
    }
    
    func setupTableView() {
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
    }

}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
