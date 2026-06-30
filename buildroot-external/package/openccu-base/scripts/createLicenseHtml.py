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
import html
import logging

import libCommonLicenses

commonLicensesDict = {}
log = logging.getLogger(__name__)
OUTPUT_ENCODING = 'iso-8859-1'

def html_text(value):
    return html.escape(str(value), quote=False)

def html_attr(value):
    return html.escape(str(value), quote=True)

def parse_args():
    parser = argparse.ArgumentParser(description='Create LICENSE.html from manifest.csv and license information created by buildroot "make legal-info" command.')
    parser.add_argument('--build-dir', required=True, type=str, default='', help='Path to build dir. For example: build-generic-x86_64')
    parser.add_argument('--output', type=str, default='license.html', help='Path to output LICENSE.html file.')
    parser.add_argument('--jar-license-info', action='append', type=str, help='Path to JAR license info file (JARLICENSEINFO.txt). Can be specified multiple times.')
    return parser.parse_args()

def parseManfifest(manifest_path):
    entries = []
    with open(manifest_path, 'r', encoding='utf-8', newline='') as f:
        # use csv.DictReader to properly parse CSV with quoted values
        reader = csv.DictReader(f)
        for row in reader:
            #print(row)  
            entries.append(row)
    return entries

def getLicenseTexts(packageSubdir):
    global log
    log.info(f'Looking for license files in {packageSubdir}...')
    licenseText = ''
    if os.path.exists(packageSubdir):
        # walk through directory recursively to find the license files
        for root, _, files in os.walk(packageSubdir):
            for fileName in sorted(files):
                licFilePath = os.path.join(root, fileName)
                licFileName = os.path.relpath(licFilePath, packageSubdir)
                with open(licFilePath, 'r', encoding='utf-8', errors='replace') as f:
                    content = f.read()
                commonLicenseName = libCommonLicenses.checkCommonLicenses(content, commonLicensesDict)
                if commonLicenseName:
                    licenseText += (
                            f'License-Text: <a href="#{html_attr(commonLicenseName)}">'
                            f'{html_text(commonLicenseName)}</a>\n'
                    )
                else:
                    licenseText += html_text(licFileName) + ':\n'
                    licenseText += html_text(content) + '\n\n'
    return licenseText          

def main():
    args = parse_args()
    global log
    logFilePath = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'createLicenseHtml.log')
    logging.basicConfig(filename=logFilePath, encoding='utf-8', level=logging.DEBUG)
    
    log.info('Starting license HTML creation process...')
    global commonLicensesDict
    commonLicensesDict = libCommonLicenses.buildCommonLicensesDict()
    
    legalInfoDir = os.path.join(args.build_dir, 'legal-info')
    log.debug(f'Parsing manifest.csv from {legalInfoDir}...')
    manifestEntries = parseManfifest( os.path.join(args.build_dir, 'legal-info','manifest.csv') )
    with open(args.output, 'w', encoding=OUTPUT_ENCODING, errors='xmlcharrefreplace') as f:
        log.debug('Writing written offer.')
        f.write(f'<!doctype html><html><head><meta charset="{OUTPUT_ENCODING}"></head><body>\n')
        #write a table of contents 
        f.write('<h1>Open Source Software License Information</h1>\n')

        # german written offer for GPL compliance
        f.write('<p>Diese Software enthält freie Software Dritter, die unter verschiedenen Lizenzbedingungen weitergegeben wird. Eine Auflistung der freien Software, die in dieser Software zum Einsatz kommt, sowie die Lizenzbedingungen unter denen diese weitergegeben wird, finden Sie anbei.</p>\n')
        f.write('<p>Die Veröffentlichung der freien Software erfolgt, "wie es ist", OHNE IRGENDEINE GARANTIE. Unsere gesetzliche Haftung bleibt hiervon unberührt.</p>\n')
        f.write('<p>Sofern die jeweiligen Lizenzbedingungen es erfordern, stellen wir Ihnen eine vollständige maschinenlesbare Kopie des Quelltextes der freien Software zur Verfügung. Kontaktieren Sie uns hierfür bitte unter support@eq-3.com.</p>\n')      
        f.write('<hr/>')
        # english written offer for GPL compliance
        f.write('<p>This software contains free third party software products used under various license conditions. A list of free software to be used and the license conditions under which the particular free software will be passed on, can be found enclosed below.</p>')
        f.write('<p>The software is provided "as is" WITHOUT ANY WARRANTY. Our legal liability remains thereby unaffected.</p>\n')
        f.write('<p>Whenever required by the particular license, we provide you with a complete and machine-readable copy of the free software source text.  Therefor please contact us at support@eq-3.com.</p>\n')
        f.write('<hr/>\n')

        # write table of contents for packages
        f.write('<h2>Packages</h2>\n')
        for entry in manifestEntries:
            package = entry.get('PACKAGE', 'Unknown Package')
            version = entry.get('VERSION', '')
            f.write(
                    f'<p><a href="#{html_attr(package)}">'
                    f'{html_text(package)} {html_text(version)}</a></p>\n'
            )
        f.write('<h2>Licenses</h2>\n')
        for licName in sorted(commonLicensesDict):
            f.write(f'<p><a href="#{html_attr(licName)}">{html_text(licName)}</a></p>\n')

        for entry in manifestEntries:
            log.info(f'Writing written offer for package {entry.get("PACKAGE", "")} {entry.get("VERSION", "")}.')
            package = entry.get('PACKAGE', '')
            version = entry.get('VERSION', '')
            licenseSubdir = package + '-' + version
            f.write(f'<h3 id="{html_attr(package)}">{html_text(package)} {html_text(version)}</h3>\n')
            f.write(f'<p>License: {html_text(entry.get("LICENSE", ""))}</p>\n')
            f.write(f'<p>Source Site: {html_text(entry.get("SOURCE SITE", ""))}</p>\n')
            
            if package != '' and version != '':
                packageSubdir = os.path.join(legalInfoDir, 'licenses', licenseSubdir)
                f.write('<pre>' + getLicenseTexts(packageSubdir) + '</pre>\n')
            f.write('<hr/>\n')
        
        #Add jar license info if specified
        if args.jar_license_info:
            for jarLicInfoFile in args.jar_license_info:
                log.info(f'Adding license information from jar license info file {jarLicInfoFile}...')
                if not os.path.isfile(jarLicInfoFile):
                    raise FileNotFoundError(f'JAR license info file not found: {jarLicInfoFile}')
                with open(jarLicInfoFile, 'r', encoding='utf-8', errors='replace') as fJarLic:
                    jarTitle = os.path.basename(jarLicInfoFile).replace('-JARLICENSEINFO.txt', '')
                    content = fJarLic.read()
                    f.write(f'<h2>License Information from {html_text(jarTitle)}</h2>\n')
                    f.write('<pre>' + html_text(content) + '</pre>\n')

        log.info('Writing common licenses...')
        f.write('<h2>Licenses</h2>\n')
        for licName in sorted(commonLicensesDict):
            f.write(f'<h3 id="{html_attr(licName)}">{html_text(licName)}</h3>\n')
            with open(
                    os.path.join(os.path.dirname(__file__), 'common-licenses', licName),
                    'r',
                    encoding='utf-8',
                    errors='replace',
            ) as fLic:
                content = fLic.read()
                f.write('<pre>' + html_text(content) + '</pre>\n')
        f.write('</body></html>\n')
        log.info('License HTML creation process completed.')

if __name__ == '__main__':
    main()
