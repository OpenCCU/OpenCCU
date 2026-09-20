import {EditorState} from "@codemirror/state";
import {EditorView, keymap} from "@codemirror/view";
import {
  defaultKeymap,
  history,
  historyKeymap,
  indentLess,
  indentMore,
  indentWithTab
} from "@codemirror/commands";
import {bracketMatching, foldCode, foldGutter, foldKeymap, indentUnit} from "@codemirror/language";
import {closeBrackets, closeBracketsKeymap, autocompletion, startCompletion, completeAnyWord} from "@codemirror/autocomplete";
import {search, searchKeymap, openSearchPanel} from "@codemirror/search";
import {lineNumbers, highlightActiveLineGutter} from "@codemirror/view";
import {StreamLanguage} from "@codemirror/language";
import {clike} from "@codemirror/legacy-modes/mode/clike";

const REGA_LANGUAGE = StreamLanguage.define(clike({
  name: "clike",
  keywords: "if while foreach return quit else elseif break continue Call Write WriteLine WriteURL WriteXML WriteHTML Debug Dump",
  types: "var boolean integer real string time object idarray xml",
  blockKeywords: "if while foreach else elseif",
  defKeywords: "system dom root devices channels datapoints structure scheduler xmlrpc interfaces tcap web",
  atoms: "null true false currenttime localtime on off up down higher lower",
  multiLineStrings: true,
  indentStatements: false,
  indentSwitch: false,
  modeProps: {closeBrackets: {pairs: "()[]{}\"\"", triples: "\""}},
  hooks: {
    "@": function(stream) {
      stream.eatWhile(/[0-9 :-]/);
      return "meta";
    },
    "!": function(stream) {
      if (!stream.eat(" ")) {
        return false;
      }
      stream.skipToEnd();
      return "comment";
    }
  }
}));

const FULLSCREEN_CLASS = "cm6-fullscreen";

function keyName(name) {
  return name.replace(/-/g, "-");
}

function buildKeymap(extraKeys, getAdapter) {
  if (!extraKeys) {
    return [];
  }

  return Object.keys(extraKeys).map((key) => {
    const value = extraKeys[key];
    return {
      key: keyName(key),
      run(view) {
        if (typeof value === "string") {
          if (value === "autocomplete") {
            return startCompletion(view);
          }
          if (value === "findPersistent") {
            return openSearchPanel(view);
          }
          return false;
        }
        if (typeof value === "function") {
          value(getAdapter());
          return true;
        }
        return false;
      }
    };
  });
}

function docFromTextarea(textarea) {
  return textarea.value || textarea.textContent || "";
}

function asOffset(doc, pos) {
  return doc.line(pos.line + 1).from + pos.ch;
}

function asPos(doc, offset) {
  const line = doc.lineAt(offset);
  return {line: line.number - 1, ch: offset - line.from};
}

function fromTextArea(textarea, options = {}) {
  const host = document.createElement("div");
  host.className = "CodeMirror";
  textarea.style.display = "none";
  textarea.parentNode.insertBefore(host, textarea.nextSibling);

  const extensions = [
    history(),
    keymap.of([...defaultKeymap, ...historyKeymap, ...closeBracketsKeymap, ...searchKeymap, ...foldKeymap]),
    keymap.of([indentWithTab]),
    search({top: false}),
    bracketMatching(),
    closeBrackets(),
    autocompletion({override: [completeAnyWord]}),
    EditorView.lineWrapping,
    indentUnit.of(" ".repeat(options.indentUnit || 2)),
    EditorState.tabSize.of(options.tabSize || 2),
    EditorView.theme({
      "&.cm-editor": {height: "100%"},
      "&.cm-editor.cm-focused": {outline: "none"}
    })
  ];

  if (options.lineNumbers !== false) {
    extensions.push(lineNumbers(), highlightActiveLineGutter());
  }
  if (options.foldGutter) {
    extensions.push(foldGutter());
  }
  if (options.readOnly) {
    extensions.push(EditorState.readOnly.of(true), EditorView.editable.of(false));
  }
  if (options.mode === "text/x-rega") {
    extensions.push(REGA_LANGUAGE);
  }

  let adapter = null;
  const extraKeymap = buildKeymap(options.extraKeys, () => adapter);
  if (extraKeymap.length > 0) {
    extensions.push(keymap.of(extraKeymap.map((entry) => ({
      key: entry.key,
      run(view) {
        return entry.run(view, adapter);
      }
    }))));
  }

  const state = EditorState.create({
    doc: docFromTextarea(textarea),
    extensions
  });
  const view = new EditorView({state, parent: host});

  adapter = {
    view,
    options: {
      indentWithTabs: !!options.indentWithTabs,
      tabSize: options.tabSize || 2
    },
    getValue() {
      return view.state.doc.toString();
    },
    setValue(value) {
      view.dispatch({
        changes: {from: 0, to: view.state.doc.length, insert: value}
      });
      textarea.value = value;
    },
    setSize(width, height) {
      if (width != null) {
        host.style.width = typeof width === "number" ? `${width}px` : `${width}`;
      }
      if (height != null) {
        host.style.height = typeof height === "number" ? `${height}px` : `${height}`;
      }
      view.requestMeasure();
    },
    getCursor() {
      return asPos(view.state.doc, view.state.selection.main.head);
    },
    somethingSelected() {
      return !view.state.selection.main.empty;
    },
    getSelection() {
      return view.state.sliceDoc(view.state.selection.main.from, view.state.selection.main.to);
    },
    getLine(lineNumber) {
      return view.state.doc.line(lineNumber + 1).text;
    },
    getRange(from, to) {
      return view.state.sliceDoc(asOffset(view.state.doc, from), asOffset(view.state.doc, to));
    },
    replaceRange(text, from, to) {
      view.dispatch({
        changes: {
          from: asOffset(view.state.doc, from),
          to: asOffset(view.state.doc, to),
          insert: text
        }
      });
      textarea.value = this.getValue();
    },
    execCommand(command) {
      if (command === "indentMore") {
        return indentMore(view);
      }
      if (command === "indentLess") {
        return indentLess(view);
      }
      if (command === "insertTab") {
        return indentWithTab(view);
      }
      if (command === "insertSoftTab") {
        const spaces = " ".repeat(this.options.tabSize);
        const pos = view.state.selection.main.head;
        view.dispatch({changes: {from: pos, to: pos, insert: spaces}});
        return true;
      }
      return false;
    },
    foldCode(pos) {
      const offset = asOffset(view.state.doc, pos);
      view.dispatch({
        selection: {anchor: offset}
      });
      return foldCode(view);
    },
    setOption(name, value) {
      if (name === "fullScreen") {
        host.classList.toggle(FULLSCREEN_CLASS, !!value);
      }
    },
    getOption(name) {
      if (name === "fullScreen") {
        return host.classList.contains(FULLSCREEN_CLASS);
      }
      return undefined;
    }
  };

  view.dispatch = ((originalDispatch) => (transaction) => {
    originalDispatch.call(view, transaction);
    textarea.value = view.state.doc.toString();
  })(view.dispatch);

  if (options.autofocus) {
    view.focus();
  }

  return adapter;
}

window.CCUCodeMirror6 = {
  fromTextArea
};
window.CodeMirror = window.CCUCodeMirror6;
