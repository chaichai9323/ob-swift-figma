import UIKit
import Components

extension GeneralOBPage {
    var vc: GeneralOBVC {
        switch self {
        case .demo:
            return OBDemoVC(page: self)
        case .bodySignals:
            return OBBodySignalsVC(page: self)
        case .readSignals:
            return OBReadSignalsVC(page: self)
        case .mainGoal:
            let vc = OBMainGoalVC(page: self)
            let indexes = GeneralOBData.shared.mainGoal.map { [IndexPath(item: $0, section: 0)] } ?? []
            vc.makeSelectIndexes(indexes) { selected in
                GeneralOBData.shared.mainGoal = selected.first?.item
            }
            return vc
        }
    }
}
