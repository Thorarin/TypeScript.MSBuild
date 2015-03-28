$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

# Some defaults used for most tests
$toolsPath = 'C:\Project\packages\PackageName.1.0.0\tools'
$paths = Get-Paths $toolsPath

# Tests
Describe "Get-Paths" {
    It "gets package directory from tools path" {
        $paths = Get-Paths "C:\packages\PackageDir.1.0.0\tools"
        $paths.Targets.Contains('\packages\PackageDir.1.0.0\') | Should Be $true
    }
}

Describe "ModifyProjectFile" {
    It "replaces imports when conditions are present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" Condition="Exists('$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props')" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" Condition="Exists('$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets')" />
</Project>
'@

        ModifyProjectFile "A" $toolsPath 'TypeScript.MSBuild' $xml

        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Props)`" Condition=`"Exists('$($paths.Props)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Targets)`" Condition=`"Exists('$($paths.Targets)')`" />") | Should Be $true
    }
    
    It "replaces imports without conditions present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" />
</Project>
'@

        ModifyProjectFile "A" $toolsPath 'TypeScript.MSBuild' $xml
        
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Props)`" Condition=`"Exists('$($paths.Props)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Targets)`" Condition=`"Exists('$($paths.Targets)')`" />") | Should Be $true
    }
}

Describe "RestoreProjectFile" {
    It "replaces imports when conditions are present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(ProjectDir)\..\packages\PackageName.1.0.0\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props')" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(ProjectDir)\..\packages\PackageName.1.0.0\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets')" />
</Project>
'@

        RestoreProjectFile "A" $toolsPath 'TypeScript.MSBuild' $xml

        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalProps)`" Condition=`"Exists('$($paths.OriginalProps)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
           "<Import Project=`"$($paths.OriginalTargets)`" Condition=`"Exists('$($paths.OriginalTargets)')`" />") | Should Be $true

    }
    
    It "replaces imports without conditions present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(ProjectDir)\..\packages\PackageName.1.0.0\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(ProjectDir)\..\packages\PackageName.1.0.0\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" />
</Project>
'@

        RestoreProjectFile "A" $toolsPath 'TypeScript.MSBuild' $xml
        
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalProps)`" Condition=`"Exists('$($paths.OriginalProps)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalTargets)`" Condition=`"Exists('$($paths.OriginalTargets)')`" />") | Should Be $true
    }
    
    It "replaces imports when TypeScript version is newer" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(ProjectDir)\..\packages\PackageName.1.0.0\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props')" />
  <PropertyGroup>
    <TypeScriptToolsVersion>2.0</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(ProjectDir)\..\packages\PackageName.1.0.0\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets')" />
</Project>
'@

        RestoreProjectFile "A" $toolsPath 'TypeScript.MSBuild' $xml

        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalProps)`" Condition=`"Exists('$($paths.OriginalProps)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
           "<Import Project=`"$($paths.OriginalTargets)`" Condition=`"Exists('$($paths.OriginalTargets)')`" />") | Should Be $true

    }    
    
    It "throws no error when imports are missing" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
</Project>
'@

        { RestoreProjectFile "A" $toolsPath 'TypeScript.MSBuild' $xml } | Should Not Throw
    }    
}
