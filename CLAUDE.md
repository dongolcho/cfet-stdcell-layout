# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Rules, a KLayout technology and DRC/LVS decks for drawing by hand the CFET standard cells of Sherazi et al., Proc. SPIE 10962 (2019), at 4T (84 nm), 3T (63 nm), double-height 3T (126 nm) and triple-height 3T (189 nm) cell height. It is not a PDK: every value is either read from the paper or assumed.

- `cfet_rules.md` is the authority for every dimension, layer number and connection rule. Read sections 3 (coordinates) and 6 (connection rules) before drawing or changing a layout, and section 8 before changing an assumed value, since it lists what changes with it.
- `README.md` gives the conditions a layout must meet before the checks run (top cell name, `prBoundary`, pin texts), the KLayout setup, and the two 3T AOI21D1 variants.

## Commands

There is no build and no test suite. Running both decks on the layouts is the test:

```powershell
powershell -ExecutionPolicy Bypass -File checks\run_checks.ps1 -Gds layouts\3t\AOI21D1_4cpp.gds
```

Options: `-Cell <top cell>` (default `AOI21D1`), `-Schematic <netlist.cir>` (overrides the choice by cell height), `-KLayout <exe>` (default `%APPDATA%\KLayout\klayout_app.exe`). The reports `<name>.drc.lyrdb` and `<name>.lvsdb` land next to the GDS and are git-ignored.

- The script exits 0 even when DRC or LVS fails. Judge the result by the last `Info:` or `Error:` line of the `== DRC ==` and `== LVS ==` sections.
- When changing a deck, run it on every GDS under `layouts/` before and after the change and compare. A refactor leaves the output unchanged; a fix names the layout whose result changes.

### Reading or editing a GDS from a script

GDS is binary. Script it with KLayout's embedded Python (module `pya`), which needs no separate Python install: `klayout_app.exe -b -r <script.py> -rd gds=<layout.gds>`. Each `-rd name=value` becomes a global variable of the script.

`klayout_app.exe` is a GUI program: PowerShell's `&` returns before it finishes, sets no exit code, and its output arrives out of order. Run it the way `Invoke-KLayoutDeck` in `checks/run_checks.ps1` does, with `Start-Process -NoNewWindow -Wait -RedirectStandardOutput`.

Coordinates are integer nm (dbu 0.001 µm); the DRC deck stops on any other dbu.

## How the pieces fit

- **Layer numbers live in several places.** `cfet_rules.md` section 4, `tech/cfet_sherazi2019/cfet.lyp`, and the `input(n, 0)` lines of both `checks/cfet.drc` and `checks/cfet.lvs` (plus `README.md` where it names one). The decks hardcode the numbers and do not read the `.lyp`. A new or renumbered layer changes all of them, and the LVS `connect(...)` chain when the layer conducts.
- **`cfet.drc` copies the rule values.** Its constants (`CPP`, `MINT_END_SPACE`, ...) and `RULES_BY_HEIGHT` repeat `cfet_rules.md` sections 3, 5 and 7; change both together.
- **The `prBoundary` height selects the rule set, in each deck separately.** DRC looks it up in `RULES_BY_HEIGHT` (84, 63, 126 or 189 nm); LVS looks it up in `NETLIST_SUFFIX_BY_HEIGHT` to pick `netlists/<top cell>_4t.cir`, `_3t.cir`, `_3t2h.cir` or `_3t3h.cir`. A new height needs both. DRC derives the tracks, the gate grid and the S/D columns from the `prBoundary` lower-left corner, so a cell may sit anywhere.
- **Variant files keep the top cell name.** LVS finds the netlist by the top cell name, not the file name, so `layouts/3t/AOI21D1_5cpp.gds` and `AOI21D1_4cpp.gds` both hold the cell `AOI21D1`.
- **LVS device model.** LVS takes `PO1` minus `POLYCUT` as the gate, so a cut splits one poly line into separate gates; DRC lands `VINTGA` and `SuperVia` on the same layer. Each gate crossing `FININTENT` is one pFET (bottom tier) under one nFET (top tier). Before the compare, LVS removes every transistor whose source and drain are on one net and prints how many; these appear where an uncut gate crosses a row in which it drives nothing. LVS joins nets with the same `VDD` or `VSS` label (`connect_implicit`), because a double-height cell has two VSS rails joined only outside the cell. The deck copies the channel layers once per tier, so `M0bot` reaches only the pFET S/D and `M0top` only the nFET S/D. The netlists use 4-terminal SPICE `M` lines; `Mos3SpiceReader` drops the bulk. W is 5 nm per nanosheet (two in 4T, one in 3T) and L is 14 nm.

## Conventions

- A value added to `cfet_rules.md` carries exactly one basis tag (paper text, measured, derived, assumed), and an assumed value gets its reason below its table (section 2).
- Layouts are `layouts/<4t|3t>/<cell>.gds`, or `<cell>_<variant>.gds` when a cell is drawn in more than one way. Revise a layout in place; git keeps the earlier versions.
- `GUIDE` (200/0) holds reference outlines only; neither deck reads it.
- A commit that changes a layout states the DRC and LVS result in its body.
