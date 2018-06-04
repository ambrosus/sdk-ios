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

class ModalMessageView: UIView {

    private let animationDuration: TimeInterval = 0.3
    private let showMessageLength: TimeInterval = 2
    private let viewTag = 303
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var customView: UIView!
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed(String(describing: ModalMessageView.self), owner: self, options: nil)
        addSubview(customView)
        tag = viewTag
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Colors.darkElement2

        layer.shadowRadius = 5
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func present(in view: UIView, withMessage message: NSAttributedString) {
        messageLabel.attributedText = message
        if let messageView = view.viewWithTag(tag) {
            messageView.removeFromSuperview()
        }
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: Interface.screenWidth).isActive = true
        animateInView()
    }
    
    private func animateInView() {
        alpha = 0
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 1
        }) { (completed) in
            UIView.animate(withDuration: self.animationDuration, delay: self.showMessageLength, animations: {
                self.alpha = 0
            }, completion: { (completion) in
                self.removeFromSuperview()
            })
        }
    }

}
