/*
* ----------------------------------------------------------------------------
* "THE BEER-WARE LICENSE" (Revision 42):
* <g.litenstein@gmail.com> wrote this file. As long as you retain this notice you
* can do whatever you want with this stuff. If we meet some day, and you think
* this stuff is worth it, you can buy me a beer in return., Gregorio Litenstein.
* ----------------------------------------------------------------------------
*/

import Foundation
import SwiftCLI
import SWDA_Common

class SetCommand: Command {

	let name = "setHandler"
	let shortDescription = "Sets <application> as the default handler for a given <type>/<subtype> combination."

    @Key("-u", "--UTI", description: "Change the default application for <subtype>")
    var uti: String?

    @Key("-U", "--URL", description: "Change the default application for <subtype>")
    var url: String?

    @Flag("--internet", "--browser", "--web", description: "Changes the default web browser.")
    var internet: Bool

    @Flag("--mail", "--email", "--e-mail", description: "Changes the default e-mail client.")
    var mail: Bool

    @Flag("--ftp", description: "Changes the default FTP client.")
    var ftp: Bool

    @Flag("--rss", description: "Changes the default RSS client.")
    var rss: Bool

    @Flag("--news", description: "Changes the default news client.")
    var news: Bool

    @Key("--app", "--application", description: "The <application> to register as default handler. Specifying \"None\" will remove the currently registered handler.")
    var application: String?

    @Key("--role", description: "--role <Viewer|Editor|Shell|All>, specifies the role with which to register the handler. Default is All.")
    var roleString: String?

    var optionGroups: [OptionGroup] {
        return [
            OptionGroup(options: [$uti, $url, $internet, $mail, $ftp, $rss, $news], restriction: .exactlyOne)
        ]
    }

	func execute() throws  {
        var kind = ""
        var contentType: String? = nil

        if let val = uti { kind = "UTI"; contentType = val }
        else if let val = url { kind = "URL"; contentType = val }
        else if internet { kind = "http" }
        else if mail { kind = "mailto" }
        else if ftp { kind = "ftp" }
        else if rss { kind = "RSS" }
        else if news { kind = "news" }

        guard let inApplication = application else {
             throw CLI.Error(message: "Missing required argument: --application")
        }

        var role: LSRolesMask = LSRolesMask.all
        if let r = roleString {
             let rolesDict = ["editor":LSRolesMask.editor,"viewer":LSRolesMask.viewer,"shell":LSRolesMask.shell,"all":LSRolesMask.all]
             if let temp = rolesDict[r.lowercased()] {
                 role = temp
             } else {
                 role = LSRolesMask.all
             }
        }

        var bundleID: String? = nil
        var statusCode: OSStatus = kLSUnknownErr

        statusCode = LSWrappers.getBundleID(inApplication, outBundleID: &bundleID)
        guard (statusCode == 0) else {
             throw CLI.Error(message: LSWrappers.LSErrors.init(value: statusCode).print(argument: (app: inApplication, content: contentType ?? kind)))
        }

        switch(kind) {
        case "UTI","URL":
            if let contentString = contentType {
                statusCode = ((kind == "URL") ? LSWrappers.Schemes.setDefaultHandler(contentString, bundleID!) : LSWrappers.UTType.setDefaultHandler(contentString, bundleID!, role))
            }
        case "http","mailto","ftp","rss","news":
            statusCode = LSWrappers.Schemes.setDefaultHandler(kind, bundleID!)
        default:
            statusCode = kLSUnknownErr
        }

        do {
            try displayAlert(error: statusCode, arg1: (bundleID != nil ? bundleID : inApplication), arg2: contentType ?? kind)
        } catch { print(error) }
	}
}
