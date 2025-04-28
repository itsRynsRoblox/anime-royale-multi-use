#Requires AutoHotkey v2.0

UseCustomPoints() {
    global savedCoords  ; Access the global saved coordinates
    points := []

    presetIndex := PlacementProfiles.Value  ; Get the currently selected preset index

    AddToLog("Index:" presetIndex)

    ; Ensure presetIndex is valid
    if (presetIndex < 1 || !savedCoords.Has(presetIndex)) {
        AddToLog("⚠️ No placements set for Preset: " PlacementProfiles.Text)
        return points  ; Return empty list if invalid index
    }

    ; Directly use saved coordinates for the selected preset
    for coord in savedCoords[presetIndex] {
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