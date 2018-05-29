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
import MapKit
import AmbrosusSDK

final class LocationDetailCell: UICollectionViewCell {

    @IBOutlet weak var mapView: MKMapView!

    var event: AMBEvent = AMBEvent() {
        didSet {
            guard let lattitude = event.lattitude?.doubleValue,
                let longitude = event.longitude?.doubleValue else {
                    return
            }
            let coordinates = CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = event.locationName

            /// The lattitude and longitude delta, set lower to set map closer to the coordinates
            let delta: Double = 0.0015
            let zoomSpan = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            let coordinateRegion = MKCoordinateRegion(center: coordinates, span: zoomSpan)
            mapView.setRegion(coordinateRegion, animated: true)
            mapView.addAnnotation(annotation)
        }
    }

}
