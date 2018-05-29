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

private let reuseIdentifier = "Cell"
private let locationKey = "location"

class EventDetailsCollectionViewController: UICollectionViewController {

    private let dataKey = "data"
    private let locationKey = "location"

    var event: AMBEvent = AMBEvent() {
        didSet {
            title = event.type
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.collectionView?.reloadData()
            }
        }
    }

    private var formattedSections: FormattedSections {
        return event.formattedSections
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: SectionHeaderView.self))
    }

    fileprivate func isLocationSection(at section: Int) -> Bool {
        return formattedSections[section].keys.first == locationKey
    }

}

// MARK: UICollectionViewDataSource
extension EventDetailsCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return formattedSections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return formattedSections[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard numberOfSections(in: collectionView) > 0 else {
            return UICollectionViewCell()
        }
        let reuseIdentifer = isLocationSection(at: indexPath.section) ?
            "LocationDetailCell" :
            ParallaxHeroLayout.SectionType.moduleDetailCell.id

        let section = formattedSections[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath)
        if let cell = cell as? ModuleDetailCollectionViewCell,
            let sectionValues = section.values.first {
            cell.populate(with: sectionValues)
        } else if let cell = cell as? LocationDetailCell {
            cell.event = event
        }
        return cell
    }

}

extension EventDetailsCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: SectionHeaderView.self), for: indexPath)
        let section = formattedSections[indexPath.section]
        if let sectionHeaderView = sectionHeaderView as? SectionHeaderView,
            let title = section.first?.key {
                sectionHeaderView.set(title: title)
        }
        return sectionHeaderView
    }

}

extension EventDetailsCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = formattedSections[indexPath.section]
        guard let key = section.first?.key,
            let items = section[key] else {
                return CGSize(width: Interface.screenWidth, height: 0)
        }
        let sectionCount = CGFloat(items.count)
        let height: CGFloat = {
            if isLocationSection(at: indexPath.section) {
                return Interface.screenWidth
            } else {
                return ModuleDetailCollectionViewCell.getHeight(forNumberOfSectionTypes: sectionCount)
            }
        }()
        return CGSize(width: Interface.screenWidth, height: height)
    }

}
