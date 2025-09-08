// A5 Sangbog template, made by naitsa/lorenzen, and the typst gods (some chat)

#let config = (
    // Font
    main-font: "Times New Roman",
    song-title-font: "Source Sans 3",
    subtext-font: "Times New Roman",
    song-text-font: "Times New Roman",
    
    // Size
    main-text-size: 10pt,
    song-title-size: 14pt,
    subtext-text-size: 10pt,
    song-text-size: 8pt,
)


#let songbook(
    title: "Songbook",
    author: none,
    date: none,
    body
) = {
    // Setop af sider
    set page(
        paper: "a5",
        margin: (
            top: 1.5cm,
            bottom: 1.5cm,
            left: 1.2cm,
            right: 1.2cm
        ),
        /* numbering: "1",
        number-align: (page-number) => if calc.odd(page-number) { right } else { left } */
    )

    set page(
        numbering: none,  // Disable default numbering
        footer: context [
            #if calc.odd(here().page()) [
                #align(right)[#counter(page).display()]
            ] else [
                #align(left)[#counter(page).display()]
            ]
        ]
    )
    
    // Normal tekst udseene
    set text(
        font: config.main-font,
        size: config.main-text-size,
        lang: "dk"
    )
    
    // Mellemrum mellem paragraffer
    set par(
        justify: true,
        leading: 0.65em,
    )
    
    body
}

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
        width: (1/cols) * size.width * (1 - float(gutter)*(cols - 1)),
        content
      )
    )
    #block(
      height: height / cols,
      columns(cols, gutter: gutter, content)
    )
  ])
}


// note funktion
#let note(cols: 1, body) = {
    v(0em)
    block(
        width: 100%,
        [
            #if cols > 1 [
                #eqcolumns(cols, gutter: 1em)[
                    #text(font: config.song-text-font, size: config.song-text-size)[#body]
                ]
            ] else [
                #text(font: config.song-text-font, size: config.song-text-size)[#body]
            ]
        ]
    )
    v(0em)
}

// Funktion for vers
#let vers(body) = {
    counter("verse").step()
    v(0em)
    grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        align: (top, left),
        text(font: config.song-text-font, size: config.song-text-size)[#context counter("verse").display().],
        block(breakable: true)[
            #set par(leading: 0.65em)
            #text(font: config.song-text-font, size: config.song-text-size)[#body]
        ]
    )
}

// Funktion for omkvæd
#let omkvæd(body) = {
    v(0em)
    text(font: config.song-text-font, size: config.song-text-size)[Omkvæd:]
    v(-0.65em)
    pad(left: 1em)[
        #block(breakable: true)[
            #set par(leading: 0.65em)
            #text(font: config.song-text-font, size: config.song-text-size)[#body]
        ]
    ]
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
                    #text(font: config.song-title-font, size: config.song-title-size, weight: "bold")[
                        #context counter("song").display(). #title
                    ] #song-label
                ]
                
                let title-width = measure(title-with-number).width
                let spacing-width = measure(h(2em)).width
                let subtext-content = if subtext != none {
                    text(font: config.subtext-font, size: config.subtext-text-size, style: "italic")[#subtext]
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
            })
            #v(0.5em)
            #if cols > 1 [
                #eqcolumns(cols)[#body]
            ] else [
                #body
            ]
        ]
    )
}