#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Image.ahk
#Include Functions.ahk
#Include UpdateChecker.ahk

;Update Checker
global repoOwner := "itsRynsRoblox"
global repoName := "anime-royale-multi-use"
global currentVersion := "1.3.3"
; Basic Application Info
global aaTitle := "Ryn's Anime Royale Macro "
global version := "v" . currentVersion
global rblxID := "ahk_exe RobloxPlayerBeta.exe"
;Coordinate and Positioning Variables
global targetWidth := 816
global targetHeight := 638
global offsetX := -5
global offsetY := 1
global WM_SIZING := 0x0214
global WM_SIZE := 0x0005
global centerX := 408
global centerY := 320
global successfulCoordinates := []
global maxedCoordinates := []
global nukeCoordinates := []
global placedCounts := Map()
;Hotkeys
global F1Key := "F1"
global F2Key := "F2"
global F3Key := "F3"
global F4Key := "F4"
;Statistics Tracking
global Wins := 0
global loss := 0
global mode := ""
global StartTime := A_TickCount
global currentTime := GetCurrentTime()
global unitCardsVisible := true
;Custom Unit Placement
global waitingForClick := false
global savedCoords := []  ; Initialize an empty array to hold the coordinates
;Gui creation
global uiBorders := []
global uiBackgrounds := []
global uiTheme := []
global UnitData := []
global aaMainUI := Gui("+AlwaysOnTop -Caption")
global lastlog := ""
global aaMainUIHwnd := aaMainUI.Hwnd
global ActiveControlGroup := ""
;Theme colors
uiTheme.Push("0xffffff")  ; Header color
uiTheme.Push("0c000a")  ; Background color
uiTheme.Push("0xffffff")    ; Border color
uiTheme.Push("0c000a")  ; Accent color
uiTheme.Push("0x3d3c36")   ; Trans color
uiTheme.Push("000000")    ; Textbox color
uiTheme.Push("00ffb3") ; HighLight
;Logs/Save settings
global settingsGuiOpen := false
global SettingsGUI := ""
global currentOutputFile := A_ScriptDir "\Logs\LogFile.txt"
global WebhookURLFile := "Settings\WebhookURL.txt"
global DiscordUserIDFile := "Settings\DiscordUSERID.txt"
global SendActivityLogsFile := "Settings\SendActivityLogs.txt"
;Custom Pictures
GithubImage := "Images\github-logo.png"
DiscordImage := "Images\another_discord.png"

if !DirExist(A_ScriptDir "\Logs") {
    DirCreate(A_ScriptDir "\Logs")
}
if !DirExist(A_ScriptDir "\Settings") {
    DirCreate(A_ScriptDir "\Settings")
}

setupOutputFile()

;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------
aaMainUI.BackColor := uiTheme[2]
global Webhookdiverter := aaMainUI.Add("Edit", "x0 y0 w1 h1 +Hidden", "") ; diversion
uiBorders.Push(aaMainUI.Add("Text", "x0 y0 w1364 h1 +Background" uiTheme[3]))  ;Top line
uiBorders.Push(aaMainUI.Add("Text", "x0 y0 w1 h697 +Background" uiTheme[3]))   ;Left line
uiBorders.Push(aaMainUI.Add("Text", "x1363 y0 w1 h630 +Background" uiTheme[3])) ;Right line
uiBorders.Push(aaMainUI.Add("Text", "x1363 y0 w1 h697 +Background" uiTheme[3])) ;Second Right line
uiBackgrounds.Push(aaMainUI.Add("Text", "x3 y3 w1360 h27 +Background" uiTheme[2])) ;Title Top
uiBorders.Push(aaMainUI.Add("Text", "x0 y30 w1363 h1 +Background" uiTheme[3])) ;Title bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y443 w560 h1 +Background" uiTheme[3])) ;Placement bottom
uiBorders.Push(aaMainUI.Add("Text", "x803 y527 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(aaMainUI.Add("Text", "x802 y30 w1 h667 +Background" uiTheme[3])) ;Roblox Right
uiBorders.Push(aaMainUI.Add("Text", "x0 y697 w1364 h1 +Background" uiTheme[3], "")) ;Roblox second bottom
uiBorders.Push(aaMainUI.Add("Text", "x0 y631 w803 h1 +Background" uiTheme[3], "")) ;Roblox second bottom

global robloxHolder := aaMainUI.Add("Text", "x3 y33 w797 h597 +Background" uiTheme[5], "") ;Roblox window box
global exitButton := aaMainUI.Add("Picture", "x1330 y1 w32 h32 +BackgroundTrans", Exitbutton) ;Exit image
exitButton.OnEvent("Click", (*) => Destroy()) ;Exit button
global minimizeButton := aaMainUI.Add("Picture", "x1300 y3 w27 h27 +Background" uiTheme[2], Minimize) ;Minimize gui
minimizeButton.OnEvent("Click", (*) => minimizeUI()) ;Minimize gui
aaMainUI.SetFont("Bold s16 c" uiTheme[1], "Verdana") ;Font
global windowTitle := aaMainUI.Add("Text", "x10 y3 w1200 h29 +BackgroundTrans", aaTitle "" . "" version) ;Title

aaMainUI.Add("Text", "x805 y501 w558 h25 +Center +BackgroundTrans", "Process") ;Process header
uiBorders.Push(aaMainUI.Add("Text", "x803 y499 w560 h1 +Background" uiTheme[3])) ;Process Top
aaMainUI.SetFont("norm s11 c" uiTheme[1]) ;Font
global process1 := aaMainUI.Add("Text", "x810 y536 w538 h18 +BackgroundTrans c" uiTheme[7], "➤ Original Creator: Ryn (@TheRealTension)") ;Processes
global process2 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") ;Processes 
global process3 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process4 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process5 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process6 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
global process7 := aaMainUI.Add("Text", "xp yp+22 w538 h18 +BackgroundTrans", "") 
WinSetTransColor(uiTheme[5], aaMainUI) ;Roblox window box

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
ShowSettingsGUI(*) {
    global settingsGuiOpen, SettingsGUI
    
    ; Check if settings window already exists
    if (SettingsGUI && WinExist("ahk_id " . SettingsGUI.Hwnd)) {
        WinActivate("ahk_id " . SettingsGUI.Hwnd)
        return
    }
    
    if (settingsGuiOpen) {
        return
    }
    
    settingsGuiOpen := true
    SettingsGUI := Gui("-MinimizeBox +Owner" aaMainUIHwnd)  
    SettingsGui.Title := "Settings"
    SettingsGUI.OnEvent("Close", OnSettingsGuiClose)
    SettingsGUI.BackColor := uiTheme[2]
    
    ; Window border
    SettingsGUI.Add("Text", "x0 y0 w1 h300 +Background" uiTheme[3])     ; Left
    SettingsGUI.Add("Text", "x599 y0 w1 h300 +Background" uiTheme[3])   ; Right
    SettingsGUI.Add("Text", "x0 y281 w600 h1 +Background" uiTheme[3])   ; Bottom
    
    ; Right side sections
    SettingsGUI.SetFont("s10", "Verdana")
    SettingsGUI.Add("GroupBox", "x310 y5 w280 h160 Center c" uiTheme[1], "Discord Webhook")  ; Box
    
    SettingsGUI.SetFont("s9", "Verdana")
    SettingsGUI.Add("Text", "x320 y30 c" uiTheme[1], "Webhook URL")     ; Webhook Text
    global WebhookURLBox := SettingsGUI.Add("Edit", "x320 y50 w260 h20 c" uiTheme[6])  ; Store webhook
    SettingsGUI.Add("Text", "x320 y83 c" uiTheme[1], "Discord ID (optional)")  ; Discord Id Text
    global DiscordUserIDBox := SettingsGUI.Add("Edit", "x320 y103 w260 h20 c" uiTheme[6])  ; Store Discord ID
    global SendActivityLogsBox := SettingsGUI.Add("Checkbox", "x320 y135 c" uiTheme[1], "Send Process")  ; Enable Activity

    ; HotKeys
    SettingsGUI.Add("GroupBox", "x10 y90 w160 h160 Center c" uiTheme[1], "Keybinds")
    SettingsGUI.Add("Text", "x20 y110 c" uiTheme[1], "Position Roblox:")
    global F1Box := SettingsGUI.Add("Edit", "x125 y110 w30 h20 c" uiTheme[6], F1Key)
    SettingsGUI.Add("Text", "x20 y140 c" uiTheme[1], "Start Macro:")
    global F2Box := SettingsGUI.Add("Edit", "x100 y140 w30 h20 c" uiTheme[6], F2Key)
    SettingsGUI.Add("Text", "x20 y170 c" uiTheme[1], "Stop Macro:")
    global F3Box := SettingsGUI.Add("Edit", "x100 y170 w30 h20 c" uiTheme[6], F3Key)
    SettingsGUI.Add("Text", "x20 y200 c" uiTheme[1], "Pause Macro:")
    global F4Box := SettingsGUI.Add("Edit", "x110 y200 w30 h20 c" uiTheme[6], F4Key)

    ; Private Server section
    SettingsGUI.Add("GroupBox", "x310 y175 w280 h100 Center c" uiTheme[1], "Private Server")  ; Box
    SettingsGUI.Add("Text", "x320 y195 c" uiTheme[1], "Private Server Link (optional)")  ; Ps text
    global PsLinkBox := SettingsGUI.Add("Edit", "x320 y215 w260 h20 c" uiTheme[6])  ;  ecit box

    SettingsGUI.Add("GroupBox", "x10 y10 w115 h70 Center c" uiTheme[1], "UI Navigation")
    SettingsGUI.Add("Text", "x20 y30 c" uiTheme[1], "Navigation Key")
    global UINavBox := SettingsGUI.Add("Edit", "x20 y50 w20 h20 c" uiTheme[6], "\")

    ; Save buttons
    webhookSaveBtn := SettingsGUI.Add("Button", "x460 y135 w120 h25", "Save Webhook")
    webhookSaveBtn.OnEvent("Click", (*) => SaveWebhookSettings())

    keybindSaveBtn := SettingsGUI.Add("Button", "x20 y220 w50 h20", "Save")
    keybindSaveBtn.OnEvent("Click", SaveKeybindSettings)

    PsSaveBtn := SettingsGUI.Add("Button", "x460 y240 w120 h25", "Save PsLink")
    PsSaveBtn.OnEvent("Click", (*) => SavePsSettings())

    UINavSaveBtn := SettingsGUI.Add("Button", "x50 y50 w60 h20", "Save")
    UINavSaveBtn.OnEvent("Click", (*) => SaveUINavSettings())

    ; Loadsettings
    if FileExist(WebhookURLFile)
        WebhookURLBox.Value := FileRead(WebhookURLFile, "UTF-8")
    if FileExist(DiscordUserIDFile)
        DiscordUserIDBox.Value := FileRead(DiscordUserIDFile, "UTF-8")
    if FileExist(SendActivityLogsFile)
        SendActivityLogsBox.Value := (FileRead(SendActivityLogsFile, "UTF-8") = "1")   
    if FileExist("Settings\PrivateServer.txt")
        PsLinkBox.Value := FileRead("Settings\PrivateServer.txt", "UTF-8")
    if FileExist("Settings\UINavigation.txt")
        UINavBox.Value := FileRead("Settings\UINavigation.txt", "UTF-8")

    ; Show the settings window
    SettingsGUI.Show("w600 h285")
    Webhookdiverter.Focus()
}

OpenGuide(*) {
    GuideGUI := Gui("+AlwaysOnTop")
    GuideGUI.SetFont("s10 bold", "Segoe UI")
    GuideGUI.Title := "Anime Guardians Guide"

    GuideGUI.BackColor := "0c000a"
    GuideGUI.MarginX := 20
    GuideGUI.MarginY := 20

    ; Add Guide content
    GuideGUI.SetFont("s16 bold", "Segoe UI")

    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "1 - In your ROBLOX settings, make sure your keyboard is set to click to move and your graphics are set to 1 and enable UI navigation")
    GuideGUI.Add("Picture", "x50 w700   cWhite +Center", "Images\Clicktomove.png")
    GuideGUI.Add("Picture", "x50 w700   cWhite +Center", "Images\graphics1.png")
    GuideGUI.Show("w800")
}

aaMainUI.SetFont("s9 Bold c" uiTheme[1])

global guideBtn := aaMainUI.Add("Button", "x900 y5 w90 h20", "Guide")
guideBtn.OnEvent("Click", OpenGuide)

global miscSettingsButton := aaMainUI.Add("Button", "x1000 y5 w90 h20", "Unit Config")
miscSettingsButton.OnEvent("Click", (*) => ToggleControlGroup("Unit"))

global miscSettingsButton := aaMainUI.Add("Button", "x1100 y5 w90 h20", "Timer Config")
miscSettingsButton.OnEvent("Click", (*) => ToggleControlGroup("Timer"))

global settingsBtn := aaMainUI.Add("Button", "x1200 y5 w90 h20", "Settings")
settingsBtn.OnEvent("Click", ShowSettingsGUI)

placementSaveBtn := aaMainUI.Add("Button", "x807 y471 w80 h20", "Save")
placementSaveBtn.OnEvent("Click", SaveSettings)
aaMainUI.SetFont("s9")
global NextLevelBox := aaMainUI.Add("Checkbox", "x900 y451 cffffff Checked", "Next Level")
global ReturnLobbyBox := aaMainUI.Add("Checkbox", "x900 y451 cffffff Checked", "Return To Lobby")
global HardModeBox := aaMainUI.Add("Checkbox", "x1040 y476 cffffff Checked", "Hard Mode")
global PriorityUpgrade := aaMainUI.Add("CheckBox", "x900 y476 cffffff", "Priority Upgrade")

PlacementPresetText := aaMainUI.Add("Text", "x837 y390 w130 h20", "Placement Profile")
global PlacementProfiles := aaMainUI.Add("DropDownList", "x845 y410 w100 h180 Choose1 +Center", ["Story", "Raid", "Challenge", "Event", "Custom #1", "Custom #2", "Custom #3"])
PlacementProfiles.OnEvent("Change", SendPlacements)

PlacementPatternText := aaMainUI.Add("Text", "x982 y390 w115 h20", "Placement Type")
global PlacementPatternDropdown := aaMainUI.Add("DropDownList", "x985 y410 w100 h180 Choose2 +Center", ["Circle", "Custom", "Grid", "Random"])

PlaceSpeedText := aaMainUI.Add("Text", "x1120 y390 w115 h20", "Placement Speed")
global PlaceSpeed := aaMainUI.Add("DropDownList", "x1125 y410 w100 h180 Choose1 +Center", ["Super Fast (1s)", "Fast (1.5s)", "Default (2s)", "Slow (2.5s)", "Very Slow (3s)", "Toaster (4s)"])

modulationText := aaMainUI.Add("Text", "x1268 y390 w80 h20", "Modulation")
modulationEdit := aaMainUI.Add("Edit", "x1275 y410 w60 h20 +Center c000000", "1.00")  ; Default value
modulationUpDown := aaMainUI.Add("UpDown", "Range1-50")  ; Set range

; Ensure input stays within 0.75 - 50 range
modulationEdit.OnEvent("Change", ModulationValidate)

ModulationValidate(*) {
    val := modulationEdit.Value + 0  ; Convert to number
    if (val < 0.75) 
        modulationEdit.Value := "0.75"
    else if (val > 50) 
        modulationEdit.Value := "50"
}

placementSaveText := aaMainUI.Add("Text", "x807 y451 w80 h20", "Save Config")

; Custom Placement Settings
global CustomSettings := aaMainUI.Add("GroupBox", "x410 y634 w390 h60 +Center c" uiTheme[1], "Custom Placement Settings")

customPlacementButton := aaMainUI.Add("Button", "x430 y667 w80 h20", "Set")
customPlacementButton.OnEvent("Click", (*) => StartCoordCapture())

customPlacementClearButton := aaMainUI.Add("Button", "x565 y667 w80 h20", "Clear")
customPlacementClearButton.OnEvent("Click", (*) => DeleteCoordsForPreset(PlacementProfiles.Value))

fixCameraText := aaMainUI.Add("Text", "x725 y647 w60 h20 +Left +BackgroundTrans", "Camera")
fixCameraButton := aaMainUI.Add("Button", "x710 y667 w80 h20", "Fix")
fixCameraButton.OnEvent("Click", (*) => BasicSetup())

Hotkeytext := aaMainUI.Add("Text", "x807 y35 w530 h30", "To change keybinds click top right settings, Below are default hotkey settings ")
Hotkeytext2 := aaMainUI.Add("Text", "x807 y50 w530 h30", "F1:Reposition roblox window|F2:Start Macro|F3:Stop Macro|F4:Pause Macro")
GithubButton := aaMainUI.Add("Picture", "x30 y640 w40 h40 +BackgroundTrans cffffff", GithubImage)
DiscordButton := aaMainUI.Add("Picture", "x112 y645 w60 h34 +BackgroundTrans cffffff", DiscordImage)

GithubButton.OnEvent("Click", (*) => OpenGithub())
DiscordButton.OnEvent("Click", (*) => OpenDiscord())

global MiscSettings := aaMainUI.Add("GroupBox", "x808 y85 w550 h296 +Center Hidden c" uiTheme[1], "Timer Settings")
global UnitSettings := aaMainUI.Add("GroupBox", "x808 y85 w550 h296 +Center Hidden c" uiTheme[1], "Unit Settings")

LobbySleepText := aaMainUI.Add("Text", "x818 y123.5 w130 h20 +Center Hidden", "Lobby Sleep Timer")
global LobbySleepTimer := aaMainUI.Add("DropDownList", "x950 y120 w100 h180 Hidden Choose1", ["No Delay", "5 Seconds", "10 Seconds", "15 Seconds", "20 Seconds", "25 Seconds", "30 Seconds", "35 Seconds", "40 Seconds", "45 Seconds", "50 Seconds", "55 Seconds", "60 Seconds"])

WebhookSleepText := aaMainUI.Add("Text", "x818 y163.5 w130 h20 +Center Hidden", "Webhook Timer")
global WebhookSleepTimer := aaMainUI.Add("DropDownList", "x950 y160 w100 h180 Hidden Choose1", ["No Delay", "1 minute", "3 minutes", "5 minutes", "10 minutes"])

global NukeUnitSlotEnabled := aaMainUI.Add("Checkbox", "x818 y123.5 Hidden Choose1 cffffff Checked", "Nuke Unit | Slot")
global NukeUnitSlot := aaMainUI.Add("DropDownList", "x950 y120 w100 h180 Hidden Choose1", ["1", "2", "3", "4", "5", "6"])

NukeUnitText := aaMainUI.Add("Text", "x818 y163.5 w130 h20 +Center Hidden", "Nuke Timer")
global NukeUnitTimer := aaMainUI.Add("ComboBox", "x950 y160 w100 h180 Hidden Choose1 c000000", [""])


;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT
global modeSelectionGroup := aaMainUI.Add("GroupBox", "x808 y38 w500 h45 Background" uiTheme[2], "Mode Select")
aaMainUI.SetFont("s10 c" uiTheme[6])
global ModeDropdown := aaMainUI.Add("DropDownList", "x818 y53 w140 h180 Choose0 +Center", ["Story", "Legend", "Raid", "Tower", "Custom"])
global StoryDropdown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Green Planet", "Ghoul City", "Sharkman Island", "Hidden Village", "Fairy Town", "Cursed Town", "Corp City", "Soul World", "Strongest City"])
global StoryActDropdown := aaMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinity"])
global LegendDropDown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Hell", "Shadow City"])
global RaidDropdown := aaMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Green Planet", "Hollow Desert", "Red Palace", "Sorcery Academy", "Lookout", "Slayers District", "Underground Tomb", "Boru's Room", "Candy Park", "Aura Room"])
global RaidActDropdown := aaMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1"])
global ConfirmButton := aaMainUI.Add("Button", "x1218 y53 w80 h25", "Confirm")

StoryDropdown.Visible := false
StoryActDropdown.Visible := false
RaidDropdown.Visible := false
LegendDropDown.Visible := false
RaidActDropdown.Visible := false
ReturnLobbyBox.Visible := false
NextLevelBox.Visible := false
HardModeBox.Visible := false
Hotkeytext.Visible := false
Hotkeytext2.Visible := false
ModeDropdown.OnEvent("Change", OnModeChange)
StoryDropdown.OnEvent("Change", OnStoryChange)
RaidDropdown.OnEvent("Change", OnRaidChange)
ConfirmButton.OnEvent("Click", OnConfirmClick)
;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI
;------UNIT CONFIGURATION------UNIT CONFIGURATION------UNIT CONFIGURATION/------UNIT CONFIGURATION/------UNIT CONFIGURATION/------UNIT CONFIGURATION/

AddUnitCard(aaMainUI, index, x, y) {
    unit := {}
 
    unit.Background := aaMainUI.Add("Text", Format("x{} y{} w550 h45 +Background{}", x, y, uiTheme[4]))
    unit.BorderTop := aaMainUI.Add("Text", Format("x{} y{} w550 h2 +Background{}", x, y, uiTheme[3]))
    unit.BorderBottom := aaMainUI.Add("Text", Format("x{} y{} w552 h2 +Background{}", x, y+45, uiTheme[3]))
    unit.BorderLeft := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x, y, uiTheme[3]))
    unit.BorderRight1 := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+250, y, uiTheme[3]))
    unit.BorderRight2 := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+550, y, uiTheme[3]))
    unit.BorderRight3 := aaMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+390, y, uiTheme[3]))
    aaMainUI.SetFont("s11 Bold c" uiTheme[1])
    unit.UnitTitle := aaMainUI.Add("Text", Format("x{} y{} w60 h25 +BackgroundTrans", x+30, y+18), "Unit " index)

    aaMainUI.SetFont("s9 c" uiTheme[1])
    unit.PlacementText := aaMainUI.Add("Text", Format("x{} y{} w70 h20 +BackgroundTrans", x+100, y+2), "Placement")
    unit.PriorityText := aaMainUI.Add("Text", Format("x{} y{} w60 h20 BackgroundTrans", x+183, y+2), "Priority")

    unit.PlaceUpgradeText := aaMainUI.Add("Text", Format("x{} y{} w250 h20 BackgroundTrans", x+183+83, y+2), "Place && Upgrade")
    unit.UpgradeTitle := aaMainUI.Add("Text", Format("x{} y{} w250 h25 +BackgroundTrans", x+295, y+20), "Enabled")

    unit.UpgradeCapText := aaMainUI.Add("Text", Format("x{} y{} w250 h20 BackgroundTrans", x+425, y+2), "Upgrade Limit")
    unit.UpgradeLimitTitle := aaMainUI.Add("Text", Format("x{} y{} w250 h25 +BackgroundTrans", x+430, y+20), "Enabled")   
    
    UnitData.Push(unit)
    return unit
}

;Create Unit slot
y_start := 85
y_spacing := 50
Loop 6 {
    AddUnitCard(aaMainUI, A_Index, 808, y_start + ((A_Index-1)*y_spacing))
}

enabled1 := aaMainUI.Add("CheckBox", "x818 y105 w15 h15", "")
enabled2 := aaMainUI.Add("CheckBox", "x818 y155 w15 h15", "")
enabled3 := aaMainUI.Add("CheckBox", "x818 y205 w15 h15", "")
enabled4 := aaMainUI.Add("CheckBox", "x818 y255 w15 h15", "")
enabled5 := aaMainUI.Add("CheckBox", "x818 y305 w15 h15", "")
enabled6 := aaMainUI.Add("CheckBox", "x818 y355 w15 h15", "")

upgradeEnabled1 := aaMainUI.Add("CheckBox", "x1070 y105 w15 h15", "")
upgradeEnabled2 := aaMainUI.Add("CheckBox", "x1070 y155 w15 h15", "")
upgradeEnabled3 := aaMainUI.Add("CheckBox", "x1070 y205 w15 h15", "")
upgradeEnabled4 := aaMainUI.Add("CheckBox", "x1070 y255 w15 h15", "")
upgradeEnabled5 := aaMainUI.Add("CheckBox", "x1070 y305 w15 h15", "")
upgradeEnabled6 := aaMainUI.Add("CheckBox", "x1070 y355 w15 h15", "")

upgradeLimitEnabled1 := aaMainUI.Add("CheckBox", "x1210 y105 w15 h15", "")
upgradeLimitEnabled2 := aaMainUI.Add("CheckBox", "x1210 y155 w15 h15", "")
upgradeLimitEnabled3 := aaMainUI.Add("CheckBox", "x1210 y205 w15 h15", "")
upgradeLimitEnabled4 := aaMainUI.Add("CheckBox", "x1210 y255 w15 h15", "")
upgradeLimitEnabled5 := aaMainUI.Add("CheckBox", "x1210 y305 w15 h15", "")
upgradeLimitEnabled6 := aaMainUI.Add("CheckBox", "x1210 y355 w15 h15", "")

aaMainUI.SetFont("s8 c" uiTheme[6])

; Placement dropdowns
Placement1 := aaMainUI.Add("DropDownList", "x908 y105 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement2 := aaMainUI.Add("DropDownList", "x908 y155 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement3 := aaMainUI.Add("DropDownList", "x908 y205 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement4 := aaMainUI.Add("DropDownList", "x908 y255 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement5 := aaMainUI.Add("DropDownList", "x908 y305 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement6 := aaMainUI.Add("DropDownList", "x908 y355 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])

Priority1 := aaMainUI.Add("DropDownList", "x990 y105 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority2 := aaMainUI.Add("DropDownList", "x990 y155 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority3 := aaMainUI.Add("DropDownList", "x990 y205 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority4 := aaMainUI.Add("DropDownList", "x990 y255 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority5 := aaMainUI.Add("DropDownList", "x990 y305 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Priority6 := aaMainUI.Add("DropDownList", "x990 y355 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])

; Upgrade Limit
UpgradeLimit1 := aaMainUI.Add("DropDownList", "x1300 y105 w40 h180 Choose1 +Center", ["0","1","2","3","4","5","6","7","8","9","10", "11"])
UpgradeLimit2 := aaMainUI.Add("DropDownList", "x1300 y155 w40 h180 Choose1 +Center", ["0","1","2","3","4","5","6","7","8","9","10", "11"])
UpgradeLimit3 := aaMainUI.Add("DropDownList", "x1300 y205 w40 h180 Choose1 +Center", ["0","1","2","3","4","5","6","7","8","9","10", "11"])
UpgradeLimit4 := aaMainUI.Add("DropDownList", "x1300 y255 w40 h180 Choose1 +Center", ["0","1","2","3","4","5","6","7","8","9","10", "11"])
UpgradeLimit5 := aaMainUI.Add("DropDownList", "x1300 y305 w40 h180 Choose1 +Center", ["0","1","2","3","4","5","6","7","8","9","10", "11"])
UpgradeLimit6 := aaMainUI.Add("DropDownList", "x1300 y355 w40 h180 Choose1 +Center", ["0","1","2","3","4","5","6","7","8","9","10", "11"])

readInSettings()
aaMainUI.Show("w1366 h700")
WinMove(0, 0,,, "ahk_id " aaMainUIHwnd)
forceRobloxSize()  ; Initial force size and position
SetTimer(checkRobloxSize, 600000)  ; Check every 10 minutes
;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION
;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS

;Process text
AddToLog(current) { 
    global process1, process2, process3, process4, process5, process6, process7, currentOutputFile, lastlog

    ; Remove arrow from all lines first
    process7.Value := StrReplace(process6.Value, "➤ ", "")
    process6.Value := StrReplace(process5.Value, "➤ ", "")
    process5.Value := StrReplace(process4.Value, "➤ ", "")
    process4.Value := StrReplace(process3.Value, "➤ ", "")
    process3.Value := StrReplace(process2.Value, "➤ ", "")
    process2.Value := StrReplace(process1.Value, "➤ ", "")
    
    ; Add arrow only to newest process
    process1.Value := "➤ " . current
    
    elapsedTime := getElapsedTime()
    Sleep(50)
    FileAppend(current . " " . elapsedTime . "`n", currentOutputFile)

    ; Add webhook logging
    lastlog := current
    if FileExist("Settings\SendActivityLogs.txt") {
        SendActivityLogsStatus := FileRead("Settings\SendActivityLogs.txt", "UTF-8")
        if (SendActivityLogsStatus = "1") {
            WebhookLog()
        }
    }
}

;Timer
getElapsedTime() {
    global StartTime
    ElapsedTime := A_TickCount - StartTime
    Minutes := Mod(ElapsedTime // 60000, 60)  
    Seconds := Mod(ElapsedTime // 1000, 60)
    return Format("{:02}:{:02}", Minutes, Seconds)
}

;Basically the code to move roblox, below

sizeDown() {
    global rblxID
    
    if !WinExist(rblxID)
        return

    WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
    
    ; Exit fullscreen if needed
    if (OutWidth >= A_ScreenWidth && OutHeight >= A_ScreenHeight) {
        Send "{F11}"
        Sleep(100)
    }

    ; Force the window size and retry if needed
    Loop 3 {
        WinMove(X, Y, targetWidth, targetHeight, rblxID)
        Sleep(100)
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth == targetWidth && OutHeight == targetHeight)
            break
    }
}

moveRobloxWindow() {
    global aaMainUIHwnd, offsetX, offsetY, rblxID
    
    if !WinExist(rblxID) {
        AddToLog("Waiting for Roblox window...")
        return
    }

    ; First ensure correct size
    sizeDown()
    
    ; Then move relative to main UI
    WinGetPos(&x, &y, &w, &h, aaMainUIHwnd)
    WinMove(x + offsetX, y + offsetY,,, rblxID)
    WinActivate(rblxID)
}

forceRobloxSize() {
    global rblxID
    
    if !WinExist(rblxID) {
        checkCount := 0
        While !WinExist(rblxID) {
            Sleep(5000)
            if(checkCount >= 5) {
                AddToLog("Attempting to locate the Roblox window")
            } 
            checkCount += 1
            if (checkCount > 12) { ; Give up after 1 minute
                AddToLog("Could not find Roblox window")
                return
            }
        }
        AddToLog("Found Roblox window")
    }

    WinActivate(rblxID)
    sizeDown()
    moveRobloxWindow()
}
; Function to periodically check window size
checkRobloxSize() {
    global rblxID
    if WinExist(rblxID) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth != targetWidth || OutHeight != targetHeight) {
            sizeDown()
            moveRobloxWindow()
        }
    }
}
;Basically the code to move roblox, Above

OnSettingsGuiClose(*) {
    global settingsGuiOpen, SettingsGUI
    settingsGuiOpen := false
    if SettingsGUI {
        SettingsGUI.Destroy()
        SettingsGUI := ""  ; Clear the GUI reference
    }
}

checkSizeTimer() {
    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, "ahk_exe RobloxPlayerBeta.exe")
        if (OutWidth != 816 || OutHeight != 638) {
            AddToLog("Fixing Roblox window size")
            moveRobloxWindow()
        }
    }
}

StartCoordCapture() {
    global savedCoords
    global waitingForClick
    global placement1, placement2, placement3, placement4, placement5, placement6

    presetIndex := PlacementProfiles.Value

    ; Retrieve values from dropdowns
    totalEnabled := placement1.Value + placement2.Value + placement3.Value + placement4.Value + placement5.Value + placement6.Value

    ; Stop coordinate capture if the max total is reached
    if savedCoords[presetIndex].Length >= totalEnabled {
        AddToLog("Max total coordinates reached. Stopping coordinate capture.")
        return
    }

    if (WinExist(rblxID)) {
        WinActivate(rblxID)
    }

    waitingForClick := true
    AddToLog("Press LShift to stop coordinate capture")
    SetTimer UpdateTooltip, 50  ; Update tooltip position every 50ms
}

UpdateTooltip() {
    global waitingForClick
    if waitingForClick {
        MouseGetPos &x, &y
        ToolTip "Click anywhere to save coordinates...", x + 10, y + 10  ; Offset tooltip slightly
    } else {
        ToolTip()  ; Hide tooltip when not waiting
        SetTimer UpdateTooltip, 0  ; Stop the timer
    }
}

~LShift::
{
    global waitingForClick
    if waitingForClick {
        AddToLog("Stopping coordinate capture")
        waitingForClick := false
    }
}

~LButton::
{
    global waitingForClick, savedCoords
    global placement1, placement2, placement3, placement4, placement5, placement6

    if !scriptInitialized
        return

    if waitingForClick {
        presetIndex := PlacementProfiles.Value

        if (presetIndex < 1)
        {
            if (debugMessages) {
                AddToLog("⚠️ Invalid preset index: " presetIndex)
            }
            return
        }

        totalEnabled := placement1.Value + placement2.Value + placement3.Value + placement4.Value + placement5.Value + placement6.Value

        MouseGetPos(&x, &y)
        SetTimer(UpdateTooltip, 0)

        ; ✅ Get or initialize the preset slot safely
        coords := GetOrInitPresetCoords(presetIndex)
        coords.Push({x: x, y: y})
        savedCoords[presetIndex] := coords

        ToolTip("Coords Set: " coords.Length " / Total Enabled: " totalEnabled, x + 10, y + 10)
        AddToLog("📌 [Preset: " PlacementProfiles.Text "] Saved → X: " x ", Y: " y " | Set: " coords.Length " / Enabled: " totalEnabled)
        SetTimer(ClearToolTip, -1200)

        if coords.Length >= totalEnabled {
            AddToLog("✅ [Preset " PlacementProfiles.Text "] All coordinates set, Stopping capture.")
            waitingForClick := false
        }
    }
}


GetOrInitPresetCoords(index) {
    global savedCoords
    if !IsObject(savedCoords)
        savedCoords := []

    ; Extend the array up to the index if needed
    while (savedCoords.Length < index)
        savedCoords.Push([])

    if !IsObject(savedCoords[index])
        savedCoords[index] := []

    return savedCoords[index]
}

ClearToolTip() {
    ToolTip()  ; Properly clear tooltip
    Sleep 100  ; Small delay to ensure clearing happens across all systems
    ToolTip()  ; Redundant clear to catch edge cases
}

DeleteCoordsForPreset(index) {
    global savedCoords

    ; Ensure savedCoords is initialized as an object
    if !IsObject(savedCoords)
        savedCoords := []

    ; Extend the array up to the index if needed
    while (savedCoords.Length < index)
        savedCoords.Push([])

    ; Check if the preset has coordinates (i.e., non-empty)
    if (savedCoords[index].Length > 0) {
        savedCoords[index] := []  ; Clear the coordinates for the specified preset
        AddToLog("🗑️ Cleared coordinates for Preset: " PlacementProfiles.Text)
    } else {
        AddToLog("⚠️ No coordinates to clear for Preset: " PlacementProfiles.Text)
    }
}

SendPlacements(*) {
    global savedCoords

    presetIndex := PlacementProfiles.Value

    AddToLog("Preset: " PlacementProfiles.Text " has " savedCoords[presetIndex].Length " saved placements")
}

SetUnitCardVisibility(visible) {
    for _, unit in UnitData {
        for _, control in unit.OwnProps() {
            if IsObject(control)
                control.Visible := visible
        }
    }

    controlNames := [
        "Placement", "Priority", "enabled", "upgradeEnabled",
        "upgradeLimitEnabled", "UpgradeLimit"
    ]

    for name in controlNames {
        loop 6 {
            control := %name%%A_Index%
            if IsObject(control)
                control.Visible := visible
        }
    }
}

HideUnitCards() {
    SetUnitCardVisibility(false)
}

ShowUnitCards() {
    SetUnitCardVisibility(true)
}

ShowOnlyControlGroup(groupToShow) {
    global ControlGroups := Map()

    ControlGroups["Default"] := [
        Placement1, Placement2, Placement3, Placement4, Placement5, Placement6,
        Priority1, Priority2, Priority3, Priority4, Priority5, Priority6,
        enabled1, enabled2, enabled3, enabled4, enabled5, enabled6,
        upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6,
        upgradeLimitEnabled1, upgradeLimitEnabled2, upgradeLimitEnabled3, upgradeLimitEnabled4, upgradeLimitEnabled5, upgradeLimitEnabled6,
        UpgradeLimit1, UpgradeLimit2, UpgradeLimit3, UpgradeLimit4, UpgradeLimit5, UpgradeLimit6
    ]
    
    ControlGroups["Unit"] := [
        UnitSettings, NukeUnitText, NukeUnitTimer, NukeUnitSlotEnabled, NukeUnitSlot
    ]
    
    ControlGroups["Timer"] := [
        MiscSettings, LobbySleepText, LobbySleepTimer, WebhookSleepText, WebhookSleepTimer
    ]

    for name, controls in ControlGroups {
        isVisible := (name = groupToShow)
        for control in controls {
            if IsObject(control)
                control.Visible := isVisible
        }
    }
}

ToggleControlGroup(groupName) {
    global ActiveControlGroup
    if (ActiveControlGroup = groupName) {
        ShowOnlyControlGroup("Default") ; hide all
        ActiveControlGroup := ""
        AddToLog("Displaying: Default UI")
        ShowUnitCards()
    } else {
        ShowOnlyControlGroup(groupName)
        ActiveControlGroup := groupName
        AddToLog("Displaying: " groupName " Settings UI")
        HideUnitCards()
    }
}