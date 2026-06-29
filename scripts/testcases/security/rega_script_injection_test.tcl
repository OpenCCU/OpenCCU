#!/usr/bin/tclsh
##
# rega_script_injection_test.tcl
#
# Regression tests for GHSA-c45w-fgwq-mvq4 / patch
# 0207-WebUI-Fix-ReGaScriptInjection.
#
# Background
# ----------
# The WebUI builds HomeMatic Script (ReGa) by interpolating user input into
#   var <name> = "<value>";
# declarations. The escaping helpers escaped the quote character but NOT the
# backslash, so a crafted value could introduce an unescaped quote and break
# out of the string literal -> the remainder is parsed as live ReGa script
# (system.Exec -> command execution as root). The PDA interface interpolated
# request parameters with no escaping at all.
#
# What we verified on a real ReGa engine (non-destructive, WriteLine only):
#
#   OLD (vulnerable):  var p = "\\";WriteLine(31337);!";   -> output: PRE 31337
#                      (the \\ decodes to one backslash, the next quote closes
#                       the literal, and WriteLine(31337) EXECUTES)
#   NEW (fixed):       var p = "\\\";WriteLine(31337);!";  -> output: PRE
#                      (the \" stays a literal quote inside the string; the
#                       injected code is inert data)
#
# These tcl-level tests assert the same security invariant without needing a
# full firmware build: the escaped output, when placed between the surrounding
# quotes, must never contain a character that terminates or escapes the
# enclosing "..." literal.
#
# Run:  tclsh tests/security/rega_script_injection_test.tcl
##

set ::failures 0
proc ok {name cond} {
    if {[uplevel 1 [list expr $cond]]} {
        puts "PASS: $name"
    } else {
        puts "FAIL: $name"
        incr ::failures
    }
}

# --- the helpers exactly as patched (and the old vulnerable forms) -----------

# vulnerable (pre-patch) -- backslash NOT escaped
proc vuln_hmscript_escape {str} {
    return [string map {
        "\'" "\\\'"  "\"" "\\\""  "\n" "\\n"  "\r" "\\r"  "\t" "\\t"
    } $str]
}
# fixed -- backslash escaped FIRST
proc hmscript_escapeString {str} {
    return [string map {
        "\\" "\\\\"  "\'" "\\\'"  "\"" "\\\""  "\n" "\\n"  "\r" "\\r"  "\t" "\\t"
    } $str]
}
# fixed rega_escape (the latent twin)
proc rega_escape {value} {
    return [string map {
        "\\" "\\\\"  "\'" "\\\'"  "\"" "\\\""  "\f" "\\\f"  "\t" "\\\t"  "\r" "\\\r"  "\n" "\\\n"
    } $value]
}
# already-correct JSON encoder (DOES escape backslash) -- regression guard only,
# this code was never vulnerable and was NOT changed by the patch.
proc json_toString {str} {
    set map {
        "\"" "\\\""  "\\" "\\\\"  "/" "\\/"  "\b" "\\b"  "\f" "\\f"
        "\n" "\\n"  "\r" "\\r"  "\t" "\\t"
    }
    return "\"[string map $map $str]\""
}
# PDA entry-point validator added by the patch
proc pda_validate_id {x} {
    if {![regexp {^[0-9]+$} $x]} { return "" }
    return $x
}

# --- the security invariant --------------------------------------------------
# Given the bytes that go BETWEEN the surrounding quotes of  var x = "<body>";
# return 1 if those bytes would terminate or escape the enclosing literal
# (i.e. contain an unescaped quote, or end in an odd run of backslashes).
proc literal_is_unsafe {body} {
    set bs 0
    foreach c [split $body ""] {
        if {$c eq "\\"} { incr bs; continue }
        if {$c eq "\"" && ($bs % 2) == 0} { return 1 }
        set bs 0
    }
    if {($bs % 2) == 1} { return 1 }   ;# trailing backslash escapes closing quote
    return 0
}

# --- malicious / tricky inputs ----------------------------------------------
set inputs [list \
    {\"}                            \
    {\\"}                           \
    {";WriteLine(31337)}            \
    {\";WriteLine(31337);!}         \
    {\\\";system.Exec("id")}        \
    {C:\Users\admin\file}           \
    "ends with one backslash \\"    \
    {plain harmless value}          \
]

# 1) the fixed escapers neutralise every input
foreach in $inputs {
    ok "hmscript_escapeString safe: [string range $in 0 24]" \
        {![literal_is_unsafe [hmscript_escapeString $in]]}
    ok "rega_escape safe:          [string range $in 0 24]" \
        {![literal_is_unsafe [rega_escape $in]]}
}

# 2) document the bug: the OLD escaper IS exploitable for the PoC input
ok "vuln escaper breaks out (documents CVE)" \
    {[literal_is_unsafe [vuln_hmscript_escape {\";WriteLine(31337);!}]]}

# 3) legitimate backslashes are preserved (no silent data loss) once decoded:
#    fixed output doubles them, so a Windows path keeps both backslashes.
ok "backslash preserved (no data loss)" \
    {[hmscript_escapeString {a\b}] eq {a\\b}}

# 4) json_toString was already correct (regression guard, unchanged by patch)
ok "json_toString already escapes backslash" \
    {![literal_is_unsafe [string range [json_toString {a\b}] 1 end-1]]}

# 5) PDA numeric-id validation rejects injection, keeps valid ids
ok "pda rejects injected favId"   {[pda_validate_id {0";system.Exec("id")}] eq ""}
ok "pda rejects empty favId"      {[pda_validate_id {}] eq ""}
ok "pda keeps numeric favId"      {[pda_validate_id {1234}] eq {1234}}

puts ""
if {$::failures == 0} {
    puts "ALL TESTS PASSED"
    exit 0
} else {
    puts "$::failures TEST(S) FAILED"
    exit 1
}
