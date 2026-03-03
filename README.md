# Primary Monitor Auto Switcher

Automatically switches your primary monitor when configured applications launch. Monitors the application and restores your primary monitor as soon as the app closes. Perfect for Skyrim, games, or any application on a secondary monitor.

## Features

- ✅ **Multi-Application Support** - Monitor multiple applications simultaneously
- ✅ **File-Based Configuration** - Easy setup via config.ini (no app editing required)
- ✅ **Automatic Detection** - Watches for configured application processes
- ✅ **Instant Switching** - Changes primary monitor when apps start
- ✅ **Smart Launch Detection** - Checks if app is running after minimum timeout, with intelligent retries
- ✅ **Automatic Restore** - Restores primary monitor as soon as app is confirmed running
- ✅ **Manual Hotkeys** - Optional keyboard shortcuts for manual control
- ✅ **Lightweight** - Minimal system resource usage

## Requirements

- **Windows** (tested on Windows 10/11)
- **AutoHotkey** v2 ([Download](https://www.autohotkey.com/))
- **NirCmd** ([Download](https://www.nirsoft.net/utils/nircmd.html))

## Quick Setup

### Automated Setup (Recommended)

1. **Run the setup script:**
   ```powershell
   .\setup.ps1
   ```
   This will:
   - Download NirCmd automatically
   - Check for AutoHotkey installation
   - Provide installation instructions if needed

2. **Configure applications** in config.ini (see Configuration section below)

## Configuration

Edit `config.ini` to control which applications to monitor and monitor settings:

```ini
[Monitors]
GAME_MONITOR=1         # Monitor to switch to when apps launch
DEFAULT_MONITOR=3      # Monitor to restore to after apps open
```

### Adding Applications

Add any executable to the `[Applications]` section with its minimum launch timeout in seconds:

```ini
[Applications]          # Format: AppName.exe=timeout_in_seconds
SkyrimSE.exe=8
YourGame.exe=5
```

- **Timeout**: Minimum time to wait before checking if the app has launched (in seconds)
- Use longer timeouts for games or apps with slow load times
- The script waits this many seconds, then checks if the process is running
- If not running, it retries with half the timeout (2 more times) before giving an error
- Once confirmed running, the monitor switches back immediately

## Usage

### Manual Hotkeys

While the app is running, you can manually switch monitors:

- `Win+Shift+1` | Switch to default monitor
- `Win+Shift+2` | Switch to game monitor

### Stopping the app

- Use hotkey: `Win+Shift+Q`
- Or right-click the AutoHotkey icon in system tray → Exit

## How It Works

1. **App starts** and loads all applications from config.ini
2. **Monitors processes** every 2 seconds for configured applications
3. **When an app launches:**
   - Detects the process
   - Switches primary monitor to game monitor using NirCmd
   - Shows tray notification
   - Starts launch confirmation timer based on the timeout value
4. **Launch confirmation phase:**
   - Waits the minimum timeout (e.g., 8 seconds)
   - Checks if process is still running
   - If confirmed: immediately restores primary monitor and shows success notification
   - If not running: retries with half timeout (e.g., 4 seconds)
   - If still not running after 2 retries: restores monitor and shows error message
5. **While the app runs:**
   - Continues monitoring the process in the background
6. **When the app closes:**
   - Immediately detects process exit and resets to monitoring state
   - Ready to detect next launch
7. **App continues monitoring** for all configured applications

## Troubleshooting

### "NirCmd Not Found" Error
- Ensure `nircmd.exe` is in the same folder as the app
- Run `setup.ps1` to download automatically
- Or manually download from [nirsoft.net](https://www.nirsoft.net/utils/nircmd.html)

### "Config File Not Found" Error
- Ensure `config.ini` exists in the same folder as the app
- Use the template in config.ini as a starting point
- Verify the filename is exactly `config.ini`

### Application Doesn't Trigger Switching
- Verify the executable name in config.ini matches the actual process name
- Check Windows Task Manager for the exact executable name
- Make sure it's in the `[Applications]` section

### Monitor Doesn't Switch
- Verify monitor numbers with manual hotkeys (Win+Shift+1/2)
- Test NirCmd manually: `.\nircmd.exe setprimarydisplay 2`
- Update monitor numbers in config.ini if needed

### Monitor Switches Back Too Soon
- The timeout value is only a minimum wait time before checking if the app has launched
- Once the app is confirmed running, the monitor switches back immediately
- If the app needs more time, ensure the process is actually running after your expected startup time
- The script uses intelligent retries: it waits the timeout, then checks in half-timeout increments twice more before giving an error

### Monitor Doesn't Switch Back
- Check the TrayTip notifications - if there's an error, the app may not have launched within the retry timeouts
- Verify NirCmd is working with manual hotkeys
- Increase the timeout value in config.ini to allow more time for the app to launch
- Check Task Manager to verify the process actually started
- Try restarting the app

### Finding Your Monitor Numbers
1. Right-click the tray icon or use manual hotkeys: `Win+Shift+1` or `Win+Shift+2`
2. Or test each monitor from Command Prompt in the app folder:
   ```powershell
   .\nircmd.exe setprimarydisplay 1
   .\nircmd.exe setprimarydisplay 2
   .\nircmd.exe setprimarydisplay 3
   ```
3. Note which number corresponds to which physical monitor
4. Update `config.ini` accordingly

## File Structure

```
Monitor_Switch/
├── Monitor_Switch.exe    # Main app
├── config.ini            # Application configuration
├── setup.ps1             # Automated setup
├── nircmd.exe            # Monitor switching utility
├── NirCmd.chm            # NirCmd help documentation
└── README.md             # This file
```

## License

This project uses:
- **AutoHotkey** - Licensed under GPL
- **NirCmd** - Freeware by NirSoft

Feel free to modify and distribute this app as needed.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Verify NirCmd and AutoHotkey are properly installed
3. Test monitor switching manually with NirCmd commands

## Credits

- Monitor switching powered by [NirCmd](https://www.nirsoft.net/utils/nircmd.html) by NirSoft
- Process monitoring using [AutoHotkey](https://www.autohotkey.com/)

