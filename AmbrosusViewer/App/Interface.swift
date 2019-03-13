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

import Foundation
import UIKit

/// Constants for colors used in the Application Interface
struct Colors {
    /// The darkest background, used for Navigation and dark sections
    static let colorElement1 = UIColor(named: "ColorElement1")

    /// A lighter shade of the darkest background for section headers and interactive text
    static let colorElement2 = UIColor(named: "ColorElement2")

    /// Used for elements that cause a destructive action such as sign out
    static let destructiveColor = UIColor(named: "DestructiveColor")

    /// The color for the shadows on floating elements
    static let shadowColor = UIColor(named: "ModuleShadow")

    /// Darker shadow for elements that need to stand out
    static let deepShadow = UIColor(named: "DeepShadow")

    /// The background for screens
    static let background = UIColor(named: "ScreenBackground")

    /// The color for all floating modules
    static let module = UIColor(named: "LightElement")

    /// The color for modules when pressed
    static let modulePressed = UIColor(named: "ModulePressed")

    /// A light color for titles on dark elements
    static let navigationSectionContent = UIColor(named: "LightElement") ?? UIColor()

    /// The titles for modules, darker than information
    static let darkElement1 = UIColor(named: "DarkElement1")

    /// Used for detail modules information, lighter than detail titles
    static let darkElement2 = UIColor(named: "DarkElement2")

    /// Used in cells for descriptive text
    static let darkElement3 = UIColor(named: "DarkElement3")

    /// A lighter description for timeline dates e.g. '2 days ago'
    static let darkElement4 = UIColor(named: "DarkElement4")

    /// Unselected tab bar item tint color
    static let darkElement5 = UIColor(named: "DarkElement5")
}

/// Constants for fonts used in the Application Interface
struct Fonts {
    /// The title text for Navigation Bars
    static let navigationBarTitle = UIFont.systemFont(ofSize: 20, weight: .medium)

    /// The font for large buttons
    static let largeButtonFont = UIFont.systemFont(ofSize: 18, weight: .semibold)

    /// The title text for table sections
    static let sectionHeaderTitle = UIFont.systemFont(ofSize: 17, weight: .bold)

    /// The title text for cells
    static let cellTitle = UIFont.systemFont(ofSize: 14, weight: .medium)

    /// The title text for cells that aren't selected
    static let cellTitleDeselected = UIFont.systemFont(ofSize: 14, weight: .light)

    /// The description text for cells e.g. Sep 17, 2017
    static let cellDescription = UIFont.systemFont(ofSize: 13, weight: .light)

    /// A lighter version of descriptions for additional information
    static let cellLightDescription = UIFont.systemFont(ofSize: 11, weight: .light)

    /// The title for detail module items
    static let detailTitle = UIFont.systemFont(ofSize: 13, weight: .semibold)

    /// The info for detail module items
    static let detailInfo = UIFont.systemFont(ofSize: 12, weight: .regular)
}

/// Contains constants that are used app wide and theme settings for app wide elements
struct Interface {

    private static let rootNavigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    private static let screenSize = UIScreen.main.bounds

    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
    static let moduleWidth = screenWidth - 20
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    static let tokenKey = "token"

    static var isNavigationBarHidden: Bool {
        return rootNavigationController?.isNavigationBarHidden ?? false
    }

    static func applyNavigationBarTheme() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = Colors.colorElement1
        navigationBarAppearance.tintColor = Colors.navigationSectionContent
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.navigationSectionContent,
                                                       NSAttributedString.Key.font: Fonts.navigationBarTitle]
        navigationBarAppearance.isTranslucent = false
    }

    static func applyTabBarTheme() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = Colors.colorElement1
        tabBarAppearance.tintColor = Colors.navigationSectionContent
        tabBarAppearance.unselectedItemTintColor = Colors.darkElement5
        tabBarAppearance.isTranslucent = false
    }
}

extension UITabBar {

    func centerItems() {
        guard let items = items else {
            return
        }
        let centeredImageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        for item in items {
            item.imageInsets = centeredImageEdgeInsets
        }
    }
}
