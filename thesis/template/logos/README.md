# Logos

The cover needs two logos, the University of Stuttgart logo and the LS3
logo. They are not part of the template, so the cover shows red
placeholders until you add them. A thesis handed in with the
placeholders is incomplete.

## University logo

Download the official logo PDF for the language of your thesis from the
[university's corporate design page](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/logo-und-schrift/).

- English. [unistuttgart_logo_englisch.pdf](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_englisch.pdf)
- German. [unistuttgart_logo_deutsch.pdf](https://www.beschaeftigte.uni-stuttgart.de/uni-services/kommunikation-und-marketing/corporate-design/cd-dateien/01_Logo/pdf/unistuttgart_logo_deutsch.pdf)

Use the PDF as it is. The template crops it, removes the "Germany" line
of the English logo, and sets your institute and department below it.
The PNG and JPG versions do not work.

## LS3 logo

Ask your supervisor for the LS3 logo file.

## Add them to your project

1. Put both files into this `logos/` folder. In the typst.app web app,
   open the file panel, select this folder, and upload the files.
2. In `main.typ`, remove the `//` in front of the `university-logo` and
   `chair-logo` lines and check that the file names match yours.

The template sizes the logos for you. Leave out `width` and `height`.
