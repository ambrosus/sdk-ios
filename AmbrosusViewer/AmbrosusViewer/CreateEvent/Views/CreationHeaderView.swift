//
//  CreationHeaderView.swift
//  AmbrosusViewer
//
//  Created by MaximCh on 3/21/19.
//  Copyright © 2019 Ambrosus Inc. All rights reserved.
//

import UIKit

enum CreationViewType: Int {
   case header, footer
}

class CreationHeaderView: UIView {

    static let height: CGFloat = 40

    private let sectionHeight: CGFloat = 38
    private let titleLabel = UILabel()
    private var isFooter = false

    init(type: CreationViewType) {
        super.init(frame: CGRect.zero)
        switch type {
        case .header:
            isFooter = false
        case .footer:
            isFooter = true
        }
        stylizeView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func stylizeView() {
        self.backgroundColor = UIColor.white
        let section = UIView()
        addSubview(section)
        section.translatesAutoresizingMaskIntoConstraints = false
        section.topAnchor.constraint(equalTo: topAnchor).isActive = true
        section.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        section.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        section.heightAnchor.constraint(equalToConstant: sectionHeight).isActive = true

        titleLabel.font = !isFooter ? Fonts.cellTitle : Fonts.cellLightDescription
        titleLabel.textColor = !isFooter ? Colors.colorElement1 : Colors.darkElement2
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        section.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: isFooter ? 8 : 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    public func setTitle(text: String) {
        titleLabel.text = isFooter ? text : text.uppercased()
    }
}
