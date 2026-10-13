// logos.typ
//
// Defaults for university-logo: auto and chair-logo: auto. The package
// bundles no logos. Students download the university logo from the
// corporate design page, the LS3 logo comes from their supervisor. Until
// then the cover shows labeled placeholders.

#let default-university-logo(language) = none

#let university-placeholder = true

#let default-chair-logo() = rect(
  width: 25mm,
  height: 24mm,
  fill: white,
  stroke: (paint: rgb(200, 30, 30), thickness: 0.8pt, dash: "dashed"),
  inset: 2mm,
  align(center + horizon, text(size: 8pt, fill: rgb(200, 30, 30), [LS3 logo missing])),
)
