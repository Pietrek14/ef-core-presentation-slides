// Templatka dla Typst w wersji 0.13.1

// Wymagane czcionki:
// https://bboxtype.com/typefaces/FiraSans/#!layout=specimen
// https://github.com/firamath/firamath/releases
// https://github.com/tonsky/FiraCode/releases

#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import metropolis: new-section, focus

#set text(lang: "pl")
#show: metropolis.setup

// Wyłącznienie wszystkich animacji w celu wysłania komuś prezentacji np. jak wykłady na PZE
// #enable-handout-mode(true)

#slide[
  #set page(header: none, footer: none, margin: 3em)
 
  #text(size: 1.3em)[
    *EF Core - współczesne podejście do aplikacji bazodanowych*
  ]

  Dawid Piotrowski

  #metropolis.divider
  
  #set text(size: .8em, weight: "light")

  #toolbox.side-by-side(columns: (1fr, auto))[
    Wydział Matematyki Stosowanej #linebreak()
    kierunek Informatyka (profil praktyczny)

    #datetime.today().display()
  ][
    #align(right, image("media/ps-logo.svg", height: 5cm))
  ]
]

#slide[
  = Agenda

  #metropolis.outline
]

#new-section[Tradycyjne podejście]

#slide[
  = Zapytania SQL

  #figure(
    image("media/img/01_sql_query.png"),
    caption: "Przykładowe zapytanie w języku MySQL"
  )
]

#slide[
  = Problemy
  Pisanie czystego kodu SQL generuje jednak szereg problemów, m. in.:
  #item-by-item[
    - Zwiększa objętość kodu
    - Wprowadza ryzyko SQL Injection @django_raw_sql
    - Łamie założenia programowania obiektowego
  ]
]

#new-section[Object-Relational Mapping]

#slide[
  = Object-Relational Mapping

  Object-Relational Mapping to mechanizm pozwalający aplikacji zbudowanej
  obiektowo osiągnąć stałość danych przez zastosowanie bazy danych. Programista
  widzi interfejs obiektowy, jednak pod spodem dane są zapisywane do bazy
  relacyjnej.
]

#slide[
  = Entity Framework

  Entity Framework, znany jako EF, to technologia typu ORM dla języka
  C\#. Encje są w niej modelowane za pomocą natywnych językowi klas.
  Współczesną wersją Entity Framework jest EF 6 i to właśnie z niego
  zamierzam korzystać podczas tej prezentacji @ef6.
]

#slide[
  = Bibliografia
  #bibliography("bibliography.yaml")
]
