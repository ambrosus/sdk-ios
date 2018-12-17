//
//  Copyright: Ambrosus Technologies GmbH
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

final class BrowseViewController: UIViewController {

    private let moduleView = ModuleView()
    private let reuseIdentifier = String(describing: BrowseCollectionViewCell.self)

    @IBOutlet weak var collectionView: UICollectionView!

    private var heightConstraint = NSLayoutConstraint()

    private var dataSource = AMBDataStore.sharedInstance.assetStore.all {
        didSet {
            updateHeight()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        heightConstraint = NSLayoutConstraint(item: moduleView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 50)
        view.backgroundColor = Colors.background
        collectionView.backgroundColor = Colors.background
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        moduleView.add(to: collectionView)
        moduleView.widthAnchor.constraint(equalToConstant: Interface.screenWidth - 20).isActive = true
        moduleView.isUserInteractionEnabled = false
        moduleView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: SectionHeaderView.height).isActive = true
        moduleView.addConstraint(heightConstraint)
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Browse"
        dataSource = AMBDataStore.sharedInstance.assetStore.all
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateHeight()
    }
    
    private func updateHeight() {
        heightConstraint.constant = CGFloat(dataSource.count) * BrowseCollectionViewCell.height
        moduleView.layoutIfNeeded()
    }

}

extension BrowseViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: SectionHeaderView.self), for: indexPath)
        
        if let sectionHeaderView = sectionHeaderView as? SectionHeaderView {
            sectionHeaderView.set(title: "Scanned Assets")
        }
        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = dataSource[indexPath.row]
        guard let assetDetailCollectionViewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: AssetDetailCollectionViewController.self)) as? AssetDetailCollectionViewController else {
            return
        }
        assetDetailCollectionViewController.asset = asset
        navigationController?.pushViewController(assetDetailCollectionViewController, animated: true)
        
    }
    
}

extension BrowseViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let assetCollectionViewCell = assetCollectionViewCell as? BrowseCollectionViewCell {
            let asset = dataSource[indexPath.row]
            let isLastCell = collectionView.numberOfItems(inSection: indexPath.section) == indexPath.row + 1
            assetCollectionViewCell.setupCell(withAsset: asset, isLastCell: isLastCell)
        }
        return assetCollectionViewCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
}

extension BrowseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Interface.screenWidth, height: BrowseCollectionViewCell.height)
    }
    
}
