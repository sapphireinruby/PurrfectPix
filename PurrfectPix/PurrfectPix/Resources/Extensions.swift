//
//  Extensions.swift
//  PurrfectPix
//
//  Created by Amber on 10/20/21.
//

import Foundation
import UIKit
import Lottie

extension UIView {
    
    var top: CGFloat {
        frame.origin.y
    }

    var bottom: CGFloat {
        frame.origin.y + height
    }

    var left: CGFloat {
        frame.origin.x
    }

    var right: CGFloat {
        frame.origin.x + width
    }

    var width: CGFloat {
        frame.size.width
    }

    var height: CGFloat {
        frame.size.height
    }
}

extension UIFont {

    class func italicSystemFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular)-> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        switch weight {
        case .ultraLight, .light, .thin, .regular:
            return font.withTraits(.traitItalic, ofSize: size)
        case .medium, .semibold, .bold, .heavy, .black:
            return font.withTraits(.traitBold, .traitItalic, ofSize: size)
        default:
            return UIFont.italicSystemFont(ofSize: size)
        }
     }

     func withTraits(_ traits: UIFontDescriptor.SymbolicTraits..., ofSize size: CGFloat) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: size)
     }

}

extension DateFormatter {
    // expensive for memory to initialize every time, for better app performance
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    // take a date input above to return a string
    static func date(from date: Date) -> String? {
        let formatter = DateFormatter.formatter
        let string = formatter.string(from: date)
        return string

    }
}

extension Decodable {
    // Create model with dictionary
    // - Parameter dictionary: Firestore data

    init?(with dictionary: [String: Any]) {

        guard let data = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
        ) else {

            return nil
        }
        guard let result = try? JSONDecoder().decode(
            Self.self,
            from: data
        ) else {

            return nil
        }
        self = result
    }
}

extension Encodable {
    // Convert model to dictionary
    // - Returns: Optional dictionary representation
    func asDictionary() -> [String: Any]? {
        
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any]
        return json
    }
}

enum BaseColor: String {

    // swiftlint:disable identifier_name
    case P1 // 889CEB light lavender purple
    case P2 // D077D8 pink-purple

}

extension UIColor {

    static let P1 = baseColor(.P1)

    static let P2 = baseColor(.P2)

    private static func baseColor(_ color: BaseColor) -> UIColor? {

        return UIColor(named: color.rawValue)!
    }

}

extension NSMutableAttributedString {
    var fontSize: CGFloat { return 18 }
    var boldFont: UIFont { return UIFont(name: "Roboto-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont: UIFont { return UIFont(name: "Roboto-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}

    func boldP1(_ value: String) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.P1
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func boldP2(_ value: String) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.P2
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func normal(_ value: String) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    /* Other styling methods */

//    func blackHighlight(_ value:String) -> NSMutableAttributedString {
//
//        let attributes:[NSAttributedString.Key : Any] = [
//            .font :  normalFont,
//            .foregroundColor : UIColor.white,
//            .backgroundColor : UIColor.black
//
//        ]
//
//        self.append(NSAttributedString(string: value, attributes:attributes))
//        return self
//    }

    func underlined(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension UIViewController {

    func createAnimation(name: String, mood: LottieLoopMode ) -> AnimationView {

            let animationView = AnimationView(name: name)

            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            animationView.center = self.view.center
            animationView.contentMode = .scaleAspectFit

            animationView.loopMode = .loop
            animationView.animationSpeed =  1
            animationView.backgroundBehavior = .pauseAndRestore // restart from other tab bar item

        self.view.addSubview(animationView)

            return animationView

        }

}

extension Notification.Name {
    // Notification to inform of new post
    static let didPostNotification = Notification.Name("didPostNotification")
}
