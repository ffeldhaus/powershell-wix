#Requires -Version 3.0

Function ConvertTo-WixNeutralString ($Text) {
  $changes = New-Object System.Collections.Hashtable
  $changes.'ß' = 'ss'
  $changes.'Ä' = 'Ae'
  $changes.'ä' = 'ae'
  $changes.'Ü' = 'Ue'
  $changes.'ü' = 'ue'
  $changes.'Ö' = 'Oe'
  $changes.'ö' = 'oe'
  $changes.' ' = '_'
  $changes.'-' = '_'
  Foreach ($key in $changes.Keys) {
    $text = $text.Replace($key, $changes.$key)
  }
  $text
}

Function New-WixUid {
  function New-RandomHexByte {
    "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)
  }
    New-Alias -Name nrhb -Value New-RandomHexByte
    ((nrhb),(nrhb),(nrhb),(nrhb),
    "-",
    (nrhb),(nrhb),
    "-",
    (nrhb),(nrhb),
    "-",
    (nrhb),(nrhb),
    "-",
    (nrhb),(nrhb),(nrhb),(nrhb),(nrhb),(nrhb)) -join ''
}


Function Get-WixLocalConfig
{
  <#
   .Synopsis
    Returns the local WiX configuration.
   .Description
    This function returns an object representing the local WiX
    configuration.  Configuration is returned from a JSON formatted config file
    (default location: '.WiX\settings.json').  Sensible default values are
    returned if they are not contained in this file.  Upgrade codes are
    generated and stored if they do not exist.
     
    Individual configuration values can also be selected.  If no configuration
    values are selected, all values are returned.
   .Example
    Get-WixLocalConfig
    Gets local WiX configuration from '.WiX\settings.json'.
   .Example
    (Get-WixLocalConfig -ProductName).ProductName
    Gets 'ProductName' as a stringfrom '.WiX\settings.json'.
   .Parameter File
    An alternative configuration file.
   .Parameter ProductShortName
    Include "ProductShortName" in returned object.
   .Parameter ProductName
    Include "ProductName" in returned object.
   .Parameter ProductVersion
    Include "ProductVersion" in returned object.
   .Parameter Manufacturer
    Include "Manufacturer" in returned object.
   .Parameter HelpLink
    Include "HelpLink" in returned object.
   .Parameter AboutLink
    Include "AboutLink" in returned object.
   .Parameter UpgradeCodeX86
    Include "UpgradeCodeX86" in returned object.
   .Parameter UpgradeCodeX64
    Include "UpgradeCodeX64" in returned object.
   .Inputs
    None
   .Outputs
    `System.Management.Automation.PSCustomObject`
    
    Returns a custom object representing the local WiX
    configuration.
   .Notes
    NAME: Get-WixLocalConfig
   
    AUTHOR: Richard Grainger <grainger@gmail.com>
   .Link
    https://github.com/liger1978/powershell-wix/tree/master/docsget-wixlocalconfig.md
 #>
  [Cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false)]  [string] $File = '.WiX\settings.json',
    [Parameter(Mandatory=$false)]  [switch] $ProductShortName,
    [Parameter(Mandatory=$false)]  [switch] $ProductName,
    [Parameter(Mandatory=$false)]  [switch] $ProductVersion,
    [Parameter(Mandatory=$false)]  [switch] $Manufacturer,
    [Parameter(Mandatory=$false)]  [switch] $HelpLink,
    [Parameter(Mandatory=$false)]  [switch] $AboutLink,
    [Parameter(Mandatory=$false)]  [switch] $UpgradeCodeX86,
    [Parameter(Mandatory=$false)]  [switch] $UpgradeCodeX64
  ) #end Param
  "File: " + $File
  $defaults = @{'ProductShortName' = (Split-Path -Leaf (Split-Path (Split-Path $File)));
                'ProductName' = (Split-Path -Leaf (Split-Path (Split-Path $File)));
                'ProductVersion' = '1.0.0';
                'Manufacturer' = (Split-Path -Leaf (Split-Path (Split-Path $File)));
                'HelpLink' = ("http://www.google.com/q=" + 
                    (Split-Path -Leaf (Split-Path (Split-Path $File))));
                'AboutLink' = ("http://www.google.com/q=" + 
                    (Split-Path -Leaf (Split-Path (Split-Path $File))));
                'UpgradeCodeX86' = (New-WixUid);
                'UpgradeCodeX64' = (New-WixUid)}
  $settings = New-Object -TypeName PSCustomObject
  $readSettings = New-Object -TypeName PSCustomObject
  $params = $PSBoundParameters.GetEnumerator()|
            Where-Object {($_.Key -ne 'File')}
  
  # Make sure we have persistent upgrade codes
  if (Test-Path $File){
    try {
      $readSettings = Get-Content -Raw $File | ConvertFrom-Json
    } catch {}
  }
  If (!$readSettings.UpgradeCodeX86 -or !$readSettings.UpgradeCodeX64){
    If (!$readSettings.UpgradeCodeX86){
      Add-Member -InputObject $readSettings -MemberType NoteProperty `
                     -Name UpgradeCodeX86 -Value (New-WixUid)
    }
    If (!$readSettings.UpgradeCode64){
      Add-Member -InputObject $readSettings -MemberType NoteProperty `
                     -Name UpgradeCodeX64 -Value (New-WixUid)
    }
    #$readsettings
    $null = (New-Item -ItemType Directory -Force -Path (Split-Path $File))
    $readSettings | ConvertTo-JSON | Out-File $File
  }
  
  if (Test-Path $File){
    try {
      $readSettings = Get-Content -Raw $File | ConvertFrom-Json
    } catch {}
  }
  foreach ($parameter in $params){
    $setting = $parameter.Key.ToLower()
    $value = $parameter.Value
    if ($value){
      if ($readSettings.$setting) { 
        Add-Member -InputObject $settings -MemberType NoteProperty `
                   -Name $setting -Value $readSettings.$setting
      }
      elseif ($defaults.$setting) {
        Add-Member -InputObject $settings -MemberType NoteProperty `
                   -Name $setting -Value $defaults.$setting}
      else {
       Add-Member -InputObject $settings -MemberType NoteProperty `
                  -Name $setting -Value (Read-Host "$setting")
      }
    }
  } 
  if ($params.count -eq 0){
    foreach ($default in $defaults.GetEnumerator()){
      $setting = $default.Name
      $value = $default.Value
      Add-Member -InputObject $settings -MemberType NoteProperty `
                 -Name $setting -Value $value -Force
    }
    $readSettings.PSObject.Properties |
    foreach-object {
      $setting = $_.Name
      $value = $_.Value
      Add-Member -InputObject $settings -MemberType NoteProperty `
                 -Name $setting -Value $value -Force
    }
  }
  Return $settings
} #end Function Get-WixLocalConfig 


Function Set-WixLocalConfig
{
  <#
   .Synopsis
    Sets local WiX configuration.
   .Description
    This function accepts an object representing configuration settings or 
    individual configuration settings and writes them to a JSON
    formatted file (default location: '.WiX\settings.json').  It returns the new
    configuration.
   .Example
    Set-WixLocalConfig -ProductName "My Awesome PowerShell Module "
    Sets the 'ProductName' setting in default config file '.WiX\settings.json'.
   .Parameter File
    An alternative configuration file.
   .Parameter Replace
    Replace all existing configuration with new settings.
   .Parameter ProductShortName
    Set "ProductShortName" value.
   .Parameter ProductName
    Set "ProductName" value.
   .Parameter ProductVersion
    Set "ProductVersion" value.
   .Parameter Manufacturer
    Set "Manufacturer" value.
   .Parameter HelpLink
    Set "HelpLink" value.
   .Parameter AboutLink
    Set "AboutLink" value.
   .Parameter UpgradeCodeX86
    Set "UpgradeCodeX86" value.
   .Parameter UpgradeCodeX64
    Set "UpgradeCodeX64" value.
   .Inputs
    `System.Management.Automation.PSCustomObject`
    
    Provide a custom object representing the local WiX
    configuration.  Use Get-WixLocalConfig to see an example of the object
    format.
   .Outputs
    `System.Management.Automation.PSCustomObject`
    
    Returns a custom object representing the new local WiX
    configuration.    
   .Notes
    NAME: Set-WixLocalConfig
    
    AUTHOR: Richard Grainger <grainger@gmail.com>
   .Link
    https://github.com/liger1978/powershell-wix/tree/master/docsset-wixlocalconfig.md
 #>
  [Cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false)]        [string]  $File = '.WiX\settings.json',
    [Parameter(Mandatory=$false)]        [switch]  $Replace,
    [Parameter(Mandatory=$true,
               Position=0,
               ValueFromPipeline=$true,
               ParameterSetName="Object")] [object]  $Settings,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $ProductShortName,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $ProductName,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $ProductVersion,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $Manufacturer,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $HelpLink,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $AboutLink,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $UpgradeCodeX86,
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $UpgradeCodeX64
  ) #end Param
  If ($Settings){
    $newSettings = New-Object -TypeName PSCustomObject
      if (!$Replace){
      $readSettings = Get-WixLocalConfig -File $File
      $readSettings.PSObject.Properties | 
      foreach-object {
        Add-Member -InputObject $newSettings -MemberType NoteProperty `
                    -Name $_.Name -Value $_.Value
      }
    }
    $Settings.PSObject.Properties | 
    foreach-object {
      $setting = $_.Name
      $value = $_.Value
      Add-Member -InputObject $newSettings -MemberType NoteProperty `
                 -Name $setting -Value $value -Force

    }
    $null = (New-Item -ItemType Directory -Force -Path (Split-Path $File))
    $newSettings | ConvertTo-JSON | Out-File $File
    Get-WixLocalConfig -File $File
  } 
  else {
    $params = $PSBoundParameters.GetEnumerator()|
              Where-Object {($_.Key -ne 'File' -and
                             $_.Key -ne 'Settings' -and
                             $_.Key -ne 'Replace')}
    $Settings = New-Object -TypeName PSCustomObject
    foreach ($parameter in $params){
      $setting = $parameter.Key
      $value = $parameter.Value
        if ($value){
          Add-Member -InputObject $Settings -MemberType NoteProperty `
                     -Name $setting -Value $value
        }
    }
    Set-WixLocalConfig -File $File -Settings $Settings -Replace:$Replace
  }
} #end Function Set-WixLocalConfig
 
Function Start-WixBuild
{
  <#
   .Synopsis
    Converts a PowerShell module folder to installable MSI package files.
   .Description
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
   
   .Example
    Start-WixBuild
    Convert the current directory, containing a PowerShell module, into
    installable MSI package files.
   .Example
    Start-WixBuild -Path 'C:\users\myuser\mymodules\awesomemodule'
    Convert a PowerShell module in 'C:\users\myuser\mymodules\awesomemodule'
    into installable MSI package files.
   .Parameter Path
    The path to the folder containing the PowerShell module to be converted.
    Defaults to current directory.
   .Parameter OutputFolder
    The path to the folder to out the MSI package files.  Defaults to current
    directory.
   .Parameter LicenceFile
    The path to a rich text file (.rtf) containing your module's license
    information.  The licence will be inlcuded in the generated MSI package
    files. Defaults to 'license.rtf' in the current directory.
   .Parameter IconFile
    The path to an icon file (.ico).  The icon will be displayed in
    'Add/Remove Programs' for your package.  Defaults to 'icon.ico' in the
    current directory.  If this can't be found an included PowerShell icon is
    used.
   .Parameter BannerFile
    The path to a bitmap file (.bmp). The image will be displayed at the top of
    every installer dialogue for your package (except the first dialog).
    Defaults to 'banner.bmp' in the current directory. If this can't be found an
    included PowerShell banner is used.
   .Parameter DialogFile
    The path to a bitmap file (.bmp). The image will be displayed at the top of
    the first installer dialogue for your package. Defaults to 'dialog.bmp' in
    the current directory. If this can't be found an included PowerShell dialog
    image is used.
   .Parameter ShortName
    The short name of your package.  Defaults to current folder name/
   .Inputs
    None
   .Outputs
    None
   .Notes
    NAME: Start-WixBuild
   
    AUTHOR: Richard Grainger <grainger@gmail.com>
   .Link
    https://github.com/liger1978/powershell-wix/tree/master/docsstart-wixbuild.md
 #>
  [Cmdletbinding()]
  Param(
    [Parameter(Mandatory=$false)]  [string] $Path = (Get-Location).Path,
    [Parameter(Mandatory=$false)]  [string] $OutputFolder = (Get-Location).Path,
    [Parameter(Mandatory=$false)]  [string] $LicenseFile = "$Path\license.rtf",
    [Parameter(Mandatory=$false)]  [string] $IconFile = "$Path\icon.ico",
    [Parameter(Mandatory=$false)]  [string] $BannerFile = "$Path\banner.bmp",
    [Parameter(Mandatory=$false)]  [string] $DialogFile = "$Path\dialog.bmp",
    [Parameter(Mandatory=$false)]  [string] $ProductShortName = (Get-WiXLocalConfig -ProductShortName -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).ProductShortName,
    [Parameter(Mandatory=$false)]  [string] $ProductName = (Get-WiXLocalConfig -ProductName -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).ProductName,
    [Parameter(Mandatory=$false)]  [string] $ProductVersion = (Get-WiXLocalConfig -ProductVersion -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).ProductVersion,
    [Parameter(Mandatory=$false)]  [string] $Manufacturer = (Get-WiXLocalConfig -Manufacturer -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).Manufacturer,
    [Parameter(Mandatory=$false)]  [string] $HelpLink = (Get-WiXLocalConfig -HelpLink -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).HelpLink,
    [Parameter(Mandatory=$false)]  [string] $AboutLink = (Get-WiXLocalConfig -AboutLink -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).AboutLink,
    [Parameter(Mandatory=$false)]  [string] $UpgradeCodeX86 = (Get-WiXLocalConfig -UpgradeCodeX86 -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).UpgradeCodeX86,
    [Parameter(Mandatory=$false)]  [string] $UpgradeCodeX64 = (Get-WiXLocalConfig -UpgradeCodeX64 -File ((Resolve-Path (Join-Path $Path ".wix\settings.json")).path) ).UpgradeCodeX64,
    [Parameter(Mandatory=$false)]  [int]    $Increment = 3,
    [Parameter(Mandatory=$false)]  [switch] $NoX86,
    [Parameter(Mandatory=$false)]  [switch] $NoX64
  )
  #(Resolve-Path (Join-Path $Path ".wix\settings.json")).path
    # Increment version number if requested
  If ($Increment -gt 0) {
    $versionArray = $ProductVersion.split(".")
    If ($Increment -gt $versionArray.length) {
      $extraDigits = $Increment - $versionArray.length
      for ($i=0;$i -lt $extraDigits-1; $i++){
        $versionArray += "0"
      }
      $versionArray += "1"
    }
    else {
      $versionArray[$Increment - 1] = [string]([int]($versionArray[$Increment - 1]) + 1)
    }
    $NewProductVersion = $versionArray -Join "."
    Set-WixLocalConfig -ProductVersion $NewProductVersion | Out-Null
  }

  # MSI IDs
  $productId = ConvertTo-WixNeutralString($ProductShortName)
  
  # Date and time
  $timeStamp = (Get-Date -format yyyyMMddHHmmss)
  
  # WiX paths
  #$libDir = Join-Path $PSScriptRoot "lib"
  If ((Get-ChildItem -Path 'C:\Program Files*\WiX*\' -Filter heat.exe -Recurse)){
    $wixDir = Split-Path ((((Get-ChildItem -Path 'C:\Program Files (x86)\WiX*\' -Filter heat.exe -Recurse) | Select-Object FullName)[0]).FullName)
  }
  Else {
    Throw "Please install WiX Toolset"
    Return
  }
  
  #$wixDir = Join-Path $libdir "wix"
  $heatExe = Join-Path $wixDir "heat.exe"
  $candleExe = Join-Path $wixDir "candle.exe"
  $lightExe = Join-Path $wixDir "light.exe"
  
  
  # Other paths
  $thisModuleName = ConvertTo-WixNeutralString($MyInvocation.MyCommand.ModuleName)
  $tmpDirGlobalRoot = Join-Path $Env:TMP $thisModuleName
  $tmpDirThisRoot = Join-Path $tmpDirGlobalRoot $productId
  $tmpDir = Join-Path $tmpDirThisRoot $timeStamp

  $varName = "var." + $productId
  $oldMsi = Join-Path $OutputFolder ($productID + '*' + ".msi")
  $cabFileName = $productId + ".msi"
  
  $moduleIconFile = Join-Path $PSScriptRoot "icon.ico"
  $moduleBannerFile = Join-Path $PSScriptRoot "banner.bmp"
  $moduleDialogFile = Join-Path $PSScriptRoot "dialog.bmp"
  
  $tmpIconFile = Join-Path $tmpDir "icon.ico"
  $tmpBannerFile = Join-Path $tmpDir "banner.bmp"
  $tmpDialogFile = Join-Path $tmpDir "dialog.bmp"
  
  # MSI IDs
  $productId = ConvertTo-WixNeutralString($ProductShortName)
  
    
  # Create tmp folder
  if (test-path $tmpDir) {
    Remove-Item $tmpDir -Recurse
  }
  New-Item $tmpDir -ItemType directory | Out-Null
  
  # Add license
  if (test-path $LicenseFile) {
    $licenseCmd = @"
<WixVariable Id="WixUILicenseRtf" Value="$LicenseFile"></WixVariable>
"@

  # Add icon
  if (test-path $IconFile) {
     Copy-Item $IconFile $tmpIconFile
  }
  elseif (test-path $moduleIconFile){
    Copy-Item $moduleIconFile $tmpIconFile
  }
  if (test-path $tmpIconFile) {
    $iconCmd = @"
<Icon Id="icon.ico" SourceFile="$tmpIconFile"/>
<Property Id="ARPPRODUCTICON" Value="icon.ico" />
"@
  }

  # Add banner graphic
  if (test-path $BannerFile) {
     Copy-Item $BannerFile $tmpBannerFile
  }
  elseif (test-path $moduleBannerFile){
    Copy-Item $moduleBannerFile $tmpBannerFile
  }
  if (test-path $tmpBannerFile) {
    $bannerCmd = @"
<WixVariable Id="WixUIBannerBmp" Value="$tmpBannerFile"></WixVariable>
"@
  }

  # Add dialog graphic
  if (test-path $DialogFile) {
     Copy-Item $DialogFile $tmpDialogFile
  }
  elseif (test-path $moduleDialogFile){
    Copy-Item $moduleDialogFile $tmpDialogFile
  }
  if (test-path $tmpDialogFile) {
    $dialogCmd = @"
<WixVariable Id="WixUIDialogBmp" Value="$tmpDialogFile"></WixVariable>
"@
  }

  }
  
  # Platform settings
  $platforms = @()
  
  $x86Settings = @{ 'arch' = 'x86';
                    'sysFolder' = 'SystemFolder';
                    'upgradeCode' = $UpgradeCodeX86;
                    'productName' = "${ProductName} (x86)";
                    'outputMsi' = (Join-Path $OutputFolder ($productID + "_" + $ProductVersion + "_x86.msi"))}
  $x64Settings = @{ 'arch' = 'x64';
                    'sysFolder' = 'System64Folder';
                    'upgradeCode' = $UpgradeCodeX64;
                    'productName' = "${ProductName} (x64)";
                    'outputMsi' = (Join-Path $OutputFolder ($productID + "_" + $ProductVersion + "_x64.msi"))                    }
  
  If (!$Nox86) {
    $platforms += $x86Settings
  }
  If (!$Nox64) {
    $platforms += $x64Settings
  }

  # Remove existing MSIs
  Remove-Item $oldMsi
  
  # Do the build
  foreach ($platform in $platforms) {
    $platformArch = $platform.arch
    $platformUpgradeCode = $platform.upgradeCode
    $platformSysFolder = $platform.sysFolder
    $platformProductName = $platform.productName
    $platformOutputMsi = $platform.outputMsi
    
    $modulesWxs = Join-Path $tmpDir "_modules${platformArch}.wxs"
    $productWxs = Join-Path $tmpDir ".wxs${platformArch}"
    $modulesWixobj = Join-Path $tmpDir "_modules${platformArch}.wixobj"
    $productWixobj = Join-Path $tmpDir ".wixobj${platformArch}"
    $productPdb = Join-Path $tmpDir ($productID + ".wizpdb${platformArch}")

    # Build XML
    $wixXml = [xml] @"
<?xml version="1.0" encoding="utf-8"?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'> 
  <Product Id="*" Language="1033" Name="$platformProductName" Version="$ProductVersion"
           Manufacturer="$Manufacturer" UpgradeCode="$platformUpgradeCode" >
    
    <Package Id="*" Description="$platformProductName Installer" 
             InstallPrivileges="elevated" Comments="$ProductShortName Installer" 
             InstallerVersion="200" Compressed="yes" Platform="$platformArch">
    </Package>
    $iconCmd
    <Upgrade Id="$platformUpgradeCode">
      <!-- Detect any newer version of this product -->
      <UpgradeVersion Minimum="$ProductVersion" IncludeMinimum="no" OnlyDetect="yes"
                      Language="1033" Property="NEWPRODUCTFOUND" />

      <!-- Detect and remove any older version of this product -->
      <UpgradeVersion Maximum="$ProductVersion" IncludeMaximum="yes" OnlyDetect="no"
                      Language="1033" Property="OLDPRODUCTFOUND" />
    </Upgrade>
    
    <!-- Define a custom action -->
    <CustomAction Id="PreventDowngrading"
                  Error="Newer version already installed." />

    <InstallExecuteSequence>
      <!-- Prevent downgrading -->
      <Custom Action="PreventDowngrading" After="FindRelatedProducts">
        NEWPRODUCTFOUND
      </Custom>
      <RemoveExistingProducts After="InstallFinalize" />
    </InstallExecuteSequence>

    <InstallUISequence>
      <!-- Prevent downgrading -->
      <Custom Action="PreventDowngrading" After="FindRelatedProducts">
        NEWPRODUCTFOUND
      </Custom>
    </InstallUISequence>
    
    <Media Id="1" Cabinet="$cabFileName" EmbedCab="yes"></Media>
    $licenseCmd
    $bannerCmd
    $dialogCmd
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="$platformSysFolder" Name="$platformSysFolder">
        <Directory Id="WindowsPowerShell" Name="WindowsPowerShell">
          <Directory Id="v10" Name="v1.0">
            <Directory Id="INSTALLDIR" Name="Modules">
              <Directory Id="$ProductId" Name="$ProductShortName">
              </Directory>
            </Directory>
          </Directory> 
        </Directory>
      </Directory>
    </Directory>
    <Property Id="ARPHELPLINK" Value="$HelpLink"></Property>
    <Property Id="ARPURLINFOABOUT" Value="$AboutLink"></Property>
    <Feature Id="$ProductId" Title="$ProductShortName" Level="1"
             ConfigurableDirectory="INSTALLDIR">
      <ComponentGroupRef Id="$ProductId">
      </ComponentGroupRef>
    </Feature>
    <UI></UI>
    <UIRef Id="WixUI_InstallDir"></UIRef>
    <Property Id="WIXUI_INSTALLDIR" Value="INSTALLDIR"></Property>
  </Product>
</Wix>
"@

    # Save XML and create productWxs
    $wixXml.Save($modulesWxs)
    &$heatExe dir $Path -nologo -sfrag -sw5151 -suid -ag -srd -dir $productId -out $productWxs -cg $productId -dr $productId | Out-Null
    
    # Produce wixobj files
    &$candleexe $modulesWxs -out $modulesWixobj | Out-Null
    &$candleexe $productWxs -out $productWixobj | Out-Null
    
    # Produce the MSI file
    &$lightexe -sw1076 -spdb -ext WixUIExtension -out $platformOutputMsi $modulesWixobj $productWixobj -b $Path -sice:ICE91 -sice:ICE69 -sice:ICE38 -sice:ICE57 -sice:ICE64 -sice:ICE204 -sice:ICE80 | Out-Null
    
  }
  # Remove tmp dir
  Remove-Item $tmpDir -Recurse
} #end Start-WixBuild
