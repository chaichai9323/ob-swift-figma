import UIKit
import Components
import OOGFontKit
import OOGMacroKits
import SnapKit

final class OBDemoVC: GeneralOBVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLab.attributedText = mainPage.pageData.pageTitle
    }
}
