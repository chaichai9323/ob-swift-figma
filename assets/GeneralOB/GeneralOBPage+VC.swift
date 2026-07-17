import UIKit
import Components

extension GeneralOBPage {
    var vc: GeneralOBVC {
        switch self {
        case .demo:
            return OBDemoVC(page: self)
        }
    }
}
