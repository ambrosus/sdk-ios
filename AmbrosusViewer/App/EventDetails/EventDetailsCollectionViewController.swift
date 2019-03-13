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
import MapKit

private let reuseIdentifier = "Cell"
private let locationKey = "location"

final class MapFormatter {

    let region: MKCoordinateRegion
    let annotation: MKPointAnnotation

    init?(event: AMBEvent) {
        guard let lattitude = event.lattitude?.doubleValue,
            let longitude = event.longitude?.doubleValue,
            lattitude > -90 && lattitude < 90 && longitude > -179 && longitude < 179 else {
                return nil
        }
        let coordinates = CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = event.locationName
        self.annotation = annotation

        /// The lattitude and longitude delta, set lower to set map closer to the coordinates
        let delta: Double = 0.0015
        let zoomSpan = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let coordinateRegion = MKCoordinateRegion(center: coordinates, span: zoomSpan)
        self.region = coordinateRegion
    }
}

final class EventMapView: MKMapView {

    init(mapFormatter: MapFormatter) {
        super.init(frame: CGRect(x: 0, y: 0, width: Interface.screenWidth, height: Interface.screenWidth))
        setRegion(mapFormatter.region, animated: false)
        addAnnotation(mapFormatter.annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class EventDetailsCollectionViewController: UICollectionViewController {

    private let dataKey = "data"
    private let locationKey = "location"

    var mapFormatter: MapFormatter?
    var mapView: EventMapView?

    var event: AMBEvent = AMBEvent() {
        didSet {
            title = event.name ?? event.type
            if let mapFormatter = MapFormatter(event: event) {
                mapView = EventMapView(mapFormatter: mapFormatter)
            }
            self.collectionView?.reloadData()
        }
    }

    private var formattedSections: AMBFormattedSections {
        return event.formattedSections
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView?.register(LargeActionButtonReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: LargeActionButtonReusableView.self))
        collectionView?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: SectionHeaderView.self))
    }

    fileprivate func isLocationSection(at section: Int) -> Bool {
        return formattedSections[section].keys.first == "ambrosus.event.location"
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
        } else if let cell = cell as? LocationDetailCell,
            let mapView = mapView {
                cell.setupCell(mapView: mapView)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat = section == 0 ? 75 : 0
        let size = CGSize(width: collectionView.bounds.width, height: height)
        return size
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let height: CGFloat = section == 0 ? 85 : SectionHeaderView.height
//        let size = CGSize(width: collectionView.bounds.width, height: height)
//        return size
//    }

}

extension EventDetailsCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let shouldShowBlockchainVerification = indexPath.section == 0 && kind == UICollectionView.elementKindSectionFooter
        let reusableViewClass = kind == UICollectionView.elementKindSectionFooter ? LargeActionButtonReusableView.self : SectionHeaderView.self
        let reuseIdentifier = String(describing: reusableViewClass)
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)

        guard shouldShowBlockchainVerification || kind == UICollectionView.elementKindSectionHeader else {
            return sectionHeaderView
        }

        let section = formattedSections[indexPath.section]
        if let sectionHeaderView = sectionHeaderView as? SectionHeaderView,
            let title = section.first?.key {
                sectionHeaderView.set(title: title)
        } else if let largeActionView = sectionHeaderView as? LargeActionButtonReusableView {
            largeActionView.set(title: "Blockchain Verification", image: #imageLiteral(resourceName: "Verified"))
            largeActionView.button.widthAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true
            largeActionView.button.topAnchor.constraint(equalTo: largeActionView.topAnchor).isActive = true
            largeActionView.buttonAction = { () -> Void in
                let urlString = "https://ambrosus.github.io/app-checker/?eventId=\(self.event.id)"
                guard let url = URL(string: urlString) else {
                    return
                }
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }

        return sectionHeaderView
    }
}

extension EventDetailsCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = formattedSections[indexPath.section]
        let height: CGFloat = {
            if isLocationSection(at: indexPath.section) {
                return Interface.screenWidth + 20
            } else {
                let data = section.values.first ?? [:]
                return ModuleDetailCollectionViewCell.getHeight(data: data)
            }
        }()
        return CGSize(width: Interface.screenWidth, height: height)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
