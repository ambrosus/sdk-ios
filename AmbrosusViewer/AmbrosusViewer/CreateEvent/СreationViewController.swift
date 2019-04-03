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

enum CreationSections: Int, CaseIterable {
    case createAsset, createEvent
}

enum CreationFieldType: Int, CaseIterable {
    case name, type, accessLevel, description, createButton
}

class CreationViewController: UIViewController {

    private var currentTextField = UITextField()
    private var name = ""
    private var type = ""
    private var accessLevel = 0
    private var eventDescription = ""

    @IBOutlet weak var tableView: UITableView!

    fileprivate func registerCells() {
        tableView.register(UINib(nibName: CreationTextFieldTableViewCell.cellIdentifier(), bundle: nil), forCellReuseIdentifier: CreationTextFieldTableViewCell.cellIdentifier())
        tableView.register(UINib(nibName: CreationButtonTableViewCell.cellIdentifier(), bundle: nil), forCellReuseIdentifier: CreationButtonTableViewCell.cellIdentifier())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Creation Form".localized
        registerCells()
    }

    @objc func createEventBtnTapped() {
        currentTextField.resignFirstResponder()
        if name.count == 0 {
            let alert = DialogBuilder(style: .alert)
                .setTitle("Error".localized)
                .setMessage("Name cannot be empty.".localized)
                .addAction("OK".localized, completion: nil)
                .build()
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        if type.count == 0 {
            let alert = DialogBuilder(style: .alert)
                .setTitle("Error".localized)
                .setMessage("Type cannot be empty.".localized)
                .addAction("OK".localized, completion: nil)
                .build()
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        createAssetWithEvent()
    }

    @objc func createAssetBtnTapped() {
        currentTextField.resignFirstResponder()
        createAssetWithoutEvents()
    }

    private func createAssetWithoutEvents() {
        AMBNetwork.createAsset(createdBy: AccountsManager.sharedInstance.getPublicKey()) { asset, _ in
            guard let asset = asset else {
                let alert = DialogBuilder(style: .alert)
                    .setTitle("Error".localized)
                    .setMessage("Error, no Asset created.".localized)
                    .addAction("OK".localized, completion: nil)
                    .build()
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            AMBDataStore.sharedInstance.assetStore.insert(asset)
            let alert = DialogBuilder(style: .alert)
                .setTitle("Success".localized)
                .setMessage("Your asset created successfully.".localized)
                .addAction("OK".localized, completion: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                .build()
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func createAssetWithEvent() {
        AMBNetwork.createAsset(createdBy: AccountsManager.sharedInstance.getPublicKey()) { asset, _ in
            guard let asset = asset else {
                let alert = DialogBuilder(style: .alert)
                    .setTitle("Error".localized)
                    .setMessage("Error, no Asset created.".localized)
                    .addAction("OK".localized, completion: nil)
                    .build()
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            let eventData = [
                ["type": self.type,
                 "name": self.name,
                 "description": self.eventDescription]
            ]
            AMBDataStore.sharedInstance.assetStore.insert(asset)
            AMBNetwork.createEvent(assetId: asset.id, createdBy: AccountsManager.sharedInstance.getPublicKey(), accessLevel: self.accessLevel, data: eventData) { event, _ in
                guard let event = event else {
                    let alert = DialogBuilder(style: .alert)
                        .setTitle("Error".localized)
                        .setMessage("Error, no Event created.".localized)
                        .addAction("OK".localized, completion: nil)
                        .build()
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                AMBDataStore.sharedInstance.eventStore.insert([event])
                let alert = DialogBuilder(style: .alert)
                    .setTitle("Success".localized)
                    .setMessage("Your asset and event created successfully.".localized)
                    .addAction("OK".localized, completion: { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    .build()
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension CreationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch CreationSections(rawValue: section) {
        case .createAsset?:
            return 1
        default:
            return CreationFieldType.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CreationSections(rawValue: indexPath.section) {
        case .createAsset?:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreationButtonTableViewCell.cellIdentifier()) as? CreationButtonTableViewCell
            cell?.button.setTitle("Create Asset".localized, for: .normal)
            cell?.button.addTarget(self, action: #selector(createAssetBtnTapped), for: .touchUpInside)
            return cell ?? UITableViewCell()
        case .createEvent?:
            switch CreationFieldType(rawValue: indexPath.row) {
            case .name?:
                let cell = tableView.dequeueReusableCell(withIdentifier: CreationTextFieldTableViewCell.cellIdentifier()) as? CreationTextFieldTableViewCell
                cell?.fieldLabel?.text = "Name *".localized
                cell?.textField.placeholder = "enter event name".localized
                cell?.textField.delegate = self
                cell?.textField.tag = indexPath.row
                return cell ?? UITableViewCell()
            case .type?:
                let cell = tableView.dequeueReusableCell(withIdentifier: CreationTextFieldTableViewCell.cellIdentifier()) as? CreationTextFieldTableViewCell
                cell?.fieldLabel?.text = "Type *".localized
                cell?.textField.placeholder = "enter event type".localized
                cell?.textField.delegate = self
                cell?.textField.tag = indexPath.row
                return cell ?? UITableViewCell()
            case .accessLevel?:
                let cell = tableView.dequeueReusableCell(withIdentifier: CreationTextFieldTableViewCell.cellIdentifier()) as? CreationTextFieldTableViewCell
                cell?.fieldLabel?.text = "Access Level".localized
                cell?.textField.placeholder = "enter event access level".localized
                cell?.textField.delegate = self
                cell?.textField.tag = indexPath.row
                return cell ?? UITableViewCell()
            case .description?:
                let cell = tableView.dequeueReusableCell(withIdentifier: CreationTextFieldTableViewCell.cellIdentifier()) as? CreationTextFieldTableViewCell
                cell?.fieldLabel?.text = "Description".localized
                cell?.textField.placeholder = "enter event description".localized
                cell?.textField.delegate = self
                cell?.textField.tag = indexPath.row
                return cell ?? UITableViewCell()
            case .createButton?:
                let cell = tableView.dequeueReusableCell(withIdentifier: CreationButtonTableViewCell.cellIdentifier()) as? CreationButtonTableViewCell
                cell?.button.setTitle("Create Event".localized, for: .normal)
                cell?.button.addTarget(self, action: #selector(createEventBtnTapped), for: .touchUpInside)
                return cell ?? UITableViewCell()
            case .none:
                return UITableViewCell()
            }
        case .none:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch CreationSections(rawValue: indexPath.section) {
        case .createAsset?:
            return CreationButtonTableViewCell.cellHeight()
        default:
            switch CreationFieldType(rawValue: indexPath.row) {
            case .createButton?:
                return CreationButtonTableViewCell.cellHeight()
            default:
                return CreationTextFieldTableViewCell.cellHeight()
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return CreationSections.allCases.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CreationHeaderView(type: .header)
        switch CreationSections(rawValue: section) {
        case .createAsset?:
            header.setTitle(text: "Create Asset".localized)
        case .createEvent?:
            header.setTitle(text: "Create Event".localized)
        case .none:
            return UIView()
        }
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = CreationHeaderView(type: .footer)
        switch CreationSections(rawValue: section) {
        case .createAsset?:
            footer.setTitle(text: "Create asset without events.".localized)
        case .createEvent?:
            footer.setTitle(text: "Create asset and event with information what you provide above.".localized)
        case .none:
            return UIView()
        }
        return footer
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CreationHeaderView.height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CreationHeaderView.height
    }
}

extension CreationViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch CreationFieldType(rawValue: currentTextField.tag) {
        case .name?:
            name = currentTextField.text!
        case .type?:
            type = currentTextField.text!
        case .accessLevel?:
            accessLevel = Int(currentTextField.text!) ?? 0
        case .description?:
            eventDescription = currentTextField.text!
        case .createButton?:
            break
        case .none:
            break
        }
        currentTextField = UITextField()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
