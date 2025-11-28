/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <g.litenstein@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return., Gregorio Litenstein.
 * ----------------------------------------------------------------------------
 */

import PreferencePanes
import SWDA_Common

/** Main PreferencePane class */

public class SWDAMainPrefPane: NSPreferencePane {
    @IBOutlet weak var mainCustomView: NSView!
    @IBOutlet weak var tabViewController: SWDATabViewController?

/** Populate our utility singleton with instances of the views and TabView Controller; initialize tabs. */
    public override func assignMainView() {
        ControllersRef.sharedInstance.tabViewController = self.tabViewController
        ControllersRef.sharedInstance.thePrefPane = self
        ControllersRef.sharedInstance.theMainView = self.mainCustomView
        super.assignMainView()
    }
/** Add the TabView Controller to the Main View and load content for the default tab. */
    public override func mainViewDidLoad() {
           super.mainViewDidLoad()
                   self.tabViewController!.view.translatesAutoresizingMaskIntoConstraints = false
                   self.mainCustomView.addSubview(self.tabViewController!.view)
                   self.tabViewController!.view.topAnchor.constraint(equalTo: self.mainCustomView.topAnchor).isActive = true
                   self.tabViewController!.view.bottomAnchor.constraint(equalTo: self.mainCustomView.bottomAnchor).isActive = true
                   self.tabViewController!.view.leadingAnchor.constraint(equalTo: self.mainCustomView.leadingAnchor).isActive = true
                   self.tabViewController!.view.trailingAnchor.constraint(equalTo: self.mainCustomView.trailingAnchor).isActive = true
           }
/** Initialize the content array when the pane is first opened. */
   public override func didSelect() {
           ControllersRef.TabData.getContentArray(for: (ControllersRef.sharedInstance.tabViewController?.tabViewItems[0].view as! SWDATabTemplate), initialSetup: true)
   }

@IBAction func showAboutDialog(_ sender: NSButton) {
    let mainBundle = Bundle(identifier: "cl.fail.lordkamina.SwiftDefaultApps")
    let appVersionString: String = mainBundle?.object(forInfoDictionaryKey:"CFBundleShortVersionString") as! String
    let buildNumberString: String = mainBundle?.object(forInfoDictionaryKey:"CFBundleVersion") as! String

        let alert = NSAlert()
        alert.window.title = "About"
        alert.messageText = "SwiftDefaultApps, v. \(appVersionString) build \(buildNumberString)"
    alert.informativeText = "by Centaurioun."
    alert.icon = ControllersRef.appIcon
    alert.accessoryView = HyperlinkTextField(frame: NSRect(x: 0, y:10, width:330, height:18), url: "https://github.com/Centaurioun/SwiftDefaultApps")

    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    alert.layout()

        DispatchQueue.main.async {
            alert.runModal()
        }
    }
}
