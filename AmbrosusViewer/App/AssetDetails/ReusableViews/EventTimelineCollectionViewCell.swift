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

final class EventTimelineCollectionViewCell: UICollectionViewCell {

    fileprivate enum EventType {
        case transport
        case lab
        case pin
        case identification
        case harvest

        // Array of all types, can be removed when moving to Swift 4.2
        static var allTypes: [EventType] = [.transport, .lab, .pin, .identification, .harvest]

        var image: UIImage {
            switch self {
            case .transport:
                return #imageLiteral(resourceName: "Transport")
            case .lab:
                return #imageLiteral(resourceName: "Beaker")
            case .pin:
                return #imageLiteral(resourceName: "Pin")
            case .identification:
                return #imageLiteral(resourceName: "ScanSmall")
            case .harvest:
                return #imageLiteral(resourceName: "Leaf")
            }
        }

        var fields: [String] {
            switch self {
            case .transport:
                return ["transport", "redirection", "shipped"]
            case .lab:
                return ["pressure", "humidity", "qualitycontrolled", "manufactured"]
            case .pin:
                return ["location", "customs", "displayed", "arrived"]
            case .identification:
                return ["identifier", "info"]
            case .harvest:
                return ["harvested"]
            }
        }

        static func getType(for event: AMBEvent) -> EventType {
            let typeString = event.type.lowercased()
            for type in allTypes {
                for field in type.fields {
                    if typeString.contains(field) {
                        return type
                    }
                }
            }
            return .identification
        }
    }

    @IBOutlet weak var timelineBorderViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timelineBorderViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTimelineBorderView: UIView!
    @IBOutlet weak var eventTimelineIconView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var privacyLevel: UILabel!
    @IBOutlet weak var moduleView: ModuleView!

    var event: AMBEvent = AMBEvent() {
        didSet {
            let privacyLevelValue: String = {
                return event.accessLevel == 0 ? "Public" : "Private"
            }()
            let timelineIcon: UIImage = EventType.getType(for: event).image

            eventNameLabel.text = event.name ?? event.type
            locationLabel.text = event.locationName
            timeLabel.text = event.date
            privacyLevel.text = privacyLevelValue
            eventTimelineIconView.image = timelineIcon
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        eventNameLabel.textColor = Colors.colorElement2
        locationLabel.textColor = Colors.darkElement3
        timeLabel.textColor = Colors.darkElement4
        privacyLevel.textColor = Colors.darkElement4
        eventTimelineIconView.backgroundColor = Colors.colorElement2
        eventTimelineBorderView.backgroundColor = eventTimelineIconView.backgroundColor
        eventTimelineIconView.layer.cornerRadius = 27 / 2

        eventNameLabel.font = Fonts.cellTitle
        locationLabel.font = Fonts.cellLightDescription
        timeLabel.font = Fonts.cellLightDescription
        privacyLevel.font = Fonts.cellLightDescription
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.moduleView.backgroundColor = self.isHighlighted ? Colors.modulePressed : Colors.module
            }
        }
    }
}
