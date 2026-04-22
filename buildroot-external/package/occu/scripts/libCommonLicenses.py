import os
import hashlib

def buildCommonLicensesDict():
    commonLicensesDict = {}
    commonLicensesDir = os.path.join(os.path.dirname(__file__), 'common-licenses')
    if os.path.exists(commonLicensesDir):
        for licFile in sorted(os.scandir(commonLicensesDir), key=lambda e: e.name):
            if licFile.is_file():
                with open(licFile.path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    contentNoWhitespace = ''.join(content.split())
                    commonLicensesDict[licFile.name] = hashlib.sha256(
                            contentNoWhitespace.encode('utf-8')
                    ).hexdigest()
    return commonLicensesDict

def checkCommonLicenses(licenseText, commonLicensesDict):
    licenseTextNoWhitespace = ''.join(licenseText.split()).encode('utf-8')
    licenseHash = hashlib.sha256(licenseTextNoWhitespace).hexdigest()
    for licName, licHash in commonLicensesDict.items():
        if licenseHash == licHash:
            return licName
    return None
