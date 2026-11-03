# CFET standard-cell hand layout

Rules, KLayout setup and checks for drawing the CFET standard cells of Sherazi et al., "CFET Standard-cell design down to 3Track height for node 3nm and below" (Proc. SPIE 10962, 2019) by hand in KLayout.

**This is not a PDK.** The paper does not name its PDK. Every value here is either read from the paper or assumed to fill a gap, and `cfet_rules.md` marks which is which.

## Contents

- `cfet_rules.md`: dimension and connection rules. Each value is tagged paper text, measured, derived or assumed. Read sections 3 (coordinates) and 6 (connection rules) before drawing.
- `tech/cfet_sherazi2019/cfet.lyp`: KLayout layer properties. Sets the 17 layer names of the Figure 8 legend, their GDS numbers, colors and fill patterns, plus the reference-only layer `GUIDE` (200/0).
- `tech/cfet_sherazi2019/cfet.lyt`: KLayout technology file. Sets the dbu to 1 nm, offers editing grids of 1, 5, 21 and 42 nm, and loads `cfet.lyp`. 21 nm is the MINT pitch and 42 nm is the CPP.
- `checks/`: DRC and LVS decks and the script that runs them.
- `netlists/`: schematic netlists (SPICE) for LVS, one per cell and height: `<cell>_4t.cir`, `<cell>_3t.cir`.
- `layouts/4t/`, `layouts/3t/`: hand-drawn layouts, one GDS per cell. git keeps the earlier versions.

## Using the technology in KLayout

1. Make the folder `tech/cfet_sherazi2019` visible to KLayout as `<KLayout home>\tech\cfet_sherazi2019`, either by copying it or with a directory junction:
   ```powershell
   New-Item -ItemType Junction -Path "$HOME\KLayout\tech\cfet_sherazi2019" -Target "<repo>\tech\cfet_sherazi2019"
   ```
   KLayout then registers the technology `cfet_sherazi2019` at startup.
2. When creating a new layout, select the technology `cfet_sherazi2019`. The layer list and the grids are set with it.
3. To use the layer properties without the technology, open `cfet.lyp` with `File > Load Layer Properties`, and check that the dbu is 0.001 µm.

## DRC and LVS

The `checks` folder holds:
- `cfet.drc`: KLayout DRC deck. Checks the dimension and connection rules of `cfet_rules.md`.
- `cfet.lvs`: KLayout LVS deck. Compares the netlist extracted from the layout with the schematic netlist.
- `run_checks.ps1`: PowerShell script that runs both decks in one go.

```powershell
powershell -ExecutionPolicy Bypass -File "<repo>\checks\run_checks.ps1" -Gds "<saved GDS path>"
```

Both decks read the cell height from `prBoundary` and apply the 4T rules to an 84 nm high cell and the 3T rules to a 63 nm high cell. LVS compares the cell with `netlists/<cell>_4t.cir` or `netlists/<cell>_3t.cir`; `-Schematic <netlist.cir>` overrides that choice.

Before checking, the layout must meet these conditions:
- **Cell name:** `AOI21D1`. For another name, add `-Cell <name>`.
- **Cell boundary:** a cell boundary rectangle on `prBoundary`, 84 nm (4T) or 63 nm (3T) high and a whole number of CPP wide. The DRC deck computes the track and gate-grid positions from it.
- **Pin names:** texts `A1`, `A2`, `B`, `ZN` on the `MINTINTENT` layer and texts `VDD`, `VSS` on the `MBURINTENT` layer. LVS matches the schematic pins by these names.

The checks write report files next to the GDS. Open `<name>.drc.lyrdb` in KLayout's Marker Browser and `<name>.lvsdb` in its Netlist Browser to see the locations.

Recommended drawing order: following the coordinates of `cfet_rules.md` section 3, first lay down the cell boundary (`prBoundary`), the BPR (`MBURINTENT`), the channels (`FININTENT`) and the gates (`PO1`, `POLYDUMMY`), then draw the contacts and MINT on top.

## 3T exercise

`layouts/3t/AOI21D1.gds` is a 4 CPP frame (168 x 63 nm) with the boundary, BPR, channel line, `POLYCUT` and the two edge dummies. The gates, contacts, vias and MINT are left to draw. The `GUIDE` outlines show tracks T1..T3, the poly lines and the S/D columns over a 5 CPP range, so they also cover the cell after widening.

1. Draw AOI21D1 in 4 CPP and run the checks. `cfet_rules.md` section 7 explains which MINT rules stop the three inputs on T2.
2. Widen the cell to 5 CPP: move the right edge dummy from x = 168 to 210, stretch `prBoundary`, the BPR, `FININTENT` and `POLYCUT` to x = 210, and insert a `POLYDUMMY` at the poly line you choose.
3. Decide whether to cut `FININTENT` under that dummy (`cfet_rules.md` section 7, diffusion break), and check again.
