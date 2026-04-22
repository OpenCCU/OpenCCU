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
import zipfile
import re
import html2text
import libCommonLicenses
import logging

commonLicenses = {}

log = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser(
        description=(
            'Extract license information from HMIPServer/HMServer/'
            'ESHBridge jar files.'
        )
    )
    parser.add_argument(
        '--packagedir',
        required=True,
        type=str,
        default='',
        help='Path to the package directory containing the jar file.',
    )
    parser.add_argument(
        '--jarfile',
        required=True,
        type=str,
        default='',
        help='jar filename.'
    )
    parser.add_argument(
        '--output',
        type=str,
        default='',
        help='Path to output license info file. If not specified, the output file will be created in the same directory as the jar file with name <jarfile>-JARLICENSEINFO.txt'
    )
    parser.add_argument(
        '--logdir',
        type=str,
        default='',
        help='Path where logfile output should be written to. If not specified, the logfile will be written to the same path like the output licenseinfo file.'
    )
    return parser.parse_args()

def getLicenseInfoFromJarFile(jarFilePath):
    global log
    global commonLicenses
    if os.path.exists(jarFilePath):
        with zipfile.ZipFile(jarFilePath, mode='r') as jarchive:
            # extract and read the THIRD-PARTY.txt file from the jar
            namelist = jarchive.namelist()
            thirdPartyListing = ''
            for member in namelist:
                if member.endswith('THIRD-PARTY.txt'):
                    log.debug(f'Found THIRD-PARTY.txt in jar: {member}. Extracting license information from this file...')
                    with jarchive.open(member) as source:
                        thirdPartyListing = source.read().decode('utf-8', errors='ignore')
                    break
            # now extract and read license texts from jar if any exist
            # to do so we reduce namelist for entries in licenses subdir and 
            # collect the license texts in a set to avoid duplicates
            log.debug(f'Looking for license files in jar {jarFilePath}...')
            reg = re.compile('.*licenses/.+')
            namelist = list(filter(reg.match, namelist))
            converter = html2text.HTML2Text()
            converter.bypass_tables = True
            # converter.use_automatic_links = True
            converter.ignore_links = True
            converter.body_width = 120
            converter.ignore_images = True
            licenseTextsSet = set()
            for member in namelist:
                with jarchive.open(member) as source:
                    licenseText = ''
                    if member.lower().endswith(('.htm', '.html')):
                        licenseText = converter.handle(
                                source.read().decode('utf-8', errors='ignore')
                        )
                        log.debug(f'Converted HTML license {member} to text format.')
                    else:
                        licenseText = source.read().decode('utf-8', errors='ignore')
                    if libCommonLicenses.checkCommonLicenses(licenseText, commonLicenses) is None:
                        licenseTextsSet.add(licenseText)
            return thirdPartyListing, licenseTextsSet
    return None, None

def main():
    args = parse_args()

    outputFilePath = args.output if args.output else os.path.join(args.packagedir, args.jarfile + '-JARLICENSEINFO.txt')

    global log

    log = logging.getLogger(__name__)
    # Log both to file and console
    logFilePath = os.path.join(args.logdir if args.logdir else os.path.dirname(outputFilePath), args.jarfile + '-JARLICENSEINFO.log')
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(logFilePath, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )
    
    log.info(f'Starting license extraction for {args.jarfile}')
    log.info(f'Log file: {os.path.abspath(logFilePath)}')
    log.info(f'Package directory: {args.packagedir}')

    global commonLicenses
    commonLicenses = libCommonLicenses.buildCommonLicensesDict()

    jarFilePath = os.path.join(args.packagedir, args.jarfile)
    if not os.path.exists(jarFilePath):
        log.error(f'Jar file {jarFilePath} does not exist. Skipping license extraction for this jar.')
        raise FileNotFoundError(jarFilePath)
    thirdPartyListing, licenseTextsSet = getLicenseInfoFromJarFile(jarFilePath)
    log.info(f'Writing extracted license information to {outputFilePath}...')
    with open(outputFilePath, 'w', encoding='utf-8') as f:
        f.write(thirdPartyListing + '\n\n')
        f.write('License Texts:\n')
        for licenseText in sorted(licenseTextsSet):
            f.write(licenseText + '\n\n')
    log.info(f'License extraction completed successfully for {args.jarfile}')

if __name__ == '__main__':
    main()
