 # Architektura UI dla Fiszki AI

## 1. Przegląd struktury UI

Aplikacja opiera się na jasno zdefiniowanej strukturze widoków, które łączą funkcjonalności opisane w dokumentach PRD, planie API i notatkach sesji planowania. Główne widoki obejmują moduł logowania/rejestracji, dashboard, listę fiszek, ekran tworzenia fiszek manualnych, ekran generowania fiszek przez AI, ekran recenzji fiszek, sesje powtórkowe oraz moduł zarządzania kontem. Interfejs został zaprojektowany z myślą o użytkownikach korzystających z przeglądarek desktopowych, z naciskiem na intuicyjność, dostępność, real-time walidację i bezpieczeństwo dzięki integracji z mechanizmami JWT i Supabase Auth.

## 2. Lista widoków

### Ekran logowania/rejestracji
- **Ścieżka widoku:** `/auth`
- **Główny cel:** Umożliwienie rejestracji nowych użytkowników oraz logowania istniejących.
- **Kluczowe informacje:** Formularze logowania i rejestracji, komunikaty walidacyjne, opcja przełączania między trybami.
- **Kluczowe komponenty:** Formularze, pola tekstowe, przyciski, alerty walidacyjne.
- **UX, dostępność i bezpieczeństwo:** Intuicyjne komunikaty błędów, oznaczenie pól obowiązkowych, ochrona danych dzięki walidacji po stronie klienta.

### Dashboard użytkownika
- **Ścieżka widoku:** `/dashboard`
- **Główny cel:** Prezentacja skrótów i podsumowania najważniejszych funkcji aplikacji.
- **Kluczowe informacje:** Statystyki, skróty do widoków (lista fiszek, tworzenie, generacja, recenzja, sesje powtórkowe).
- **Kluczowe komponenty:** Karty informacyjne, liczniki, elementy interaktywnych skrótów.
- **UX, dostępność i bezpieczeństwo:** Przejrzysty układ, responsywne komponenty, zabezpieczenia dostępu poprzez autoryzację.

### Lista fiszek
- **Ścieżka widoku:** `/flashcards`
- **Główny cel:** Przeglądanie stworzonych fiszek z możliwością filtrowania i paginacji.
- **Kluczowe informacje:** Lista fiszek, status recenzji, opcje edycji i usuwania, opcje filtrowania oraz paginacja (przyciski „next” i „prev”).
- **Kluczowe komponenty:** Tabele lub listy, pola filtrowania, przyciski paginacji.
- **UX, dostępność i bezpieczeństwo:** Łatwa nawigacja, szybka reakcja na operacje, dostępność dla czytników ekranowych.

### Ekran tworzenia fiszek manualnych
- **Ścieżka widoku:** `/flashcards/create`
- **Główny cel:** Umożliwienie użytkownikowi ręcznego tworzenia nowej fiszki.
- **Kluczowe informacje:** Pola „Przód” (max 200 znaków) i „Tył” (max 500 znaków) z natychmiastową walidacją.
- **Kluczowe komponenty:** Formularze, komponenty walidacji, przyciski zapisu.
- **UX, dostępność i bezpieczeństwo:** Real-time walidacja, czytelne komunikaty błędów, zabezpieczenie przed przekroczeniem limitów znaków.

### Ekran generowania fiszek przez AI
- **Ścieżka widoku:** `/flashcards/generate`
- **Główny cel:** Wprowadzenie tekstowego wkładu do modelu AI umożliwiającego generowanie fiszek.
- **Kluczowe informacje:** Pole do wpisania danych (limit 10 000 znaków), przycisk inicjujący generację, wskaźnik statusu operacji (animacja lub pasek postępu).
- **Kluczowe komponenty:** Pole tekstowe, wskaźnik postępu, alerty walidacyjne.
- **UX, dostępność i bezpieczeństwo:** Informacje zwrotne w czasie rzeczywistym, jasne statusy operacji, ograniczenie liczby znaków dla ochrony przed nadużyciami.

### Ekran recenzji fiszek generowanych przez AI
- **Ścieżka widoku:** `/flashcards/review`
- **Główny cel:** Ocena i zatwierdzanie propozycji fiszek wygenerowanych przez AI.
- **Kluczowe informacje:** Lista proponowanych fiszek, opcje akceptacji, edycji oraz odrzucenia fiszki.
- **Kluczowe komponenty:** Lista elementów, przyciski akcji, modal dialog do edycji potwierdzającego zmiany.
- **UX, dostępność i bezpieczeństwo:** Jasne oznaczenie statusu, potwierdzenie operacji krytycznych, intuicyjna interakcja.

### Ekran sesji powtórkowych
- **Ścieżka widoku:** `/flashcards/review-session`
- **Główny cel:** Przeprowadzenie sesji powtórkowych z użyciem fiszek.
- **Kluczowe informacje:** Fiszki do powtórki, opcje oznaczania jako zapamiętane lub wymagające dalszej nauki.
- **Kluczowe komponenty:** Karty fiszek, kontrolki oznaczania, przyciski nawigacyjne.
- **UX, dostępność i bezpieczeństwo:** Przyjazny interfejs, responsywność, intuicyjne sterowanie, czytelne komunikaty statusu.

### Moduł zarządzania kontem użytkownika
- **Ścieżka widoku:** `/account`
- **Główny cel:** Zarządzanie danymi konta, zmiana hasła oraz opcja usunięcia konta.
- **Kluczowe informacje:** Dane użytkownika, opcje edycji, formularze zmiany hasła, potwierdzenie przed usunięciem konta.
- **Kluczowe komponenty:** Formularze, przyciski, modal dialogi potwierdzające operacje.
- **UX, dostępność i bezpieczeństwo:** Bezpieczne przetwarzanie danych, intuicyjny interfejs, potwierdzenia krytycznych operacji.

## 3. Mapa podróży użytkownika

1. Użytkownik odwiedza widok `/auth` i dokonuje rejestracji lub logowania.
2. Po poprawnej autoryzacji użytkownik trafia do dashboardu na `/dashboard`, gdzie widzi podsumowanie oraz skróty do głównych funkcji.
3. Użytkownik wybiera jedną z opcji:
   - Przeglądanie fiszek na `/flashcards`
   - Tworzenie fiszek manualnych na `/flashcards/create`
   - Generowanie fiszek przez AI na `/flashcards/generate`
4. Po wygenerowaniu fiszki przez AI, użytkownik przechodzi do widoku recenzji na `/flashcards/review`, gdzie ocenia i modyfikuje propozycje.
5. Użytkownik może rozpocząć sesję powtórkową przez wejście na `/flashcards/review-session`.
6. Opcjonalnie, użytkownik przechodzi do widoku zarządzania kontem na `/account` w celu przeglądania i edycji danych osobowych oraz zmiany hasła lub usunięcia konta.

## 4. Układ i struktura nawigacji

- Nawigacja główna jest umieszczona w topbarze, który zawiera linki do wszystkich kluczowych widoków: Dashboard, Fiszki, Tworzenie, Generacja, Recenzja, Sesja powtórkowa oraz Zarządzanie kontem.
- W topbarze wykorzystany zostanie komponent navigation menu od shadcn/ui, gwarantujący spójny wygląd i funkcjonalność.
- Użytkownicy przemieszczają się między widokami poprzez kliknięcia w odpowiednie linki w topbarze, a mechanizmy autoryzacji (np. JWT) zabezpieczają dostęp do poszczególnych sekcji aplikacji.

## 5. Kluczowe komponenty

- **Formularze autoryzacji:** Komponenty umożliwiające logowanie i rejestrację, wyposażone w real-time walidację i czytelne komunikaty błędów.
- **Topbar i menu nawigacyjne:** Elementy umożliwiające łatwy dostęp do głównych widoków, oparte na komponentach shadcn/ui.
- **Listy/Tabele fiszek:** Komponenty prezentujące dane fiszek z funkcjonalnościami filtrowania, paginacji oraz opcji edycji/usuwania.
- **Komponenty formularzy do tworzenia/edycji fiszek:** Obsługujące limity znaków dla pól „Przód” i „Tył”, wyposażone w mechanizmy real-time walidacji.
- **Wskaźniki statusu operacji:** Komponenty informujące o postępie operacji, np. podczas generowania fiszek przez AI, za pomocą animacji lub pasków postępu.
- **Modale i system powiadomień:** Komponenty do wyświetlania potwierdzeń działań oraz komunikatów błędów, wspomagające proces interakcji użytkownika.