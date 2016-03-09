# Start-WixBuild
## SYNOPSIS
Converts a PowerShell module folder to installable MSI package files.

## SYNTAX
```powershell
Start-WixBuild [[-Path] <String>] [-OutputFolder <String>] [-LicenseFile <String>] [-IconFile <String>] [-BannerFile <String>] [-DialogFile <String>] [-ProductShortName <String>] [-ProductName <String>] [-ProductVersion <String>] [-Manufacturer <String>] [-HelpLink <String>] [-AboutLink <String>] [-UpgradeCodeX86 <String>] [-UpgradeCodeX64 <String>] [-Increment <Int32>] [-NoX86] [-NoX64] [<CommonParameters>]
```

## DESCRIPTION
This function uses the WiX Toolset to convert a directory containing a
PowerShell module to an installable Microsoft Installer package file (MSI).
By default 32bit and 64bit MSI files are generated.  The target install
directories for the MSI files
are set to:

 - `C:\Windows\System32\WindowsPowerShell\v1.0\Modules` (64bit MSI on 64bit
 Windows and 32bit MSI on 32bit Windows).
 - `C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Modules` (32bit MSI on 64bit
 Windows).

See the each function parameter for options.

## PARAMETERS
### -Path \<String\>
The path to the folder containing the PowerShell module to be converted.
Defaults to current directory.
```
Required?                    false
Position?                    1
Default value                (Get-Location).Path
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -OutputFolder \<String\>
The path to the folder to out the MSI package files.  Defaults to current
directory.
```
Required?                    false
Position?                    named
Default value                (Get-Location).Path
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -LicenseFile \<String\>

```
Required?                    false
Position?                    named
Default value                "$Path\license.rtf"
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -IconFile \<String\>
The path to an icon file (.ico).  The icon will be displayed in
'Add/Remove Programs' for your package.  Defaults to 'icon.ico' in the
current directory.  If this can't be found an included PowerShell icon is
used.
```
Required?                    false
Position?                    named
Default value                "$Path\icon.ico"
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -BannerFile \<String\>
The path to a bitmap file (.bmp). The image will be displayed at the top of
every installer dialogue for your package (except the first dialog).
Defaults to 'banner.bmp' in the current directory. If this can't be found an
included PowerShell banner is used.
```
Required?                    false
Position?                    named
Default value                "$Path\banner.bmp"
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -DialogFile \<String\>
The path to a bitmap file (.bmp). The image will be displayed at the top of
the first installer dialogue for your package. Defaults to 'dialog.bmp' in
the current directory. If this can't be found an included PowerShell dialog
image is used.
```
Required?                    false
Position?                    named
Default value                "$Path\dialog.bmp"
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductShortName \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -ProductShortName -Path $Path).ProductShortName
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductName \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -ProductName -Path $Path).ProductName
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductVersion \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -ProductVersion -Path $Path).ProductVersion
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Manufacturer \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -Manufacturer -Path $Path).Manufacturer
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -HelpLink \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -HelpLink -Path $Path).HelpLink
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -AboutLink \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -AboutLink -Path $Path).AboutLink
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -UpgradeCodeX86 \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -UpgradeCodeX86 -Path $Path).UpgradeCodeX86
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -UpgradeCodeX64 \<String\>

```
Required?                    false
Position?                    named
Default value                (Get-WiXLocalConfig -UpgradeCodeX64 -Path $Path).UpgradeCodeX64
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Increment \<Int32\>

```
Required?                    false
Position?                    named
Default value                3
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -NoX86 \<SwitchParameter\>

```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -NoX64 \<SwitchParameter\>

```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```

## INPUTS
None

## OUTPUTS
None

## NOTES
NAME: Start-WixBuild

AUTHOR: Richard Grainger <grainger@gmail.com>

## EXAMPLES
### EXAMPLE 1
```powershell
PS C:\>Start-WixBuild
```

Convert the current directory, containing a PowerShell module, into
installable MSI package files.
 
### EXAMPLE 2
```powershell
PS C:\>Start-WixBuild -Path 'C:\users\myuser\mymodules\awesomemodule'
```

Convert a PowerShell module in 'C:\users\myuser\mymodules\awesomemodule'
into installable MSI package files.

