# CleaningApp — Specyfikacja Produktu

> Wersja: 0.5 | Data: 2026-03-18

---

## 1. Cel i kontekst

CleaningApp to aplikacja na iOS pomagająca użytkownikowi zarządzać codziennym sprzątaniem domu. Główna propozycja wartości: zamiast przytłaczać długą listą zaległości, aplikacja **inteligentnie rozkłada zadania w ciągu tygodnia** i pokazuje użytkownikowi tylko to, co ma do zrobienia dzisiaj — wraz z szacowanym czasem sprzątania.

### Cel MVP

- Skonfigurowanie pokoi i zadań (onboarding)
- Automatyczne generowanie tygodniowego planu sprzątania
- Czytelny widok "co dziś robię i ile to zajmie"
- Codzienne powiadomienie push zachęcające do sprzątania

### Poza MVP (mieć z tyłu głowy przy projektowaniu)

- Wiele domostw (wiele konfiguracji pokoi/zadań)
- Profile domowników z podziałem zadań
- Synchronizacja przez CloudKit
- Dynamiczny czas wykonania (średnia z historii) — **kandydat do MVP, dodać jako pierwsze usprawnienie**

---

## 2. Architektura danych

### 2.1 Modele domenowe

```swift
struct Room: Identifiable, Equatable {
    let id: UUID
    var name: String
    var icon: RoomIcon       // predefiniowany enum
    let createdAt: Date
}

struct Task: Identifiable, Equatable {
    let id: UUID
    var name: String
    var roomId: UUID
    var frequency: Frequency
    var estimatedDuration: TaskDuration
    let createdAt: Date
}

enum Frequency: Equatable, Codable {
    // Wielokrotnie dziennie
    case twiceDaily              // 2× dziennie (np. mycie zębów, przewietrzenie)

    // Codziennie
    case daily                   // codziennie

    // Co kilka dni
    case everyOtherDay           // co 2 dni
    case everyXDays(Int)         // co X dni (3–6)

    // Tygodniowe
    case timesPerWeek(Int)       // X razy w tygodniu (1–6)

    // Wielotygodniowe
    case everyOtherWeek          // co 2 tygodnie
    case everyXWeeks(Int)        // co X tygodni (3–4)

    // Miesięczne
    case timesPerMonth(Int)      // X razy w miesiącu (1–3)
    case monthly                 // raz w miesiącu

    // Sezonowe / rzadkie
    case everyXMonths(Int)       // co X miesięcy (2–6), np. mycie okien
    case quarterly               // raz na kwartał (co 3 miesiące)
    case biannually              // dwa razy w roku
    case yearly                  // raz w roku (np. czyszczenie kanałów wentylacyjnych)
}

enum TaskDuration: Int, CaseIterable, Codable {
    case fiveMinutes   = 5
    case tenMinutes    = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case sixtyMinutes  = 60
}

enum RoomIcon: String, CaseIterable, Codable {
    case kitchen       // fork.knife
    case livingRoom    // sofa
    case bedroom       // bed.double
    case bathroom      // shower
    case hallway       // door.left.hand.open
    case office        // desktopcomputer
    case garage        // car
    case laundry       // washer
    case custom        // square.grid.2x2 (dla pokoi tworzonych przez użytkownika)
}
```

#### Rejestr wykonanych zadań (pod przyszłe dynamiczne czasy)

```swift
struct CompletedTask: Identifiable {
    let id: UUID
    let taskId: UUID
    let completedAt: Date
    var measuredDuration: Int?   // w minutach; nil jeśli nie mierzono
}
```

#### Zaplanowane zadanie (wynik algorytmu)

```swift
struct ScheduledTask: Identifiable {
    let id: UUID
    let task: Task
    let room: Room
    let scheduledDate: Date      // konkretny dzień tygodnia
    var isCompleted: Bool
}
```

### 2.2 Persystencja (SwiftData)

Każdy model domenowy ma odpowiadającą mu encję SwiftData (`RoomEntity`, `TaskEntity`, `CompletedTaskEntity`, `SkippedTaskEntity`). Mapowanie przez dedykowane mappery — wzorzec już istniejący w projekcie.

`ScheduledTask` **nie** jest persystowany — jest przeliczany przez algorytm. Persystowany jest `CompletedTask` (fakt wykonania) oraz `SkippedTask` (fakt przesunięcia — patrz sekcja 3).

```swift
struct SkippedTask: Identifiable {
    let id: UUID
    let taskId: UUID
    let originalDate: Date    // dzień, na który zadanie było zaplanowane
    let skippedAt: Date       // kiedy użytkownik nacisnął "przesuń"
}
```

---

## 3. Algorytm harmonogramowania

> To jest serce aplikacji.

### 3.1 Wejście

- Lista wszystkich `Task` użytkownika (z `frequency` i `estimatedDuration`)
- Historia `CompletedTask` (daty wykonań każdego zadania)
- Historia `SkippedTask` (zadania przesunięte — wracają do puli)
- Bieżąca data + zakres dni do zaplanowania (pozostałe dni tygodnia)
**Dzienny limit czasu** — **30 minut** domyślnie, konfigurowalne przez użytkownika w Settings (MVP). Tolerancja ±2 min.

### 3.2 Zasady działania

1. **Horyzont: tydzień kalendarzowy (pon–ndz)** — algorytm operuje na bieżącym tygodniu kalendarzowym. Jeśli użytkownik zaczyna w środę, plan obejmuje środę–niedzielę. Nowy pełny plan generowany jest w poniedziałek.

2. **Plan jest żywy, ale z umiarem** — plan zmienia się tylko w konkretnych sytuacjach (patrz punkt 5). Odhaczenie wykonanego zadania **nie** trigggeruje przeplanowania.

3. **Twardy dzienny limit czasu (±2 min tolerancja)** — algorytm nigdy nie przekroczy dziennego limitu dla danego dnia. Jeśli po dołożeniu zaległych zadań limit byłby przekroczony, nadwyżka zadań jest przenoszona na kolejne dni (lub oznaczana jako "odłożone na przyszły tydzień" jeśli brakuje miejsca w tygodniu). Zadania nigdy się nie duplikują.

4. **Równomierne rozłożenie w ramach limitu** — spośród dni, które jeszcze mają wolne moce przerobowe (poniżej limitu), algorytm minimalizuje odchylenie standardowe dziennego łącznego czasu. Cel: każdy dzień ma podobny czas, żaden nie jest "przeładowany".

5. **Triggery przeplanowania** (na pozostałe dni tygodnia, z pominięciem już minionych):
   - **O północy** — jeśli w minionym dniu zostały niewykonane zadania, wracają do puli; algorytm generuje nowy plan na pozostałe dni
   - **Przy otwarciu aplikacji** — jeśli od ostatniego przeplanowania minęła północ (backup dla przypadku gdy app była zamknięta)
   - **"Przesuń na jutro"** — przesunięte zadanie trafia do `SkippedTask` i natychmiast triggeruje przeplanowanie pozostałych dni
   - **Po edycji struktury** — dodanie/edycja/usunięcie zadania lub pokoju
   - **Na żądanie** — pull-to-refresh

6. **Bez duplikacji zaległości** — zadanie niewykonane wraca do puli jako jeden egzemplarz, niezależnie od tego ile razy było już przesuwane. Algorytm uwzględnia jego oryginalną częstotliwość i datę ostatniego wykonania przy ponownym planowaniu.

7. **Zachowanie ciągłości częstotliwości** — przy planowaniu uwzględniamy datę ostatniego wykonania z `CompletedTask`, żeby zachować właściwe odstępy. Np. zadanie "co 2 tygodnie" wykonane w środę → pojawi się w planie za ~14 dni od tej środy.

### 3.3 Pseudokod (high-level)

```
func reschedule(tasks, completionHistory, skippedHistory, remainingDays, dailyLimit) -> [ScheduledTask]:
    pool = []   // zadania do zaplanowania

    for each task in tasks:
        lastCompletion = completionHistory.lastDate(for: task.id)
        lastSkip       = skippedHistory.lastDate(for: task.id)
        
        // Wyznacz ile razy zadanie powinno wystąpić w remainingDays
        occurrences = occurrencesNeeded(task.frequency, lastCompletion, remainingDays)
        
        // Dodaj do puli jako N egzemplarzy (nigdy więcej niż 1 zaległy)
        pool.append(contentsOf: repeat(task, occurrences))

    // Posortuj dni po aktualnym obciążeniu (rosnąco)
    slots = { day: currentLoad } for each day in remainingDays

    // Przypisuj zadania do dni respektując limit
    for each taskInstance in pool (sorted by priority: overdue first):
        candidateDays = slots.filter { load + task.duration <= dailyLimit + 2min }
        
        if candidateDays.isEmpty:
            // Brak miejsca w tym tygodniu → oznacz jako "odłożone"
            markAsPostponed(taskInstance)
        else:
            bestDay = candidateDays.minBy { load }   // najmniej obciążony
            slots[bestDay].append(taskInstance)

    return flatten(slots)
```

`occurrencesNeeded` — na podstawie `frequency` i `lastCompletion` wyznacza liczbę wystąpień zadania w oknie `remainingDays`. Zaległe zadanie (niewykonane w poprzednich dniach) dolicza **co najwyżej 1 dodatkowe** wystąpienie.

`dailyLimit` — domyślnie **30 minut**, tolerancja ±2 min. Docelowo konfigurowalne w Settings użytkownika..

---

## 4. Ekrany

### 4.1 Onboarding (przebudowa istniejącego)

Kluczowy cel onboardingu: **jak najszybciej doprowadzić użytkownika do stanu "gotowy do działania"**, jednocześnie pokazując mu wartość aplikacji.

#### Krok 1 — Welcome
- Jasna propozycja wartości: "Sprzątaj mądrzej, nie ciężej"
- Krótki opis: algorytm, codzienne plany, bez stresu
- CTA: "Zaczynamy" → krok 2

#### Krok 2 — Wybierz pokoje
- Siatka predefiniowanych pokoi z ikonami (kuchnia, salon, łazienka, sypialnia, korytarz, biuro, garaż, pralnia)
- Możliwość zaznaczenia wielu naraz (toggle selection)
- Przycisk "+ Dodaj własny" otwiera sheet z polem tekstowym i wyborem ikony (z `custom` jako fallback)
- Minimum 1 pokój wymagany do przejścia dalej
- CTA: "Dalej" → krok 3

#### Krok 3 — Dodaj zadania do pokoi
- Dla każdego wybranego pokoju: lista predefiniowanych zadań z checkboxami
- **Brak edycji częstotliwości/czasu w onboardingu** — zadania przyjmują wartości domyślne; konfiguracja dostępna w aplikacji po onboardingu
- Opcja pominięcia ("Dodaj zadania później") — zadania można skonfigurować w aplikacji
- Predefiniowane zestawy zadań per pokój (przykłady):
  - Kuchnia: odkurzanie, mycie podłogi, czyszczenie blatu, mycie zlewu, mycie piekarnika
  - Łazienka: mycie toalety, mycie umywalki, mycie prysznica/wanny, mycie podłogi
  - Salon: odkurzanie, mycie podłogi, ścieranie kurzu
  - Sypialnia: odkurzanie, zmiana pościeli, wietrzenie
- CTA: "Zakończ konfigurację"

#### Krok 4 — Gotowe!
- Krótkie podsumowanie: X pokoi, Y zadań, plan gotowy
- CTA: "Przejdź do aplikacji" → `completeOnboarding()`

### 4.2 Home — Plan na dziś

Główny ekran aplikacji.

**Header:**
- Data (np. "Wtorek, 18 marca")
- Łączny szacowany czas na dziś (np. "~25 minut")

**Pasek postępu (główny element wizualny, tuż pod headerem):**
- Duży, wyraźny `ProgressView` zajmujący całą szerokość ekranu
- Wyświetla % ukończonych zadań na dziś (np. 3/5 = 60%)
- Obok lub pod paskiem czytelna etykieta: "3 z 5 zadań" 
- Wypełnienie animowane przy odhaczaniu każdego kolejnego zadania
- Przy 100% — krótka celebracja (np. animacja confetti lub zmiana koloru na zielony)

**Lista zadań na dziś:**
- Każde zadanie: nazwa, nazwa pokoju, szacowany czas, checkbox
- Odhaczenie = zapisanie `CompletedTask` z `completedAt = now` + animacja paska postępu
- Opcja "przesuń na jutro" (swipe action) — zadanie wraca do puli algorytmu i triggeruje przeplanowanie pozostałych dni

**Stan pusty (brak zadań na dziś):**
- Motywujący komunikat ("Dziś wolne! Zasłużony odpoczynek.")

**Stan brak konfiguracji:**
- CTA zachęcające do dodania pokoi/zadań

**Sekcja gamifikacji (poniżej listy zadań):**

Wyświetlana zawsze, bez przytłaczania — lekka, pomocnicza, nie dominuje nad planem.

- **Streak dzienny** — liczba kolejnych dni kalendarzowych, w których wykonano co najmniej jedno zadanie. Wyświetlany jako liczba z ikoną ognia (np. "🔥 5 dni z rzędu"). Obok streak bieżący — najdłuższy streak wszech czasów (np. "Rekord: 14 dni").
- **Postęp tygodniowy** — liczba ukończonych zadań w bieżącym tygodniu kalendarzowym (np. "12/18 zadań w tym tygodniu").
- **Heatmapa aktywności** — siatka kafelków analogiczna do GitHub contribution graph; każdy kafelek = 1 dzień, intensywność koloru = liczba wykonanych zadań. Zakres: ostatnie ~12 tygodni (3 miesiące), wyświetlany poziomo z możliwością scrolla. Brak danych = szary kafelek.

**Model danych dla gamifikacji** — wyliczane dynamicznie z `CompletedTask`, bez osobnych encji persystowanych:

```swift
struct GamificationStats {
    let currentStreak: Int       // liczba kolejnych dni z ≥1 wykonanym zadaniem
    let longestStreak: Int       // historyczny rekord streaka
    let tasksThisWeek: Int       // ukończone zadania w bieżącym tygodniu kalendarzowym
    let totalTasksThisWeek: Int  // zaplanowane zadania w bieżącym tygodniu
    let activityData: [Date: Int] // data → liczba wykonanych zadań (pod heatmapę)
}
```

`GamificationStats` wyliczany przez `GamificationService` na podstawie historii `CompletedTask`.

### 4.3 Rooms — Pokoje i zadania

**Lista pokoi:**
- Karta każdego pokoju: ikona, nazwa, liczba zadań
- FAB / toolbar button: dodaj nowy pokój
- Swipe: usuń pokój (z potwierdzeniem)

**Detail pokoju:**
- Nazwa pokoju (edytowalna)
- Lista zadań pokoju: nazwa, częstotliwość, czas
- Dodaj zadanie (predefiniowane z listy lub własne)
- Edycja/usuwanie zadania

**Detail zadania (sheet):**
- Nazwa (edytowalne pole tekstowe)
- Częstotliwość: Picker (Codziennie / X razy w tygodniu / X razy w miesiącu)
- Czas wykonania: Picker segmented (5 / 10 / 15 / 30 / 60 min)
- Zapisz / Anuluj

### 4.4 Settings — Ustawienia

- **Dzienny limit sprzątania** — Stepper lub Slider (krok: 5 min), zakres 10–120 min, domyślnie 30 min
  - Zmiana → natychmiastowe przeliczenie planu na pozostałe dni tygodnia
- **Godzina powiadomienia** — `DatePicker` (tylko godzina), domyślnie 17:00
  - Zmiana godziny → anulowanie starego powiadomienia → rejestracja nowego przez `LocalNotificationKit`
- **Powiadomienia** — toggle włącz/wyłącz
- **Sekcja "Nadchodzące"** (placeholder, wyłączone w MVP):
  - Wiele domostw
  - Domownicy
- **Sekcja deweloperska** (tylko DEV/MOCK) — istniejący DevSettings

---

## 5. Powiadomienia

- **Trigger:** codziennie o godzinie wybranej przez użytkownika (domyślnie 17:00)
- **Treść:** 
  - Tytuł: "Czas na sprzątanie!"
  - Body: "Masz X zadań na dziś — zajmie to ok. Y minut."
- **Implementacja:** `LocalNotificationKit` (już w projekcie)
- **Harmonogram:** powiadomienie jest przeplanowywane (cancel + reschedule) przy:
  - Zmianie godziny w Settings
  - Włączeniu/wyłączeniu powiadomień
  - Przeliczeniu planu (aktualizacja treści z nową liczbą zadań)
- **Uprawnienia:** pytanie o zgodę przy pierwszym uruchomieniu po onboardingu

---

## 6. Konwencje techniczne

### 6.1 Stack

| Element | Wartość |
|---|---|
| Platform | iOS 18.0+ |
| Language | Swift 6.0 |
| UI | SwiftUI |
| Persistence | SwiftData |
| Navigation | NavigationKit (custom SPM) |
| Notifications (timer) | Do zaimportowania — dedykowany pakiet SPM (do dodania do projektu) |

### 6.2 Architektura

Projekt stosuje wzorzec **RIB (Router–Interactor–Builder)** + Presenter + View, zgodnie z istniejącym kodem:

```
Feature/
├── Presentation/
│   ├── FeatureView.swift          // SwiftUI View, tylko UI
│   └── FeaturePresenter.swift     // @Observable, tłumaczy akcje widoku na wywołania Interactora/Routera
└── RIB/
    ├── FeatureBuilder.swift       // Składa zależności, buduje widok
    ├── FeatureInteractor.swift    // Logika biznesowa + protokół
    └── FeatureRouter.swift        // Nawigacja + protokół
```

Logika algorytmu harmonogramowania trafia do osobnego serwisu (`SchedulingService`) — nie do Interactora, żeby był testowalny jednostkowo.

### 6.3 Nowe serwisy do stworzenia

| Serwis | Odpowiedzialność |
|---|---|
| `TaskManager` | CRUD dla `Task`, wzorzec analogiczny do `RoomManager` |
| `SchedulingService` | Algorytm `reschedule(...)` — generowanie/aktualizacja planu tygodniowego |
| `CompletedTaskManager` | Zapis i odczyt historii wykonań |
| `SkippedTaskManager` | Zapis i odczyt historii przesunięć |
| `GamificationService` | Wyliczanie `GamificationStats` z historii `CompletedTask` |
| `NotificationScheduler` | Wrapper nad `LocalNotificationKit` dla logiki powiadomień CleaningApp |

### 6.4 Rozszerzenie modelu `Room`

Istniejący `Room` (tylko `id` + `createdAt`) zostanie rozszerzony o `name` i `icon`. Analogicznie `RoomEntity`.

### 6.5 Tracking czasu wykonania (MVP+)

Pierwsza planowana funkcja po stabilizacji MVP:

- Przy odhaczaniu zadania: opcjonalny stoper (start/stop)
- Zmierzony czas zapisywany w `CompletedTask.measuredDuration`
- Po N wykonaniach (np. 3) `TaskManager` wylicza `averageDuration` i używa go zamiast `estimatedDuration` w algorytmie i widokach
- Wymaga dedykowanego pakietu SPM do timera (do dodania do projektu)

---

## 7. Predefiniowane dane

### Pokoje i zadania (przykładowe, do rozszerzenia)

| Pokój | Ikona | Predefiniowane zadania (domyślna częstotliwość, czas) |
|---|---|---|
| Kuchnia | fork.knife | Odkurzanie (2×/tydz, 10 min), Mycie podłogi (1×/tydz, 15 min), Czyszczenie blatu (3×/tydz, 5 min), Mycie zlewu (2×/tydz, 10 min), Mycie piekarnika (1×/mies, 30 min) |
| Łazienka | shower | Mycie toalety (1×/tydz, 10 min), Mycie umywalki (2×/tydz, 5 min), Mycie prysznica/wanny (1×/tydz, 15 min), Mycie podłogi (1×/tydz, 10 min) |
| Salon | sofa | Odkurzanie (2×/tydz, 15 min), Mycie podłogi (1×/tydz, 20 min), Ścieranie kurzu (1×/tydz, 10 min) |
| Sypialnia | bed.double | Odkurzanie (1×/tydz, 10 min), Zmiana pościeli (1×/tydz, 15 min), Wietrzenie (codziennie, 5 min) |
| Korytarz | door.left.hand.open | Odkurzanie (2×/tydz, 5 min), Mycie podłogi (1×/tydz, 10 min) |
| Biuro | desktopcomputer | Ścieranie kurzu (1×/tydz, 10 min), Odkurzanie (1×/tydz, 10 min) |
| Garaż | car | Zamiatanie (1×/mies, 20 min), Porządkowanie (1×/mies, 30 min) |
| Pralnia | washer | Pranie (2×/tydz, 10 min), Czyszczenie pralki (1×/mies, 15 min) |

---

## 8. Otwarte pytania / decyzje do podjęcia

- [ ] **Ikony custom pokoi:** Pakiet do wyboru ikon zostanie zaimportowany przez użytkownika — na razie `custom` jako placeholder SF Symbol (`square.grid.2x2`).

~~- [ ] Onboarding krok 3 (zadania): tylko checkboxy, edycja w aplikacji~~ ✓
~~- [ ] Tydzień: tydzień kalendarzowy pon–ndz~~ ✓
~~- [ ] "Przesuń na jutro": wraca do puli, triggeruje przeplanowanie pozostałych dni~~ ✓
~~- [ ] Niewykonane zadania: o północy wracają do puli, nowy plan na pozostałe dni~~ ✓
~~- [ ] Odhaczenie wykonanego zadania nie triggeruje przeplanowania~~ ✓
~~- [ ] Twardy dzienny limit z tolerancją ±2 min, bez duplikacji zaległości~~ ✓
~~- [ ] Dzienny limit: 30 min domyślnie, konfigurowalne przez użytkownika w Settings (MVP)~~ ✓
~~- [ ] Tracking czasu: MVP+ (pierwsze usprawnienie)~~ ✓
