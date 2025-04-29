#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount
global currentMap := ""

LoadKeybindSettings()  ; Load saved keybinds
;CheckForUpdates()
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5:: {

}

F6:: {
    CopyMouseCoords()
}

F7::{
    Run (A_ScriptDir "\Lib\FindText.ahk")
}


StartMacro(*) {
    if (!ValidateMode()) {
        return
    }
    StartSelectedMode()
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddToLog("Macro Paused")
        Sleep(1000)
    } else {
        AddToLog("Macro Resumed")
        Sleep(1000)
    }
}

CheckForReturnToLobby() {
    ; Check for return to lobby text
    if (ok := FindText(&X, &Y, 151, 433, 655, 469, 0.10, 1, ReturnToLobbyText)) {
        return true
    }
    return false
}

CheckForUnitManager() {
    ; Check for unit manager text
    if (ok := FindText(&X, &Y, 768, 286, 785, 314, 0.05, 0.10, UnitManager)) {
        return true
    }
    return false
}

PlacingUnits(untilSuccessful := true) {
    global successfulCoordinates, maxedCoordinates
    successfulCoordinates := []
    maxedCoordinates := []
    placedCounts := Map()  

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        AddToLog("No units enabled - skipping to monitoring")
        return MonitorStage()
    }

    placementPoints := PlacementPatternDropdown.Text = "Custom" ? UseCustomPoints() : PlacementPatternDropdown.Text = "Circle" ? GenerateCirclePoints() : PlacementPatternDropdown.Text = "Grid" ? GenerateGridPoints() : PlacementPatternDropdown.Text = "Spiral" ? GenerateSpiralPoints() : PlacementPatternDropdown.Text = "Up and Down" ? GenerateUpandDownPoints() : GenerateRandomPoints()

    ; Go through each slot
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value

        ; Get number of placements wanted for this slot
        placements := "placement" slotNum
        placements := %placements%
        placements := Integer(placements.Text)

        ; Initialize count if not exists
        if !placedCounts.Has(slotNum)
            placedCounts[slotNum] := 0

        ; If enabled, place all units for this slot
        if (enabled && placements > 0) {
            AddToLog("Placing Unit " slotNum " (0/" placements ")")
            
            for point in placementPoints {
                ; Skip if this coordinate was already used successfully
                alreadyUsed := false
                for coord in successfulCoordinates {
                    if (coord.x = point.x && coord.y = point.y) {
                        alreadyUsed := true
                        break
                    }
                }
                for coord in maxedCoordinates {
                    if (coord.x = point.x && coord.y = point.y) {
                        alreadyUsed := true
                        break
                    }
                }
                if (alreadyUsed)
                    continue

                ; If untilSuccessful is false, try once and move on
                if (!untilSuccessful) {
                    if (placedCounts[slotNum] < placements) {
                        if PlaceUnit(point.x, point.y, slotNum) {
                            successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                            placedCounts[slotNum] += 1
                            AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                            FixClick(700, 560) ; Move Click
                            AttemptUpgrade()
                        }
                        AttemptUpgrade()
                    }
                }
                ; If untilSuccessful is true, keep trying the same point until it works
                else {
                    while (placedCounts[slotNum] < placements) {
                        if PlaceUnit(point.x, point.y, slotNum) {
                            successfulCoordinates.Push({x: point.x, y: point.y, slot: slotNum})
                            placedCounts[slotNum] += 1
                            AddToLog("Placed Unit " slotNum " (" placedCounts[slotNum] "/" placements ")")
                            FixClick(700, 560) ; Move Click
                            AttemptUpgrade()
                            break ; Move to the next placement spot
                        }
                        AttemptUpgrade()

                        if (CheckGameOver()) {
                            return MonitorStage()
                        }

                        Reconnect()
                        Sleep(500) ; Prevents spamming clicks too fast
                    }
                }

                if (CheckGameOver()) {
                    return MonitorStage()
                }
            }
        }
    }
    AddToLog("All units placed to requested amounts")
    UpgradeUnits()
}

AttemptUpgrade() {
    global successfulCoordinates, maxedCoordinates

    if (successfulCoordinates.Length = 0) {
        return ; No units placed yet
    }

    anyEnabled := false
    for slotNum in [1, 2, 3, 4, 5, 6] {
        enabled := "upgradeEnabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            anyEnabled := true
            break
        }
    }

    if (!anyEnabled) {
        if (debugMessages) {
            AddToLog("No units enabled - skipping")
        }
        return
    }

    unitsToRemove := []  ; Store units that reach max level

    if (PriorityUpgrade.Value) {
        if (debugMessages) {
            AddToLog("Using priority-based upgrading")
        }

        ; Loop through priority levels (1-6) and upgrade all matching units
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            upgradedThisRound := false

            for index, coord in successfulCoordinates { 
                ; Check if upgrading is enabled for this unit's slot
                upgradeEnabled := "upgradeEnabled" coord.slot
                upgradeEnabled := %upgradeEnabled%
                if (!upgradeEnabled.Value) {
                    if (debugMessages) {
                        AddToLog("Skipping Unit " coord.slot " - Upgrading Disabled")
                    }
                    continue
                }

                ; Get the priority value for this unit's slot
                priority := "priority" coord.slot
                priority := %priority%

                if (priority.Text = priorityNum) {
                    if (debugMessages) {
                        AddToLog("Upgrading Unit " coord.slot " at (" coord.x ", " coord.y ")")
                    }
                    UpgradeUnit(coord.x, coord.y)

                    if MaxUpgrade() {
                        AddToLog("Max upgrade reached for Unit " coord.slot)
                        successfulCoordinates.RemoveAt(index)
                        maxedCoordinates.Push(coord)
                        FixClick(740, 545) ; Click away from unit
                        continue
                    }

                    if (CheckGameOver()) {
                        AddToLog("Stage ended during upgrades, proceeding to results")
                        successfulCoordinates := []
                        maxedCoordinates := []
                        return MonitorStage()
                    }

                    Sleep(200)
                    FixClick(740, 545) ; Click away from unit
                    Reconnect()

                    upgradedThisRound := true
                }
            }

            if upgradedThisRound {
                Sleep(300) ; Add a slight delay between batches
            }
        }
    } else {
        ; Normal (non-priority) upgrading - upgrade all available units
        for index, coord in successfulCoordinates {
            ; Check if upgrading is enabled for this unit's slot
            upgradeEnabled := "upgradeEnabled" coord.slot
            upgradeEnabled := %upgradeEnabled%
            if (!upgradeEnabled.Value) {
                if (debugMessages) {
                    AddToLog("Skipping Unit " coord.slot " - Upgrading Disabled")
                }
                continue
            }

            if (debugMessages) {
                AddToLog("Upgrading Unit " coord.slot " at (" coord.x ", " coord.y ")")
            }
            UpgradeUnit(coord.x, coord.y)

            if MaxUpgrade() {
                AddToLog("Max upgrade reached for Unit " coord.slot)
                successfulCoordinates.RemoveAt(index)
                maxedCoordinates.Push(coord)
                FixClick(740, 545) ; Click away from unit
                continue
            }

            if (CheckGameOver()) {
                AddToLog("Stage ended during upgrades, proceeding to results")
                successfulCoordinates := []
                maxedCoordinates := []
                return MonitorStage()
            }

            Sleep(200)
            FixClick(740, 545) ; Click away from unit
            Reconnect()
        }
    }
    if (debugMessages) {
        AddToLog("Upgrade attempt completed")
    }
}

UpgradeUnits() {
    global successfulCoordinates

    totalUnits := Map()    
    upgradedCount := Map()  
    
    ; Initialize counters
    for coord in successfulCoordinates {
        if (!totalUnits.Has(coord.slot)) {
            totalUnits[coord.slot] := 0
            upgradedCount[coord.slot] := 0
        }
        totalUnits[coord.slot]++
    }

    AddToLog("Initiating Unit Upgrades...")

    if (PriorityUpgrade.Value) {
        AddToLog("Using priority upgrade system")
        
        ; Go through each priority level (1-6)
        for priorityNum in [1, 2, 3, 4, 5, 6] {
            ; Find which slot has this priority number
            for slot in [1, 2, 3, 4, 5, 6] {
                priority := "priority" slot
                priority := %priority%
                if (priority.Text = priorityNum) {
                    ; Skip if no units in this slot
                    hasUnitsInSlot := false
                    for coord in successfulCoordinates {
                        if (coord.slot = slot) {
                            hasUnitsInSlot := true
                            break
                        }
                    }
                    
                    if (!hasUnitsInSlot) {
                        continue
                    }

                    AddToLog("Starting upgrades for priority " priorityNum " (slot " slot ")")
                    
                    ; Keep upgrading current slot until all its units are maxed
                    while true {
                        slotDone := true
                        
                        for index, coord in successfulCoordinates {
                            if (coord.slot = slot) {
                                slotDone := false
                                UpgradeUnit(coord.x, coord.y)

                                if (CheckGameOver()) {
                                    AddToLog("Stage ended during upgrades, proceeding to results")
                                    successfulCoordinates := []
                                    MonitorStage()
                                    return
                                }

                                if MaxUpgrade() {
                                    upgradedCount[coord.slot]++
                                    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
                                    successfulCoordinates.RemoveAt(index)
                                    FixClick(325, 185) ;Close upg menu
                                    break
                                }

                                Sleep(200)
                                FixClick(700, 560) ; Move Click
                                Reconnect()
                            }
                        }
                        
                        if (slotDone || successfulCoordinates.Length = 0) {
                            AddToLog("Finished upgrades for priority " priorityNum)
                            break
                        }
                    }
                }
            }
        }
        
        AddToLog("Priority upgrading completed")
        return MonitorStage()
    } else {
        ; Normal upgrade (no priority)
        while true {
            if (successfulCoordinates.Length == 0) {
                AddToLog("All units maxed, proceeding to monitor stage")
                return MonitorStage()
            }

            for index, coord in successfulCoordinates {
                UpgradeUnit(coord.x, coord.y)

                if (CheckGameOver()) {
                    AddToLog("Stage ended during upgrades, proceeding to results")
                    successfulCoordinates := []
                    MonitorStage()
                    return
                }

                if MaxUpgrade() {
                    upgradedCount[coord.slot]++
                    AddToLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot] "/" totalUnits[coord.slot] ")")
                    successfulCoordinates.RemoveAt(index)
                    FixClick(325, 185) ;Close upg menu
                    continue
                }

                Sleep(200)
                FixClick(700, 560) ; Move Click
                Reconnect()
            }
        }
    }
}

StoryMode() {
    global StoryDropdown, StoryActDropdown
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)

    FixClick(564, 204) ; Exit Daily Reward
    Sleep (1500)

    StoryMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 176, 261, 220, 281, 0.10, 0.10, StoryMaps)) {
        StoryMovement()
    }

    StartStory(currentStoryMap, currentStoryAct)
    StartMode()
    RestartStage(false)
}

LegendMode() {
    global LegendDropDown
    
    ; Get current map and act
    currentLegendStage := LegendDropDown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendStage)

    FixClick(564, 204) ; Exit Daily Reward
    Sleep (1500)

    LegendMovement()
    
    ; Start stage
    while !(ok:=FindText(&X, &Y, 183, 239, 228, 257, 0.10, 0.10, LegendMaps)) {
        LegendMovement()
    }

    StartLegend(currentLegendStage)
    StartMode()
    RestartStage(false)
}

RaidMode() {
    global RaidDropdown, RaidActDropdown
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)

    FixClick(564, 204) ; Exit Daily Reward
    Sleep (1500)

    RaidMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 195, 236, 235, 253, 0.10, 0.10, RaidMaps)) {
        RaidMovement()
    }

    StartRaid(currentRaidMap, currentRaidAct)
    StartMode()
    RestartStage(false)
}

CustomMode() {
    AddToLog("Starting Custom Mode")
    RestartCustomStage()
}

RestartCustomStage() {
    ; Wait for loading
    CheckLoaded()

    ; Check for vote screen and press start
    CheckForVoteScreen()

    ; Wait for game to actually start
    StartedGame()

    ; Begin unit placement and management
    PlacingUnits(PlacementPatternDropdown.Text == "Custom")
    
    ; Monitor stage progress
    MonitorStage()
}

HandleStoryMode() {
    global lastResult
    if (ReturnLobbyBox.Value) {
        ClickReturnToLobby()
        return CheckLobby()
    } else {
        if (lastResult "win" && NextLevelBox.Value) {
            ClickNextRoom()
        } else {
            ClickReplay()
        }
        return RestartStage(true)
    }
}

HandleTowerMode() {
    global lastResult
    if (lastResult = "loss") {
        ClickReturnToLobby()
        return CheckLobby()
    } else {
        ClickNextRoom()
        return RestartStage(true)
    }
}

HandleRaidMode() {
    if (ReturnLobbyBox.Value) {
        ClickReturnToLobby()
        return CheckLobby()
    } else {
        ClickReplay()
        return RestartStage(true)
    }
}

HandleDefaultMode() {
    if (ReturnLobbyBox.Value) {
        ClickReturnToLobby()
        return CheckLobby()
    } else {
        ClickReplay()
    }
    if (ModeDropdown.Text = "Custom") {
        return RestartCustomStage()
    }
    return RestartStage(true)
}

MonitorStage() {
    global Wins, loss, mode, StoryActDropdown

    lastClickTime := A_TickCount
    
    Loop {
        Sleep(1000)

        Reconnect()

        while !CheckGameOver() {
            ClickWhileWaiting()
        }
        
        AddToLog("Checking win/loss status")
        stageEndTime := A_TickCount
        stageLength := FormatStageTime(stageEndTime - stageStartTime)

        if (ok := FindText(&X, &Y, 144, 171, 355, 203, 0, 0, DefeatText)) {
            AddToLog("Defeat detected - Stage Length: " stageLength)
            isWin := false
            loss += 1
        }
    
        if (ok := FindText(&X, &Y, 144, 171, 355, 203, 0.10, 0.10, VictoryText)) {
            AddToLog("Victory detected - Stage Length: " stageLength)
            isWin := true
            Wins += 1
        }

        SendWebhookWithTime(true, stageLength)

        if (ModeDropdown.Text = "Story") {
            HandleStoryMode()
        } else if (ModeDropdown.Text = "Raid") {
            HandleRaidMode()
        } else if (ModeDropdown.Text = "Tower") {
            HandleTowerMode()
        } else {
            HandleDefaultMode()
        }
        return
    }
}

StoryMovement() {
    ; Click Play
    FixClick(30, 300)
    Sleep (2000)
    ;Walk To Room
    SendInput ("{w down}")
    Sleep (3500)
    SendInput ("{w up}")
    KeyWait "w"
    Sleep (1000)
    SendInput ("{d down}")
    Sleep (5600)
    SendInput ("{d up}")
    KeyWait "d"
    Sleep (1000)
    SendInput ("{s down}")
    Sleep (2000)
    SendInput ("{s up}")
    KeyWait "w"
    Sleep (1000)
}

LegendMovement() {
    ; Click Play
    FixClick(30, 300)
    Sleep (2000)
    ;Walk To Room
    SendInput ("{w down}")
    Sleep (3500)
    SendInput ("{w up}")
    KeyWait "w"
    Sleep (1000)
    SendInput ("{a down}")
    Sleep (5800)
    SendInput ("{a up}")
    KeyWait "a"
    Sleep (1000)
    SendInput ("{s down}")
    Sleep (2000)
    SendInput ("{s up}")
    KeyWait "w"
    Sleep (1000)
}

RaidMovement() {
    ; Click Play
    FixClick(30, 300)
    Sleep (2000)
    ;Walk To Room
    SendInput ("{w down}")
    Sleep (11000)
    SendInput ("{w up}")
    KeyWait "w"
    Sleep (1000)
    SendInput ("{a down}")
    Sleep (8000)
    SendInput ("{a up}")
    KeyWait "a"
    Sleep (1000)
    SendInput ("{s down}")
    Sleep (4000)
    SendInput ("{s up}")
    KeyWait "w"
    Sleep (1000)
}

StartStory(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

    ; Get Story map 
    StoryMap := GetMapData("StoryMap", map)
    
    ; Scroll if needed
    if (StoryMap.scrolls > 0) {
        AddToLog("Scrolling down " StoryMap.scrolls " for " map)
        MouseMove(255, 280)
        loop StoryMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)
    
    ; Get act details
    StoryAct := GetMapData("StoryAct", act)
    
    ; Scroll if needed for act
    if (StoryAct.scrolls > 0) {
        AddToLog("Scrolling down " StoryAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop StoryAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(StoryAct.x, StoryAct.y)
    Sleep(1000)

    if (HardModeBox.Value) {
        FixClick(590, 380) ; Click Hard Mode
        Sleep(1000)
    }

    if (act != "Infinity") {
        SetModulationModifier()
    }
    return true
}

StartRaid(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

    RaidMap := GetMapData("RaidMap", map)
    
    if (RaidMap.scrolls > 0) {
        AddToLog("Scrolling down " RaidMap.scrolls " for " map)
        MouseMove(300, 240)
        loop RaidMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    FixClick(RaidMap.x, RaidMap.y)
    Sleep(1000)
    
    SetModulationModifier()
    return true
}

StartLegend(map) {
    AddToLog("Selecting map: " map)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

    LegendMap := GetMapData("LegendMap", map)
    
    ; Scroll if needed
    if (LegendMap.scrolls > 0) {
        AddToLog("Scrolling down " LegendMap.scrolls " for " map)
        MouseMove(210, 260)
        loop LegendMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(LegendMap.x, LegendMap.y)
    Sleep(1000)

    SetModulationModifier()
    return true
}

StartChallenge() {
    FixClick(640, 70)
    Sleep(500)
}

StartMode() {
    if (ModeDropdown.Text = "Story") {
        FixClick(575, 445)
    }
    else if (ModeDropdown.Text = "Raid") {
        FixClick(560, 410)
    } else {
        FixClick(570, 430)
    }
    Sleep (500)
    if (ModeDropdown.Text = "Story") {
        FixClick(155, 475) ; Click Start
    } else {
        FixClick(460, 415) ; Click Start
    }
    Sleep (500)
}

Zoom() {
    MouseMove(400, 300)
    Sleep 100
    FixClick(400, 300)
    Sleep 100
    ; Zoom in smoothly
    Loop 12 {
        Send "{WheelUp}"
        Sleep 50
    }

    ; Look down
    Click
    MouseMove(400, 400)  ; Move mouse down to angle camera down
    
    ; Zoom back out smoothly
    Loop 12 {
        Send "{WheelDown}"
        Sleep 50
    }
    
    ; Move mouse back to center
    MouseMove(400, 300)
}

DetectMap() {
    AddToLog("Waiting for map...")
    startTime := A_TickCount
    
    Loop {
        ; Check if we waited more than 5 minute for votestart
        if (A_TickCount - startTime > 300000) {
            if (ok := FindText(&X, &Y, 1, 264, 53, 304, 0, 0, AreaText)) {
                AddToLog("Found in lobby - restarting selected mode")
                return StartSelectedMode()
            }
            AddToLog("Could not detect map after 5 minutes - proceeding without movement")
            return "no map found"
        }

        if (ModeDropdown.Text = "Story") {
            AddToLog("Map detected: " StoryDropdown.Text)
            return StoryDropdown.Text
        } else if (ModeDropdown.Text = "Legend") {
            AddToLog("Map detected: " LegendDropDown.Text)
            return LegendDropDown.Text
        } else if (ModeDropdown.Text = "Raid") {
            AddToLog("Map detected: " RaidDropdown.Text)
            return RaidDropdown.Text
        } else if (ModeDropdown.Text = "Tower") {
            AddToLog("Map detected: Leveling Tower")
            return "Leveling Tower"
        }        

        ; Check for Unit Manager
        if (ok := CheckForUnitManager()) {
            AddToLog("No map was found")
            return "no map found"
        }

        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {

    }
}

RestartStage(seamless := false) {
    global currentMap

    if (currentMap = "") {
        currentMap := DetectMap()
    }
    
    ; Wait for loading
    CheckLoaded()

    ; Do initial setup and map-specific movement during vote timer
    if (!seamless) {
        BasicSetup(false)
        if (currentMap != "no map found") {
            HandleMapMovement(currentMap)
        }
    } else {
        BasicSetup(true)
        AddToLog("Game supports seamless replay, skipping setup")
    }

    ; Wait for game to actually start
    StartedGame()

    ; Begin unit placement and management
    PlacingUnits(PlacementPatternDropdown.Text == "Custom")
    
    ; Monitor stage progress
    MonitorStage()
}

PlaceUnit(x, y, slot := 1) {
    SendInput(slot)
    Sleep 50
    FixClick(x, y)
    Sleep 50
    SendInput("q")
    Sleep 500
    if UnitPlaced() {
        Sleep 15
        return true
    }
    return false
}

ClickUnit(x, y) {
    FixClick(x, y)
    Sleep 50
    return UnitPlaced()
}

MaxUpgrade() {
    Sleep 500
    ; Check for max text
    if (ok := FindText(&X, &Y, 89, 300, 181, 315, 0, 0, MaxUpgraded)) {
        return true
    }
    return false
}

UnitPlaced() {
    if (WaitForUpgradeText(PlacementSpeed())) { ; Wait up to 4.5 seconds for the upgrade text to appear
        AddToLog("Unit Placed Successfully")
        FixClick(325, 185) ; Close upgrade menu
        return true
    }
    return false
}

WaitForUpgradeText(timeout := 4500) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (FindText(&X, &Y, 88, 301, 187, 315, 0.10, 0.10, UpgradeText)) {
            return true
        }
        Sleep 100  ; Check every 100ms
    }
    return false  ; Timed out, upgrade text was not found
}

UpgradeUnit(x, y) {
    FixClick(x, y + 3)
    SendInput ("{T}")
    SendInput ("{T}")
    SendInput ("{T}")
}

CheckLobby() {
    global currentMap
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 1, 264, 53, 304, 0, 0, AreaText)) {
            break
        }
        Reconnect()
    }
    currentMap := ""
    AddToLog("Returned to lobby, restarting selected mode")
    return StartSelectedMode()
}

CheckLoaded() {
    loop {
        Sleep(1000)
        ; Check for unit manager
        if (ok := CheckForUnitManager()) {
            AddToLog("Game loaded")
            break
        }
        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(1000)
        AddToLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

StartSelectedMode() {
    if (ModeDropdown.Text = "Story") {
        ;CustomMode()
        StoryMode()
    }
    else if (ModeDropdown.Text = "Legend") {
        LegendMode()
        ;RaidMode()
    }
    else if (ModeDropdown.Text = "Raid") {
        CustomMode()
        ;RaidMode()
    }
    else if (ModeDropdown.Text = "Tower") {
        CustomMode()
        ;RaidMode()
    }
    else if (ModeDropdown.Text = "Custom") {
        CustomMode()
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)
    
    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)
    
    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before starting the macro!")
        return false
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

GetNavKeys() {
    return StrSplit(FileExist("Settings\UINavigation.txt") ? FileRead("Settings\UINavigation.txt", "UTF-8") : "\,#,}", ",")
}

CheckForVoteScreen() {
    if (ok:=FindText(&X, &Y, 633, 182, 729, 233, 0, 0, VoteScreen)) {
          AddToLog("Found Vote Screen")
          FixClick(659, 190)
          FixClick(659, 190)
          FixClick(659, 190)
          return true
    }
    return false
}

PlacementSpeed() {
    speeds := [1000, 1500, 2000, 2500, 3000, 4000]  ; Array of sleep values
    speedIndex := PlaceSpeed.Value  ; Get the selected speed value

    if speedIndex is number  ; Ensure it's a number
        return speeds[speedIndex]  ; Use the value directly from the array
}

GetMapData(type, name) {
    data := Map(
        "StoryMap", Map(
            "Green Planet", {x: 250, y: 280, scrolls: 0},
            "Ghoul City", {x: 250, y: 325, scrolls: 0},
            "Sharkman Island", {x: 250, y: 365, scrolls: 0},
            "Hidden Village", {x: 250, y: 405, scrolls: 0},
            "Fairy Town", {x: 250, y: 320, scrolls: 1},
            "Cursed Town", {x: 250, y: 360, scrolls: 1},
            "Corp City", {x: 250, y: 405, scrolls: 1},
            "Soul World", {x: 250, y: 360, scrolls: 2},
            "Strongest City", {x: 250, y: 405, scrolls: 2}
        ),
        "StoryAct", Map(
            "Act 1", {x: 395, y: 270, scrolls: 0},
            "Act 2", {x: 395, y: 290, scrolls: 0},
            "Act 3", {x: 395, y: 315, scrolls: 0},
            "Act 4", {x: 395, y: 335, scrolls: 0},
            "Act 5", {x: 395, y: 360, scrolls: 0},
            "Act 6", {x: 395, y: 385, scrolls: 0},
            "Infinity", {x: 395, y: 405, scrolls: 0}
        ),
        "LegendMap", Map(
            "Hell", {x: 260, y: 250, scrolls: 0},
            "Shadow City", {x: 260, y: 300, scrolls: 0}
        ),
        "RaidMap", Map(
            "Green Planet", {x: 250, y: 245, scrolls: 0},
            "Hollow Desert", {x: 250, y: 290, scrolls: 0},
            "Red Palace", {x: 250, y: 335, scrolls: 0},
            "Sorcery Academy", {x: 250, y: 375, scrolls: 0},

            "Lookout", {x: 250, y: 275, scrolls: 1},
            "Slayers District", {x: 250, y: 325, scrolls: 1},
            "Underground Tomb", {x: 250, y: 365, scrolls: 1},

            "Boru's Room", {x: 250, y: 285, scrolls: 2},
            "Candy Park", {x: 250, y: 325, scrolls: 2},
            "Aura Room", {x: 250, y: 365, scrolls: 2}
        ),
        "RaidAct", Map(
            "Act 1", {x: 380, y: 245, scrolls: 0},
            "Act 2", {x: 380, y: 275, scrolls: 0},
            "Act 3", {x: 380, y: 305, scrolls: 0},
            "Act 4", {x: 380, y: 335, scrolls: 0},
            "Act 5", {x: 380, y: 365, scrolls: 0},
            "Act 6", {x: 380, y: 395, scrolls: 0}
        )
    )

    return data.Has(type) && data[type].Has(name) ? data[type][name] : {}
}

CheckGameOver() {
    if (ok := FindText(&X, &Y, 453, 202, 627, 228, 0.10, 0.10, XP)) {
        return true
    }
}