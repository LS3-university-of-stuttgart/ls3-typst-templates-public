// style.typ
//
// Page geometry, fonts, headings, and styling rules for
// the dissertation. Used by lib.typ. Not a public-facing module.
//
// The A4 mode follows the Merkblatt manuscript rules: 12pt body, roughly
// 1.5 line spacing, margins over 2cm on every side. The A5 mode is the
// Mitteilungsheft print layout derived from the diss_a5 LaTeX template.

#import "common.typ": colors, fonts
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages

// Layout metrics per paper format. Single source of truth for everything
// that differs between the A4 manuscript and the A5 print version.
#let metrics(paper) = {
  if paper == "a5" {
    (
      paper: "a5",
      margin: (inside: 22mm, outside: 17mm, top: 20mm, bottom: 22mm),
      body-size: 10pt,
      leading: 0.8em,
      par-spacing: 1.2em,
      h1-size: 18pt,
      h2-size: 12pt,
      h3-size: 11pt,
      h4-size: 10pt,
      h1-above: 1.2cm,
      h1-below: 1cm,
      corner-size: 8pt,
    )
  } else {
    (
      paper: "a4",
      margin: (inside: 30mm, outside: 25mm, top: 25mm, bottom: 30mm),
      body-size: 12pt,
      // Merkblatt asks for 1.5 line spacing in the manuscript. Typst's
      // default leading of 0.65em reads like single spacing; 0.9em with
      // 12pt body lands at the 1.5-line look of the LaTeX manuscript.
      leading: 0.9em,
      par-spacing: 1.4em,
      h1-size: 24pt,
      h2-size: 14pt,
      h3-size: 12pt,
      h4-size: 12pt,
      h1-above: 2cm,
      h1-below: 1.5cm,
      corner-size: 9pt,
    )
  }
}

// Build the header and footer used on body pages. Two-sided.
// Returns a dictionary suitable for `set page(header: ..., footer: ...)`.
#let two-sided-header-footer(language: "english", corner-size: 9pt) = {
  let header-content = context {
    let here = here()
    let chapter-title = ""
    let candidates = query(selector(heading.where(level: 1)).before(here))
    if candidates.len() > 0 {
      chapter-title = candidates.last().body
    }
    set text(size: corner-size, fill: colors.anthrazit)
    if calc.odd(here.page()) {
      align(right, chapter-title)
    } else {
      align(left, chapter-title)
    }
  }

  let footer-content = context {
    if page.numbering == none {
      return
    }
    set text(size: corner-size, fill: colors.anthrazit)
    let counter-val = counter(page).get().first()
    let formatted = numbering(page.numbering, counter-val)
    if calc.odd(here().page()) {
      align(right, formatted)
    } else {
      align(left, formatted)
    }
  }

  (header: header-content, footer: footer-content)
}

// Apply all global dissertation styling. body-font is "sans" (default,
// TeX Gyre Heros) or "serif" (New Computer Modern body, sans headings).
// heading-rule draws a thin mittelblau rule below every chapter-level heading.
#let apply-style(body, paper: "a4", body-font: "sans", heading-rule: false) = {
  let m = metrics(paper)

  set page(
    paper: m.paper,
    margin: m.margin,
    binding: left,
  )

  // Only the first serif family. New Computer Modern ships with Typst,
  // and the Latin Modern fallback in common.typ would warn wherever it
  // is not installed, typst.app included.
  let body-font-stack = if body-font == "serif" { fonts.serif.first() } else { fonts.sans }
  set text(font: body-font-stack, size: m.body-size)
  show heading: set text(font: fonts.sans)
  set par(leading: m.leading, justify: true, first-line-indent: 0pt, spacing: m.par-spacing)

  set enum(indent: 1em)
  set list(indent: 1em)
  set terms(indent: 1em)

  // Wire up the two-sided footer so outer-corner page numbers appear.
  // Header is disabled for now (set to none); the running chapter title
  // header is implemented in two-sided-header-footer() and can be enabled
  // by passing the .header field to set page(header: ...) here, or by
  // wiring in the hydra package for richer context-aware headers later.
  let hf = two-sided-header-footer(corner-size: m.corner-size)
  set page(header: none, footer: hf.footer)

  set heading(numbering: (..nums) => nums.pos().map(str).join("."))
  set math.equation(numbering: "(1)")

  show link: set text(fill: colors.mittelblau)

  show raw.where(block: false): it => box(
    fill: colors.block-body,
    inset: (x: 3pt, y: 0.5pt),
    outset: (y: 1pt),
    radius: 2pt,
    text(font: fonts.mono, size: 0.92em, fill: colors.mittelblau, it),
  )

  show: codly.lang-set_(languages: codly-languages)
  show raw.where(block: true): codly.new

  // Chapter-level heading. New right-opening page, number inline, optional
  // thin mittelblau rule below. The spacing to the text is the same with
  // and without the rule.
  show heading.where(level: 1): it => {
    pagebreak(to: "odd", weak: true)
    v(m.h1-above)
    let prefix = if it.numbering != none {
      [#counter(heading).display(it.numbering)#h(0.6em)]
    } else {
      []
    }
    set par(justify: false)
    text(
      size: m.h1-size,
      weight: "bold",
      fill: black,
      hyphenate: false,
    )[#prefix#it.body]
    v(4mm)
    if heading-rule {
      line(length: 100%, stroke: 1pt + colors.mittelblau)
    }
    v(m.h1-below)
  }

  show heading.where(level: 2): it => {
    v(8mm, weak: true)
    text(size: m.h2-size, weight: "bold", fill: black, it)
    v(2mm)
  }
  show heading.where(level: 3): it => {
    v(5mm, weak: true)
    text(size: m.h3-size, weight: "bold", fill: black, it)
    v(1mm)
  }
  show heading.where(level: 4): it => {
    v(3mm, weak: true)
    text(size: m.h4-size, weight: "bold", style: "italic", fill: black, it)
  }

  show figure.caption: it => {
    text(weight: "bold", fill: black, it.supplement + " " + str(it.counter.display()) + ":")
    " "
    it.body
  }

  body
}
