//
//  Copyright: Ambrosus Inc.
//  Email: tech@ambrosus.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
// (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AmbrosusSDK

struct Settings {

    static let accessLevelDemoActivatedKey = "accessLevelDemoActivatedKey"
}

final class SettingsTableViewController: UITableViewController {

    enum SectionType: Int {
        case account, endpoint, createAsset
    }

    private var numberOfCellsForSection: [Int: Int] {

        return  AccountsManager.sharedInstance.isSignedIn() ?
            [0: 2, 1: 2, 2: 1] : [0: 2, 1: 2]
    }

    private var selectedCell: Int = UserDefaults.standard.integer(forKey: EndpointManager.selectedEndpointUserDefaultsKey)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Settings".localized
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
                cell.textLabel?.text = "Manage Demo Accounts".localized
                cell.textLabel?.textColor = Colors.colorElement2
            } else if !AccountsManager.sharedInstance.isSignedIn() {
                cell.textLabel?.text = "Sign in with your private key QRcode".localized
                cell.textLabel?.textColor = Colors.colorElement2
            } else {
                cell.textLabel?.text = "Sign Out".localized
                cell.textLabel?.textColor = Colors.destructiveColor
            }
            cell.accessoryType = .disclosureIndicator
        case .endpoint:
            cell.textLabel?.text = EndpointManager.shared.endpoints[indexPath.row]
            cell.textLabel?.textColor = Colors.darkElement1
            cell.accessoryType = indexPath.row == selectedCell ? .checkmark : .none
            cell.textLabel?.font = indexPath.row == selectedCell ? Fonts.cellTitle : Fonts.cellTitleDeselected
        case .createAsset:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Create assets and events with form".localized
                cell.textLabel?.textColor = Colors.colorElement2
            } else {
                cell.textLabel?.text = "Create assets and events with code".localized
                cell.textLabel?.textColor = Colors.colorElement2
            }
        }
        return cell
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
            } else if !AccountsManager.sharedInstance.isSignedIn() {
                let viewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: AccountScanViewController.self))
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                signOut()
                SampleFetcher.sharedInstance.fetch()
            }
        case .endpoint:
            setEndPoint(at: indexPath.row)
        case .createAsset:
            if indexPath.row == 0 {
                let creationWithFormController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: CreationViewController.self))
                navigationController?.pushViewController(creationWithFormController, animated: true)
            } else {
                let creationWithCodeController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: CreationWithCodeViewController.self))
                navigationController?.pushViewController(creationWithCodeController, animated: true)
            }
        }
    }

    private func signOut() {
        AccountsManager.sharedInstance.signOut()
        tableView.reloadData()
    }

    private func setEndPoint(at index: Int) {
        selectedCell = index
        UserDefaults.standard.set(selectedCell, forKey: EndpointManager.selectedEndpointUserDefaultsKey)
        tableView.reloadData()
        EndpointManager.shared.set(with: index)
    }
}
