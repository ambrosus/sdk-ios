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
        guard AccountsManager.sharedInstance.getPublicKey() != account.publicKey else {
            return
        }
        AccountsManager.sharedInstance.signInWithDemoModel(with: account)
        let firstIndexPath = IndexPath(row: 0, section: 0)
        collectionView.performBatchUpdates({
            collectionView.moveItem(at: indexPath, to: firstIndexPath)
        }, completion: { (_: Bool) -> Void in
            collectionView.reloadData()
        })
    }
}
