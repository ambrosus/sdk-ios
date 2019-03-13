//
//  SettingsTableViewController.swift
//  AmbrosusViewer
//
//  Created by Stein, Maxwell on 8/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import AmbrosusSDK

struct Settings {

    static let accessLevelDemoActivatedKey = "accessLevelDemoActivatedKey"
}

final class SettingsTableViewController: UITableViewController {

    enum SectionType: Int {
        case account, endpoint, accessLevelDemo
    }

    private var numberOfCellsForSection: [Int: Int] {
        return [0: AMBUserSession.sharedInstance.isSignedIn ? 2 : 1,
                1: 2]
    }

    private var selectedCell: Int = UserDefaults.standard.integer(forKey: EndpointManager.selectedEndpointUserDefaultsKey)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.topItem?.title = "Settings"
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numberOfCellsForSection.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfCellsForSection[section] ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.font = Fonts.cellTitle
        let sectionType = SectionType(rawValue: indexPath.section) ?? SectionType.account
        switch sectionType {
        case .account:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Manage Accounts"
                cell.textLabel?.textColor = Colors.colorElement2
            } else {
                cell.textLabel?.text = "Sign Out"
                cell.textLabel?.textColor = Colors.destructiveColor
            }
            cell.accessoryType = .disclosureIndicator
        case .endpoint:
            cell.textLabel?.text = EndpointManager.shared.endpoints[indexPath.row]
            cell.textLabel?.textColor = Colors.darkElement1
            cell.accessoryType = indexPath.row == selectedCell ? .checkmark : .none
            cell.textLabel?.font = indexPath.row == selectedCell ? Fonts.cellTitle : Fonts.cellTitleDeselected
        case .accessLevelDemo:
            cell.textLabel?.text = "Activate Demo"
            cell.textLabel?.font = Fonts.cellTitleDeselected
            cell.textLabel?.textColor = Colors.darkElement1
            cell.selectionStyle = .none

            let accessDemoSwitch = UISwitch()
            accessDemoSwitch.setOn(UserDefaults.standard.bool(forKey: Settings.accessLevelDemoActivatedKey), animated: false)
            cell.accessoryView = accessDemoSwitch
            accessDemoSwitch.addTarget(self, action: #selector(didSwitchAccessDemo(_:)), for: .valueChanged)
        }
        return cell
    }

    @objc func didSwitchAccessDemo(_ sender: Any) {
        guard let accessDemoSwitch = sender as? UISwitch else {
            return
        }
        setAccessLevelDemo(on: accessDemoSwitch.isOn)
    }

    private func setAccessLevelDemo(on: Bool) {
        UserDefaults.standard.set(on, forKey: Settings.accessLevelDemoActivatedKey)
        SampleFetcher.setSampleAccounts()
        AMBUserSession.sharedInstance.signOut()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionType = SectionType(rawValue: indexPath.section) ?? SectionType.account
        switch sectionType {
        case .account:
            // Manage Accounts
            if indexPath.row == 0 {
                let accountsCollectionViewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: AccountsCollectionViewController.self))
                navigationController?.pushViewController(accountsCollectionViewController, animated: true)

                // Sign Out
            } else {
                signOut()
            }
        case .endpoint:
            setEndPoint(at: indexPath.row)
        case .accessLevelDemo:
            break
        }
    }

    private func signOut() {
        AMBUserSession.sharedInstance.signOut()
        UserDefaults.standard.set(nil, forKey: AccountManager.signedInUserStoredKey)
        tableView.reloadData()
    }

    private func setEndPoint(at index: Int) {
        selectedCell = index
        UserDefaults.standard.set(selectedCell, forKey: EndpointManager.selectedEndpointUserDefaultsKey)
        tableView.reloadData()
        EndpointManager.shared.set(with: index)
    }
}
