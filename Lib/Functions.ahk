#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false

SavePsSettings(*) {
    AddToLog("Saving Private Server")
    
    if FileExist("Settings\PrivateServer.txt")
        FileDelete("Settings\PrivateServer.txt")
    
    FileAppend(PsLinkBox.Value, "Settings\PrivateServer.txt", "UTF-8")
}

SaveUINavSettings(*) {
    AddToLog("Saving UI Navigation Key")
    
    if FileExist("Settings\UINavigation.txt")
        FileDelete("Settings\UINavigation.txt")
    
    FileAppend(UINavBox.Value, "Settings\UINavigation.txt", "UTF-8")
}
 
 ;Minimizes the UI
 minimizeUI(*){
    aaMainUI.Minimize()
 }
 
 Destroy(*){
    aaMainUI.Destroy()
    ExitApp
 }

 ;Login Text
 setupOutputFile() {
     content := "`n==" aaTitle "" version "==`n  Start Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }
 
 ;Gets the current time
 getCurrentTime() {
     currentHour := A_Hour
     currentMinute := A_Min
     currentSecond := A_Sec
 
     return Format("{:d}h.{:02}m.{:02}s", currentHour, currentMinute, currentSecond)
 }



 OnModeChange(*) {
    global mode
    selected := ModeDropdown.Text
    
    ; Hide all dropdowns first
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    HardModeBox.Visible := false
    
    if (selected = "Story") {
        StoryDropdown.Visible := true
        StoryActDropdown.Visible := true
        HardModeBox.Visible := true
        mode := "Story"
    } else if (selected = "Raid") {
        RaidDropdown.Visible := true
        RaidActDropdown.Visible := true
        mode := "Raid"
    } else if (selected = "Custom") {
        mode := "Custom"
    } else {
        mode := selected
    }
}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnRaidChange(*) {
    if (RaidDropdown.Text != "") {
        RaidActDropdown.Visible := true
    } else {
        RaidActDropdown.Visible := false
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }

    ; For Story mode, check if both Story and Act are selected
    if (ModeDropdown.Text = "Story") {
        if (StoryDropdown.Text = "" || StoryActDropdown.Text = "") {
            AddToLog("Please select both Story and Act before confirming")
            return
        }
        AddToLog("Selected " StoryDropdown.Text " - " StoryActDropdown.Text)
        ReturnLobbyBox.Visible := false
        NextLevelBox.Visible := (StoryActDropdown.Text != "Infinity")
        HardModeBox.Visible := true
    }
    ; For Raid mode, check if both Raid and RaidAct are selected
    else if (ModeDropdown.Text = "Raid") {
        if (RaidDropdown.Text = "" || RaidActDropdown.Text = "") {
            AddToLog("Please select both Raid and Act before confirming")
            return
        }
        AddToLog("Selected " RaidDropdown.Text " - " RaidActDropdown.Text)
        ReturnLobbyBox.Visible := true
    }
    ; For Custom mode
    else if (ModeDropdown.Text = "Custom") {
            AddToLog("Selected Custom")
    } else {
        AddToLog("Selected " ModeDropdown.Text " mode")
        ReturnLobbyBox.Visible := true
    }

    AddToLog("Don't forget to enable Click to Move and UI Navigation!")

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    global confirmClicked := true
}


FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

OpenGithub() {
    Run("https://github.com/itsRynsRoblox?tab=repositories")
}

OpenDiscord() {
    Run("https://discord.gg/mistdomain")
}

ClickReturnToLobby() {
    ClickUntilGone(0, 0, 151, 433, 655, 469, ReturnToLobbyText, 0, -35)
}

ClickNextRoom() {
    ClickUntilGone(0, 0, 151, 433, 655, 469, ReturnToLobbyText, -420, -35)
}

ClickReplay() {
    ClickUntilGone(0, 0, 151, 433, 655, 469, ReturnToLobbyText, -150, -35)
}

ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)  
        } else {
            FixClick(x, y) 
        }
        Sleep(1000)
    }
}

RightClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY, "Right")  
        } else {
            FixClick(x, y, "Right") 
        }
        Sleep(1000)
    }
}

SetGameSpeed() {
    if (ModeDropdown.Text = "Story") {
        AddToLog("Setting game speed to 3x")
        loop 3 {
            FixClick(588, 553) ; Click Game Speed
            Sleep(300)
        }
    }
}

ClickWhileWaiting() {
    Loop 10 {
        FixClick(400, 495)
        Sleep(500)
        if CheckForReturnToLobby() {
            break
        }
    }
}

CloseChat() {
    if (ok := FindText(&X, &Y, 123, 50, 156, 79, 0, 0, OpenChat)) {
        AddToLog "Closing Chat"
        FixClick(138, 30) ;close chat
    }
}

BasicSetup(replay := false) {
    if (!replay) {
        SendInput("{Tab}") ; Closes Player leaderboard
        Sleep 300
        FixClick(564, 72) ; Closes Player leaderboard
        Sleep 300
        CloseChat()
        Sleep 1500
        ;ChangeSpeed()
        Sleep 1500
        Zoom()
        Sleep 1500
    }
    ;CheckForVoteScreen()
    Sleep 300
}

SetModulationModifier() {
    if (ModeDropdown.Text = "Story") {
        FixClick(378, 465)
    } else {
        FixClick(392, 432) ; Open Modifier
    }
    Sleep(500)
    FixClick(343, 330) ; Click Modifier Box
    Sleep(500)
    Send(modulationEdit.Value) ; Enter Modifier
    Sleep(500)
    FixClick(400, 420) ; Confirm Modifier
    Sleep(500)
}

ChangeSpeed() {
    if (ModeDropdown.Text = "Story") {
        if (StoryActDropdown.Text = "Infinity") {
            loop 3 {
                FixClick(585, 550)
                Sleep (500)
            }
        } else {
            loop 2 {
                FixClick(585, 550)
                Sleep (500)
            }
        }
    } else {
        loop 2 {
            FixClick(585, 550)
            Sleep (500)
        }
    }
}

Reconnect() {   
    ; Check for Disconnected Screen using FindText
    if (ok := FindText(&X, &Y, 450, 410, 539, 427, 0, 0, Disconnect)) {
        AddToLog("Lost Connection! Attempting To Reconnect To Private Server...")

        psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

        ; Reconnect to Ps
        if FileExist("Settings\PrivateServer.txt") && (psLink := FileRead("Settings\PrivateServer.txt", "UTF-8")) {
            AddToLog("Connecting to private server...")
            Run(psLink)
        } else {
            Run("roblox://placeID=16347800591")
        }

        Sleep(5000)  

        loop {
            AddToLog("Reconnecting to Roblox...")
            Sleep(15000)

            if WinExist(rblxID) {
            forceRobloxSize()
            moveRobloxWindow()
            Sleep(1000)
            }
            
            if (ok := FindText(&X, &Y, 746, 514, 789, 530, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                return StartSelectedMode()
            } else {
                Reconnect() 
            }
        }
    }
}