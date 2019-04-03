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

struct AMBSectionFormatter {

    /// Used to get key to store key: value in AMBFormattedSections
    ///
    /// - Parameter dictionary: The dictionary with subdictionaries
    /// - Returns: Key for AMBFormatedSection
    static func getDescriptiveName(from dictionary: [String: Any]) -> String? {
        guard let type = dictionary[AMBConstants.typeKey] as? String,
            type.contains(AMBConstants.eventTypePrefix) else {
                return nil
        }
        return type
    }

    /// Recursively traverses the data for an AMBModel and extracts an array that can be used
    /// as a data source for display
    ///
    /// - Parameter data: The dictionary to extract sub dictionaries from
    /// - Returns: The formatted data source
    private static func getDictionaries(_ data: [String: Any]) -> AMBFormattedSections {
        var formattedData = data
        var sections: AMBFormattedSections = []

        /// Finds all additional subdictionarys and removes those values from the main dictionary
        ///
        /// - Parameter dictionary: The dictionary with subdictionaries available, removes those values
        /// - Returns: The additional subdictionaries as formatted sections
        func fetchAdditionalSections(dictionary: inout [String: Any]) -> AMBFormattedSections {
            let additionalSections = getDictionaries(dictionary)
            for additionalSection in additionalSections {
                for key in additionalSection.keys {
                    dictionary.removeValue(forKey: key)
                }
            }
            return additionalSections
        }

        for key in formattedData.keys {
            if var dictionary = formattedData[key] as? [String: Any] {
                formattedData.removeValue(forKey: key)
                sections.append(contentsOf: fetchAdditionalSections(dictionary: &dictionary))
                let name = getDescriptiveName(from: dictionary) ?? key
                let dataSection = [name: dictionary]
                sections.append(dataSection)

                // If this key contains an array of dictionaries, extract all dictionaries from the array
            } else if let dictionaries = formattedData[key] as? [[String: Any]] {
                for (i, var dictionary) in dictionaries.enumerated() {
                    // index the dictionaries that belong to the same parent
                    sections.append(contentsOf: fetchAdditionalSections(dictionary: &dictionary))
                    let keyIndexed = i > 0 ? key + " \(i+1)" : key
                    let name = getDescriptiveName(from: dictionary) ?? keyIndexed
                    let dataSection = [name: dictionary]
                    sections.append(dataSection)
                }
            }
        }
        return sections
    }

    /// Used for create AMBFormattedSections from data dictionaries
    ///
    /// - Parameter data: The json data which will represent like AMBFormatedSections
    /// - Returns: The dictionaries as formatted sections
    static func getFormattedSections(fromData data: [String: Any]) -> AMBFormattedSections {
        var formattedData = data

        data.forEach {
            if $0.value is [String: Any] || $0.value is [[String: Any]] {
                formattedData.removeValue(forKey: $0.key)
            }
        }
        var sections = getDictionaries(data)
        for (i, section) in sections.enumerated() {
            if var dictionary = section[AMBConstants.contentKey] {
                for key in formattedData.keys {
                    dictionary[key] = formattedData[key]
                }
                sections.remove(at: i)
                sections.append([AMBConstants.contentKey: dictionary])
            }
        }
        for (i, section) in sections.enumerated() {
            for value in section.values where value.values.isEmpty {
                sections.remove(at: i)
            }
        }
        return sections
    }
}
