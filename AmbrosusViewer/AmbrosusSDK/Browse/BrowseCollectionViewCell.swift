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

final class BrowseCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static let height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = Colors.darkElement2
        descriptionLabel.textColor = Colors.descriptionText
        descriptionLabel.font = Fonts.cellDescription
        titleLabel.font = Fonts.cellTitle
    }
    
    func setupCell(withAsset asset: AMBAsset, isLastCell: Bool) {
        titleLabel.text = asset.name ?? asset.id
        descriptionLabel.text = asset.date
        
        // The last cell in a section shouldn't have a separator
        separatorView.isHidden = isLastCell
    }
    
}
