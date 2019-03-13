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
import SafariServices

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}

class TitleInfoView: UIView {

    let titleLabel = UILabel()
    let infoLabel = UILabel()

    static let desiredWidth = Interface.screenWidth - 40

    init() {
        super.init(frame: CGRect.zero)
        titleLabel.font = Fonts.detailTitle
        infoLabel.font = Fonts.detailInfo

        titleLabel.textColor = Colors.darkElement1
        infoLabel.textColor = Colors.darkElement2
        titleLabel.numberOfLines = 1
        infoLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        infoLabel.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)

        addSubview(titleLabel)
        addSubview(infoLabel)

        setupAutoLayout()
        isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedView(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(withTitle title: String?, info: String?) {
        titleLabel.text = title
        infoLabel.text = info
        format(for: info)
    }

    func format(for info: String?) {
        guard let info = info else {
            return
        }
        infoLabel.font = isDictionary(info: info) ? UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular) : Fonts.detailInfo
        infoLabel.textColor = isURL(info: info) ? Colors.colorElement2 : Colors.darkElement2
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

    private func isDictionary(info: String) -> Bool {
        let height = info.height(withConstrainedWidth: TitleInfoView.desiredWidth, font: Fonts.detailInfo)
        let isDictionary = height > 100
        return isDictionary
    }

    private func isURL(info: String) -> Bool {
        let isNotDictionary = !isDictionary(info: info)
        return isNotDictionary && (info.contains("http") || info.contains("www."))
    }

    @objc func tappedView(_ sender: UITapGestureRecognizer) {
        guard let info = infoLabel.text else {
            return
        }
        if isURL(info: info) {
            open(urlString: info)
        } else {
            copy(info: info)
        }
    }

    private func open(urlString: String) {
        guard let presentedViewController = UIApplication.shared.keyWindow?.rootViewController,
            let url = URL(string: urlString) else {
                return
        }
        let safariViewController = SFSafariViewController(url: url)
        presentedViewController.present(safariViewController, animated: true, completion: nil)
    }

    private func copy(info: String) {
        UIPasteboard.general.string = info
        guard let presentedViewController = UIApplication.shared.keyWindow?.rootViewController,
            let titleLabelText = titleLabel.text else {
                return
        }
        let attributedString = NSMutableAttributedString(string: "Copied ", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .semibold)])
        attributedString.append(NSAttributedString(string: "'\(titleLabelText)'!", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .regular)]))
        ModalMessageView().present(in: presentedViewController.view, withMessage: attributedString)
    }
}

extension SFSafariViewController {

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
