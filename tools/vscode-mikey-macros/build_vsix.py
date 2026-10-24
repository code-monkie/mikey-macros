#!/usr/bin/env python3
"""Builds the mikey-macros lint VS Code extension into a .vsix file.

    python tools/vscode-mikey-macros/build_vsix.py

No Node or npm needed: a .vsix is a zip with a manifest. The file lands next
to this script; install it in VS Code with Extensions > ... > Install from
VSIX..., or `code --install-extension <file>.vsix`.
"""
import json
import os
import zipfile
from xml.sax.saxutils import escape

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "extension")
LICENSE = os.path.join(HERE, "..", "..", "LICENSE")

pkg = json.load(open(os.path.join(SRC, "package.json"), encoding="utf-8"))
out = os.path.join(HERE, "%s-%s.vsix" % (pkg["name"], pkg["version"]))

manifest = """<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema-design/2011">
  <Metadata>
    <Identity Language="en-US" Id="{name}" Version="{version}" Publisher="{publisher}" />
    <DisplayName>{display}</DisplayName>
    <Description xml:space="preserve">{description}</Description>
    <Tags>{tags}</Tags>
    <Categories>{categories}</Categories>
    <GalleryFlags>Public</GalleryFlags>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="{engine}" />
      <Property Id="Microsoft.VisualStudio.Code.ExtensionKind" Value="workspace" />
    </Properties>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code" />
  </Installation>
  <Dependencies />
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true" />
    <Asset Type="Microsoft.VisualStudio.Services.Content.Details" Path="extension/README.md" Addressable="true" />
    <Asset Type="Microsoft.VisualStudio.Services.Content.License" Path="extension/LICENSE.txt" Addressable="true" />
  </Assets>
</PackageManifest>
""".format(
    name=escape(pkg["name"]), version=escape(pkg["version"]), publisher=escape(pkg["publisher"]),
    display=escape(pkg["displayName"]), description=escape(pkg["description"]),
    tags=escape(",".join(pkg.get("keywords", []))), categories=escape(",".join(pkg.get("categories", []))),
    engine=escape(pkg["engines"]["vscode"]),
)

content_types = """<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension=".json" ContentType="application/json" />
  <Default Extension=".js" ContentType="application/javascript" />
  <Default Extension=".md" ContentType="text/markdown" />
  <Default Extension=".txt" ContentType="text/plain" />
  <Default Extension=".vsixmanifest" ContentType="text/xml" />
</Types>
"""

with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", content_types)
    z.writestr("extension.vsixmanifest", manifest)
    for folder, _, names in os.walk(SRC):
        for name in sorted(names):
            full = os.path.join(folder, name)
            z.write(full, "extension/" + os.path.relpath(full, SRC).replace(os.sep, "/"))
    z.write(LICENSE, "extension/LICENSE.txt")

print("built", os.path.relpath(out))
