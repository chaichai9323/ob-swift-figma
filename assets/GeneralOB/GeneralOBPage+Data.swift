import UIKit
import OOGMacroKits
import Components
import OOGFontKit

extension GeneralOBPage {
    
    /// 列表行高是否一致
    var cellHeightIsConsistent: Bool {
        switch self {
        case .mainGoal:
            return true
        default:
            return true
        }
    }
    
    /// 列表是否支持多选
    var multipleSelected: Bool {
        switch self {
        case .mainGoal:
            return false
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
                pageTitle: #Localized("Ai Coach").attributed
            )
        case .bodySignals:
            return GeneralOBPageData(
                pageTitle: #Localized("Your body gives signals every day").attributed
            )
        case .readSignals:
            return GeneralOBPageData(
                pageTitle: #Localized("Read the signals\nDecide your day.").attributed
            )
        case .mainGoal:
            return GeneralOBPageData(
                pageTitle: #Localized("What’s your main goal?").attributed,
                items: [
                    GeneralOBPageItem(title: "Staying health", localizedTitle: #Localized("Staying health"), icon: "GeneralOB/mainGoal/staying_health"),
                    GeneralOBPageItem(title: "Improving performance", localizedTitle: #Localized("Improving performance"), icon: "GeneralOB/mainGoal/improving_performance"),
                    GeneralOBPageItem(title: "Better sleep & recovery", localizedTitle: #Localized("Better sleep & recovery"), icon: "GeneralOB/mainGoal/better_sleep"),
                    GeneralOBPageItem(title: "Reducing fatigue & stress", localizedTitle: #Localized("Reducing fatigue & stress"), icon: "GeneralOB/mainGoal/reducing_stress"),
                    GeneralOBPageItem(title: "Better exercise", localizedTitle: #Localized("Better exercise"), icon: "GeneralOB/mainGoal/better_exercise"),
                    GeneralOBPageItem(title: "Understand my body signals", localizedTitle: #Localized("Understand my body signals"), icon: "GeneralOB/mainGoal/body_signals")
                ]
            )
        }
    }
}
