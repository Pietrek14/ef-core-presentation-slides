// Templatka dla Typst w wersji 0.13.1

// Wymagane czcionki:
// https://bboxtype.com/typefaces/FiraSans/#!layout=specimen
// https://github.com/firamath/firamath/releases
// https://github.com/tonsky/FiraCode/releases

#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/lilaq:0.6.0" as lq

#import metropolis: new-section, focus

#set text(lang: "pl")
#show: metropolis.setup
#show: codly-init.with()

#show emph: it => {
  text(black, it.body, style: "italic")
}

#codly(languages: codly-languages)

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
  Najpopularniejszą wersją Entity Framework jest EF Core @ef_core i to
  właśnie z niej zamierzam korzystać podczas tej prezentacji.
]

#slide[
  = Pakiety NuGet

  EF Core składa się z jednego, głównego pakietu NuGet oraz szeregu modularnych
  rozszerzeń, obsługujących popularne rozwiązania bazodanowe takie, jak:
   - PostgreSQL
   - SQL Server
   - SQLite
   - MongoDB
   - MySQL @ef_core_database_providers

  Istnieją także inne pakiety rozszerzające funkcjonalności EF Core.
]

#slide[
  = Pakiety NuGet
  Pakiet do pracy z bazami MySQL nie został jeszcze niestety zaktualizowany do wersji 10, więc korzystamy z nieco starszej wersji EF Core.

  #figure(
    image("media/img/02_nuget_packages.png"),
    caption: "Pakiety NuGet do obsługi EF Core z bazą MySQL"
  )
]

#slide[
  = Model danych

  Dane modelujemy za pomocą klas C\#. Rozpocznijmy od prostego przykładu.

  ```cs
  public class Student
  {
      public Guid StudentId { get; set; }
      public string FirstName { get; set; } = null!;
      public string LastName { get; set; } = null!;
      public int Age { get; set; }
  }
  ```

  Kluczowym polem jest tutaj `StudentId`. Zostanie ono automatycznie
  rozpoznane przez EF Core jako klucz główny @ef_core_tutorial.
]

#slide[
  = Model danych

  Utworzony model musimy umieścić w tzw. kontekście danych. Jest to
  obiekt odpowiedzialny za komunikację z bazą danych. Wygląda następująco:

  ```cs
  public class SchoolContext : DbContext
  {
      public DbSet<Student> Students { get; set; }

      protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
      {
          String connString = "Server=localhost;Database=school;User=root;Password=;";
          optionsBuilder.UseMySql(connString, ServerVersion.AutoDetect(connString));
      }
  }
  ```
]

#slide[
  = Migracje
  Po utworzeniu modelu naszych danych, chcielibyśmy, aby EF Core utworzył
  na jego podstwie bazę danych. Proces ten nazywa się migracją. Migrację
  tworzymy za pomocą narzędzia `Add-Migration`. Narzędzie te generuje kod 
  tworzący odpowiednie tabele, który możemy sobie przejrzeć. Zmiany 
  zatwierdzamy poleceniem `Update-Database`.

  #figure(
    image("media/img/03_add_migration.png"),
    caption: "Dodawanie nowej migracji"
  )
]

#slide[
  = Migracje
  Po wykonaniu migracji, wygenerowana baza danych stała się widoczna w
  phpmyadmin. Poza tabelą _students_, EF Core stworzył także tabelę
  _\_\_efmigrationhistory_, której zadaniem jest śledzić przeprowadzone
  na bazie migracje @ef_core_tutorial.

  #figure(
    image("media/img/04_generated_database.png"),
    caption: "Wygenerowana baza danych"
  )
]

#slide[
  = Migracje
  #figure(
    image("media/img/05_student_table_structure.png"),
    caption: "Struktura tabeli students"
  )
]

#slide[
  = Rozszerzenie modelu
  Celem zaprezentowania rozszerzalności migracji oraz zaprezentowania
  relacji wyposażamy model także w klasę `Class`, opisującą szkolną
  klasę jako grupę uczniów.

  ```cs
  public class Class
  {
      public Guid ClassId { get; set; }
      public string Name { get; set; } = null!;
      public ICollection<Student> Students { get; set; } = null!;
  }
  ```
]

#slide[
  = Rozszerzenie modelu
  Należy oczywiście uzupełnić kontekst o odpowiednie pole.

  ```cs
  public class SchoolContext : DbContext
  {
      public DbSet<Student> Students { get; set; }
      public DbSet<Class> Classes { get; set; }

      protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
      {
          String connString = "Server=localhost;Database=school;User=root;Password=;";
          optionsBuilder.UseMySql(connString, ServerVersion.AutoDetect(connString));
      }
  }
  ```
]

#slide[
  = Rozszerzenie modelu
  Poleceniem `Add-Migration` tworzy się nową migrację, odpowiedzialną
  za rozszerzenie bazy o tabelę _classes_.

  #figure(
    image("media/img/06_classes_migration.png"),
    caption: "Utworzenie i zatwierdzenie migracji"
  )
]

#slide[
  = Rozszerzenie modelu
  W bazie danych pojawiła się tabela _classes_.

  #figure(
    image("media/img/07_classes_table_structure.png"),
    caption: "Struktura tabeli classes"
  )
]

#slide[
  = Rozszerzenie modelu
  Co jednak istotniejsze z perspektywy tego przykładu, mimo dokładnie
  takiego samego kodu C\# w ramach klasy `Student`, zmieniona została
  także tabela _students_. EF Core automatycznie dodał do niej nowe pole
  `ClassId`, implementujące relację jeden-do-wielu.

  #figure(
    image("media/img/08_student_table_structure_with_class_id.png"),
    caption: "Struktura tabeli students po wprowadzeniu relacji"
  )
]

#slide[
  = Populowanie bazy
  Aby dodać dane do bazy z poziomu kodu C\#, najpierw należy instancjonować
  klasę `SchoolContext`. Stanowi ona repozytorium naszych danych. Z poziomu
  programu traktujemy ją jako zwykły obiekt. Korzystamy z metody `Add`, aby
  dodać do niej nowe dane.

  ```cs
  using var context = new SchoolContext();

  Student dawidPiotrowski = new Student() { 
      StudentId = Guid.NewGuid(),
      FirstName = "Dawid",
      LastName = "Piotrowski",
      Age = 21
  };

  Student danielSmiglo = new Student() { 
      StudentId = Guid.NewGuid(),
      FirstName = "Daniel",
      LastName = "Smiglo",
      Age = 22
  };

  context.Add(dawidPiotrowski);
  context.Add(danielSmiglo);

  context.SaveChanges();
  ```
]

#slide[
  = Populowanie bazy
  W celu zaprezentowania relacji, tworzymy także obiekt typu `Class`

  ```cs
  Class exampleClass = new Class() { 
      ClassId = Guid.NewGuid(),
      Name = "1A",
      Students = new List<Student>() { dawidPiotrowski, danielSmiglo }
  };

  context.Add(exampleClass);

  context.SaveChanges();
  ```
]

#slide[
  = Populowanie bazy
  Po uruchomieniu załączonego kodu, tabele w bazie zapełniły się
  ustawionymi wartościami.

  #figure(
    image("media/img/09_student_table_populated.png"),
    caption: "Spopulowana tabela students"
  )

  #figure(
    image("media/img/10_classes_table_populated.png"),
    caption: "Spopulowana tabela classes"
  )
]

#slide[
  = Wybieranie rekordów
  Aby dostać się do danych w bazie, wykorzystujemy powszechny w C\# mechanizm
  zapytań LINQ. Co istotne, zapytania wykonują się po stronie bazy danych,
  a nie na lokalnie pobranych rekordach @ef_core_queries.

  ```cs
  var student = context.Students.FirstOrDefault(s => s.FirstName == "Dawid");

  if(student is Student)
  {
      Console.WriteLine($"{student.FirstName} {student.LastName}"); // Dawid Piotrowski
  }
  ```
]

#slide[
  = Edycja rekordów
  Tak wybrany rekord jesteśmy w stanie edytować jak zwykły obiekt C\#.
  Następnie wystarczy zapisać kontekst, aby zmiany znalazły się w bazie
  danych.

  ```cs
  if (student is Student)
    student.Age++;

  context.SaveChanges();
  ```

  #figure(
    image("media/img/11_edited_record.png"),
    caption: "Edytowany rekord"
  )
]

#slide[
  = Usuwanie rekordów
  Rekordy możemy oczywiście również usuwać. Dokonujemy tego za pomocą
  metody `Remove`.

  ```cs
  if (student is Student)
    context.Remove(student);

  context.SaveChanges();
  ```
]

#new-section[Zalety i wady rozwiązań ORM]

#slide[
  = Zalety korzystania z ORM

  #item-by-item[
    - Upraszają kod, co pozytywnie wpływa na produktywność
    - Zwiększają bezpieczeństwo, zapobiegając np. SQL Injection
    - Ułatwiają migracje między różnymi bazami danych
    - Oferują większą czytelność kodu, ułatwiając jego utrzymywanie @pros_and_cons_of_orm
    - Lepiej wpasowują się w obiektową architekturę aplikacji
  ]
]

#slide[
  = Wady korzystania z ORM

  #item-by-item[
    - Zdarza im się produkować nieoptymalne zapytania
    - Wypełnianie obiektów danymi z bazy (hydration) często tworzy bottleneck'i @orms_are_overrated
    - Wysoki poziom abstrakcji utrudnia debugowanie
    - Czyste zapytania SQL oferują większy poziom kontroli nad zapytaniem @pros_and_cons_of_orm
  ]
]

#new-section[Podsumowanie]

#slide[
  = Wnioski
  Technologie ORM to popularne, pełnowymiarowe rozwiązania, stanowiące
  rzeczywistą alternatywę dla tradycyjnych zapytań SQL. Decydując się
  na zastosowanie ich w projekcie informatycznym, należy rozważyć
  zarówno ich mocne strony, jak i niedociągnięcia. Nawet, jeśli preferuje
  się pisanie czystego kodu SQL, warto mieć podstawową wiedzę na temat ORM'ów
  jako branżowego standardu dla aplikacji bazodanowych.
]

#slide[
  = Wnioski
  Aby udowodnić popularności ORM'ów, zaprezentowano dane dotyczące liczby
  wyszukań frazy "ORM" w wyszukiwarce Google @orm_trends.

  #let parse-date(str) = {
    let parts = str.trim().split("-")
    let y = int(parts.at(0))
    let m = int(parts.at(1))
    let d = int(parts.at(2))
    
    y + ((m - 1) * 30.5 + d) / 365.25
  }

  #let convs = (
    Week: parse-date,
    rest: float,
  )

  #let data = lq.load-txt(
    read("media/multiTimeline.csv"),
    header: true,
    converters: convs
  )

  #lq.diagram(
    title: [Tygodniowe wyszukiwania frazy "ORM" przez ostatnie 5 lat],
    ylabel: [Liczba wyszukań],
    
    width: 90%,
    height: 80%,
    margin: ( x: 0%, y: 5% ),
    ylim: ( 0, auto ),
    xaxis: (
      format-ticks: (ticks, ..) => ticks.map(t => str(calc.round(t))),
      tick-distance: 1.0
    ),

    lq.plot(data.Week, data.popularity)
  )
]

#slide[
  = Dziękuję za uwagę!

  #figure(
    image("media/img/12_me.jpg"),
    caption: "Ja dziękujący za uwagę"
  )
]

#slide[
  = Bibliografia
  #bibliography("bibliography.yaml")
]
