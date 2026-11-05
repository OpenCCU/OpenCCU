#!/usr/bin/env python3
"""Print the "OpenCCU-Base Changes" category of the release notes.

Usage: scripts/openccu-base-changes.py <openccu-base-dir> <old> <new> <limit>

The entries of the OpenCCU-Base component changelogs
(src/<component>/CHANGELOG.md) that are new between the OpenCCU-Base
revisions <old> and <new> are taken from scripts/changelog-sections.py of
the OpenCCU-Base checkout <openccu-base-dir> and shortened to one line each,
like the other categories of the release notes, with the pull requests
and the GitHub user names of the authors given at the end of the entry:

  - rfd: fix a request to the radio module getting the answer of another one (OpenCCU-Base#282, @jens-maus)

If the category does not fit into <limit> characters, the components with
the most text are replaced by one line each with a link to their changelog,
so every changed component keeps a line. Nothing is printed if both revisions are equal, one of
them is unknown or the OpenCCU-Base checkout does not have that script yet.
"""

import os
import re
import subprocess
import sys

TITLE = "#### 🧩 OpenCCU-Base Changes"
SCRIPT = "scripts/changelog-sections.py"
MAX_SUMMARY = 120
SKIPPED_SUBSECTION = "Migrated from OpenCCU patches"

LINK_RE = re.compile(r"\[([^\]]*)\]\(([^)\s]*)\)")
PULL_RE = re.compile(r"https://github\.com/OpenCCU/OpenCCU-Base/pull/(\d+)")
AUTHOR_RE = re.compile(r"(?:^|[\s,(])@([A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)\b")
# the end of the first sentence or clause, but not "e.g." or "i.e."
SENTENCE_RE = re.compile(r"(?<!e\.g)(?<!i\.e)[.:;](?=\s|$)")


def entries(markdown):
    """Return [(component, text), ...] of the "* " entries of the output of
    changelog-sections.py, with the lines of each entry joined. Entries of a
    "Migrated from OpenCCU patches" subsection are left out: OpenCCU already
    contained these changes as rootfs patches."""
    result = []
    component = None
    skip = False
    entry = None
    for line in markdown.splitlines():
        if line.startswith("### "):
            component = line[4:].strip()
            skip = False
            entry = None
        elif line.startswith("#### ") or line.startswith("##### "):
            skip = line.lstrip("#").strip().startswith(SKIPPED_SUBSECTION)
            entry = None
        elif line.startswith("* ") and component and not skip:
            entry = [line[2:]]
            result.append((component, entry))
        elif entry is not None and line.startswith("  "):
            entry.append(line)
        else:
            entry = None
    return [(c, " ".join(" ".join(e).split())) for c, e in result]


def references(text):
    """Return (text, refs) of a changelog entry, split before its closing
    parenthesis of references: links to pull requests and issues and the
    GitHub user names of the authors, e.g. "([#1](...), fixes [#2](...), @a)"
    or "(@a)". refs is empty if the entry has no such parenthesis."""
    if text.endswith(")"):
        depth = 0
        for i in range(len(text) - 1, -1, -1):
            depth += {")": 1, "(": -1}.get(text[i], 0)
            if depth == 0:
                inner = text[i + 1:-1]
                if "](" in inner or AUTHOR_RE.search(LINK_RE.sub("", inner)):
                    return text[:i].rstrip(), inner
                break
    return text, ""


def summarize(text):
    """Return (summary, pulls, authors) of a changelog entry: its first
    sentence or clause without parentheses and links, the OpenCCU-Base pull
    request numbers it references and the GitHub user names of its
    authors."""
    pulls = []
    for _, url in LINK_RE.findall(text):
        match = PULL_RE.fullmatch(url)
        if match and match.group(1) not in pulls:
            pulls.append(match.group(1))
    text, refs = references(text)
    authors = list(dict.fromkeys(AUTHOR_RE.findall(LINK_RE.sub("", refs))))
    # an entry ending with a bare link, e.g. "[#1](...)"
    text = re.sub(r"\s*\[[^\]]*\]\([^)\s]*\)\s*$", "", text)
    text = LINK_RE.sub(r"\1", text).strip()
    text = re.sub(r"^patch \d+: ", "", text)
    match = SENTENCE_RE.search(text)
    if match:
        text = text[:match.start()]
    text = re.sub(r" \([^()]*\)", "", text).strip(" ,")
    if len(text) > MAX_SUMMARY:
        cut = text.rfind(", ", 0, MAX_SUMMARY)
        if cut < MAX_SUMMARY // 2:
            cut = text.rfind(" ", 0, MAX_SUMMARY)
        text = text[:cut].rstrip(" ,") + " …"
    if text.count("`") % 2:
        text = text[:text.rfind("`")].rstrip(" ,") + " …"
    return text, pulls, authors


def lines(markdown, url):
    """Return the release note lines of the entries, one per entry."""
    result = []
    for component, text in entries(markdown):
        summary, pulls, authors = summarize(text)
        refs = ", ".join([f"[OpenCCU-Base#{n}]({url}/pull/{n})" for n in pulls]
                         + [f"@{a}" for a in authors])
        line = f"- {component}: {summary}" + (f" ({refs})" if refs else "")
        if line not in result:
            result.append(line)
    return result


def main():
    """Print the OpenCCU-Base category within the given limit."""
    if len(sys.argv) != 5:
        sys.exit(__doc__.split("\n\n")[1])
    base_dir, old, new, limit = sys.argv[1:4] + [int(sys.argv[4])]
    if not old or not new or old == new or \
            not os.path.isfile(os.path.join(base_dir, SCRIPT)):
        return
    url = os.environ.get("GITHUB_SERVER_URL", "https://github.com") + \
        "/OpenCCU/OpenCCU-Base"
    markdown = subprocess.run(["python3", SCRIPT, old, new], cwd=base_dir,
                              check=True, capture_output=True,
                              text=True).stdout
    body = lines(markdown, url)
    if not body:
        return
    # the lines of each component, to replace the largest components by a
    # line with a link to their changelog until the category fits
    groups = {}
    for line in body:
        groups.setdefault(line[2:line.index(":")], []).append(line)
    linked = set()
    while True:
        text = "\n".join([TITLE, "", *(l for g in groups.values() for l in g)])
        text += "\n"
        if len(text) <= limit:
            print(text, end="")
            return
        rest = [c for c in groups if c not in linked]
        if not rest:
            break
        component = max(rest, key=lambda c: len("\n".join(groups[c])))
        count = len(groups[component])
        groups[component] = [
            f"- {component}: {count} change{'s' if count > 1 else ''}, see its "
            f"[changelog]({url}/blob/{new}/src/{component}/CHANGELOG.md)"]
        linked.add(component)
    # not even one line per component fits
    text = f"{TITLE}\n\n- see the [full commit log]({url}/compare/{old}...{new})\n"
    if len(text) <= limit:
        print(text, end="")


if __name__ == "__main__":
    main()
