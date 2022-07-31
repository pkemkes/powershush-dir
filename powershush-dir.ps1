function IsAdmin {
    $windowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($windowsID)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $windowsPrincipal.IsInRole($adminRole)
}

function RelaunchAsAdmin($arguments) {
    Write-Output "Relaunching as admin..."
    $CommandLine = "-File `"" + $MyInvocation.ScriptName + "`" " + $arguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
}

function Pause {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

function CheckContinue ($question = "Continue?") {
    Write-Host ("{0} [Y/n]: " -f $question)
    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    if (-Not (($key.Character -eq 13) -Or ($key.Character -Eq 'y'))) {
        Write-Host "Aborting..."
        Pause
        Exit
    }
}

function GetFiles($arguments) {
    if ($arguments.Count -eq 1) {
        $dir = $arguments[0]
    }
    else {
        $dir = Read-Host "What directory to shush? Enter path"
    }
    $exeFiles = Get-ChildItem -Path $dir -Include *.exe -File -Recurse -ErrorAction SilentlyContinue -Force
    $dllFiles = Get-ChildItem -Path $dir -Include *.dll -File -Recurse -ErrorAction SilentlyContinue -Force
    if ($null -ne $exeFiles) {
        $files = $exeFiles
        if ($null -ne $dllFiles)
        {
            $files = $files + $dllFiles
        }
    }
    else {
        $files = $dllFiles
    }
    return $files
}

function RuleExists($name) {
    $rule = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    return ($null -ne $rule)
}

function ShushDir($arguments) {
    $files = GetFiles($arguments)
    Write-Host "Found the following files to block:"
    foreach ($file in $files) {
        Write-Output $file.FullName
    }
    CheckContinue "Shall we commence the blocking?"
    Write-Host "Searching for already present rules and start blocking..."
    foreach ($file in $files) {
        $outName = "Block outbound {0}" -f $file.FullName
        $inName = "Block inbound {0}" -f $file.FullName
        if (-Not (RuleExists $outName)){
            $null = New-NetFirewallRule -DisplayName $outName -Direction Outbound -Action Block -Program $file.FullName
            Write-Host ("Blocked outbound for {0}" -f $file.FullName)
        }
        else {
            Write-Host ("Outbound rule for {0} already exists." -f $file.FullName)
        }
        if (-Not (RuleExists $inName)){
            $null = New-NetFirewallRule -DisplayName $inName -Direction Inbound -Action Block -Program $file.FullName
            Write-Host ("Blocked inbound for {0}" -f $file.FullName)
        }
        else {
            Write-Host ("Inbound rule for {0} already exists." -f $file.FullName)
        }
    }
}

if (-Not (IsAdmin)) {
    RelaunchAsAdmin($MyInvocation.UnboundArguments)
}

Write-Host "powershush-dir - Block all incoming and outgoing traffic for .exe and .dll files in a given directory"
Write-Host "-----------------------------------------------------------------------------------------------------"
ShushDir($args)
Pause