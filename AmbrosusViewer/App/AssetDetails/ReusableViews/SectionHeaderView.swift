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

final class SectionHeaderView: UICollectionReusableView {

    static let height: CGFloat = 58

    private let coloredSectionHeight: CGFloat = 38
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stylizeView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        stylizeView()
    }

    private func stylizeView() {
        let coloredSection = UIView()
        addSubview(coloredSection)
        coloredSection.translatesAutoresizingMaskIntoConstraints = false
        coloredSection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        coloredSection.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        coloredSection.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        coloredSection.heightAnchor.constraint(equalToConstant: coloredSectionHeight).isActive = true
        coloredSection.backgroundColor = Colors.darkElement2

        titleLabel.font = Fonts.sectionHeaderTitle
        titleLabel.textColor = Colors.navigationSectionContent
        titleLabel.numberOfLines = 1
        coloredSection.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: coloredSection.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    }

    func set(title: String) {
        titleLabel.text = title.uppercased()
    }

}
