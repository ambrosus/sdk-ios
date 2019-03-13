//
//  LargeActionButtonReusableView.swift
//  AmbrosusViewer
//
//  Created by Stein, Maxwell on 7/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

final class LargeActionButtonReusableView: UICollectionReusableView {

    let button = LargeActionButton()
    var buttonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func set(title: String, image: UIImage? = nil) {
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
    }

    private func setup() {
        addSubview(button)
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc func buttonTapped() {
        buttonAction?()
    }
}

final class LargeActionButton: UIButton {

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        backgroundColor = Colors.colorElement2
        setTitleColor(.white, for: .normal)
        tintColor = .white
        titleLabel?.font = Fonts.largeButtonFont

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(greaterThanOrEqualToConstant: 220).isActive = true
        heightAnchor.constraint(equalToConstant: 55).isActive = true

        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        adjustsImageWhenHighlighted = false
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.backgroundColor = self.isHighlighted ? Colors.colorElement1 : Colors.colorElement2
            }
        }
    }
}
