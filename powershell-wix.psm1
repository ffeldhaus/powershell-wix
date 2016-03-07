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
    configuration.  Configuration is returned from (in order of preference):
    
     - a JSON formatted config file (default location: '.WiX\settings.json')
     - from sensible default values
     - from user input
     
    Individual configuration values can also be selected.  If no configuration
    values are selected, all values contained in the file and defaults will be
    returned, but the user will not be prompted for missing values.
   .Example
    Get-WixLocalConfig
    Gets local WiX configuration from '.WiX\settings.json'.
   .Parameter File
    An alternative configuration file.
   .Parameter UpgradeCode
    Include "UpgradeCode" in returned object.
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
    [Parameter(Mandatory=$false)]  [switch] $UpgradeCode
  ) #end Param
  $defaults = @{'ProductShortName' = (Split-Path (Get-Location) -Leaf);
                'ProductName' = (Split-Path (Get-Location) -Leaf);
                'ProductVersion' = '1.0.0';
                'Manufacturer' = (Split-Path (Get-Location) -Leaf);
                'HelpLink' = ("http://www.google.com/q=" + 
                    (Split-Path (Get-Location) -Leaf));
                'AboutLink' = ("http://www.google.com/q=" + 
                    (Split-Path (Get-Location) -Leaf));
                'UpgradeCode' = (New-WixUid)}
  $settings = New-Object -TypeName PSCustomObject
  $readSettings = New-Object -TypeName PSCustomObject
  $params = $PSBoundParameters.GetEnumerator()|
            Where-Object {($_.Key -ne 'File')}
  
  if (Test-Path $File){
    try {
      $readSettings = Get-Content -Raw $File | ConvertFrom-Json
    } catch {}
  }
  foreach ($parameter in $params){
    $setting = $parameter.Key
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
    $null = (New-Item -ItemType Directory -Force -Path (Split-Path $File))
    $settings | ConvertTo-JSON | Out-File $File 
    
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
    Set-WixLocalConfig -UpgradeCode "YOURGUID-GOES-HERE-0123-012345678901"
    Sets the UpgradeCode setting in default config file '.WiX\settings.json'.
   .Parameter File
    An alternative configuration file.
   .Parameter Replace
    Replace all existing configuration with new settings.
   .Parameter UpgradeCode
    Set "UpgradeCode" value.
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
    [Parameter(Mandatory=$false, ParameterSetName="Strings")][string] $UpgradeCode
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
    Converts a PowerShell module folder to an installable MSI file.
   .Description
    This function uses the WiX Toolset to convert a directory containing a
    PowerShell module to an installable MSI file.
   .Example

   .Parameter X

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
    [Parameter(Mandatory=$false)]  [string] $LicenseFile = "$Path\License.rft",
    [Parameter(Mandatory=$false)]  [string] $ProductShortName = (Get-WiXLocalConfig -ProductShortName).ProductShortName,
    [Parameter(Mandatory=$false)]  [string] $ProductName = (Get-WiXLocalConfig -ProductName).ProductName,
    [Parameter(Mandatory=$false)]  [string] $ProductVersion = (Get-WiXLocalConfig -ProductVersion).ProductVersion,
    [Parameter(Mandatory=$false)]  [string] $Manufacturer = (Get-WiXLocalConfig -Manufacturer).Manufacturer,
    [Parameter(Mandatory=$false)]  [string] $HelpLink = (Get-WiXLocalConfig -HelpLink).HelpLink,
    [Parameter(Mandatory=$false)]  [string] $AboutLink = (Get-WiXLocalConfig -AboutLink).AboutLink,
    [Parameter(Mandatory=$false)]  [string] $UpgradeCode = (Get-WiXLocalConfig -UpgradeCode).UpgradeCode,
    [Parameter(Mandatory=$false)]  [int]    $Increment = 3,
    [Parameter(Mandatory=$false)]  [switch] $x86
  )
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
  If ((((Get-ChildItem -Path 'C:\Program Files*\WiX*\' -Filter heat.exe -Recurse) | Select-Object FullName)[0]).FullName){
    $wixDir = Split-Path ((((Get-ChildItem -Path 'C:\Program Files (x86)\WiX*\' -Filter heat.exe -Recurse) | Select-Object FullName)[0]).FullName)
  }
  Else {
    Out-Host "Please install WiX Toolset"
    exit 1
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
  $modulesWxs = Join-Path $tmpDir "_modules.wxs"
  $productWxs = Join-Path $tmpDir ".wxs"
  $modulesWixobj = Join-Path $tmpDir "_modules.wixobj"
  $productWixobj = Join-Path $tmpDir ".wixobj"
  $varName = "var." + $productId
  $outputMsi = Join-Path $OutputFolder ($productID + $ProductVersion + ".msi")
  $oldMsi = Join-Path $OutputFolder ($productID + '*' + ".msi")
  $productPdb = Join-Path $tmpDir ($productID + ".wizpdb")
  $cabFileName = $productId + ".msi"
  
  # MSI IDs
  $productId = ConvertTo-WixNeutralString($ProductShortName)
  
  #Platform
  If ($x86) {
    $platform = "x86"
    $sysFolder = "SystemFolder"
  }
  else {
    $platform = "x64"
    $sysFolder = "System64Folder"
  }

  # Add license
  if (test-path $LicenseFile) {
    $licenseCmd = @"
<WixVariable Id="WixUILicenseRtf" Value="License.rtf"></WixVariable>
"@
  }
  $wixXml = [xml] @"
<?xml version="1.0" encoding="utf-8"?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'> 
  <Product Id="*" Language="1033" Name="$ProductName" Version="$ProductVersion"
           Manufacturer="$Manufacturer" UpgradeCode="$UpgradeCode" >
    
    <Package Id="*" Description="$ProductName Installer" 
             InstallPrivileges="elevated" Comments="$ProductShortName Installer" 
             InstallerVersion="200" Compressed="yes" Platform="$platform">
    </Package>
    
    <Upgrade Id="$UpgradeCode">
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
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="$sysFolder" Name="$sysFolder">
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
  
  # Create tmp folder
  if (test-path $tmpDir) {
    Remove-Item $tmpDir -Recurse
  }
  New-Item $tmpDir -ItemType directory | Out-Null
  
  # Remove existing MSIs
  Remove-Item $oldMsi
  
  # Save XML and create productWxs
  $wixXml.Save($modulesWxs)
  &$heatExe dir $Path -nologo -sfrag -sw5151 -suid -ag -srd -dir $productId -out $productWxs -cg $productId -dr $productId | Out-Null
  
  # Produce wixobj files
  &$candleexe $modulesWxs -out $modulesWixobj | Out-Null
  &$candleexe $productWxs -out $productWixobj | Out-Null
  
  # Produce the MSI file
  &$lightexe -sw1076 -spdb -ext WixUIExtension -out $outputMsi $modulesWixobj $productWixobj -b $Path -sice:ICE91 -sice:ICE69 -sice:ICE38 -sice:ICE57 -sice:ICE64 -sice:ICE204 -sice:ICE80 | Out-Null
  
  # Remove tmp dir
  Remove-Item $tmpDir -Recurse
  
} #end Start-WixBuild
