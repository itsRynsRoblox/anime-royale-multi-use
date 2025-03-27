#Requires AutoHotkey v2.0
#Include Image.ahk
global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

LoadKeybindSettings()  ; Load saved keybinds
;CheckForUpdates()
Hotkey(F1Key, (*) => moveRobloxWindow())
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5:: {

}

F6:: {

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
    if (ok := FindText(&X, &Y, 136, 420, 565, 465, 0, 0, ReturnToLobby)) {
        return true
    }
    return false
}

CheckForUnitManager() {
    ; Check for unit manager text
    if (ok := FindText(&X, &Y, 701, 318, 784, 344, 0.10, 0.10, UnitManager)) {
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

    placementPoints := PlacementPatternDropdown.Text = "Custom" ? GenerateCustomPoints() : PlacementPatternDropdown.Text = "Circle" ? GenerateCirclePoints() : PlacementPatternDropdown.Text = "Grid" ? GenerateGridPoints() : PlacementPatternDropdown.Text = "Spiral" ? GenerateSpiralPoints() : PlacementPatternDropdown.Text = "Up and Down" ? GenerateUpandDownPoints() : GenerateRandomPoints()

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
                        if CheckForReturnToLobby()
                            return MonitorStage()

                        Reconnect()
                        CheckEndAndRoute()
                        Sleep(500) ; Prevents spamming clicks too fast
                    }
                }

                if CheckForReturnToLobby()
                    return MonitorStage()
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

                    if CheckForReturnToLobby() {
                        AddToLog("Stage ended during upgrades, proceeding to results")
                        successfulCoordinates := []
                        maxedCoordinates := []
                        return MonitorStage()
                    }

                    Sleep(200)
                    FixClick(740, 545) ; Click away from unit
                    Reconnect()
                    CheckEndAndRoute()

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

            if CheckForReturnToLobby() {
                AddToLog("Stage ended during upgrades, proceeding to results")
                successfulCoordinates := []
                maxedCoordinates := []
                return MonitorStage()
            }

            Sleep(200)
            FixClick(740, 545) ; Click away from unit
            Reconnect()
            CheckEndAndRoute()
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

                                if CheckForReturnToLobby() {
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
                                FixClick(560, 560) ; Move Click
                                Reconnect()
                                CheckEndAndRoute()
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

                if CheckForReturnToLobby() {
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
                FixClick(560, 560) ; Move Click
                Reconnect()
                CheckEndAndRoute()
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
    while !(ok:=FindText(&X, &Y, 573, 485, 678, 514, 0, 0, SelectMode)) {
        StoryMovement()
    }

    AddToLog("Starting " currentStoryMap " - " currentStoryAct)
    StartStoryNoUI(currentStoryMap, currentStoryAct)

    ; Handle play mode selection
    PlayHere(true)
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
    while !(ok := FindText(&X, &Y, 551, 453, 640, 478, 0.10, 0.10, SelectRaid)) {
        RaidMovement()
    }

    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaidNoUI(currentRaidMap, currentRaidAct)
    ; Handle play mode selection
    PlayHere(true)
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

    ; Begin unit placement and management
    PlacingUnits(PlacementPatternDropdown.Text == "Custom")
    
    ; Monitor stage progress
    MonitorStage()
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

MonitorEndScreen() {
    global mode

    Loop {
        Sleep(3000)
        if (CheckForReturnToLobby()) {
            AddToLog("Found Lobby Text - Current Mode: " mode)
            Sleep(2000)



            if (mode = "Story") {
                HandleStoryMode()
            } else if (mode = "Raid") {
                HandleRaidMode()
            } else {
                HandleDefaultMode()
            }
            return
        }    
        Reconnect()
    }
}

HandleStoryMode() {
    AddToLog("Handling Story mode end")
    if (StoryActDropdown.Text != "Infinity") {
        ClickUntilGone(0, 0, 136, 420, 565, 465, ReturnToLobby, (NextLevelBox.Value && lastResult = "win") ? 250 : 100, -30)
    } else {
        AddToLog("Story Infinity replay")
        ClickUntilGone(0, 0, 136, 420, 565, 465, ReturnToLobby, 100, -30)
    }
    RestartStage(true)
}

HandleRaidMode() {
    AddToLog("Handling Raid end")
    ClickUntilGone(0, 0, 136, 420, 565, 465, ReturnToLobby, ReturnLobbyBox.Value ? 25 : 100, -30)
    if (ReturnLobbyBox.Value) {
        return CheckLobby()
    } else {
        return RestartStage(true)
    }
}

HandleDefaultMode() {
    AddToLog("Handling end case")
    ClickUntilGone(0, 0, 136, 420, 565, 465, ReturnToLobby, ReturnLobbyBox.Value ? 25 : 100, -30)
    if (ReturnLobbyBox.Value) {
         return CheckLobby()
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

        while !CheckForReturnToLobby() {  
            ClickThroughDrops()
        }
        
        AddToLog("Checking win/loss status")
        stageEndTime := A_TickCount
        stageLength := FormatStageTime(stageEndTime - stageStartTime)

        if (ok := FindText(&X, &Y, 15, 388, 84, 406, 0.10, 0.10, UnitExistence)) {
            SendInput("{X}")
        }

        if (ok := FindText(&X, &Y, 150, 180, 350, 260, 0, 0, DefeatText)) {
            AddToLog("Defeat detected - Stage Length: " stageLength)
            isWin := false
            loss += 1
        }
    
        if (ok := FindText(&X, &Y, 130, 183, 292, 211, 0.10, 0.10, VictoryText)) {
            AddToLog("Victory detected - Stage Length: " stageLength)
            isWin := true
            Wins += 1
        }

        SendWebhookWithTime(true, stageLength)

        return MonitorEndScreen()
    }
}

ClickThroughDrops() {
    if (debugMessages) {
        AddToLog("Clicking through item drops...")
    }
    Loop 10 {
        FixClick(400, 495)
        Sleep(500)
        if CheckForReturnToLobby() {
            break
        }
    }
}

StoryMovement() {
    ; Click Play
    FixClick(30, 300)
    Sleep (2000)
    ;Walk To Room
    SendInput ("{s down}")
    SendInput ("{d down}")
    Sleep (2500)
    SendInput ("{s up}")
    SendInput ("{d up}")
    Sleep (1000)
    SendInput ("{w down}")
    SendInput ("{d down}")
    Sleep (2500)
    SendInput ("{w up}")
    SendInput ("{d up}")
}

RaidMovement() {
    ; Click Play
    FixClick(763, 235)
    Sleep (2000)
    FixClick(526, 427)
    Sleep (2000)
    ;Walk To Room
    SendInput ("{a down}")
    Sleep (1700)
    SendInput ("{a up}")
    Sleep (1000)
    SendInput ("{w down}")
    Sleep (1200)
    SendInput ("{w up}")
    Sleep (1000)
    SendInput ("{a down}")
    Sleep (1100)
    SendInput ("{a up}")
    Sleep (1000)
    SendInput ("{w down}")
    Sleep (500)
    SendInput ("{w up}")
}

StartStory(map, StoryActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)

    FixClick(502, 465) ; Friends Only
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    leftArrows := 7 ; Go Over To Story
    Loop leftArrows {
        SendInput("{Left}")
        Sleep(200)
    }

    downArrows := GetStoryDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select storymode
    Sleep(500)

    SendInput("{Right}") ; Go to act selection
    Sleep(1000)
    SendInput("{Right}")
    Sleep(1000)
    
    actArrows := GetStoryActDownArrows(StoryActDropdown) ; Act selection down arrows
    if (mode = "Story" && StoryActDropdown = "Infinity") {
        FixClick(284,433)
        Sleep 200
    }
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

StartStoryNoUI(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)
    ; Get Story map 
    StoryMap := GetMapData("StoryMap", map)
    
    ; Scroll if needed
    if (StoryMap.scrolls > 0) {
        AddToLog("Scrolling down " StoryMap.scrolls " for " map)
        MouseMove(210, 260)
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
        FixClick(625, 390) ; Click Hard Mode
        Sleep(500)
    }

    if (act != "Infinity") {
        SetModulationModifier()
    }
    return true
}

StartRaidNoUI(map, act) {
    AddToLog("Selecting map: " map " and act: " act)
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)
    ; Get Story map 
    RaidMap := GetMapData("RaidMap", map)
    
    ; Scroll if needed
    if (RaidMap.scrolls > 0) {
        AddToLog("Scrolling down " RaidMap.scrolls " for " map)
        MouseMove(210, 260)
        loop RaidMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(RaidMap.x, RaidMap.y)
    Sleep(1000)
    
    ; Get act details
    RaidAct := GetMapData("RaidAct", act)
    
    ; Scroll if needed for act
    if (RaidAct.scrolls > 0) {
        AddToLog("Scrolling down " RaidAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop RaidAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(RaidAct.x, RaidAct.y)
    Sleep(1000)
    SetModulationModifier()
    return true
}

StartChallenge() {
    FixClick(640, 70)
    Sleep(500)
}

StartRaid(map, RaidActDropdown) {
    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)
    navKeys := GetNavKeys()
    for key in navKeys {
        SendInput("{" key "}")
    }
    Sleep(500)

    leftArrows := 7 ; Go Over To Story
    Loop leftArrows {
        SendInput("{Left}")
        Sleep(200)
    }

    downArrows := GetRaidDownArrows(map) ; Map selection down arrows
    Loop downArrows {
        SendInput("{Down}")
        Sleep(200)
    }

    SendInput("{Enter}") ; Select storymode
    Sleep(500)

    SendInput("{Right}") ; Go to act selection
    Sleep(1000)
    SendInput("{Right}")
    Sleep(1000)
    
    actArrows := GetRaidActDownArrows=(RaidActDropdown) ; Act selection down arrows
    Loop actArrows {
        SendInput("{Down}")
        Sleep(200)
    }
    
    SendInput("{Enter}") ; Select Act
    Sleep(500)
    for key in navKeys {
        SendInput("{" key "}")
    }
}

PlayHere(clickConfirm := true) {
    if (clickConfirm) {
        FixClick(620, 465) ; Click Confirm
        Sleep (1000)
    }
    FixClick(158, 473) ; Click Start
    Sleep (500)
}

GetStoryDownArrows(map) {
    switch map {
        case "Large Village": return 0
        case "Hollow Land": return 1
        case "Monster City": return 2
        case "Academy Demon": return 3
    }
}

GetStoryClickCoords(map) {
    switch map {
        case "Large Village": return { x: 235, y: 240 }
        case "Hollow Land": return { x: 235, y: 295 }
        case "Monster City": return { x: 235, y: 350 }
        case "Academy Demon": return { x: 235, y: 400 }
    }
}

GetStoryActClickCoords(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return { x: 380, y: 230 }
        case "Act 2": return { x: 380, y: 260 }
        case "Act 3": return { x: 380, y: 290 }
        case "Act 4": return { x: 380, y: 320 }
        case "Act 5": return { x: 380, y: 350 }
        case "Act 6": return { x: 380, y: 380 }
        case "Infinity": return { x: 380, y: 405 }
    }
}

GetRaidClickCoords(map) {
    switch map {
        case "Lawless City": return { x: 235, y: 240 }
        case "Temple": return { x: 235, y: 295 }
        case "Orc Castle": return { x: 235, y: 350 }
    }
}

GetRaidActClickCoords(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return { x: 380, y: 230 }
    }
}

GetStoryActDownArrows(StoryActDropdown) {
    switch StoryActDropdown {
        case "Act 1": return 0
        case "Act 2": return 1
        case "Act 3": return 2
        case "Act 4": return 3
        case "Act 5": return 4
        case "Act 6": return 5
        case "Infinity": return 6
    }
}

GetRaidDownArrows(map) {
    switch map {
        case "Lawless City": return 0
        case "Temple": return 1
        case "Orc Castle": return 2
    }
}

GetRaidActDownArrows(RaidActDropdown) {
    switch RaidActDropdown {
        case "Act 1": return 0
    }
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

TpSpawn() {
    FixClick(26, 570) ;click settings
    Sleep 300
    FixClick(400, 215)
    Sleep 300
    loop 4 {
        Sleep 150
        SendInput("{WheelDown 1}") ;scroll
    }
    Sleep 300
    if (ok := FindText(&X, &Y, 215, 160, 596, 480, 0, 0, Spawn)) {
        AddToLog("Found Teleport to Spawn button")
        FixClick(X + 100, Y - 30)
    } else {
        AddToLog("Could not find Teleport button")
    }
    Sleep 300
    FixClick(583, 147)
    Sleep 300

    ;

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
        ChangeSpeed()
        Sleep 1500
        Zoom()
        Sleep 1500
    }
    CheckForVoteScreen()
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

DetectMap() {
    AddToLog("Determining Movement Necessity on Map...")
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

        if (ModeDropdown.Text = "Raid") {
            AddToLog("Map detected: " RaidDropdown.Text)
            return RaidDropdown.Text
        }

        mapPatterns := Map(


        )

        for mapName, pattern in mapPatterns {
            if (ok := FindText(&X, &Y, 14, 494, 329, 552, 0, 0, pattern)) {
                AddToLog("Detected map: " mapName)
                return mapName
            }
        }

        ; Check for Unit Manager
        if (ok := CheckForUnitManager()) {
            AddToLog("No Map Found or Movement Unnecessary")
            return "no map found"
        }

        Sleep 1000
        Reconnect()
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {
        case "Large Village":
            MoveForLargeVillage()
    }
}

MoveForLargeVillage() {
    Fixclick(586, 545, "Right")
    Sleep (6000)
}

RestartStage(seamless := false) {
    currentMap := DetectMap()
    
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
        AddToLog("Game supports seamless replay, skipping most of setup")
    }

    ; Wait for game to actually start
    StartedGame()

    ; Begin unit placement and management
    PlacingUnits(PlacementPatternDropdown.Text == "Custom")
    
    ; Monitor stage progress
    MonitorStage()
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

PlaceUnit(x, y, slot := 1) {
    SendInput(slot)
    Sleep 50
    FixClick(x, y)
    Sleep 50
    SendInput("q")
    Sleep 500
    FixClick(x, y)
    Sleep 50
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
    FixClick(x, y - 3)
    SendInput ("{T}")
    SendInput ("{T}")
    SendInput ("{T}")
}

CheckLobby() {
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 1, 264, 53, 304, 0, 0, AreaText)) {
            break
        }
        Reconnect()
    }
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
        StoryMode()
    }
    else if (ModeDropdown.Text = "Raid") {
        RaidMode()
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

GenerateCustomPoints() {
    global savedCoords  ; Access the global saved coordinates
    points := []

    ; Directly use savedCoords without generating new points
    for coord in savedCoords {
        points.Push({x: coord.x, y: coord.y})
    }

    return points
}

GenerateRandomPoints() {
    points := []
    gridSize := 40  ; Minimum spacing between units
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Define placement area boundaries (adjust these as needed)
    minX := centerX - 180  ; Left boundary
    maxX := centerX + 180  ; Right boundary
    minY := centerY - 140  ; Top boundary
    maxY := centerY + 140  ; Bottom boundary
    
    ; Generate 40 random points
    Loop 40 {
        ; Generate random coordinates
        x := Random(minX, maxX)
        y := Random(minY, maxY)
        
        ; Check if point is too close to existing points
        tooClose := false
        for existingPoint in points {
            ; Calculate distance to existing point
            distance := Sqrt((x - existingPoint.x)**2 + (y - existingPoint.y)**2)
            if (distance < gridSize) {
                tooClose := true
                break
            }
        }
        
        ; If point is not too close to others, add it
        if (!tooClose)
            points.Push({x: x, y: y})
    }
    
    ; Always add center point last (so it's used last)
    points.Push({x: centerX, y: centerY})
    
    return points
}

GenerateGridPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points row by row
    Loop squaresPerSide {
        currentRow := A_Index
        y := startY + ((currentRow - 1) * gridSize)
        
        ; Generate each point in the current row
        Loop squaresPerSide {
            x := startX + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

GenerateUpandDownPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)
    
    ; Center point coordinates
    centerX := 408
    centerY := 320
    
    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)
    
    ; Generate grid points column by column (left to right)
    Loop squaresPerSide {
        currentColumn := A_Index
        x := startX + ((currentColumn - 1) * gridSize)
        
        ; Generate each point in the current column
        Loop squaresPerSide {
            y := startY + ((A_Index - 1) * gridSize)
            points.Push({x: x, y: y})
        }
    }
    
    return points
}

; circle coordinates
GenerateCirclePoints() {
    points := []
    
    ; Define each circle's radius
    radius1 := 45    ; First circle 
    radius2 := 90    ; Second circle 
    radius3 := 135   ; Third circle 
    radius4 := 180   ; Fourth circle 
    
    ; Angles for 8 evenly spaced points (in degrees)
    angles := [0, 45, 90, 135, 180, 225, 270, 315]
    
    ; First circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius1 * Cos(radians)
        y := centerY + radius1 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ; second circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius2 * Cos(radians)
        y := centerY + radius2 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ; third circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius3 * Cos(radians)
        y := centerY + radius3 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    ;  fourth circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius4 * Cos(radians)
        y := centerY + radius4 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }
    
    return points
}

; Spiral coordinates (restricted to a rectangle)
GenerateSpiralPoints(rectX := 4, rectY := 123, rectWidth := 795, rectHeight := 433) {
    points := []
    
    ; Calculate center of the rectangle
    centerX := rectX + rectWidth // 2
    centerY := rectY + rectHeight // 2
    
    ; Angle increment per step (in degrees)
    angleStep := 30
    ; Distance increment per step (tighter spacing)
    radiusStep := 10
    ; Initial radius
    radius := 20
    
    ; Maximum radius allowed (smallest distance from center to edge)
    maxRadiusX := (rectWidth // 2) - 1
    maxRadiusY := (rectHeight // 2) - 1
    maxRadius := Min(maxRadiusX, maxRadiusY)

    ; Generate spiral points until reaching max boundary
    Loop {
        ; Stop if the radius exceeds the max boundary
        if (radius > maxRadius)
            break
        
        angle := A_Index * angleStep
        radians := angle * 3.14159 / 180
        x := centerX + radius * Cos(radians)
        y := centerY + radius * Sin(radians)
        
        ; Check if point is inside the rectangle
        if (x < rectX || x > rectX + rectWidth || y < rectY || y > rectY + rectHeight)
            break ; Stop if a point goes out of bounds
        
        points.Push({ x: Round(x), y: Round(y) })
        
        ; Increase radius for next point
        radius += radiusStep
    }
    
    return points
}

CheckEndAndRoute() {
    if (ok := FindText(&X, &Y, 137, 422, 632, 460, 0, 0, ReturnToLobby)) {
        AddToLog("Found end screen")
        return MonitorEndScreen()
    }
    return false
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

PlacementSpeed() {
    speeds := [1000, 1500, 2000, 2500, 3000, 4000]  ; Array of sleep values
    speedIndex := PlaceSpeed.Value  ; Get the selected speed value

    if speedIndex is number  ; Ensure it's a number
        return speeds[speedIndex]  ; Use the value directly from the array
}

GetMapData(type, name) {
    data := Map(
        "StoryMap", Map(
            "Green Planet", {x: 210, y: 260, scrolls: 0},
            "Ghoul City", {x: 210, y: 330, scrolls: 0},
            "Sharkman Island", {x: 210, y: 410, scrolls: 0},

            "Hidden Village", {x: 210, y: 345, scrolls: 1},
            "Fairy Town", {x: 210, y: 430, scrolls: 1},

            "Cursed Town", {x: 210, y: 360, scrolls: 2},
            "Corp City", {x: 210, y: 425, scrolls: 2},

            "Soul World", {x: 210, y: 365, scrolls: 3},
            "Strongest City", {x: 210, y: 430, scrolls: 3}
        ),
        "StoryAct", Map(
            "Act 1", {x: 380, y: 245, scrolls: 0},
            "Act 2", {x: 380, y: 275, scrolls: 0},
            "Act 3", {x: 380, y: 305, scrolls: 0},
            "Act 4", {x: 380, y: 335, scrolls: 0},
            "Act 5", {x: 380, y: 365, scrolls: 0},
            "Act 6", {x: 380, y: 395, scrolls: 0},
            "Infinity", {x: 380, y: 425, scrolls: 0}
        ),
        "RaidMap", Map(
            "Green Planet", {x: 380, y: 250, scrolls: 0},
            "Hollow Desert", {x: 380, y: 300, scrolls: 0},
            "Red Palace", {x: 380, y: 350, scrolls: 0},
            "Sorcery Academy", {x: 380, y: 400, scrolls: 0},

            "Lookout", {x: 380, y: 310, scrolls: 1},
            "Slayers District", {x: 380, y: 360, scrolls: 1},
            "Underground Tomb", {x: 380, y: 400, scrolls: 1},

            "Boru's Room", {x: 630, y: 340, scrolls: 2},
            "Candy Park", {x: 630, y: 390, scrolls: 2}

        ),
        "RaidAct", Map(
            "Act 1", {x: 380, y: 245, scrolls: 0},
            "Act 2", {x: 380, y: 275, scrolls: 0},
            "Act 3", {x: 380, y: 305, scrolls: 0},
            "Act 4", {x: 380, y: 335, scrolls: 0},
            "Act 5", {x: 380, y: 365, scrolls: 0},
            "Act 6", {x: 380, y: 395, scrolls: 0}
        ),
        "LegendMap", Map(
            "Magic Hills", {x: 630, y: 240, scrolls: 0},
            "Spirit Invasion", {x: 630, y: 290, scrolls: 0},
            "Space Center", {x: 630, y: 340, scrolls: 0},
            "Fabled Kingdom", {x: 630, y: 390, scrolls: 0},
            "Ruined City", {x: 630, y: 440, scrolls: 0},

            "Virtual Dungeon", {x: 630, y: 350, scrolls: 1},
            "Dungeon Throne", {x: 630, y: 405, scrolls: 1},
            "Rain Village", {x: 630, y: 440, scrolls: 1}
        ),
        "LegendAct", Map(
            "Act 1", {x: 285, y: 235, scrolls: 0},
            "Act 2", {x: 285, y: 270, scrolls: 0},
            "Act 3", {x: 285, y: 305, scrolls: 0},
            "Act 4", {x: 285, y: 340, scrolls: 0},
            "Act 5", {x: 285, y: 375, scrolls: 0},
            "Act 6", {x: 285, y: 395, scrolls: 0}
        )
    )

    return data.Has(type) && data[type].Has(name) ? data[type][name] : {}
}