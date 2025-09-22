# Plan implementacji widoku Sesji Nauki

## 1. Przegląd
Widok Sesji Nauki umożliwia użytkownikowi przeglądanie fiszek zaplanowanych do powtórki na dany dzień. Użytkownik widzi najpierw przód fiszki, a następnie może odsłonić jej tył. Po przejrzeniu wszystkich fiszek sesja kończy się odpowiednim komunikatem. Widok obsługuje również stan, w którym nie ma fiszek do powtórki.

## 2. Routing widoku
Widok powinien być dostępny pod ścieżką `/flashcards/`.

## 3. Struktura komponentów
```
StudySessionView (Container)
├── StudyCardDisplay
│   ├── CardFront
│   └── CardBack (conditionally rendered)
├── Button (Show Answer / Next)
└── MessageDisplay (for no cards/session end)
```

## 4. Szczegóły komponentów

### `StudySessionView` (Container Component)
- **Opis komponentu:** Główny komponent kontenerowy dla widoku sesji nauki. Odpowiada za pobieranie danych fiszek do powtórki, zarządzanie stanem sesji (aktualna fiszka, stan odsłonięcia odpowiedzi, stan zakończenia sesji) oraz renderowanie odpowiednich komponentów podrzędnych (`StudyCardDisplay`, przycisków, `MessageDisplay`).
- **Główne elementy:** Div kontenera, warunkowe renderowanie `StudyCardDisplay`, `Button` i `MessageDisplay`.
- **Obsługiwane interakcje:** Pobieranie danych przy załadowaniu widoku, obsługa kliknięć przycisków "Pokaż odpowiedź" i "Następna".
- **Obsługiwana walidacja:** Brak bezpośredniej walidacji w tym komponencie; logika opiera się na danych z API.
- **Typy:** `FlashcardDTO[]` (lista fiszek), `FlashcardDTO | null` (aktualna fiszka), `boolean` (stan odsłonięcia, stan ładowania, stan błędu, stan zakończenia sesji).
- **Propsy:** Brak (pobiera dane z API).

### `StudyCardDisplay`
- **Opis komponentu:** Wyświetla aktualną fiszkę w sesji nauki. Składa się z komponentów `CardFront` i `CardBack`.
- **Główne elementy:** Komponenty `CardFront`, `CardBack`.
- **Obsługiwane interakcje:** Brak bezpośrednich interakcji; wyświetla dane przekazane przez propsy.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `FlashcardDTO`.
- **Propsy:**
    - `flashcard: FlashcardDTO` - Aktualnie wyświetlana fiszka.
    - `isBackVisible: boolean` - Flaga określająca, czy tył fiszki jest widoczny.

### `CardFront`
- **Opis komponentu:** Wyświetla przód (pole `front`) fiszki.
- **Główne elementy:** Element tekstowy (np. `<p>`, `<div>`) wyświetlający `flashcard.front`.
- **Obsługiwane interakcje:** Brak.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `string` (tekst przodu fiszki).
- **Propsy:**
    - `text: string` - Tekst do wyświetlenia (z `flashcard.front`).

### `CardBack`
- **Opis komponentu:** Wyświetla tył (pole `back`) fiszki. Renderowany warunkowo.
- **Główne elementy:** Element tekstowy (np. `<p>`, `<div>`) wyświetlający `flashcard.back`.
- **Obsługiwane interakcje:** Brak.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `string` (tekst tyłu fiszki).
- **Propsy:**
    - `text: string` - Tekst do wyświetlenia (z `flashcard.back`).

### `Button` (Komponent reużywalny z `shadcn/ui`)
- **Opis komponentu:** Przycisk używany do akcji "Pokaż odpowiedź" i "Następna". Jego etykieta i akcja zmieniają się w zależności od stanu sesji.
- **Główne elementy:** Standardowy element `<button>`.
- **Obsługiwane interakcje:** Kliknięcie (`onClick`).
- **Obsługiwana walidacja:** Brak.
- **Typy:** Brak specyficznych typów; używa standardowych typów zdarzeń React.
- **Propsy:**
    - `onClick: () => void` - Funkcja wywoływana po kliknięciu.
    - `label: string` - Tekst wyświetlany na przycisku ("Pokaż odpowiedź" lub "Następna").
    - `disabled?: boolean` - Opcjonalna flaga do wyłączania przycisku.

### `MessageDisplay`
- **Opis komponentu:** Wyświetla komunikaty dla użytkownika, np. o braku fiszek do powtórki lub zakończeniu sesji.
- **Główne elementy:** Element tekstowy (np. `<p>`, `<div>`) wyświetlający komunikat.
- **Obsługiwane interakcje:** Brak.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `string` (treść komunikatu).
- **Propsy:**
    - `message: string` - Komunikat do wyświetlenia.

## 5. Typy
- **`FlashcardDTO`**: Zdefiniowany w `src/types.ts`. Używany do reprezentacji danych fiszki pobranych z API.
  \`\`\`typescript
  export interface FlashcardDTO {
    uuid: string;
    userId: string;
    createdAt: string;
    generationId?: string | null;
    front: string;           // from database field \`przód\`
    back: string;            // from database field \`tył\`
    method: 'ai' | 'manual'; // from database field \`metoda_tworzna\`
    status: 'pending' | 'accepted' | 'rejected'; // from database field \`status_recenzji\`
  }
  \`\`\`
- **ViewModel (niejawny):** Stan zarządzany w `StudySessionView` pełni rolę ViewModel, przechowując:
    - `flashcards: FlashcardDTO[]` - Lista fiszek do powtórki.
    - `currentCardIndex: number` - Indeks aktualnie wyświetlanej fiszki.
    - `isBackVisible: boolean` - Czy tył aktualnej fiszki jest widoczny.
    - `isLoading: boolean` - Stan ładowania danych z API.
    - `error: string | null` - Komunikat błędu.
    - `isSessionFinished: boolean` - Czy sesja została zakończona.
    - `noCardsAvailable: boolean` - Czy są dostępne jakiekolwiek fiszki do powtórki.

## 6. Zarządzanie stanem
- Stan będzie zarządzany lokalnie w komponencie `StudySessionView` za pomocą hooków `useState` i `useEffect` (React).
- **Zmienne stanu:**
    - `flashcards`: Przechowuje listę fiszek pobraną z API.
    - `currentCardIndex`: Śledzi indeks aktualnej fiszki.
    - `isBackVisible`: Kontroluje widoczność tyłu fiszki.
    - `isLoading`: Wskazuje, czy dane są ładowane.
    - `error`: Przechowuje ewentualne komunikaty błędów.
    - `isSessionFinished`: Wskazuje, czy wszystkie fiszki zostały przejrzane.
    - `noCardsAvailable`: Wskazuje, czy API zwróciło pustą listę fiszek.
- **Custom Hook:** Prawdopodobnie nie będzie potrzebny dedykowany custom hook, chyba że logika pobierania i zarządzania stanem stanie się bardzo złożona. Na początek wystarczą standardowe hooki React w `StudySessionView`.
- `useEffect` zostanie użyty do pobrania danych fiszek przy pierwszym renderowaniu komponentu.

## 7. Integracja API
- **Endpoint:** `GET /flashcards`
- **Cel:** Pobranie listy fiszek użytkownika. Należy dodać parametr filtrujący, aby pobrać tylko fiszki zaplanowane do powtórki na dany dzień (zakładając, że backend udostępnia taką możliwość, np. przez dodatkowy parametr query `status=scheduled` lub `needsReview=true`. Jeśli nie, frontend będzie musiał pobrać wszystkie i filtrować lub backend będzie musiał zostać rozszerzony). Na potrzeby tego planu zakładamy, że API *może* zwrócić listę fiszek do powtórki. Jeśli endpoint `GET /flashcards` nie wspiera filtrowania wg "zaplanowane do powtórki", należy użyć `GET /flashcards/review` jako alternatywy, jeśli fiszki do powtórki pokrywają się z tymi oczekującymi na recenzję, lub zgłosić potrzebę modyfikacji API. Zgodnie z opisem endpointów, nie ma dedykowanego endpointu do pobierania fiszek *zaplanowanych* do nauki w systemie spaced repetition. Najbliższy jest `GET /flashcards/review`, ale dotyczy on fiszek wygenerowanych przez AI i oczekujących na akceptację. **Należy założyć, że na potrzeby MVP US-011 użyjemy endpointu `GET /flashcards` bez specjalnego filtrowania powtórek, pobierając po prostu wszystkie zaakceptowane fiszki użytkownika i prezentując je w sesji.** W przyszłości endpoint API powinien zostać dostosowany do obsługi logiki spaced repetition.
- **Metoda HTTP:** `GET`
- **Parametry zapytania (Query Parameters):** Można użyć paginacji (`page`, `limit`), ale dla sesji nauki prawdopodobnie lepiej pobrać wszystkie zaakceptowane fiszki (`status=accepted`, jeśli API to wspiera) lub po prostu wszystkie fiszki i filtrować na frontendzie.
- **Typy:**
    - **Żądanie:** Brak ciała żądania dla GET. Parametry query opcjonalne.
    - **Odpowiedź:** `PaginatedResponse<FlashcardDTO>` lub bezpośrednio `FlashcardDTO[]` (zależnie od implementacji API). Będziemy oczekiwać `FlashcardDTO[]`.
- **Obsługa w komponencie:** Funkcja asynchroniczna w `StudySessionView` wywoływana w `useEffect`, używająca `fetch` lub biblioteki typu `axios` do wykonania zapytania GET. Odpowiedź zapisywana w stanie `flashcards`.

## 8. Interakcje użytkownika
1.  **Załadowanie widoku:**
    - Komponent `StudySessionView` montuje się.
    - Wywoływane jest zapytanie do API (`GET /flashcards`).
    - Wyświetlany jest wskaźnik ładowania (`isLoading = true`).
    - Po otrzymaniu odpowiedzi:
        - Jeśli lista fiszek jest pusta: `noCardsAvailable = true`. Wyświetlany jest komunikat z `MessageDisplay` ("Gratulacje! Nie masz więcej fiszek do powtórzenia na dziś.").
        - Jeśli lista nie jest pusta: `flashcards` jest ustawiane, `currentCardIndex = 0`. Wyświetlany jest `StudyCardDisplay` z przodem pierwszej fiszki (`isBackVisible = false`). Przycisk pokazuje "Pokaż odpowiedź".
        - Jeśli wystąpił błąd: `error` jest ustawiany, wyświetlany jest komunikat błędu.
2.  **Kliknięcie "Pokaż odpowiedź":**
    - `isBackVisible` jest ustawiane na `true`.
    - `CardBack` staje się widoczny.
    - Przycisk zmienia etykietę na "Następna" i staje się aktywny.
3.  **Kliknięcie "Następna":**
    - Sprawdzane jest, czy istnieje następna fiszka (`currentCardIndex < flashcards.length - 1`).
    - Jeśli tak:
        - `currentCardIndex` jest inkrementowany.
        - `isBackVisible` jest resetowane na `false`.
        - `StudyCardDisplay` renderuje nową fiszkę (tylko przód).
        - Przycisk wraca do etykiety "Pokaż odpowiedź".
    - Jeśli nie (była to ostatnia fiszka):
        - `isSessionFinished` jest ustawiane na `true`.
        - Wyświetlany jest komunikat z `MessageDisplay` ("Sesja zakończona! Wszystkie fiszki na dziś zostały powtórzone."). Komponent `StudyCardDisplay` i przycisk są ukrywane.

## 9. Warunki i walidacja
- **Warunek ładowania:** `isLoading === true`. Wpływa na interfejs, pokazując wskaźnik ładowania zamiast treści. Dotyczy `StudySessionView`.
- **Warunek braku fiszek:** `noCardsAvailable === true`. Wpływa na interfejs, pokazując komunikat "Gratulacje! Nie masz więcej fiszek do powtórzenia na dziś." zamiast fiszki. Dotyczy `StudySessionView`.
- **Warunek odsłonięcia odpowiedzi:** `isBackVisible === true`. Wpływa na `StudyCardDisplay` (renderuje `CardBack`) i `Button` (zmienia etykietę i stan). Dotyczy `StudySessionView`, `StudyCardDisplay`, `Button`.
- **Warunek końca sesji:** `isSessionFinished === true`. Wpływa na interfejs, pokazując komunikat "Sesja zakończona..." zamiast fiszki. Dotyczy `StudySessionView`.
- **Walidacja:** Brak walidacji wprowadzanych danych przez użytkownika w tym widoku. Logika opiera się na stanie i danych z API.

## 10. Obsługa błędów
- **Błąd pobierania danych:** Jeśli zapytanie `GET /flashcards` zakończy się błędem (np. problem sieciowy, błąd serwera 5xx, brak autoryzacji 401):
    - Stan `error` w `StudySessionView` jest ustawiany na odpowiedni komunikat (np. "Nie udało się pobrać fiszek. Spróbuj ponownie później." lub specyficzny komunikat błędu z API).
    - Wyświetlany jest komunikat błędu użytkownikowi (np. za pomocą `MessageDisplay` lub dedykowanego komponentu błędu/alertu).
- **Niespodziewany stan:** Należy rozważyć obsługę sytuacji, gdy dane z API mają nieoczekiwany format, chociaż użycie TypeScript powinno to minimalizować. W razie problemów można wyświetlić ogólny komunikat błędu.

## 11. Kroki implementacji
1.  **Utworzenie pliku strony:** Stworzyć plik strony Astro dla ścieżki `/flashcards/index.astro` (lub odpowiednik w React, jeśli używany jest routing React wewnątrz Astro).
2.  **Implementacja `StudySessionView`:**
    - Zdefiniować komponent kontenera `StudySessionView.tsx`.
    - Dodać logikę zarządzania stanem (`useState` dla `flashcards`, `currentCardIndex`, `isBackVisible`, `isLoading`, `error`, `isSessionFinished`, `noCardsAvailable`).
    - Implementować `useEffect` do pobierania danych z `GET /flashcards` przy montowaniu komponentu.
    - Dodać obsługę stanów ładowania, błędu, braku fiszek i końca sesji.
    - Zaimplementować funkcje obsługi kliknięć przycisków (`handleShowAnswer`, `handleNextCard`).
3.  **Implementacja `StudyCardDisplay`, `CardFront`, `CardBack`:**
    - Stworzyć komponenty prezentacyjne `StudyCardDisplay.tsx`, `CardFront.tsx`, `CardBack.tsx`.
    - `StudyCardDisplay` przyjmuje `flashcard` i `isBackVisible` jako propsy i renderuje `CardFront` oraz warunkowo `CardBack`.
    - `CardFront` i `CardBack` przyjmują `text` jako props i renderują go.
4.  **Implementacja `MessageDisplay`:**
    - Stworzyć prosty komponent `MessageDisplay.tsx` przyjmujący `message` jako props.
5.  **Integracja komponentów w `StudySessionView`:**
    - W `StudySessionView`, renderować warunkowo `StudyCardDisplay`, `Button` (z `shadcn/ui`) lub `MessageDisplay` w zależności od stanu (`isLoading`, `error`, `noCardsAvailable`, `isSessionFinished`).
    - Przekazać odpowiednie propsy do komponentów podrzędnych (np. aktualną fiszkę do `StudyCardDisplay`, etykietę i `onClick` do `Button`).
6.  **Styling:** Dodać style (np. za pomocą Tailwind CSS) do wszystkich komponentów, aby wyglądały zgodnie z projektem UI (jeśli istnieje) lub estetycznie.
7.  **Testowanie:** Przetestować różne scenariusze:
    - Poprawne ładowanie i wyświetlanie fiszek.
    - Przechodzenie między fiszkami.
    - Stan braku fiszek.
    - Stan końca sesji.
    - Obsługę błędów API.
8.  **Refaktoryzacja (opcjonalnie):** Jeśli logika stanu w `StudySessionView` stanie się zbyt skomplikowana, rozważyć wydzielenie jej do custom hooka (np. `useStudySession`). 