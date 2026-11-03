# Rule set for hand-drawn CFET 4T/3T standard cells

Source paper: S. M. Y. Sherazi et al., "CFET Standard-cell design down to 3Track height for node 3nm and below", Proc. SPIE 10962, 1096206 (2019). Referred to below as "the paper".

## 1. Purpose

This document sets the dimensions and connection rules for drawing the paper's CFET cells (for example the AOI21D1 of Figure 8) in KLayout.

The paper does not name a PDK (the design rules and layer definitions a foundry ships). Only some dimensions appear, in Figures 4–6. This document therefore does three things:
1. It copies the values that the paper states.
2. It fills the missing values with assumptions that do not contradict the drawing in Figure 8.
3. It marks the source of every value.

Assumed values can be changed at any time. Section 8 lists which rules change with them.

## 2. Source tags

The "Basis" column of each table holds exactly one of these four words:

- **paper text**: a value written in the paper's text or in a dimension label of a figure.
- **measured**: a value measured from pixel ratios in a figure of the paper. This is an inference.
- **derived**: a value obtained by adding or subtracting paper-text values. It is as reliable as its inputs.
- **assumed**: a value this document sets because the paper does not give it. The reason for the choice is in the text below the table.

## 3. Coordinate system and cell frame (4T)

- **Coordinates:** the origin is the lower-left corner of the cell. x runs along the gate repetition direction (West to East), y along the cell height (South to North).
- **Units:** all coordinates are integers in nm, so a database unit (dbu, the smallest layout coordinate step) of 1 nm is sufficient.
- **Tiers:** the top tier is nFET and the bottom tier is pFET (paper Figure 4, paper text). A tier is one level of vertically stacked devices.
- **Power rails:** the VDD rail is buried at the North cell edge and the VSS rail at the South cell edge (Figure 4, paper text).

### y direction (cell height)

| Item | y start (nm) | y end (nm) | Basis |
|---|---:|---:|---|
| Cell boundary | 0 | 84 | paper text |
| BPR, VSS (`MBURINTENT`) | -16 | 16 | derived |
| BPR, VDD (`MBURINTENT`) | 68 | 100 | derived |
| MINT T4 | 5 | 16 | derived |
| MINT T3 | 26 | 37 | derived |
| MINT T2 | 47 | 58 | derived |
| MINT T1 | 68 | 79 | derived |
| Channel F1 (`FININTENT`) | 29 | 34 | derived |
| Channel F2 (`FININTENT`) | 50 | 55 | derived |
| Channel span of an S/D contact | 26 | 58 | derived |

**Derivation.** The coordinates above are computed from paper-text values.
- **MINT:** width 11 nm, space 10 nm, pitch 21 nm (Figure 5). The cell boundary lies in the middle of the space between tracks (Section 1.3 of the paper), so the first track starts 5 nm from the boundary.
- **BPR:** its width is 11 + 10 + 11 = 32 nm (Figure 6), centered on the cell boundary. Seen from above, the BPR therefore overlaps the edge tracks (T1, T4).
- **Channel:** 5 nm wide (Figure 6), centered under the two center tracks (T2, T3) (Figure 4).
- **S/D contact:** a contact extends 3 nm beyond the channel (Figure 6). The span that covers both channels is therefore 26–58 nm, 32 nm long, which equals the 32 nm in Figure 4.

T1 is the North track and T4 the South track.

### x direction (gate direction)

| Item | Value (nm) | Basis |
|---|---:|---|
| CPP (contacted poly pitch) | 42 | measured |
| Gate width (`PO1`, gate length) | 14 | assumed |
| S/D contact width (`M0top`, `M0bot`) | 14 | assumed |
| Gate-to-S/D-contact space | 7 | derived |
| AOI21D1 cell width (4 CPP) | 168 | derived |

- **CPP:** in Figure 8 the 4 CPP cell width looks twice the 84 nm cell height, so CPP is set to 42 nm. This is exactly twice the MINT pitch.
- **Gate and S/D contact:** the 42 nm CPP is split into gate 14, space 7, contact 14, space 7. These values keep every coordinate an integer and lie within the gate-length range of 3 nm-class processes (roughly 12–16 nm).
- **Placement:** gate centers are at x = 0, 42, 84, 126, 168. The two ends, 0 and 168, are dummy poly (`POLYDUMMY`) on the cell boundary. S/D column centers are at x = 21, 63, 105, 147.

## 4. Layer list

The GDS layer numbers are set by this document (assumed). The layer names follow the legend of the paper's Figure 8. The list runs from the physically lowest layer to the highest.

1. `MBURINTENT` (1/0): buried power rail (BPR), the power line buried in the wafer below the devices.
2. `FININTENT` (2/0): nanosheet channel line. The top and bottom tiers are stacked at the same position, so it is drawn once.
3. `PO1` (10/0): gate, shared by both tiers.
4. `POLYDUMMY` (11/0): dummy poly on the left and right cell boundaries.
5. `POLYCUT` (12/0): area that cuts the gates at the top and bottom cell boundaries.
6. `M0bot` (20/0): S/D contact of the bottom tier (pFET).
7. `M0top` (21/0): S/D contact of the top tier (nFET).
8. `M0merge` (22/0): layer that joins `M0top` and `M0bot` of the same S/D column directly inside the MOL. MOL (middle of line) is the set of contact layers between the devices and the first routing layer.
9. `VBurShort` (30/0): short via from `M0bot` down to the BPR; `VBS` in the paper's Figure 5.
10. `VBurTall` (31/0): tall via from `M0top` down to the BPR. It passes the `M0bot` level. `VBT` in Figure 5.
11. `Vbot` (40/0): tall via from MINT down to `M0bot`. It passes the `M0top` level.
12. `Vtop` (41/0): via from MINT down to `M0top`.
13. `VINTGA` (42/0): via from MINT down to the gate, that is, the gate contact.
14. `MINTINTENT` (50/0): MINT, the first horizontal routing layer. Input and output pin names (A1, ZN, ...) are placed on this layer as text.
15. `V1` (60/0): via between MINT and M1. The paper does not name it; this document does.
16. `M1` (61/0): vertical routing layer.
17. `prBoundary` (100/0): cell boundary rectangle. The conventional name of the layer that place-and-route tools use as the cell outline.

`FINCUT1`, `NPFET` and `DUMMY` in the Figure 8 legend are left out because no shapes on them could be found in the figure.

## 5. Dimension rules

### MINT (`MINTINTENT`)

| Rule | Value | Basis |
|---|---:|---|
| Width (nm) | 11 | paper text |
| Space between tracks (nm) | 10 | paper text |
| Line-end spacing on one track (nm) | 16 | assumed |
| Minimum area (nm²) | 550 | assumed |

- **Position:** MINT lies only on the tracks of section 3 (paper text).
- **Minimum area 550 nm²:** at 11 nm width this is a minimum length of 50 nm (about 1.2 CPP).
- **Line-end spacing 16 nm:** this value and the minimum area are chosen so that the paper's explanation of Figure 8 holds.
- **Check of the two assumed values:**
  - With all three inputs side by side on one track, each pin segment can be at most 42 − 16 = 26 nm long and violates the minimum area.
  - With the inputs staggered on T3/T2/T3, segments of about 66 nm can be used, as in Figure 8, and meet the minimum area. The line-end spacing between the A2 and B segments on T3 is then 84 − 66 = 18 nm, at least 16 nm.
- **Reference [5]:** the actual minimum-area value may be in the paper's reference [5] (Sherazi et al., SPIE 2018), which was not checked.

### S/D contact (`M0bot`, `M0top`)

| Rule | Value | Basis |
|---|---:|---|
| x width (nm) | 14 | assumed |
| Extension beyond the channel (nm) | 3 | paper text |
| Same-layer space in y (nm) | 10 | paper text |
| Cell boundary to contact end (nm) | 5 | derived |

- **y range:** a contact covers the channel span (y 26–58). To pick it up to MINT or drop it to the BPR, it is extended North to y 79 or South to y 5. The paper calls this an escape.
- **5 nm from the boundary:** in the Figure 5 cross-section the `M0bot` ends of neighboring cells are 10 nm apart, so each ends 5 nm from the boundary. That end is at the same y as the outer edge of the edge MINT track.

### Via (`Vbot`, `Vtop`, `VINTGA`, `VBurShort`, `VBurTall`, `V1`)

| Rule | Value | Basis |
|---|---:|---|
| y size (nm) | 11 | measured |
| x size (nm) | 10 | assumed |
| `Vbot` to `M0top` space (nm) | 10 | paper text |
| `VBurTall` to `M0bot` space (nm) | 10 | paper text |

- **y size 11 nm:** in Figure 5 the via top is drawn as wide as MINT, so it is set to 11 nm. Its y position equals the MINT track exactly.
- **x size 10 nm:** leaves 2 nm of margin on each side on a 14 nm wide contact or gate.
- **Position:**
  - `VBurShort`, `VBurTall`: at the edge-track position over the BPR. VDD at the T1 position, VSS at the T4 position.
  - `Vtop`, `VINTGA`: on any of the four tracks.
  - `Vbot`: only on the edge tracks.

### Gate (`PO1`, `POLYDUMMY`, `POLYCUT`)

| Rule | Value | Basis |
|---|---:|---|
| Gate width (nm) | 14 | assumed |
| Gate pitch (nm) | 42 | measured |
| `POLYCUT` y size (nm) | 10 | assumed |

- **Gate y range:** gates and dummy poly run over the full y 0–84.
- **`POLYCUT` position:** centered on the top and bottom cell boundaries, at y -5–5 and y 79–89, across the full cell width (x 0–168).
- **`FININTENT` extent:** drawn over the full x 0–168 (assumed). The diffusion break at the cell boundary is taken to be at the dummy poly. A diffusion break is the structure that cuts the channel from the devices of the neighboring cell.

### M1 (`M1`)

| Rule | Value | Basis |
|---|---:|---|
| Pitch (nm) | 42 | paper text |
| Width (nm) | 21 | assumed |

- **Pitch:** as the paper's Figure 10 explanation says, M1 is placed over the S/D columns (x = 21, 63, ...) with a 1:1 gear ratio to CPP. The gear ratio is the ratio of the pitches of two layers.
- **Need:** the 4T AOI21D1 does not need M1. In the paper's 4T library only 2 of 55 cells use M1.

## 6. Connection rules

The rules in this section set which connections are possible, not dimensions.

1. **Bottom-tier contact pickup:** a bottom-tier contact (`M0bot`) can be picked up to MINT only at the edge tracks (T1, T4) (paper text, Section 1.3). Under the center tracks the `M0top` contacts leave no room to drop a `Vbot` between them.
2. **Top-tier contact pickup:** a top-tier contact (`M0top`) can be picked up at any of the four tracks (paper text).
3. **Space of vias that pass the other tier:** `Vbot` and `VBurTall` pass the contact level of the other tier, so they must stay 10 nm away from that tier's contacts (derived from the paper-text spaces in section 5).
   - `Vbot` must stay away from `M0top`. For example, when `M0bot` runs North to y 79 and `Vbot` is on T1, the `M0top` of the same column must end below y 58, that is, run South or stay within the channel span.
   - `VBurTall` must stay away from `M0bot`. So `M0bot` must run to the side opposite the `M0top` that uses `VBurTall`.
   - `Vtop` and `VBurShort`, in contrast, do not pass the other tier. A placement where `M0bot` reaches VDD through `VBurShort` and `M0top` reaches T1 through `Vtop` on the same North side does not violate this rule.
   - All four S/D columns of Figure 8 use `Vbot` or `VBurTall` and keep this space. In S/D 1, 3 and 4, `M0bot` runs North and `M0top` runs South. In S/D 2 only `M0bot` runs South and `M0top` stays within the channel span.
4. **VDD connection:** a pFET reaches VDD by extending `M0bot` North and placing `VBurShort` at the T1 position.
5. **VSS connection:** an nFET reaches VSS by extending `M0top` South and placing `VBurTall` at the T4 position. Both can be seen in S/D 4 of Figure 8 (measured).
6. **`M0merge`:** when `M0top` and `M0bot` of the same column are on the same net, they can be joined directly with `M0merge` without MINT. It is drawn inside the area where both contacts overlap (assumed). Figure 8 does not use it.

## 7. Changing to 3T

3T has one channel per transistor, so it has only one center track (paper text, Section 1.4).

| Item | y start (nm) | y end (nm) | Basis |
|---|---:|---:|---|
| Cell boundary | 0 | 63 | paper text |
| BPR, VSS | -16 | 16 | derived |
| BPR, VDD | 47 | 79 | derived |
| MINT T3 (South) | 5 | 16 | derived |
| MINT T2 | 26 | 37 | derived |
| MINT T1 (North) | 47 | 58 | derived |
| Channel F1 | 29 | 34 | derived |
| Channel span of an S/D contact | 26 | 37 | derived |

All other dimensions and connection rules are the same as for 4T. With only one center track for input pins, inputs cannot be staggered. The paper therefore uses a SuperVia (Figure 9) or adds a dummy poly (Figure 10).

## 8. Changing assumed values and open decisions

Changing an assumed value changes other values with it:

- **CPP:** gate width, contact width, spaces and cell width change together. The x-direction table of section 3 must be recomputed.
- **MINT minimum area and line-end spacing:** change these two only within the range where the paper's claim, "staggered inputs pass, inputs side by side on one track fail", still holds. That range is where both inequalities below hold:
  - minimum length (minimum area ÷ 11) > 42 − line-end spacing
  - minimum length ≤ about 66 nm, and line-end spacing ≤ 18 nm

Two decisions remain:

1. **Whether to move these rules into a KLayout DRC deck.**
   - A DRC deck is a check script that KLayout runs to mark rule violations in a layout.
   - Recommendation: check the first few cells by hand against this document, and build the deck once the cell count grows. The rule count is still small enough to check by hand.
2. **Whether to obtain reference [5] to confirm the actual MINT minimum area.**
   - Recommendation: confirm it if you want to follow the reasoning of Figures 8 and 9 in numbers. The current value is an assumption fitted to the paper's claims.
