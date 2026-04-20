#!/usr/bin/env python3
#
# Copyright [2026] [eQ-3 AG]
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

import os
import argparse
import csv

def parse_args():
    parser = argparse.ArgumentParser(description='Create LICENSE.html from manifest.csv and license information created by buildroot "make legal-info" command.')
    parser.add_argument('--build-dir', required=True, type=str, default='', help='Path to build dir. For example: build-generic-x86_64')
    parser.add_argument('--output', type=str, default='license.html', help='Path to output LICENSE.html file.')
    return parser.parse_args()


def parseManfifest(manifest_path):
    entries = []
    with open(manifest_path, 'r') as f:
        # use csv.DictReader to properly parse CSV with quoted values
        reader = csv.DictReader(f)
        for row in reader:
            #print(row)  
            entries.append(row)
    return entries

def getLicenseTexts(packageSubdir):
    print(f'Looking for license files in {packageSubdir}...')
    licenseText = ''
    if os.path.exists(packageSubdir):
        # walk through directory recursively to find the license files
        for licFile in os.scandir(packageSubdir):
            if licFile.is_file():
                with open(licFile.path, 'r', errors='ignore') as f:
                    licenseText += licFile.name + ':\n'
                    licenseText += f.read() + '\n\n'
    return licenseText          

def main():
    args = parse_args()
    legalInfoDir = os.path.join(args.build_dir, 'legal-info')
    
    manifestEntries = parseManfifest( os.path.join(args.build_dir, 'legal-info','manifest.csv') )
    with open(args.output, 'w') as f:
        f.write('<html><body>\n')
        #write a table of contents 
        f.write('<h1>Open Source Software License Information</h1>\n')

        # german written offer for GPL compliance
        f.write('<p>Diese Software enthält freie Software Dritter, die unter verschiedenen Lizenzbedingungen weitergegeben wird. Eine Auflistung der freien Software, die in dieser Software zum Einsatz kommt, sowie die Lizenzbedingungen unter denen diese weitergegeben wird, finden Sie anbei.</p>\n')
        f.write('<p>Die Veröffentlichung der freien Software erfolgt, „wie es ist“, OHNE IRGENDEINE GARANTIE. Unsere gesetzliche Haftung bleibt hiervon unberührt.</p>\n')
        f.write('<p>Sofern die jeweiligen Lizenzbedingungen es erfordern, stellen wir Ihnen eine vollständige maschinenlesbare Kopie des Quelltextes der freien Software zur Verfügung. Kontaktieren Sie uns hierfür bitte unter support@eq-3.com.</p>\n')      
        f.write('<hr/>')
        # english written offer for GPL compliance
        f.write('<p>This software contains free third party software products used under various license conditions. A list of free software to be used and the license conditions under which the particular free software will be passed on, can be found enclosed below.</p>')
        f.write('<p>The software is provided “as is” WITHOUT ANY WARRANTY. Our legal liability remains thereby unaffected.</p>\n')
        f.write('<p>Whenever required by the particular license, we provide you with a complete and machine-readable copy of the free software source text.  Therefor please contact us at support@eq-3.com.</p>\n')
        f.write('<hr/>\n')

        f.write('<h2>Packages</h2>\n')
        for entry in manifestEntries:
            package = entry.get('PACKAGE', 'Unknown Package')
            f.write(f'<p><a href="#{package}">{package} {entry["VERSION"]}</a></p>\n')

        for entry in manifestEntries:
            package = entry.get('PACKAGE', '')
            version = entry.get('VERSION', '')
            licenseSubdir = package + '-' + version
            f.write(f'<h3 id="{package}">{entry["PACKAGE"]} {entry["VERSION"]}</h3>\n')
            f.write(f'<p>License: {entry["LICENSE"]}</p>\n')
            f.write(f'<p>Source Site: {entry["SOURCE SITE"]}</p>\n')
            
            if package != '' and version != '':
                packageSubdir = os.path.join(legalInfoDir, 'licenses', licenseSubdir)
                f.write('<pre>' + getLicenseTexts(packageSubdir) + '</pre>\n')
            f.write('<hr/>\n')

        f.write('<h2>Licenses</h2>\n')
        f.write('</body></html>\n')

if __name__ == '__main__':
    main()