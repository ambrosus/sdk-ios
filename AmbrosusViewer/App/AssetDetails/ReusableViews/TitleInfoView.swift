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

class TitleInfoView: UIView {

    let titleLabel = UILabel()
    let infoLabel = UILabel()

    init() {
        super.init(frame: CGRect.zero)
        titleLabel.font = Fonts.detailTitle
        infoLabel.font = Fonts.detailInfo

        titleLabel.textColor = Colors.detailTitleText
        infoLabel.textColor = Colors.detailInfoText
        titleLabel.numberOfLines = 1
        infoLabel.numberOfLines = 1
        titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        infoLabel.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)

        addSubview(titleLabel)
        addSubview(infoLabel)

        setupAutoLayout()
        isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyInfo(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(withTitle title: String?, info: String?) {
        titleLabel.text = title?.capitalized
        infoLabel.text = info
    }

    override func updateConstraints() {
        if constraints.isEmpty {
            let labelConstraints: [NSLayoutConstraint] = {
                var labelConstraints: [NSLayoutConstraint] = []
                labelConstraints.append(titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor))
                labelConstraints.append(titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor))
                labelConstraints.append(titleLabel.topAnchor.constraint(equalTo: topAnchor))
                labelConstraints.append(infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5))
                labelConstraints.append(infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor))
                labelConstraints.append(infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor))
                labelConstraints.append(infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor))
                return labelConstraints
            }()
            addConstraints(labelConstraints)
            NSLayoutConstraint.activate(constraints)
        }
        super.updateConstraints()
    }

    private func setupAutoLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        setNeedsUpdateConstraints()
    }

    @objc func copyInfo(_ sender: UITapGestureRecognizer) {
        guard let infoText = infoLabel.text else {
            return
        }
        UIPasteboard.general.string = infoText
        guard let presentedViewController = UIApplication.shared.keyWindow?.rootViewController,
            let titleLabelText = titleLabel.text else {
                return
        }
        let attributedString = NSMutableAttributedString(string: "Copied ", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .semibold)])
        attributedString.append(NSAttributedString(string: "'\(titleLabelText)'!", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .regular)]))
        ModalMessageView().present(in: presentedViewController.view, withMessage: attributedString)
    }

}
