# ls3-uni-stuttgart-thesis

Bachelor's and master's thesis template of the Department of Stochastic
Simulation and Safety Research for Hydrosystems, LS3, at the Institute
for Modelling Hydraulic and Environmental Systems, University of
Stuttgart. German or English, two-sided printing, with cover, title
page, declaration including the AI tools statement, abstracts, and
front matter.

![Cover page](thumbnail.png)

## Start a thesis

In the typst.app web app, choose "Start from template" and search for
`ls3-uni-stuttgart-thesis`. On your own machine, run

```bash
typst init @preview/ls3-uni-stuttgart-thesis:0.1.0 my-thesis
```

Then open `main.typ`, fill in your metadata, and write your chapters in
`chapters/`.

## Logos

The University of Stuttgart and LS3 logos are not part of this package.
Until you add them, the cover shows red placeholders.

Download the official university logo PDF from the
[corporate design page](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/logo-und-schrift/), in
[English](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_englisch.pdf) or
[German](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_deutsch.pdf). The template crops it,
drops the "Germany" line of the English logo, and sets the institute
and department below it from `institute` and `chair`. Ask your
supervisor for the LS3 logo. Put both into `logos/` and pass them in
`main.typ`.

```typst
#show: thesis.with(
  university-logo: image("logos/unistuttgart_logo_englisch.pdf"),
  chair-logo: image("logos/ls3_logo.png"),
  // ...
)
```

`logos/README.md` in the new project walks through the steps.

## Font

The template uses TeX Gyre Heros, a free Helvetica clone. The typst.app
web app has it built in. On your own machine, install it from
[CTAN](https://ctan.org/pkg/tex-gyre-heros), or pick another sans font
with `sans-font`. Liberation Sans is a close match.

```typst
#show: thesis.with(sans-font: "Liberation Sans", /* ... */)
```

## Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | `[]` | Thesis title |
| `cover-title` | `auto` | Title on the cover, may use `\` for line breaks |
| `author` | `""` | Your name |
| `matriculation-number` | `""` | Your matriculation number |
| `degree` | `"master"` | `"bachelor"` or `"master"` |
| `language` | `"english"` | `"english"` or `"german"` |
| `date` | `""` | Submission date |
| `examiners`, `supervisors` | `()` | Arrays of names |
| `abstract-en`, `abstract-de` | `none` | Abstract content |
| `abbreviations`, `notation` | `none` | Optional front matter chapters |
| `bib` | `none` | A `bibliography(...)` element |
| `ai-tools` | `none` | AI tools statement, see `main.typ` |
| `body-font` | `"sans"` | `"sans"`, or `"serif"` for a LaTeX-like body |
| `sans-font` | `auto` | Font family or list of families for sans text |
| `institute`, `chair` | `auto` | Institute and chair, on the cover and the title page |
| `university-logo` | `auto` | Official university logo PDF, `auto` shows the placeholder |
| `chair-logo` | `auto` | Cover logo in the white disc |

## License

The package is MIT licensed, see `LICENSE`. Source, issues, and pull
requests live at
[LS3-university-of-stuttgart/ls3-typst-templates-public](https://github.com/LS3-university-of-stuttgart/ls3-typst-templates-public). The files in `template/`,
which `typst init` copies into your project, are under MIT-0, so your
thesis carries no license obligations.

## Changelog

### 0.1.0

First release on Typst Universe. Logos are not bundled and are passed with
`university-logo` and `chair-logo`. The cover crops the official
university logo and sets the institute and chair lines in Typst. A
different sans font can be set with `sans-font`.
