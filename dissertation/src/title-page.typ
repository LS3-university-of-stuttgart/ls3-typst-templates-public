// title-page.typ
//
// Dissertation title page per Anlage 1 of the Promotionsordnung der
// Universität Stuttgart, 01.03.2019. The Anlage is "inhaltlich
// verbindlich": title, awarding phrase, Vorgelegt von with birthplace,
// Hauptberichter/Mitberichter, Tag der mündlichen Prüfung, institute,
// year. Always German, no logos, all black.
//
// Before acceptance the awarding phrase must read "Bei der Fakultät ...
// eingereichte Abhandlung" (status: "submitted"), in the approved print
// version "Von der Fakultät ... genehmigte Abhandlung" (status:
// "accepted"). Ported from diss_template/DISS_Vorlage.tex and checked
// against the Fakultät 2 title page template
// F02_Muster-Titelblatt_Promotionen.doc. The submitted version leaves
// out the date of the oral exam, as the faculty asks.

#import "common.typ": fonts

// Title-page-local sizes per paper format.
#let _tp-metrics(paper) = {
  if paper == "a5" {
    (
      margin: (x: 18mm, y: 18mm),
      title-size: 16pt,
      author-size: 12pt,
      body-size: 10pt,
    )
  } else {
    (
      margin: (x: 25mm, y: 25mm),
      title-size: 20pt,
      author-size: 14pt,
      body-size: 12pt,
    )
  }
}

// Degree presets in the Fakultät 2 wording, one male and one female
// form per degree. The phrase slots into "zur Erlangung der Würde
// [phrase] genehmigte Abhandlung". "dr-ing" and "dr-rer-nat" without
// suffix stay accepted as the male form for documents from before 0.4.0.
#let degree-phrases = (
  "dr-ing-male": [eines Doktor-Ingenieurs (Dr.-Ing.)],
  "dr-ing-female": [einer Doktor-Ingenieurin (Dr.-Ing.)],
  "dr-rer-nat-male": [eines Doktors der Naturwissenschaften (Dr.~rer.~nat.)],
  "dr-rer-nat-female": [einer Doktorin der Naturwissenschaften (Dr.~rer.~nat.)],
  "dr-ing": [eines Doktor-Ingenieurs (Dr.-Ing.)],
  "dr-rer-nat": [eines Doktors der Naturwissenschaften (Dr.~rer.~nat.)],
)

#let degree-message = "degree must be 'dr-ing-male', 'dr-ing-female', 'dr-rer-nat-male', or 'dr-rer-nat-female', or pass degree-phrase"

#let title-page(
  title: [],
  author: "",
  birthplace: "",
  status: "submitted",
  faculty: "Bau- und Umweltingenieurwissenschaften",
  degree: "dr-ing-male",
  degree-phrase: auto,
  awarded-by: auto,
  simtech: false,
  hauptberichter: "",
  mitberichter: (),
  exam-date: "",
  institute: "",
  year: "",
  paper: "a4",
) = {
  assert(status == "submitted" or status == "accepted", message: "status must be 'submitted' or 'accepted'")
  assert(
    degree-phrase != auto or degree in degree-phrases,
    message: degree-message,
  )
  let m = _tp-metrics(paper)
  set page(
    paper: paper,
    margin: m.margin,
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: fonts.sans, fill: black, size: m.body-size)
  set par(leading: 0.65em, justify: false)

  let phrase = if degree-phrase == auto { degree-phrases.at(degree) } else { degree-phrase }
  // Promotions through SC SimTech name the Stuttgart Center for
  // Simulation Science next to the faculty, as about a third of the
  // recent IWS Hefte do.
  let awarding-body = if simtech {
    [#faculty der Universität Stuttgart und dem Stuttgart Center for Simulation Science]
  } else {
    [#faculty der Universität Stuttgart]
  }
  let awarding = if awarded-by != auto {
    awarded-by
  } else if status == "submitted" {
    // Wording from the old LaTeX template. The Fakultät 2 title page
    // template only shows "genehmigte Abhandlung".
    [Bei der Fakultät #awarding-body \
      zur Erlangung der Würde #phrase \
      eingereichte Abhandlung]
  } else {
    [Von der Fakultät #awarding-body \
      zur Erlangung der Würde #phrase \
      genehmigte Abhandlung]
  }

  // Committee rows. All Mitberichter stand below one "Mitberichter:"
  // label, as in the recent IWS Hefte. The exam date row only appears
  // once status is "accepted".
  let committee-rows = (
    ([Hauptberichter:], [#hauptberichter]),
  )
  for (i, name) in mitberichter.enumerate() {
    let label = if i == 0 { [Mitberichter:] } else { [] }
    committee-rows.push((label, [#name]))
  }

  align(center)[
    #v(1fr)
    #text(size: m.title-size, weight: "bold", hyphenate: false)[#title]
    #v(1fr)
    #awarding
    #v(1fr)
    Vorgelegt von
    #v(4mm)
    #text(size: m.author-size)[#author]
    #if birthplace != "" [
      #v(4mm)
      aus #birthplace
    ]
    #v(1fr)
    #grid(
      columns: 2,
      align: (left, left),
      column-gutter: 10mm,
      row-gutter: 3.2mm,
      ..committee-rows.flatten(),
      ..if status == "accepted" {
        ([], [], [Tag der mündlichen Prüfung:], [#exam-date])
      },
    )
    #v(1fr)
    #institute der Universität Stuttgart
    #v(4mm)
    #year
    #v(8mm)
  ]
}
