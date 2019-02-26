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

struct AssetDetailsConstants {
    private static let isIphoneX = Interface.screenHeight == 812

    static let menuOverlayHeight: CGFloat = 100
    static let menuOverlayCompactHeight: CGFloat = 50

    static let iPhoneXPadding: CGFloat = {
        if isIphoneX {
            return 30
        } else {
            return -50
        }
    }()

    static let iPhoneXMenuPadding: CGFloat = {
        if isIphoneX {
            return 44
        } else {
            return 0
        }
    }()

    static let iPhoneXSectionHeaderPadding: CGFloat = {
        if isIphoneX {
            return 15
        } else {
            return 50
        }
    }()

    static let iPhoneXSectionHeaderAdditionalPadding: CGFloat = {
        if isIphoneX {
            return 5
        } else {
            return 50
        }
    }()

    static let sectionHeaderHeight: CGFloat = 38
    static let eventCellHeight: CGFloat = 56
}

final class AssetDetailCollectionViewController: UICollectionViewController {

    private var parallaxHeroLayout: ParallaxHeroLayout? {
        return collectionView?.collectionViewLayout as? ParallaxHeroLayout
    }

    private var assetTitleOverlayView: AssetTitleOverlayView? {
        didSet {
            assetTitleOverlayView?.titleLabel.text = asset.name ?? asset.id
            assetTitleOverlayView?.imageOverlay.image = image
        }
    }

    private var heroView: HeroView? {
        didSet {
            heroView?.imageView.image = image
        }
    }
    
    private var formattedSections: [[String: Any]] {
        var formattedSections: [[String: Any]] = asset.formattedSections
        if let events = asset.events, !events.isEmpty {
            formattedSections.append(["events": events])
        }
        return formattedSections
    }
    
    var asset = AMBAsset() {
        didSet {
            guard let collectionView = collectionView else {
                return
            }

            AMBNetwork.requestEvents(fromAssetId: asset.id) { (events) in
                let existingEvents = self.asset.events ?? [AMBEvent]()
                if let events = events, !events.isEmpty && events.count > existingEvents.count  {
                    AMBDataStore.sharedInstance.eventStore.insert(events)
                    DispatchQueue.main.async {
                        requestImage()
                        self.setSectionsHeight()
                        collectionView.reloadData()
                    }
                }
            }
            func requestImage() {
                DispatchQueue.main.async {
                    guard let imageURLString = self.asset.imageURLString,
                        let imageURL = URL(string: imageURLString) else {
                            self.image = self.placeHolderimage
                            return
                    }
                    AMBNetwork.requestImage(from: imageURL) { (image, error) in
                        DispatchQueue.main.async {
                            self.image = image ?? self.placeHolderimage
                        }
                    }
                }
            }
            requestImage()
            setSectionsHeight()
            collectionView.reloadData()
        }
    }

    private func setSectionsHeight() {
        guard let parallaxHeroLayout = parallaxHeroLayout else {
            return
        }
        parallaxHeroLayout.settings.cellHeightInSection = []
        for section in formattedSections {
            let cellHeight: CGFloat = {
                if section.values.first is [AMBEvent] {
                    return AssetDetailsConstants.eventCellHeight
                } else {
                    let section = section.values.first as? [String: Any]
                    let sectionCount = CGFloat(section?.count ?? 0)
                    return ModuleDetailCollectionViewCell.getHeight(forNumberOfSectionTypes: sectionCount)
                }
            }()
            parallaxHeroLayout.settings.cellHeightInSection.append(cellHeight)
        }
    }

    private var image: UIImage? = nil {
        didSet {
            assetTitleOverlayView?.imageOverlay.image = image
            heroView?.imageView.image = image
        }
    }
    private let placeHolderimage = #imageLiteral(resourceName: "BigPlaceholder")

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionViewLayout()
        view.backgroundColor = Colors.background
        collectionView?.backgroundColor = Colors.background
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.topItem?.title = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
    }

}

// MARK: - Setup layout
private extension AssetDetailCollectionViewController {

    private func setupCollectionViewLayout() {
        guard let collectionView = collectionView else {
            return
        }

        collectionView.register(UINib(nibName: "HeroView", bundle: nil),
                                forSupplementaryViewOfKind: ParallaxHeroLayout.SectionType.header.kind,
                                withReuseIdentifier: ParallaxHeroLayout.SectionType.header.id)

        collectionView.register(UINib(nibName: "AssetTitleOverlayView", bundle: nil),
                                forSupplementaryViewOfKind: ParallaxHeroLayout.SectionType.menu.kind,
                                withReuseIdentifier: ParallaxHeroLayout.SectionType.menu.id)
        provideLayoutSettings()
    }

    private func provideLayoutSettings() {
        guard let parallaxHeroLayout = parallaxHeroLayout else {
            return
        }
        let screenWidth = Interface.screenWidth
        let ipadFriendlySize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? screenWidth / 2 : screenWidth
        
        parallaxHeroLayout.settings.headerSize = CGSize(width: ipadFriendlySize, height: ipadFriendlySize)
        parallaxHeroLayout.settings.titleOverlaySize = CGSize(width: screenWidth, height: AssetDetailsConstants.menuOverlayHeight)
        parallaxHeroLayout.settings.sectionsHeaderSize = CGSize(width: screenWidth, height: AssetDetailsConstants.sectionHeaderHeight)
        parallaxHeroLayout.settings.minimumLineSpacing = 20
    }

}

//MARK: - UICollectionViewDataSource
extension AssetDetailCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return formattedSections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = formattedSections[section]
        if let events = section.values.first as? [AMBEvent] {
            return events.count
        } else {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard numberOfSections(in: collectionView) > 0 else {
            return UICollectionViewCell()
        }
        let section = formattedSections[indexPath.section]
        let events = section.values.first as? [AMBEvent]
        let reuseIdentifer = events != nil ? "eventCell" : ParallaxHeroLayout.SectionType.moduleDetailCell.id
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath)
        if let cell = cell as? EventTimelineCollectionViewCell,
            let events = events {
                let isLastCell = indexPath.row == events.count - 1

                // Prevents the last cells timeline view from overflowing into the cell background
                cell.timelineBorderViewBottomConstraint.constant = isLastCell ? 22 : -20
            
                let isFirstCell = indexPath.row == 0

                // Sets the starting line for the timeline
                cell.timelineBorderViewTopConstraint.constant = isFirstCell ? 8 : 0

                cell.event = events[indexPath.row]
        } else if let cell = cell as? ModuleDetailCollectionViewCell,
            let sectionValues = section.values.first as? [String: Any] {
            cell.populate(with: sectionValues)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard numberOfSections(in: collectionView) > 0 else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ParallaxHeroLayout.SectionType.header.id, for: indexPath)
        }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: SectionHeaderView.self), for: indexPath)
            let section = formattedSections[indexPath.section]
            if let sectionHeaderView = supplementaryView as? SectionHeaderView,
                let title = section.keys.first {
                    sectionHeaderView.set(title: title)
            }
            return supplementaryView

        case ParallaxHeroLayout.SectionType.header.kind:
            let heroView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ParallaxHeroLayout.SectionType.header.id, for: indexPath)
            self.heroView = heroView as? HeroView
            return heroView

        case ParallaxHeroLayout.SectionType.menu.kind:
            let menuView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ParallaxHeroLayout.SectionType.menu.id, for: indexPath)
            self.assetTitleOverlayView = menuView as? AssetTitleOverlayView
            return menuView

        default:
            fatalError("Unexpected element kind")
        }
    }

}

// MARK: - UICollectionViewDelegate
extension AssetDetailCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = formattedSections[indexPath.section]
        guard let events = section.values.first as? [AMBEvent],
            let eventDetailsCollectionViewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: EventDetailsCollectionViewController.self)) as? EventDetailsCollectionViewController else {
                return
        }
        let event = events[indexPath.row]
        eventDetailsCollectionViewController.event = event
        navigationController?.pushViewController(eventDetailsCollectionViewController, animated: true)
    }

}

// MARK: - UIScrollViewDelegate
extension AssetDetailCollectionViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustMenuTopPoint(withContentOffset: scrollView.contentOffset.y)
        UIApplication.shared.setStatusBarHidden(Interface.isNavigationBarHidden, with: .slide)
    }

    private func adjustMenuTopPoint(withContentOffset contentOffsetY: CGFloat) {
        guard let headerHeight = parallaxHeroLayout?.settings.headerSize.height else {
            return
        }
        let menuViewTopPoint = headerHeight - AssetDetailsConstants.menuOverlayCompactHeight
        assetTitleOverlayView?.imageOverlay.isHidden = menuViewTopPoint > contentOffsetY
    }
    
}
