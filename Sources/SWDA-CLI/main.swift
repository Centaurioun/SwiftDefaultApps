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

let cli = CLI(name: "swda", version: "1.0", description: "Utility to retrieve and manipulate default applications in macOS.")
cli.commands = [ ReadCommand(), GetApps(), GetSchemes(), GetUTIs(), SetCommand() ]

cli.goAndExit()
