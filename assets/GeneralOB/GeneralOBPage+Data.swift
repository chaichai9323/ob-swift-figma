import UIKit
import OOGMacroKits
import Components
import OOGFontKit

extension GeneralOBPage {
    
    /// 列表行高是否一致
    var cellHeightIsConsistent: Bool {
        switch self {
        default:
            return true
        }
    }
    
    /// 列表行高
    var cellHeight: CGFloat {
        switch self {
        default: cx390(76)
        }
    }
    
    /// 列表是否支持多选
    var multipleSelected: Bool {
        switch self {
        default:
            return false
        }
    }
    
    // 底部按钮标题
    var nextButtonName: String {
        switch self {
        default:
            return #Localized("Continue")
        }
    }
    
    var pageData: GeneralOBPageData {
        switch self {
        case .demo:
            return GeneralOBPageData(
                pageTitle: #Localized("Demo").attributed
            )
        }
    }
}
