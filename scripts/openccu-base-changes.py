#!/usr/bin/env python3
"""Print the "OpenCCU-Base Changes" category of the release notes.

Usage: scripts/openccu-base-changes.py <openccu-base-dir> <old> <new> <limit>

The entries of the OpenCCU-Base component changelogs
(src/<component>/CHANGELOG.md) that are new between the OpenCCU-Base
revisions <old> and <new> are taken from scripts/changelog-sections.py of
the OpenCCU-Base checkout <openccu-base-dir> and grouped by component: every
component is a heading linked to its changelog, with its new versions, and
every entry is shortened to one line, like the other categories of the
release notes, followed by all pull requests, issues and commits linked at
the end of the entry and the GitHub user names of its authors:

  ##### [rfd](https://github.com/OpenCCU/OpenCCU-Base/blob/<new>/src/rfd/CHANGELOG.md) 2.6.1 – 2.7.1
  - fix a request to the radio module getting the answer of another one ([OpenCCU-Base#282](...), @jens-maus)

If the category does not fit into <limit> characters, the entries of the
components with the most text are replaced by one line with a link to their
changelog, so every changed component keeps its heading. Nothing is printed
if both revisions are equal, one of them is unknown or the OpenCCU-Base
checkout does not have that script yet.
"""

import os
import re
import subprocess
import sys

TITLE = "#### 🧩 OpenCCU-Base Changes"
SCRIPT = "scripts/changelog-sections.py"
MAX_SUMMARY = 120
SKIPPED_SUBSECTION = "Migrated from OpenCCU patches"
# components without a version of their own: their changelog sections carry
# the OpenCCU-Base release, which is not repeated in their heading
RELEASE_VERSIONED = ("webui", "devicetypes", "hmipserver")

LINK_RE = re.compile(r"\[([^\]]*)\]\(([^)\s]*)\)")
# a pull request, an issue or a commit on GitHub
CHANGE_RE = re.compile(r"https://github\.com/([\w.-]+)/([\w.-]+)/"
                       r"(pull|issues|commit)/([0-9a-f]{7,40}|\d+)\b[^)\s]*")
AUTHOR_RE = re.compile(r"(?:^|[\s,(])@([A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)\b")
# the end of the first sentence or clause, but not "e.g." or "i.e."
SENTENCE_RE = re.compile(r"(?<!e\.g)(?<!i\.e)[.:;](?=\s|$)")
VERSION_RE = re.compile(r"^(\S+) \(\d{4}-\d{2}-\d{2}\)$")


def entries(markdown):
    """Return ([(component, text), ...], {component: [version, ...]}) of the
    output of changelog-sections.py: the "* " entries with the lines of each
    entry joined, and the new versions of every component (newest first).
    Entries of a "Migrated from OpenCCU patches" subsection are left out:
    OpenCCU already contained these changes as rootfs patches."""
    result = []
    versions = {}
    component = None
    skip = False
    entry = None
    for line in markdown.splitlines():
        if line.startswith("### "):
            component = line[4:].strip()
            skip = False
            entry = None
        elif line.startswith("#### ") and component:
            match = VERSION_RE.match(line[5:].strip())
            if match:
                versions.setdefault(component, []).append(match.group(1))
            skip = False
            entry = None
        elif line.startswith("##### "):
            skip = line.lstrip("#").strip().startswith(SKIPPED_SUBSECTION)
            entry = None
        elif line.startswith("* ") and component and not skip:
            entry = [line[2:]]
            result.append((component, entry))
        elif entry is not None and line.startswith("  "):
            entry.append(line)
        else:
            entry = None
    return [(c, " ".join(" ".join(e).split())) for c, e in result], versions


def references(text):
    """Return (text, refs) of a changelog entry, split before its closing
    parenthesis of references: links to pull requests, issues and commits
    and the GitHub user names of the authors, e.g.
    "([#1](...), fixes [#2](...), @a)", "(cf. [OpenCCU/OpenCCU#2](...))" or
    "(@a)". refs is empty if the entry has no such parenthesis."""
    text = text.rstrip(".")
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


def change_label(url):
    """Return the label of a link to a pull request, issue or commit:
    "OpenCCU-Base#1" / "OpenCCU#2" for the repositories of OpenCCU,
    "owner/repo#3" for others and the short hash for a commit."""
    owner, repo, kind, ref = CHANGE_RE.match(url).groups()
    if kind == "commit":
        return ref[:7]
    return f"{repo}#{ref}" if owner == "OpenCCU" else f"{owner}/{repo}#{ref}"


def summarize(text):
    """Return (summary, links, authors) of a changelog entry: its first
    sentence or clause without parentheses and links, the
    [(label, url), ...] of the pull requests, issues and commits linked in
    its closing parenthesis (and of OpenCCU-Base pull requests linked
    elsewhere in it) and the GitHub user names of its authors."""
    body, refs = references(text)
    links = []
    for _, url in LINK_RE.findall(refs) + LINK_RE.findall(body):
        match = CHANGE_RE.fullmatch(url)
        if not match:
            continue
        in_refs = (_, url) in LINK_RE.findall(refs)
        if not in_refs and (match.group(1, 2, 3) != ("OpenCCU", "OpenCCU-Base", "pull")):
            continue
        link = (change_label(url), url)
        if link not in links:
            links.append(link)
    authors = list(dict.fromkeys(AUTHOR_RE.findall(LINK_RE.sub("", refs))))
    text = body
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
    return text, links, authors


def groups(markdown):
    """Return {component: [line, ...]} of the release note lines of the
    entries, one per entry, and the versions of the components."""
    result = {}
    found, versions = entries(markdown)
    for component, text in found:
        summary, links, authors = summarize(text)
        refs = ", ".join([f"[{label}]({url})" for label, url in links]
                         + [f"@{a}" for a in authors])
        line = f"- {summary}" + (f" ({refs})" if refs else "")
        lines = result.setdefault(component, [])
        if line not in lines:
            lines.append(line)
    return result, versions


def heading(component, versions, url, new):
    """Return the heading of a component: its name linked to its changelog,
    followed by its new versions (oldest – newest)."""
    link = f"{url}/blob/{new}/src/{component}/CHANGELOG.md"
    found = [] if component in RELEASE_VERSIONED else versions.get(component, [])
    span = ""
    if found:
        span = " " + (found[0] if len(found) == 1 else f"{found[-1]} – {found[0]}")
    return f"##### [{component}]({link}){span}"


def render(body, versions, url, new):
    """Return the text of the category."""
    parts = [TITLE, ""]
    for component, lines in body.items():
        parts += [heading(component, versions, url, new), *lines, ""]
    return "\n".join(parts)


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
    body, versions = groups(markdown)
    if not body:
        return
    # replace the lines of the largest components by a line with a link to
    # their changelog until the category fits
    linked = set()
    while True:
        text = render(body, versions, url, new)
        if len(text) <= limit:
            print(text, end="")
            return
        rest = [c for c in body if c not in linked]
        if not rest:
            break
        component = max(rest, key=lambda c: len("\n".join(body[c])))
        count = len(body[component])
        body[component] = [
            f"- {count} change{'s' if count > 1 else ''}, see the "
            f"[changelog]({url}/blob/{new}/src/{component}/CHANGELOG.md)"]
        linked.add(component)
    # not even one line per component fits
    text = f"{TITLE}\n\n- see the [full commit log]({url}/compare/{old}...{new})\n"
    if len(text) <= limit:
        print(text, end="")


if __name__ == "__main__":
    main()
