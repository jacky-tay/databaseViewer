//
//  UIColorExtension.swift
//  DatabaseViewer
//
//  Created by Jacky Tay on 7/07/17.
//  Copyright © 2017 SmudgeApps. All rights reserved.
//

import UIKit

class Material: UIColor {
    override static var red: UIColor {
        return UIColor(red: 0.956862745098039, green: 0.262745098039216, blue: 0.211764705882353, alpha: 1.0)
    }

    static var pink: UIColor {
        return UIColor(red: 0.913725490196078, green: 0.117647058823529, blue: 0.388235294117647, alpha: 1.0)
    }

    override static var purple: UIColor {
        return UIColor(red: 0.611764705882353, green: 0.152941176470588, blue: 0.690196078431373, alpha: 1.0)
    }

    static var deepPurple: UIColor {
        return UIColor(red: 0.403921568627451, green: 0.227450980392157, blue: 0.717647058823529, alpha: 1.0)
    }

    static var indigo: UIColor {
        return UIColor(red: 0.247058823529412, green: 0.317647058823529, blue: 0.709803921568627, alpha: 1.0)
    }

    override static var blue: UIColor {
        return UIColor(red: 0.129411764705882, green: 0.588235294117647, blue: 0.952941176470588, alpha: 1.0)
    }

    static var lightBlue: UIColor {
        return UIColor(red: 0.0117647058823529, green: 0.662745098039216, blue: 0.956862745098039, alpha: 1.0)
    }

    override static var cyan: UIColor {
        return UIColor(red: 0.0, green: 0.737254901960784, blue: 0.831372549019608, alpha: 1.0)
    }

    static var teal: UIColor {
        return UIColor(red: 0.0, green: 0.588235294117647, blue: 0.533333333333333, alpha: 1.0)
    }

    override static var green: UIColor {
        return UIColor(red: 0.298039215686275, green: 0.686274509803922, blue: 0.313725490196078, alpha: 1.0)
    }

    static var lightGreen: UIColor {
        return UIColor(red: 0.545098039215686, green: 0.764705882352941, blue: 0.290196078431373, alpha: 1.0)
    }

    static var lime: UIColor {
        return UIColor(red: 0.803921568627451, green: 0.862745098039216, blue: 0.223529411764706, alpha: 1.0)
    }

    override static var yellow: UIColor {
        return UIColor(red: 1.0, green: 0.92156862745098, blue: 0.231372549019608, alpha: 1.0)
    }

    static var amber: UIColor {
        return UIColor(red: 1.0, green: 0.756862745098039, blue: 0.0274509803921569, alpha: 1.0)
    }

    override static var orange: UIColor {
        return UIColor(red: 1.0, green: 0.596078431372549, blue: 0.0, alpha: 1.0)
    }

    static var deepOrange: UIColor {
        return UIColor(red: 1.0, green: 0.341176470588235, blue: 0.133333333333333, alpha: 1.0)
    }

    override static var brown: UIColor {
        return UIColor(red: 0.474509803921569, green: 0.333333333333333, blue: 0.282352941176471, alpha: 1.0)
    }
    
    static var grey: UIColor {
        return UIColor(red: 0.619607843137255, green: 0.619607843137255, blue: 0.619607843137255, alpha: 1.0)
    }
    
    static var blueGrey: UIColor {
        return UIColor(red: 0.376470588235294, green: 0.490196078431373, blue: 0.545098039215686, alpha: 1.0)
    }
}

extension UIColor {

    public convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    func add(_ overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0

        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0

        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

func +(lhs: UIColor, rhs: UIColor) -> UIColor {
    return lhs.add(rhs)
}
