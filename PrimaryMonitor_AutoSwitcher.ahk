; ====================================================================
; Primary Monitor Auto Switcher
; ====================================================================
; Configuration: Edit config.txt with entries like: "SkyrimSE.exe, 8"
; (exe name, timeout in seconds)
; 
; Requirements: NirCmd (nircmd.exe must be in the same directory)
; Download: https://www.nirsoft.net/utils/nircmd.html
; ====================================================================

;@Ahk2Exe-SetMainIcon shemp.ico

#SingleInstance Force

; ====================================================================
; CONFIGURATION
; ====================================================================

; Path to nircmd.exe (if in same folder, just use "nircmd.exe")
NIRCMD_PATH := "nircmd.exe"

CONFIG_FILE := A_ScriptDir . "\config.ini"
GAME_MONITOR := 0
DEFAULT_MONITOR := 0

; ====================================================================
; SCRIPT LOGIC - Reads config file and monitors processes
; ====================================================================

; Global variables - Maps to store tracked processes and their timeouts
trackedProcesses := Map()
isLaunched := Map()
isRestored := Map()

; Check if NirCmd exists
if !FileExist(NIRCMD_PATH) {
    message := "NirCmd was not found at: " . NIRCMD_PATH . "`n`n"
    message .= "Please download NirCmd from:`n"
    message .= "https://www.nirsoft.net/utils/nircmd.html`n`n"
    message .= "Extract nircmd.exe to the same folder as this script.`n`n"
    message .= "Run setup.ps1 for automatic download."
    MsgBox(message, "Error - NirCmd Not Found", "Iconx")
    ExitApp()
}

; Check if config file exists
if !FileExist(CONFIG_FILE) {
    message := "Config file not found: " . CONFIG_FILE . "`n`n"
    message .= "Please create a config.txt file with entries like:`n"
    message .= "SkyrimSE.exe, 8`n"
    message .= "MyGame.exe, 3"
    MsgBox(message, "Error - Config File Not Found", "Iconx")
    ExitApp()
}

; Load configuration from file
LoadConfig()

if (trackedProcesses.Count = 0) {
    MsgBox("No valid entries found in " . CONFIG_FILE, "Error", "Iconx")
    ExitApp()
}

if (GAME_MONITOR = 0 || DEFAULT_MONITOR = 0) {
    MsgBox("GAME_MONITOR and/or DEFAULT_MONITOR not set in " . CONFIG_FILE, "Error", "Iconx")
    ExitApp()
}

; Show startup notification
processInfo := ""
for exeName, timeout in trackedProcesses {
    processInfo .= exeName . " (" . timeout . "s)`n"
}
TrayTip("Monitoring for: " . SubStr(processInfo, 1, -1) . "`nGame Monitor: " GAME_MONITOR "`nDefault Monitor: " DEFAULT_MONITOR)

; Start monitoring loop
SetTimer(CheckProcesses, 2000)

; ====================================================================
; Load configuration from config file
; ====================================================================
LoadConfig() {
    global trackedProcesses, isLaunched, CONFIG_FILE, GAME_MONITOR, DEFAULT_MONITOR
    local appList
    
    ; Read monitor settings from [Monitors] section
    GAME_MONITOR := IniRead(CONFIG_FILE, "Monitors", "GAME_MONITOR")
    DEFAULT_MONITOR := IniRead(CONFIG_FILE, "Monitors", "DEFAULT_MONITOR")
    
    if (RegExMatch(GAME_MONITOR, "^\d+$")) {
        GAME_MONITOR := Integer(GAME_MONITOR)
    }
    if (RegExMatch(DEFAULT_MONITOR, "^\d+$")) {
        DEFAULT_MONITOR := Integer(DEFAULT_MONITOR)
    }
    
    ; Read all entries from [Applications]
    try {
        appList := IniRead(CONFIG_FILE, "Applications")
    } catch Error as e {
        return
    }
    
    ; Parse each application entry
    lines := StrSplit(appList, "`n")
    for index, line in lines {
        line := Trim(line)
        
        ; Skip empty lines
        if (line = "") {
            continue
        }
        
        ; Parse "ExeName.exe=timeout_in_seconds"
        if (InStr(line, "=")) {
            parts := StrSplit(line, "=")
            if (parts.Length >= 2) {
                exeName := Trim(parts[1])
                timeout := Trim(parts[2])
                
                ; Validate timeout is a number
                if (RegExMatch(timeout, "^\d+$")) {
                    trackedProcesses[exeName] := Integer(timeout) * 1000  ; Convert to milliseconds
                    isLaunched[exeName] := false
                    isRestored[exeName] := false
                }
            }
        }
    }
}

; ====================================================================
; Monitor for configured application processes
; ====================================================================
CheckProcesses() {
    global trackedProcesses, isLaunched
    
    for exeName, timeout in trackedProcesses {
        if ProcessExist(exeName) {
            processExists := true
        } else {
            processExists := false
        }
        
        ; Process just started - switch monitor and set up auto-restore
        if (processExists && !isLaunched[exeName]) {
            isLaunched[exeName] := true
            isRestored[exeName] := false
            
            ; Switch to game monitor
            Run(NIRCMD_PATH " setprimarydisplay " GAME_MONITOR, , 1)
            
            TrayTip(exeName " detected! Switched to Monitor " GAME_MONITOR "`nWill restore once game has launched...")
            
            ; Use a closure to capture the exeName and timeout for this specific process
            SetTimer(MonitorAndRestore.Bind(exeName, timeout, 1), -timeout)
        }
        
        ; Reset flags when process closes so we can detect next launch
        else if (!processExists && isLaunched[exeName]) {
            isLaunched[exeName] := false
            isRestored[exeName] := false
            TrayTip(exeName " closed. Monitoring for next launch...")
        }
    }
}

; ====================================================================
; Monitor if app is running and restore monitor once launched
; ====================================================================
MonitorAndRestore(exeName, timeout, attemptNum := 1) {
    global isLaunched, isRestored
    
    ; Check if process still exists
    if (ProcessExist(exeName)) {
        ; Process is still running - it has launched successfully
        ; Only show restoration message on first successful detection
        if (!isRestored[exeName]) {
            isRestored[exeName] := true
            
            Run(NIRCMD_PATH " setprimaryDisplay " DEFAULT_MONITOR, , 1)
            TrayTip(exeName " launched! Restored Monitor " DEFAULT_MONITOR)
        }
    }
    else if (attemptNum < 3) {
        ; Process not running yet - schedule next retry with half the timeout
        nextTimeout := Max(1, Floor(timeout / 2))
        nextAttempt := attemptNum + 1
        SetTimer(MonitorAndRestore.Bind(exeName, nextTimeout, nextAttempt), -nextTimeout)
    }
    else {
        ; All retries exhausted - game failed to launch
        isLaunched[exeName] := false
        isRestored[exeName] := false
        
        Run(NIRCMD_PATH " setprimaryDisplay " DEFAULT_MONITOR, , 1)
        TrayTip("ERROR: " exeName " failed to launch! Restored Monitor " DEFAULT_MONITOR)
        MsgBox(exeName " did not launch within the expected time. Monitor restored to default.", "Launch Error", "Iconx")
    }
}

; ====================================================================
; Hotkeys for manual control (optional)
; ====================================================================

; Win+Shift+1 - Switch to default monitor
#+1:: {
    Run(NIRCMD_PATH " setprimarydisplay " DEFAULT_MONITOR, , 1)
    TrayTip("Switched to Monitor " DEFAULT_MONITOR)
}

; Win+Shift+2 - Switch to game monitor
#+2:: {
    Run(NIRCMD_PATH " setprimarydisplay " GAME_MONITOR, , 1)
    TrayTip("Switched to Monitor " GAME_MONITOR)
}

; Win+Shift+Q - Quit script
#+Q:: {
    TrayTip("Exiting...")
    Sleep(500)
    ExitApp()
}
