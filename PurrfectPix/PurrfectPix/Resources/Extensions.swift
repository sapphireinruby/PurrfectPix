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
    // expensive for memeory to initialize everytime, for better app performance
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
    // 不能用了
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
    case P1 // D077D8 pinkpurple

}

extension UIColor {

    static let P1 = baseColor(.P1)

    private static func baseColor(_ color: BaseColor) -> UIColor? {

        return UIColor(named: color.rawValue)!
    }

}

extension UIViewController {

    func setupAnimation(name: String, mood: LottieLoopMode ) -> AnimationView {

            let animationView = AnimationView(name: name)

            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            animationView.center = self.view.center
            animationView.contentMode = .scaleAspectFit

            animationView.loopMode = mood
            animationView.animationSpeed =  1
            animationView.backgroundBehavior = .pauseAndRestore // restart from other tab bar item

            view.addSubview(animationView)

            return animationView

        }

}

extension Notification.Name {
    // Notification to inform of new post
    static let didPostNotification = Notification.Name("didPostNotification")
}
