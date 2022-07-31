# powershush-dir
A PowerShell script that blocks all incoming and outgoing network traffic for all `.exe`and `.dll` files in a given directory using the Windows Firewall.

### "Installation":
Place the `powershush-dir.ps1` in a directory that is in your `PATH` environment variable or simply run it locally.

### Usage:
```
powershush-dir
```
or
```
powershush-dir C:\path\to\directory
```

### Note:
This script elevates itself to admin rights, which also changes the current working directory to `System32`. Be aware that relative paths don't work as expected in this case.

### Example:
```
> powershush-dir

powershush-dir - Block all incoming and outgoing traffic for .exe and .dll files in a given directory
-----------------------------------------------------------------------------------------------------
What directory to shush? Enter path: C:\test
Found the following files to block:
C:\test\executableA.exe
C:\test\executableB.exe
C:\test\library.dll
Shall we commence the blocking? [Y/n]:
Searching for already present rules and start blocking...
Blocked outbound for C:\test\executableA.exe
Blocked inbound for C:\test\executableA.exe
Blocked outbound for C:\test\executableB.exe
Blocked inbound for C:\test\executableB.exe
Blocked outbound for C:\test\library.dll
Blocked inbound for C:\test\library.dll
Press any key to continue...
```