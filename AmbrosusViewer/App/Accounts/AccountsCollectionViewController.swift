//
//  AccountsCollectionViewController.swift
//  AmbrosusViewer
//
//  Created by Stein, Maxwell on 6/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import AmbrosusSDK

private let headerReuseIdentifier = String(describing: LargeActionButtonReusableView.self)
private let reuseIdentifier = String(describing: AccountCollectionViewCell.self)

class AccountsCollectionViewController: UICollectionViewController {

    var viewIsPresentedModally = false

    var cachedHeaderView: UICollectionReusableView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        if viewIsPresentedModally {
            let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(tappedClose))
            navigationItem.setLeftBarButton(closeButton, animated: true)
        }
        collectionView?.backgroundColor = Colors.background
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView?.reloadData()
        title = "Accounts"
    }

    @objc func tappedClose() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return AMBDataStore.sharedInstance.accountsStore.all.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let cell = cell as? AccountCollectionViewCell {
            let account = AMBDataStore.sharedInstance.accountsStore.all[indexPath.row]
            cell.setup(withAccount: account)
        }
        // Configure the cell

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let account = AMBDataStore.sharedInstance.accountsStore.all[indexPath.row]
        guard AMBUserSession.sharedInstance.signedInUserPublicKey != account.publicKey else {
            return
        }
        AMBUserSession.sharedInstance.signIn(account: account)
        let firstIndexPath = IndexPath(row: 0, section: 0)
        collectionView.performBatchUpdates({
            collectionView.moveItem(at: indexPath, to: firstIndexPath)
        }, completion: { (_: Bool) -> Void in
            collectionView.reloadData()
        })
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let cachedHeaderView = cachedHeaderView {
            return cachedHeaderView
        }

        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath)

        if let largeActionReusableView = reusableView as? LargeActionButtonReusableView {
            largeActionReusableView.set(title: "Add Account", image: #imageLiteral(resourceName: "Profile"))
            largeActionReusableView.button.centerYAnchor.constraint(equalTo: largeActionReusableView.centerYAnchor).isActive = true
            largeActionReusableView.buttonAction = { () -> Void in
                let viewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: AccountScanViewController.self))
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        cachedHeaderView = reusableView
        return reusableView
    }
}
