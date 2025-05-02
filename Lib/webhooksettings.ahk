#Include %A_ScriptDir%\Lib\Discord-Webhook-master\lib\WEBHOOK.ahk
#Include %A_ScriptDir%\Lib\AHKv2-Gdip-master\Gdip_All.ahk

global WebhookURLFile := "Settings\WebhookURL.txt"
global DiscordUserIDFile := "Settings\DiscordUSERID.txt"
global SendActivityLogsFile := "Settings\SendActivityLogs.txt"
global WebhookURL := FileRead(WebhookURLFile, "UTF-8")
global webhook := WebhookURL != "" ? WebHookBuilder(WebhookURL) : ""
global currentStreak := 0
global lastResult := "none"
global Wins := 0
global loss := 0
global mode := ""
global StartTime := A_TickCount 
global stageStartTime := A_TickCount
global macroStartTime := A_TickCount
global webhookSendTime := A_TickCount

if (!FileExist("Settings")) {
    DirCreate("Settings")
}

win_messages := [
            "(˵ •̀ ᴗ – ˵ ) ✧",
            "♡‧₊˚✧ ૮ ˶ᵔ ᵕ ᵔ˶ ა ✧˚₊‧♡",
            "/)_/)`n(,,>.<)`n/ >❤️",
            "૮꒰ ˶• ༝ •˶꒱ა ♡",
            "✧｡٩(ˊᗜˋ )و✧*｡",
            "( •̯́ ₃ •̯̀)",
            "₍ᐢ•ﻌ•ᐢ₎*･ﾟ｡"

        ],
        lose_messages := [
            "(╯°□°)╯︵ ┻━┻",
            "(ಠ益ಠ)",
            "(╥﹏╥)",
            "(⇀‸↼‶)",
            "(◣ _ ◢)",
            "<(ꐦㅍ _ㅍ)>"
        ]

CalculateElapsedTime(startTime) {
    elapsedTimeMs := A_TickCount - startTime
    elapsedTimeSec := Floor(elapsedTimeMs / 1000)
    elapsedHours := Floor(elapsedTimeSec / 3600)
    elapsedMinutes := Floor(Mod(elapsedTimeSec, 3600) / 60)
    elapsedSeconds := Mod(elapsedTimeSec, 60)
    return Format("{:02}:{:02}:{:02}", elapsedHours, elapsedMinutes, elapsedSeconds)
}

; Function to update streak
UpdateStreak(isWin) {
    global currentStreak, lastResult
    
    ; Initialize lastResult if it doesn't exist
    if (!IsSet(lastResult)) {
        lastResult := "none"
    }
    
    if (isWin) {
        if (lastResult = "win")
            currentStreak += 1
        else
            currentStreak := 1
    } else {
        if (lastResult = "lose")
            currentStreak -= 1
        else
            currentStreak := -1
    }
    
    lastResult := isWin ? "win" : "lose"
}

SendWebhookWithTime(isWin, stageLength) {
    global currentStreak, Wins, loss, WebhookURL, webhook, macroStartTime, currentMap
    
    ; Update streak
    UpdateStreak(isWin)

    ; Check if webhook file exists first
    if (!FileExist(WebhookURLFile)) {
        AddToLog("No webhook configured - skipping webhook")
        return  ; Just return if no webhook file
    }

    if !(WebhookURL ~= 'i)https?:\/\/discord\.com\/api\/webhooks\/(\d{18,19})\/[\w-]{68}') {
        AddToLog("No webhook configured - skipping webhook")
        return
    }
    
    ; Calculate macro runtime (total time)
    macroLength := FormatStageTime(A_TickCount - macroStartTime)
    
    ; Build session data
    sessionData := "⏳ Macro Runtime: " macroLength "`n"
    . "🕒 Stage Duration: " stageLength "`n"
    . "🔥 Current Streak: " (currentStreak > 0 ? currentStreak " Win Streak" : Abs(currentStreak) " Loss Streak") "`n"
    . "🗺️ Map: " currentMap "`n"
    . "🎮 Mode: " ModeDropdown.Text "`n"
    . "✅ Wins: " Wins "`n"
    . "❌ Fails: " loss "`n"
    . "📊 Total Runs: " (loss + Wins) "`n"
    . "🏆 Win Rate: " Format("{:.1f}%", (Wins / (Wins + loss)) * 100) "`n"
    isWin ? 0x0AB02D : 0xB00A0A,
    isWin ? "win" : "lose"
    
    ; Send webhook
    WebhookScreenshot(
        isWin ? "Stage Complete!" : "Stage Failed",
        sessionData,
        isWin ? 0x0AB02D : 0xB00A0A,
        isWin ? "win" : "lose"
    )
}

CropImage(pBitmap, x, y, width, height) {
    ; Initialize GDI+ Graphics from the source bitmap
    pGraphics := Gdip_GraphicsFromImage(pBitmap)
    if !pGraphics {
        MsgBox("Failed to initialize graphics object")
        return
    }

    ; Create a new bitmap for the cropped image
    pCroppedBitmap := Gdip_CreateBitmap(width, height)
    if !pCroppedBitmap {
        MsgBox("Failed to create cropped bitmap")
        Gdip_DeleteGraphics(pGraphics)
        return
    }

    ; Initialize GDI+ Graphics for the new cropped bitmap
    pTargetGraphics := Gdip_GraphicsFromImage(pCroppedBitmap)
    if !pTargetGraphics {
        MsgBox("Failed to initialize graphics for cropped bitmap")
        Gdip_DisposeImage(pCroppedBitmap)
        Gdip_DeleteGraphics(pGraphics)
        return
    }

    ; Copy the selected area from the source bitmap to the new cropped bitmap
    Gdip_DrawImage(pTargetGraphics, pBitmap, 0, 0, width, height, x, y, width, height)

    ; Cleanup
    Gdip_DeleteGraphics(pGraphics)
    Gdip_DeleteGraphics(pTargetGraphics)

    ; Return the cropped bitmap
    return pCroppedBitmap
}


WebhookSettings() { 
    if FileExist(WebhookURLFile)
        WebhookURLBox.Value := FileRead(WebhookURLFile, "UTF-8")

    if FileExist(DiscordUserIDFile)
        DiscordUserIDBox.Value := FileRead(DiscordUserIDFile, "UTF-8")

    if FileExist(SendActivityLogsFile) ; Load checkbox value
        SendActivityLogsBox.Value := (FileRead(SendActivityLogsFile, "UTF-8") = "1")

    
}

SaveWebhookSettings() {
    
    if !(WebhookURLBox.Value = "" || RegExMatch(WebhookURLBox.Value, "^https://discord\.com/api/webhooks/.*")) {
        MsgBox("Invalid Webhook URL! Please enter a valid Discord webhook URL.", "Error", "+0x1000", )
        WebhookURLBox.Value := ""
        return
    }

    if !(RegExMatch(DiscordUserIDBox.Value, "^\d*$")) {
        MsgBox("Invalid Discord User ID! Please enter a valid Discord User ID or keep it empty.", "Error", "+0x1000")
        DiscordUserIDBox.Value := ""
        return
    }

    AddToLog("Saving Webhook Configuration")
    
    ; Delete old files if they exist
    if FileExist(WebhookURLFile)
        FileDelete(WebhookURLFile)

    if FileExist(DiscordUserIDFile)
        FileDelete(DiscordUserIDFile)

    if FileExist(SendActivityLogsFile)
        FileDelete(SendActivityLogsFile)

    ; Save the new values
    FileAppend(WebhookURLBox.Value, WebhookURLFile, "UTF-8")
    FileAppend(DiscordUserIDBox.Value, DiscordUserIDFile, "UTF-8")
    FileAppend(SendActivityLogsBox.Value ? "1" : "0", SendActivityLogsFile, "UTF-8")
    
}

TextWebhook() {
    global lastlog

    ; Calculate the runtime
    ElapsedTimeMs := A_TickCount - StartTime
    ElapsedTimeSec := Floor(ElapsedTimeMs / 1000)
    ElapsedHours := Floor(ElapsedTimeSec / 3600)
    ElapsedMinutes := Floor(Mod(ElapsedTimeSec, 3600) / 60)
    ElapsedSeconds := Mod(ElapsedTimeSec, 60)
    Runtime := Format("{} hours, {} minutes", ElapsedHours, ElapsedMinutes)

    ; Prepare the attachment and embed
    myEmbed := EmbedBuilder()
        .setTitle("")
        .setDescription("[" FormatTime(A_Now, "hh:mm tt") "] " lastlog)
        .setColor(0x0077ff)
        

    ; Send the webhook
    webhook.send({
        content: (""),
        embeds: [myEmbed],
        files: []
    })

    ; Clean up resources
}

WebhookLog() {
    global WebhookURL := FileRead(WebhookURLFile, "UTF-8")
    global DiscordUserID := FileRead(DiscordUserIDFile, "UTF-8")

    if (webhookURL ~= 'i)https?:\/\/discord\.com\/api\/webhooks\/(\d{18,19})\/[\w-]{68}') {
        global webhook := WebHookBuilder(WebhookURL)
        TextWebhook()
    } 
}

SaveWebhookBtnClick() {
    AddToLog("Attempting to save webhook settings...")
    SaveWebhookSettings()
    AddToLog("Webhook settings saved")
}
;Discord webhooks, above

WebhookScreenshot(title, description, color := 0x0dffff, status := "") {
    global webhook, WebhookURL, DiscordUserID, wins, loss, currentStreak, stageStartTime
    ; Yap message

    footerMessages := Map(
        "win", win_messages,
        "lose", lose_messages
    )

    global DiscordUserID := FileRead(DiscordUserIDFile, "UTF-8")
    global wins, loss, currentStreak, stageStartTime

    if (!IsSet(stageStartTime)) {
        stageStartTime := A_TickCount
    }
    
    if !(webhookURL ~= 'i)https?:\/\/discord\.com\/api\/webhooks\/(\d{18,19})\/[\w-]{68}') {
        return
    }
    
    ; Select appropriate message based on conditions
    footerText := ""
    messages := footerMessages[status = "win" ? "win" : "lose"]  ; default messages

    ; Check if it's a long run (30+ minutes)
    stageLength := CalculateElapsedTime(stageStartTime)
    stageMinutes := Floor((A_TickCount - stageStartTime) / (1000 * 60))

    ; Helper function to replace placeholders
    ReplaceVars(text, vars) {
        for key, value in vars {
            text := StrReplace(text, "#{" key "}", value)
        }
        return text
    }

    if (status = "win") {
        messages := footerMessages["win"]
        footerText := ReplaceVars(messages[Random(1, messages.Length)], Map("count", wins))
    } else {
        messages := footerMessages["lose"]
        footerText := ReplaceVars(messages[Random(1, messages.Length)], Map("count", loss))
    }

    ; If no special message was set, use a random regular message
    if (footerText = "") {
        footerText := messages[Random(1, messages.Length)]
    }

    ; Rest of your existing WebhookScreenshot code...
    UserIDSent := (DiscordUserID = "") ? "" : "<@" DiscordUserID ">"

    ; Initialize GDI+
    pToken := Gdip_Startup()
    if !pToken {
        MsgBox("Failed to initialize GDI+")
        return
    }

    ; Capture and process screen
    pBitmap := Gdip_BitmapFromScreen()
    if !pBitmap {
        MsgBox("Failed to capture the screen")
        Gdip_Shutdown(pToken)
        return
    }

    pCroppedBitmap := CropImage(pBitmap, 0, 0, 1366, 700)
    if !pCroppedBitmap {
        MsgBox("Failed to crop the bitmap")
        Gdip_DisposeImage(pBitmap)
        Gdip_Shutdown(pToken)
        return
    }   
    
    ; Prepare and send webhook
    attachment := AttachmentBuilder(pCroppedBitmap)
    myEmbed := EmbedBuilder()
    myEmbed.setTitle(title)
    myEmbed.setDescription(description)
    myEmbed.setColor(color)
    myEmbed.setImage(attachment)
    myEmbed.setFooter({ text: footerText })

    webhook.send({
        content: UserIDSent,
        embeds: [myEmbed],
        files: [attachment]
    })

    ; Cleanup
    Gdip_DisposeImage(pBitmap)
    Gdip_DisposeImage(pCroppedBitmap)
    Gdip_Shutdown(pToken)
}

SendWebhookRequest(webhook, params, maxRetries := 3) {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", webhook, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(JSON.Stringify(params))
        AddToLog("Webhook sent successfully")
        return true
    } catch {
        AddToLog("Unable to send webhook - continuing without sending")
        return false
    }
}

TestWebhook() {
    global Wins
    wins++
    SendWebhookWithTime(true, 1)
}