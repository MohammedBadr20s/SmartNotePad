//
//  Extensions.swift
//  CharityProject
//
//  Created by D-TAG on 5/15/19.
//  Copyright © 2019 D-tag. All rights reserved.
//

import Foundation
import UIKit
//MARK:- Extensions of String
func generateRandomString(length: Int) -> String {
    let characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var randomString = String()
    for _ in 0..<length {
        randomString.append(characters.randomElement()!)
    }
    return randomString
}

extension String {
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    public var arToEnDigits : String {
        let arabicNumbers = ["٠": "0","١": "1","٢": "2","٣": "3","٤": "4","٥": "5","٦": "6","٧": "7","٨": "8","٩": "9"]
        var txt = self
        arabicNumbers.map { txt = txt.replacingOccurrences(of: $0, with: $1)}
        return txt
    }
    
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    //Validate Name
    func isValidInput() -> Bool {
        let RegEx = "^\\w{7,50}$"
        let Test = NSPredicate(format:"SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z0-9].*[a-zA-Z0-9]$)([^ ]?))$", RegEx)
        return Test.evaluate(with: self)
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func isPasswordValid() -> Bool {
        let passwordRegex = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[@#$%^&*]).{10,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return  predicate.evaluate(with: self)
    }
    func isPhone() -> Bool {
        if self.isAllDigits() == true {
            let phoneRegex = "^(009665|9665|\\+9665|05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return  predicate.evaluate(with: self)
        }else {
            return false
        }
    }
    func validateEnglishCharsInput() -> Bool {
        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: self)
        let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
        return alphabet
    }
    func isAllDigits() -> Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = self.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  self == filtered
    }
    var parseHtml: String {
        
        let encodedData = self.data(using: String.Encoding.utf8)!
        do {
            let x = try NSAttributedString(data: encodedData,     options: [.documentType: NSAttributedString.DocumentType.html,
                                                                            .characterEncoding: String.Encoding.utf8.rawValue],
                                           documentAttributes: nil)
            let message = x.string
            return message
        } catch let error as NSError {
            print(error.localizedDescription)
            return ""
        }
    }
    func checkCount() -> Bool{
        if self.count >= 191{
            return false
        }else{
            return true
        }
    }
    func verifyUrl () -> Bool {
        if self.range(of:".") != nil {
            return true
        }
        else{
            return false
        }
    }
    func convertStringToJSON() -> [String: Any]? {
        
        let data = self.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any]
            {
               return jsonArray
            } else {
                return nil
            }
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
//MARK: - Fixing Scrolling issue
extension UICollectionView {
    
    func validate(indexPath: IndexPath) -> Bool {
        if indexPath.section >= numberOfSections {
            return false
        }
        
        if indexPath.row >= numberOfItems(inSection: indexPath.section) {
            return false
        }
        
        return true
    }
}


extension UITableViewCell {
    
    func hideSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
    }
    
    func showSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}



extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}
class ImageLoader {
    
    private static let cache = NSCache<NSString, NSData>()
    
    class func image(for url: URL, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            if let data = self.cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
                return
            }
            
            guard let data = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            self.cache.setObject(data, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
        }
    }
    
}
extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = (self.frame.size.width) / 2;
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1026862158)
    }
}

//MARK:- DatePicker Validation
extension UIDatePicker {
    func set10YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -10
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    }
    
    func setValidation() {
        let _: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        let monthAgo = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        self.minimumDate = monthAgo
    }
    
}
extension Date {
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.string(from: self).lowercased()
        // or use capitalized(with: locale) if you want
    }
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    func getCurrentDateAndTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    func getCurrentDateForChat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    static func dateFromCustomString(customString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: customString) ?? Date()
    }
    
    func reduceToMonthDayYear() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: "\(month)/\(day)/\(year)") ?? Date()
    }
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension UINavigationController {
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
//        if #available(iOS 13.0, *) {
//            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
//        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
//        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
    
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
        
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}
extension NSAttributedString {
    
    convenience init(htmlString html: String, font: UIFont? = nil, useDocumentFontSize: Bool = true) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        
        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard (data != nil), let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }
        
        let fontSize: CGFloat? = useDocumentFontSize ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitBold)!
                }
                
                if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                    descrip = descrip.withSymbolicTraits(.traitItalic)!
                }
                
                attr.addAttribute(.font, value: UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize), range: range)
            }
        }
        
        self.init(attributedString: attr)
    }
    
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIViewController{
    public func clearAllTexts(){
        for view in self.view.subviews {
            view.viewOfType(type: UITextField.self) { (textField) in
                textField.text = ""
//                if lang.localized == "ar" {
//                    textField.textAlignment = .right
//                } else {
//                    textField.textAlignment = .left
//                }
                textField.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
}


extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }
            
            self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}
