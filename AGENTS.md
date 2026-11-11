# Repository Guidelines

Use this English guide for repository instructions. Skip [AGENTS_TC.md](AGENTS_TC.md) during routine context gathering. It is a translation for the project owner. Whenever you update this guide, update the translation in the same change.

## Project Structure

Bytes EPART DSL is a standalone browser editor for dimensioned industrial electrical schematics.

A product goal is to let users quickly turn text descriptions into `.dxf` schematics for niche-brand electrical components whose manufacturers do not provide `.dwg` or `.dxf` drawings. DXF export supports an individual PART view.

- `index.html` is the preview entry point and contains the UI, CSS, parser, SVG renderer, and built-in DSL samples. The flow is `parse()` → `pinList()` and geometry helpers → `draw()`.
- `docs/specification.md` is the source for the current language reference. Keep `docs/specification.html` and the previewer's quick reference aligned when syntax changes. Record historical changes in `CHANGELOG.md`.

- `refs/` holds source CAD drawings for examples. The previewer does not load these files at runtime.

## Local Development and Testing

Run `Invoke-Item .\index.html` from PowerShell to open the editor. The project has no build step, package installation, configured linter, or automated test suite. If Node.js is available, check the embedded script syntax from the project root.

```powershell
$previewHtml = Get-Content -Raw -Encoding utf8 .\index.html
if ($previewHtml -match '(?s)<script>(.*?)</script>') {
    $Matches[1] | node --check
}
```

Load each built-in example and switch through their available views. Confirm that they render without diagnostics. For parser changes, try both a valid snippet and an invalid one that produces the expected line-numbered diagnostic. For drawing or export changes, inspect the relevant view and verify that the exported SVG's millimetre dimensions match its `viewBox` extents.

## Coding and Geometry Conventions

Before proposing or changing DSL punctuation, read [IEC and EPLAN designation symbols](docs/designation-symbols.md). Avoid ambiguous overlaps where practical. If reuse is warranted, scope it to a clear command or field and document the tradeoff.

Keep edits focused and match the surrounding indentation. Use camelCase for JavaScript identifiers and uppercase DSL keywords in examples. Reuse existing parsing and geometry helpers, and escape user-provided text before inserting it into SVG or HTML.

Preserve the BODY centre as the origin, millimetres as the drawing unit, and positive rotation as counterclockwise. Keep examples functional and distinguish measured product data from schematic approximations.

## Commits and Pull Requests

Use local Git and the public [GitHub repository](https://github.com/RyanHsu255/bytes-epart-dsl). Commit and push the validated public changes when the user asks to run Git. Use short, imperative commit subjects. Double-click `Publish-GitHub.bat` to run `Publish-GitHub.ps1`, which commits and pushes through a separate checkout. Keep the script's public-file list current. Keep source CAD in `refs/`, credentials, logs, and generated staging directories out of the public repository.

Create a GitHub Release only for an explicitly requested version. In a pull request, describe the behaviour change, list the checks performed, link any related issue, and attach before-and-after screenshots for visible changes.

## Firebase Hosting

Double-click `Deploy-Firebase.bat` to run `Deploy-Firebase.ps1` and update [tools.bytes.tw](https://tools.bytes.tw/). The script stages the editor and HTML reference and deploys to the `bytes-epart-tools` Hosting site.
