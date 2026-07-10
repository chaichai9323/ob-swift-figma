import Foundation
import Onboarding

enum GeneralOBPage: String, CaseIterable {
    case demo
}

extension GeneralOBPage {
    
    private var name: String {
        return "GeneralOB" + rawValue
    }
    
    private var eventName: String {
        return "OB " + rawValue
    }
    
    /// 是否能返回上个页面
    private var canBack: Bool {
        switch self {
        case .demo:
            return true
        default:
            return true
        }
    }
    
    /// 是否隐藏进度条
    private var isHideProgress: Bool {
        switch self {
        case .demo:
            return true
        default:
            return false
        }
    }
    
    /// 当前页面是否能够在重启App的时候恢复展示
    private var canRestore: Bool {
        return true
    }

    /// 是否隐藏继续按钮
    var isHideContinueBtn: Bool {
        switch self {
        case .demo:
            return false
        default:
            return false
        }
    }
    
    /// 是否能返回到次页面
    var canBackTo: Bool {
        return true
    }
    
    private static let allPageMap: [String: GeneralOBPage] = {
        allCases.reduce(
            [String: GeneralOBPage]()
        ) { partialResult, page in
            var res = partialResult
            res[page.name] = page
            return res
        }
    }()
}


extension GeneralOBPage {
    
    static var prevIgnores: [OBPage] {
        allCases.filter {
            !$0.canBackTo
        }.map {
            $0.obPage
        }
    }
    
    var obPage: OBPage {
        return .init(
            name: name,
            eventName: eventName,
            showBackButton: canBack,
            showProgress: !isHideProgress,
            showSkipButton: false,
            canBeRestorePage: canRestore
        )
    }
    
    static func create(_ name: String) -> Self? {
        return allPageMap[name]
    }
}
