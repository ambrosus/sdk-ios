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

final class ParallaxHeroLayout: UICollectionViewLayout {

    enum SectionType: String {
        case header
        case menu
        case sectionHeader
        case moduleDetailCell

        var id: String {
            return self.rawValue
        }

        var kind: String {
            return "Kind\(self.rawValue.capitalized)"
        }
    }

    override public class var layoutAttributesClass: AnyClass {
        return ParallaxHeroLayoutAttributes.self
    }

    override public var collectionViewContentSize: CGSize {
        return CGSize(width: collectionViewWidth, height: contentHeight)
    }

    var settings = ParallaxHeroLayoutSettings()

    private var oldBounds = CGRect.zero
    private var contentHeight = CGFloat()
    private var elementAttributesCache = [SectionType: [IndexPath: ParallaxHeroLayoutAttributes]]()
    private var visibleLayoutAttributes = [ParallaxHeroLayoutAttributes]()
    private var zIndex = 0

    private var collectionViewWidth: CGFloat {
        return collectionView?.frame.width ?? 0
    }

    private var headerSize: CGSize {
        return settings.headerSize
    }

    private var titleOverlaySize: CGSize {
        return settings.titleOverlaySize
    }

    private var sectionsHeaderSize: CGSize {
        return settings.sectionsHeaderSize
    }

    private var contentOffset: CGPoint {
        return collectionView?.contentOffset ?? CGPoint()
    }
}

// MARK: - Layout Process
extension ParallaxHeroLayout {

    override public func prepare() {
        guard let collectionView = collectionView,
            elementAttributesCache.isEmpty else {
                return
        }

        cleanCache()
        contentHeight = 0
        zIndex = 0
        oldBounds = collectionView.bounds

        addLayoutItems()
        updateZIndexes()
    }

    private func addLayoutItems() {
        guard let collectionView = collectionView else {
            return
        }

        let headerAttributes = ParallaxHeroLayoutAttributes(forSupplementaryViewOfKind: SectionType.header.kind,
                                                            with: IndexPath(item: 0, section: 0))
        layoutSectionType(size: headerSize, type: .header, attributes: headerAttributes, isFirstSectionHeader: false)

        let menuAttributes = ParallaxHeroLayoutAttributes(
            forSupplementaryViewOfKind: SectionType.menu.kind,
            with: IndexPath(item: 0, section: 0))
        layoutSectionType(size: titleOverlaySize, type: .menu, attributes: menuAttributes, isFirstSectionHeader: false)

        for section in 0 ..< collectionView.numberOfSections {
            let sectionHeaderAttributes = ParallaxHeroLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
            let isFirstSectionHeader = section == 0
            layoutSectionType(size: sectionsHeaderSize, type: .sectionHeader, attributes: sectionHeaderAttributes, isFirstSectionHeader: isFirstSectionHeader)
            setupCells(in: section)
        }
    }

    private func setupCells(in section: Int) {
        guard let collectionView = collectionView else {
            return
        }

        for item in 0 ..< collectionView.numberOfItems(inSection: section) {
            let itemHeight = settings.cellHeightInSection[section]
            let itemSize = CGSize(width: Interface.screenWidth, height: itemHeight)
            let cellIndexPath = IndexPath(item: item, section: section)
            let attributes = ParallaxHeroLayoutAttributes(forCellWith: cellIndexPath)
            attributes.frame = CGRect(x: 0, y: contentHeight + settings.minimumLineSpacing, width: itemSize.width, height: itemSize.height)
            attributes.zIndex = zIndex
            contentHeight = attributes.frame.maxY
            elementAttributesCache[.moduleDetailCell]?[cellIndexPath] = attributes
            zIndex += 1
        }
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            elementAttributesCache.removeAll(keepingCapacity: true)
        }

        return true
    }

    private func cleanCache() {
        elementAttributesCache.removeAll(keepingCapacity: true)
        elementAttributesCache[.header] = [IndexPath: ParallaxHeroLayoutAttributes]()
        elementAttributesCache[.menu] = [IndexPath: ParallaxHeroLayoutAttributes]()
        elementAttributesCache[.sectionHeader] = [IndexPath: ParallaxHeroLayoutAttributes]()
        elementAttributesCache[.moduleDetailCell] = [IndexPath: ParallaxHeroLayoutAttributes]()
    }

    private func layoutSectionType(size: CGSize, type: SectionType, attributes: ParallaxHeroLayoutAttributes, isFirstSectionHeader: Bool) {
        guard size != .zero else {
            return
        }

        let headerXLocation: CGFloat = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let headerSize = Interface.screenWidth / 2
                return (Interface.screenWidth - headerSize) / 2
            } else {
                return 0
            }
        }()

        attributes.initialOrigin = {
            if type == .menu {
                return CGPoint(x: 0, y: contentHeight - AssetDetailsConstants.menuOverlayCompactHeight - AssetDetailsConstants.iPhoneXMenuPadding)
            } else if type == .sectionHeader && isFirstSectionHeader {
                return CGPoint(x: 0, y: contentHeight - AssetDetailsConstants.iPhoneXSectionHeaderPadding)
            } else if type == .header {
                return CGPoint(x: headerXLocation, y: contentHeight)
            } else {
                return CGPoint(x: 0, y: contentHeight)
            }
        }()
        attributes.frame = CGRect(origin: attributes.initialOrigin, size: size)
        attributes.zIndex = zIndex
        zIndex += 1
        contentHeight = attributes.frame.maxY
        elementAttributesCache[type]?[attributes.indexPath] = attributes
    }

    private func updateZIndexes() {
        guard let sectionHeaders = elementAttributesCache[.sectionHeader] else {
            return
        }

        var sectionHeadersZIndex = zIndex
        for (_, attributes) in sectionHeaders {
            attributes.zIndex = sectionHeadersZIndex
            sectionHeadersZIndex += 1
        }
        elementAttributesCache[.menu]?.first?.value.zIndex = sectionHeadersZIndex
    }
}

// MARK: - Provide Collection View Attributes
extension ParallaxHeroLayout {

    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return elementAttributesCache[.sectionHeader]?[indexPath]

        case SectionType.header.kind:
            return elementAttributesCache[.header]?[indexPath]

        default:
            return elementAttributesCache[.menu]?[indexPath]
        }
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return elementAttributesCache[.moduleDetailCell]?[indexPath]
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }

        visibleLayoutAttributes.removeAll(keepingCapacity: true)

        for (type, elementInfos) in elementAttributesCache {
            for (indexPath, attributes) in elementInfos {
                attributes.parallax = .identity
                attributes.transform = .identity
                updateSupplementaryViews(
                    type,
                    attributes: attributes,
                    collectionView: collectionView,
                    indexPath: indexPath)
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
        }
        return visibleLayoutAttributes
    }

    private func updateSupplementaryViews(_ type: SectionType, attributes: ParallaxHeroLayoutAttributes, collectionView: UICollectionView, indexPath: IndexPath) {
        if type == .sectionHeader {
            let itemHeight = settings.cellHeightInSection[indexPath.section]
            let upperLimit = CGFloat(collectionView.numberOfItems(inSection: indexPath.section)) * (itemHeight + settings.minimumLineSpacing)
            attributes.transform =  CGAffineTransform(translationX: 0, y: min(upperLimit, max(0, contentOffset.y - attributes.initialOrigin.y + AssetDetailsConstants.menuOverlayCompactHeight + AssetDetailsConstants.iPhoneXPadding + AssetDetailsConstants.iPhoneXSectionHeaderAdditionalPadding)))
        } else if type == .header {
            performHeaderParallax(in: collectionView, attributes: attributes)
        } else if type == .menu {
            attributes.transform = CGAffineTransform(translationX: 0, y: max(attributes.initialOrigin.y, contentOffset.y) - headerSize.height + AssetDetailsConstants.menuOverlayCompactHeight + AssetDetailsConstants.iPhoneXPadding)
        }
    }

    private func performHeaderParallax(in collectionView: UICollectionView, attributes: ParallaxHeroLayoutAttributes) {
        if contentOffset.y < 0 && !Interface.isNavigationBarHidden {
            let updatedHeight = min(collectionView.frame.height, max(headerSize.height, headerSize.height - contentOffset.y))
            let scaleFactor = updatedHeight / headerSize.height
            let delta = (updatedHeight - headerSize.height) / 2
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let translation = CGAffineTransform(translationX: 0, y: min(contentOffset.y, headerSize.height) + delta)
            attributes.transform = scale.concatenating(translation)
        }
    }
}
