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

class DialogBuilder {

    private let dialog: UIAlertController

    init(style: UIAlertController.Style) {
        dialog = UIAlertController(title: nil, message: nil, preferredStyle: style)
    }

    func setTitle(_ title: String) -> DialogBuilder {
        dialog.title = title
        return self
    }

    func setMessage(_ message: String) -> DialogBuilder {
        dialog.message = message
        return self
    }

    func addAction(_ name: String, completion: ((UIAlertAction) -> Void)?, style: UIAlertAction.Style = .default) -> DialogBuilder {
        let action = UIAlertAction(title: name, style: style, handler: completion)
        dialog.addAction(action)
        return self
    }

    func withField(placeholder: String) -> DialogBuilder {
        dialog.addTextField { textField in
            textField.placeholder = placeholder
        }
        return self
    }

    func build() -> UIAlertController {
        return dialog
    }
}
