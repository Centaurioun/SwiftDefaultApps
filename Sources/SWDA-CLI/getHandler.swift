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

class ReadCommand: Command {

	let name = "getHandler"
	let shortDescription = "Returns the default application registered for the URI Scheme or <subtype> you specify."

    @Key("-u", "--UTI", description: "Return the default application for <subtype>")
    var uti: String?

    @Key("-U", "--URL", description: "Return the default application for <subtype>")
    var url: String?

    @Flag("--internet", "--browser", "--web", description: "Returns the default web browser.")
    var internet: Bool

    @Flag("--mail", "--email", "--e-mail", description: "Returns the default e-mail client.")
    var mail: Bool

    @Flag("--ftp", description: "Returns the default FTP client.")
    var ftp: Bool

    @Flag("--rss", description: "Returns the default RSS client.")
    var rss: Bool

    @Flag("--news", description: "Returns the default news client.")
    var news: Bool

    @Flag("--all", description: "When this flag is added, a list of all applications registered for that content will printed.")
    var getAll: Bool

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

        var role: LSRolesMask = LSRolesMask.all
        if let r = roleString {
             let rolesDict = ["editor":LSRolesMask.editor,"viewer":LSRolesMask.viewer,"shell":LSRolesMask.shell,"all":LSRolesMask.all]
             if let temp = rolesDict[r.lowercased()] {
                 role = temp
             } else {
                 role = [LSRolesMask.viewer,LSRolesMask.editor]
             }
        }

        var handler: String? = nil

		switch(kind,getAll) {

		case ("UTI",true),("URL",true):

			if let contentString = contentType {

				handler = copyStringArrayAsString( ((kind == "URL") ? LSWrappers.Schemes.copyAllHandlers(contentString) : LSWrappers.UTType.copyAllHandlers(contentString, inRoles: role)) )

			}
			break

		case ("UTI",false),("URL",false):

			if let contentString = contentType {

				handler = ((kind == "URL") ? LSWrappers.Schemes.copyDefaultHandler(contentString) : LSWrappers.UTType.copyDefaultHandler(contentString, inRoles: role))
			}
			break
		case ("http",_),("mailto",_),("ftp",_),("rss",_),("news",_):

			handler = LSWrappers.Schemes.copyDefaultHandler(kind)

			break

		default:

			handler = nil

			break
		}
		let arg: String
		arg = contentType ?? "<subtype>"

		if (nil != handler) {
			print(handler!)
		} else { throw CLI.Error(message: "SwiftDefaultApps ERROR: An incompatible combination was used, or no application is registered to handle \(arg)") }
	}
}
