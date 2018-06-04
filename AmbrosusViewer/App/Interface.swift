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

import Foundation

/// Constants for colors used in the Application Interface
struct Colors {
    /// The darkest background, used for Navigation and dark sections
    static let darkElement1 = #colorLiteral(red: 0, green: 0, blue: 0.2509803922, alpha: 1)
    
    /// A lighter shade of the darkest background for section headers and interactive text
    static let darkElement2 = #colorLiteral(red: 0.0862745098, green: 0.1647058824, blue: 0.4980392157, alpha: 1)
    
    /// The color for the shadows on floating elements
    static let shadowColor = #colorLiteral(red: 0.04705882353, green: 0.03921568627, blue: 0.2980392157, alpha: 1)
    
    /// The background for screens
    static let background = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
    
    /// The color for all floating modules
    static let module = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// A light color for titles on dark elements
    static let navigationSectionContent = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// Used in cells for descriptive text
    static let descriptionText = #colorLiteral(red: 0.4756369591, green: 0.4756369591, blue: 0.4756369591, alpha: 1)
    
    /// A lighter description for timeline dates e.g. '2 days ago'
    static let lightDescriptionText = #colorLiteral(red: 0.6642268896, green: 0.6642268896, blue: 0.6642268896, alpha: 1)
    
    /// Unselected tab bar item tint color
    static let unselectedTabTint = #colorLiteral(red: 0.7087258697, green: 0.7087258697, blue: 0.7087258697, alpha: 1)
    
    /// The titles for modules, darker than information
    static let detailTitleText = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    /// Used for detail modules information, lighter than detail titles
    static let detailInfoText = #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1)
}

/// Constants for fonts used in the Application Interface
struct Fonts {
    /// The title text for Navigation Bars
    static let navigationBarTitle = UIFont.systemFont(ofSize: 20, weight: .medium)
    
    /// The title text for table sections
    static let sectionHeaderTitle = UIFont.systemFont(ofSize: 17, weight: .bold)
    
    /// The title text for cells
    static let cellTitle = UIFont.systemFont(ofSize: 14, weight: .medium)
    
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
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    static var isNavigationBarHidden: Bool {
        return rootNavigationController?.isNavigationBarHidden ?? false
    }
    
    static func applyNavigationBarTheme() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = Colors.darkElement1
        navigationBarAppearance.tintColor = Colors.navigationSectionContent
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Colors.navigationSectionContent,
                                                       NSAttributedStringKey.font: Fonts.navigationBarTitle]
        navigationBarAppearance.isTranslucent = false
    }
    
    static func applyTabBarTheme() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = Colors.darkElement1
        tabBarAppearance.tintColor = Colors.navigationSectionContent
        tabBarAppearance.unselectedItemTintColor = Colors.unselectedTabTint
        tabBarAppearance.isTranslucent = false
    }
}

extension UITabBar {
    
    func centerItems() {
        guard let items = items,
            items.count > 1 else {
                return
        }
        let centeredImageEdgeInsets = UIEdgeInsetsMake(6,0,-6,0)
        items[0].imageInsets = centeredImageEdgeInsets
        items[1].imageInsets = centeredImageEdgeInsets
    }
    
}
