#Include %A_ScriptDir%\Lib\GUI.ahk
global settingsFile := "" 


setupFilePath() {
    global settingsFile
    
    if !DirExist(A_ScriptDir "\Settings") {
        DirCreate(A_ScriptDir "\Settings")
    }

    settingsFile := A_ScriptDir "\Settings\Configuration.txt"
    return settingsFile
}

readInSettings() {
    global mode

    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6

    global PlacementPatternDropdown, PlaceSpeed, ReturnLobbyBox, PlacementProfiles, PriorityUpgrade, modulationEdit
    global savedCoords

    try {
        settingsFile := setupFilePath()
        if !FileExist(settingsFile) {
            return
        }

        content := FileRead(settingsFile)
        lines := StrSplit(content, "`n")

        savedCoords := []  ; Ensure it's initialized
        isReadingCoords := false  ; Track if we are in the [SavedCoordinates] section
        currentPreset := 0  ; Track the current preset
        
        for line in lines {
            if line = "" {
                continue
            }
        
            parts := StrSplit(line, "=")
        
            ; Check if we're entering the [SavedCoordinates] section
            if (line = "[SavedCoordinates]") {
                isReadingCoords := true
                continue  ; Skip this line
            }
        
            ; If in [SavedCoordinates] section, parse coordinates
            if (isReadingCoords) {
                ; Check for a new preset start line (e.g., [Preset 1], [Preset 2], etc.)
                if (RegExMatch(line, "^\[Preset (\d+)\]$")) {
                    currentPreset := RegExReplace(line, "^\[Preset (\d+)\]$", "$1")  ; Extract preset number
                    currentPreset := currentPreset + 0  ; Convert to integer
        
                    ; Ensure the correct index exists for the preset in savedCoords
                    while (savedCoords.Length < currentPreset) {
                        savedCoords.Push([])  ; Add empty list for new preset if needed
                    }
        
                    continue
                }
        
                ; If we encounter "NoCoordinatesSaved", reset the current preset's coordinates
                if (line = "NoCoordinatesSaved") {
                    savedCoords[currentPreset] := []  ; Clear coordinates for the current preset
                    continue
                }
        
                ; Extract X and Y values from "X=val, Y=val" format
                coordParts := StrSplit(line, ", ")
                x := StrReplace(coordParts[1], "X=")  ; Remove "X="
                y := StrReplace(coordParts[2], "Y=")  ; Remove "Y="
        
                ; Store the coordinates for the current preset
                savedCoords[currentPreset].Push({x: x, y: y})  ; Push to the correct preset index
            }
            
            switch parts[1] {
                case "Mode": mode := parts[2]
                case "Enabled1": enabled1.Value := parts[2]
                case "Enabled2": enabled2.Value := parts[2]
                case "Enabled3": enabled3.Value := parts[2]
                case "Enabled4": enabled4.Value := parts[2]
                case "Enabled5": enabled5.Value := parts[2]
                case "Enabled6": enabled6.Value := parts[2]
                case "Placement1": placement1.Text := parts[2]
                case "Placement2": placement2.Text := parts[2]
                case "Placement3": placement3.Text := parts[2]
                case "Placement4": placement4.Text := parts[2]
                case "Placement5": placement5.Text := parts[2]
                case "Placement6": placement6.Text := parts[2]
                case "UpgradeEnabled1": upgradeEnabled1.Value := parts[2]
                case "UpgradeEnabled2": upgradeEnabled2.Value := parts[2]
                case "UpgradeEnabled3": upgradeEnabled3.Value := parts[2]
                case "UpgradeEnabled4": upgradeEnabled4.Value := parts[2]
                case "UpgradeEnabled5": upgradeEnabled5.Value := parts[2]
                case "UpgradeEnabled6": upgradeEnabled6.Value := parts[2]
                case "Priority1": priority1.Text := parts[2]
                case "Priority2": priority2.Text := parts[2]
                case "Priority3": priority3.Text := parts[2]
                case "Priority4": priority4.Text := parts[2]
                case "Priority5": priority5.Text := parts[2]
                case "Priority6": priority6.Text := parts[2]
                case "Speed": PlaceSpeed.Value := parts[2] ; Set the dropdown value
                case "Profile": PlacementProfiles.Value := parts[2]
                case "Logic": PlacementPatternDropdown.Value := parts[2] ; Set the dropdown value
                case "Lobby": ReturnLobbyBox.Value := parts[2] ; Set the checkbox value
                case "Upgrade": PriorityUpgrade.Value := parts[2] ; Set the checkbox value
                case "Value": modulationEdit.Value := parts[2] ; Set the checkbox value


            }
        }
        AddToLog("✅ Settings loaded successfully!")
    } 
}


SaveSettings(*) {
    global mode

    global enabled1, enabled2, enabled3, enabled4, enabled5, enabled6
    global placement1, placement2, placement3, placement4, placement5, placement6
    global priority1, priority2, priority3, priority4, priority5, priority6
    global upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6

    global PlacementPatternDropdown, PlaceSpeed, ReturnLobbyBox, PlacementProfiles, PriorityUpgrade, modulationEdit
    global savedCoords
    try {
        settingsFile := A_ScriptDir "\Settings\Configuration.txt"
        if FileExist(settingsFile) {
            FileDelete(settingsFile)
        }

        ; Save mode and map selection
        content := "Mode=" mode "`n"
        
        ; Save settings for each unit
        content .= "`n[EnabledUnits]"
        content .= "`nEnabled1=" enabled1.Value
        content .= "`nEnabled2=" enabled2.Value
        content .= "`nEnabled3=" enabled3.Value
        content .= "`nEnabled4=" enabled4.Value
        content .= "`nEnabled5=" enabled5.Value
        content .= "`nEnabled6=" enabled6.Value

        content .= "`n`n[Placements]"
        content .= "`nPlacement1=" placement1.Text
        content .= "`nPlacement2=" placement2.Text
        content .= "`nPlacement3=" placement3.Text
        content .= "`nPlacement4=" placement4.Text
        content .= "`nPlacement5=" placement5.Text
        content .= "`nPlacement6=" placement6.Text

        content .= "`n`n[UpgradePriority]"
        content .= "`nPriority1=" priority1.Text
        content .= "`nPriority2=" priority2.Text
        content .= "`nPriority3=" priority3.Text
        content .= "`nPriority4=" priority4.Text
        content .= "`nPriority5=" priority5.Text
        content .= "`nPriority6=" priority6.Text

        content .= "`n`n[Place&Upgrade]"
        content .= "`nUpgradeEnabled1=" upgradeEnabled1.Value
        content .= "`nUpgradeEnabled2=" upgradeEnabled2.Value
        content .= "`nUpgradeEnabled3=" upgradeEnabled3.Value
        content .= "`nUpgradeEnabled4=" upgradeEnabled4.Value
        content .= "`nUpgradeEnabled5=" upgradeEnabled5.Value
        content .= "`nUpgradeEnabled6=" upgradeEnabled6.Value

        content .= "`n`n[PlacementLogic]"
        content .= "`nLogic=" PlacementPatternDropdown.Value "`n"

        content .= "`n[PlaceSpeed]"
        content .= "`nSpeed=" PlaceSpeed.Value "`n"

        content .= "`n[PlacementProfile]"
        content .= "`nProfile=" PlacementProfiles.Value "`n"

        content .= "`n[ReturnToLobby]"
        content .= "`nLobby=" ReturnLobbyBox.Value "`n"

        content .= "`n[PriorityUpgrade]"
        content .= "`nUpgrade=" PriorityUpgrade.Value "`n"

        content .= "`n[Modulation]"
        content .= "`nValue=" modulationEdit.Value "`n"

        ; Save the stored coordinates
        content .= "`n[SavedCoordinates]`n"

        ; Iterate through each preset in savedCoords
        if (IsSet(savedCoords) && savedCoords.Length > 0) {
            ; Iterate through each preset (preset index starts from 1)
            for presetIndex, coords in savedCoords {
                content .= Format("[Preset {1}]`n", presetIndex)  ; Add preset header
                if (coords.Length > 0) {
                    ; Save each coordinate pair for the preset
                    for coord in coords {
                        content .= Format("X={1}, Y={2}`n", coord.x, coord.y)
                    }
                } else {
                    content .= "NoCoordinatesSaved`n"  ; If no coordinates for the preset
                }
            }
        }
        
        FileAppend(content, settingsFile)
        AddToLog("✅ Settings saved successfully!")
    }
}

SaveKeybindSettings(*) {
    AddToLog("Saving Keybind Configuration")
    
    if FileExist("Settings\Keybinds.txt")
        FileDelete("Settings\Keybinds.txt")
        
    FileAppend(Format("F1={}`nF2={}`nF3={}`nF4={}", F1Box.Value, F2Box.Value, F3Box.Value, F4Box.Value), "Settings\Keybinds.txt", "UTF-8")
    
    ; Update globals
    global F1Key := F1Box.Value
    global F2Key := F2Box.Value
    global F3Key := F3Box.Value
    global F4Key := F4Box.Value
    
    ; Update hotkeys
    Hotkey(F1Key, (*) => moveRobloxWindow())
    Hotkey(F2Key, (*) => StartMacro())
    Hotkey(F3Key, (*) => Reload())
    Hotkey(F4Key, (*) => TogglePause())
}

LoadKeybindSettings() {
    if FileExist("Settings\Keybinds.txt") {
        fileContent := FileRead("Settings\Keybinds.txt", "UTF-8")
        Loop Parse, fileContent, "`n" {
            parts := StrSplit(A_LoopField, "=")
            if (parts[1] = "F1")
                global F1Key := parts[2]
            else if (parts[1] = "F2")
                global F2Key := parts[2]
            else if (parts[1] = "F3")
                global F3Key := parts[2]
            else if (parts[1] = "F4")
                global F4Key := parts[2]
        }
    }
}