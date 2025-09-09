// A5 Sangbog template, made by naitsa/lorenzen, and the typst gods (some chat)

#let config = (
  // Font
  main-font: "Source Serif 4",
  song-title-font: "Source Sans 3",
  subtext-font: "Source Serif 4",
  song-text-font: "Source Serif 4",
  // Size
  main-text-size: 10pt,
  song-title-size: 14pt,
  subtext-text-size: 9pt,
  song-text-size: 8pt,
  indhold-entry-size: 9pt,
  // Weight
  main-text-weight: "regular",
  song-title-weight: "bold",
  subtext-text-weight: "regular",
  song-text-weight: "medium",
  // Document
  title: "F-Klubbens Sangbog",
  description: "F-Klubbens Fabelagtige Sangbog",
  authors: (
    (name: "BoAnd"),
    (name: "Simlau"),
    (name: "AI"),
    (name: "Jesus"),
    (name: "For-mændene"),
  ),
  date: datetime.today(),
  localisation: (
    lang: "dk",
    region: "dk",
  ),
)


#let songbook(
  title: config.title,
  description: config.description,
  authors: config.authors,
  date: config.date,
  localisation: config.localisation,
  body,
) = {
  set document(
    title: title,
    description: description,
    author: authors.map(a => a.name),
    keywords: "Boobies",
    date: date,
  )

  // Setop af sider
  set page(
    paper: "a5",
    margin: (
      top: 1.5cm,
      bottom: 1.5cm,
      left: 1.2cm,
      right: 1.2cm,
    ),
    /* numbering: "1",
    number-align: (page-number) => if calc.odd(page-number) { right } else { left } */
  )

  set page(
    numbering: none, // Disable default numbering
    footer: context [
      #if calc.odd(here().page()) [
        #align(right)[#counter(page).display()]
      ] else [
        #align(left)[#counter(page).display()]
      ]
    ],
  )

  // Normal tekst udseene
  set text(
    font: config.main-font,
    size: config.main-text-size,
    weight: config.main-text-weight,
    lang: "dk",
  )

  // Mellemrum mellem paragraffer
  set par(
    justify: true,
    leading: 0.65em,
  )

  show link: it => {
    text(
      font: config.main-font,
      size: config.indhold-entry-size,
      weight: config.main-text-weight,
      it,
    )
  }

  /* set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level == 1 {
      str(nums.pos().at(0) - 1) + "." // offset by 1 for 0-indexing
    } else {
      numbering("1.1", ..nums)
    }
  }) */

  body
}

#counter("song").update(0)

// https://github.com/typst/typst/issues/466
#let balanced-cols(cols: 2, content) = style(styles => {
  let h = measure(content, styles).height / cols
  block(height: h, columns(cols, content))
})

// https://github.com/typst/typst/issues/466
#let eqcolumns(cols, gutter: 4%, content) = {
  layout(size => [
    #let (height,) = measure(
      block(
        width: (1 / cols) * size.width * (1 - float(gutter) * (cols - 1)),
        content,
      ),
    )
    #block(
      height: height / cols + 1em, // cursed 1em
      columns(cols, gutter: gutter, content),
    )
  ])
}

#let format-authors(authors) = {
  let names = authors.map(a => a.name)
  if names.len() == 1 {
    names.first()
  } else if names.len() == 2 {
    names.at(0) + " and " + names.at(1)
  } else {
    let all-but-last = names.slice(0, -1).join(", ")
    all-but-last + " and " + names.last()
  }
}


// note funktion
#let note(cols: 1, body) = {
  v(0em)
  block(
    width: 100%,
    [
      #if cols > 1 [
        #eqcolumns(cols, gutter: 1em)[
          #text(
            font: config.song-text-font,
            size: config.song-text-size,
            weight: config.song-text-weight,
          )[#body]
        ]
      ] else [
        #text(
          font: config.song-text-font,
          size: config.song-text-size,
          weight: config.song-text-weight,
        )[#body]
      ]
    ],
  )
  v(0em)
}

// Funktion for vers
#let vers(body) = {
  counter("verse").step()
  v(0em)
  table(
    rows: 1,
    columns: (1em, auto),
    row-gutter: 0.5em,
    column-gutter: 0.5em,
    stroke: none,
    inset: 0em,
    align: (right, left),
    [#text(
      font: config.song-text-font,
      size: config.song-text-size,
      weight: config.song-text-weight,
    )[#context counter("verse").display().]],
    [#text(
      font: config.song-text-font,
      size: config.song-text-size,
      weight: config.song-text-weight,
    )[#body]],
  )
  v(0em)
}

// Funktion for omkvæd
#let omkvæd(body) = {
  v(0em)
  table(
    rows: 2,
    columns: (1em, auto),
    row-gutter: 0.5em, //0.325em 0.65em
    column-gutter: 0.5em,
    stroke: none,
    inset: 0em,
    table.cell(colspan: 2)[#text(
      font: config.song-text-font,
      size: config.song-text-size,
      weight: config.song-text-weight,
    )[Omkvæd:]],
    [],
    [#text(
      font: config.song-text-font,
      size: config.song-text-size,
      weight: config.song-text-weight,
    )[#body]],
  )
}

// Funktion for sang (basically bare en block med en header)
#let sang(title, subtext: none, cols: 1, subtext-indent: 4em, body) = {
  counter("verse").update(0)
  counter("song").step()
  // Label for sangindex
  let song-label = label(title.replace(" ", "-").replace(",", "").replace(".", ""))

  block(
    width: 100%,
    inset: (bottom: 0em),
    [
      #layout(size => {
        let title-with-number = [
          #text(font: config.song-title-font, size: config.song-title-size, weight: config.song-title-weight)[
            #context counter("song").display(). #title
          ] #song-label
        ]

        let title-width = measure(title-with-number).width
        let spacing-width = measure(h(2em)).width
        let subtext-content = if subtext != none {
          text(
            font: config.subtext-font,
            size: config.subtext-text-size,
            weight: config.subtext-text-weight,
            style: "italic",
          )[#subtext]
        } else { none }

        if subtext != none and title-width + spacing-width + measure(subtext-content).width > size.width {
          // Title too long - put subtext on new line with indent
          [#title-with-number #linebreak() #h(subtext-indent) #subtext-content]
        } else if subtext != none {
          // Title fits - put subtext inline with 2em spacing
          [#title-with-number #h(2em) #subtext-content]
        } else {
          // No subtext
          title-with-number
        }
        hide(place[#heading(level: 1, numbering: none, outlined: true)[#title]])
      })
      #v(0.5em)
      #if cols > 1 [
        #eqcolumns(cols)[#body]
      ] else [
        #body
      ]
    ],
  )
}

#let forside = page[
  #set text(font: config.main-font, size: config.main-text-size, weight: config.main-text-weight)
  #align(center)[
    #v(1cm)
    #text(size: 2.5em, weight: "regular")[#smallcaps[#config.title]]
    #v(0.4cm)
    //#text(size: 14pt)[#config.description]
    //#v(3em)
    #text(size: 1em, weight: "regular")[
      Made by #format-authors(config.authors) - #config.date.year()
    ]
    #v(1.5cm)
    #image("assets/fklubben.svg", width: 70%)
  ]
]

#let forord = page()[
  \#fritfit\
  \#fritfor
]

#let meme_page_spacer = page()[
  *error*: unknown function `undefinedcontrolsequence`
]

#let indholdfortegnelse(cols: 3) = page({
  heading(level: 1, numbering: none, outlined: false, text(
    font: config.song-title-font,
    size: config.song-title-size,
    weight: config.song-title-weight,
  )[Indholdsfortegnelse])

  v(0.5cm)
  set par(leading: 0.25em)

  columns(cols, gutter: 0.5cm, {
    context {
      let chapters = query(
        heading.where(
          level: 1,
          outlined: true,
        ),
      ).sorted(key: chapter => {
        lower(repr(chapter.body))
      })

      // First, group all chapters by their starting character
      let groups = (:)

      for chapter in chapters {
        // Get the string representation and extract content
        let chapter_repr = repr(chapter.body)
        let actual_content = ""
        if chapter_repr.starts-with("[") and chapter_repr.ends-with("]") {
          actual_content = chapter_repr.slice(1, -1)
        } else {
          actual_content = chapter_repr
        }

        let chapter_text = lower(actual_content)

        // Determine group
        let group_key = "non-letter" // Default
        if chapter_text.len() > 0 {
          let first_char = chapter_text.first()
          if first_char >= "a" and first_char <= "z" {
            group_key = first_char
          }
        }

        // Add to groups
        if group_key in groups {
          groups.at(group_key).push(chapter)
        } else {
          groups.insert(group_key, (chapter,))
        }
      }

      // Sort group keys so non-letter comes first, then alphabetical
      let group_keys = groups
        .keys()
        .sorted(key: key => {
          if key == "non-letter" { "0" } else { key }
        })

      // Now print each group
      let first_group = true
      for group_key in group_keys {
        // Add spacing between groups (except before first group)
        if not first_group {
          v(0.1em)
        }
        first_group = false

        // Print all chapters in this group
        for chapter in groups.at(group_key) {
          let loc = chapter.location()
          let page = loc.page()
          link(
            loc,
            [ #chapter.body #page ],
          )
        }
      }
    }
  })
})

#let kapitelside(titel: none, asset: "assets/fklubben.svg", spacing: 2cm) = page[
  #set text(font: config.main-font, size: config.main-text-size, weight: config.main-text-weight)
  #align(center)[
    #v(1cm)
    #text(size: 2.5em, weight: "regular")[#smallcaps[#titel]]
    #v(spacing)
    #if asset != none [
      #image(asset, width: 70%)
    ]
  ]
]
