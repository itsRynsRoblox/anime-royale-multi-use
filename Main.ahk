﻿#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

global scriptInitialized := false

SendMode "Event"
#Include %A_ScriptDir%\lib/Image.ahk
#Include %A_ScriptDir%\lib/GUI.ahk
#Include %A_ScriptDir%\lib/GameMango.ahk
#Include %A_ScriptDir%\lib/Functions.ahk
#Include %A_ScriptDir%\lib/Config.ahk
#Include %A_ScriptDir%\lib/webhooksettings.ahk
#Include %A_ScriptDir%\Lib\FindText.ahk
#Include %A_ScriptDir%\Lib\UpdateChecker.ahk
#Include %A_ScriptDir%\Lib\PlacementPatterns.ahk
#Include %A_ScriptDir%\Lib\Toggles.ahk

global scriptInitialized := true