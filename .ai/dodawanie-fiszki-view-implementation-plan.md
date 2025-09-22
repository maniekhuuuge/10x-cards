# Plan implementacji widoków tworzenia fiszek

## 1. Przegląd
Plan obejmuje implementację dwóch powiązanych widoków:
1.  **Tworzenie Manualne:** Umożliwia użytkownikom ręczne dodawanie fiszek poprzez formularz z polami "Przód" i "Tył".
2.  **Generowanie AI:** Umożliwia użytkownikom wprowadzenie tekstu źródłowego ("wkład") w celu automatycznego wygenerowania fiszek przez AI.

Oba widoki muszą zawierać walidację w czasie rzeczywistym zgodnie z wymaganiami PRD i specyfikacją API.

## 2. Routing widoku
-   Widok tworzenia manualnego: `/flashcards/create`
-   Widok generowania przez AI: `/flashcards/generate`

## 2.5. Nawigacja / Punkty Wejścia
-   **Cel:** Umożliwienie użytkownikowi łatwego dostępu do widoków tworzenia manualnego i generowania AI.
-   **Implementacja:** Dodać dwa przyciski w głównym widoku aplikacji (np. na dashboardzie lub w głównym layoucie aplikacji, w zależności od istniejącej struktury).
    -   Przycisk 1: "Utwórz fiszkę manualnie" (lub podobny tekst), kierujący na ścieżkę `/flashcards/create`.
    -   Przycisk 2: "Generuj fiszki z AI" (lub podobny tekst), kierujący na ścieżkę `/flashcards/generate`.
-   **Komponenty:** Prawdopodobnie `Button` z `Shadcn/ui` oraz komponenty nawigacyjne/routingowe dostarczane przez Astro/React (np. `<a href=...>` lub dedykowany komponent `<Link>`).

## 3. Struktura komponentów

```
/flashcards/create (ManualFlashcardCreateView)
  └── FlashcardForm
      ├── InputField (dla "Przód")
      │   ├── CharacterCounter
      │   └── ValidationMessage
      ├── TextArea (dla "Tył")
      │   ├── CharacterCounter
      │   └── ValidationMessage
      └── SubmitButton

/flashcards/generate (AIGenerationView)
  └── AIGenerationInput
      ├── TextArea (dla "wkład")
      │   ├── CharacterCounter
      │   └── ValidationMessage
      ├── SubmitButton
      └── ProgressIndicator
```

## 4. Szczegóły komponentów

### `ManualFlashcardCreateView` (Komponent Strony)
-   **Opis:** Główny kontener dla widoku tworzenia manualnego (`/flashcards/create`). Zarządza stanem ładowania, błędów i sukcesu operacji zapisu fiszki. Renderuje komponent `FlashcardForm`.
-   **Główne elementy:** Wrapper `div`, `FlashcardForm`.
-   **Obsługiwane interakcje:** Przechwytuje zdarzenie `onSubmit` z `FlashcardForm`, inicjuje wywołanie API.
-   **Obsługiwana walidacja:** Brak (delegowana do `FlashcardForm`).
-   **Typy:** Stan lokalny: `isLoading: boolean`, `error: string | null`, `isSuccess: boolean`.
-   **Propsy:** Brak.

### `FlashcardForm` (Komponent Formularza)
-   **Opis:** Formularz do wprowadzania danych fiszki (Przód, Tył). Zawiera logikę walidacji i wyświetlania błędów w czasie rzeczywistym.
-   **Główne elementy:** `form`, etykiety (`label`), pola tekstowe (`input` dla Przód, `textarea` dla Tył), `CharacterCounter`, `ValidationMessage`, `SubmitButton`. Zalecane użycie komponentów z `Shadcn/ui` (np. `Input`, `Textarea`, `Button`, `Label`, `Form`).
-   **Obsługiwane interakcje:** `onChange` na polach input/textarea, `onSubmit` na formularzu.
-   **Obsługiwana walidacja:**
    -   `front`: Wymagane, Maks. 200 znaków.
    -   `back`: Wymagane, Maks. 500 znaków.
    -   Walidacja w czasie rzeczywistym po zmianie wartości.
-   **Typy:** `ViewModel: FlashcardFormData`, `ViewModel: FlashcardFormValidation`.
-   **Propsy:** `onSubmit: (data: FlashcardFormData) => void`, `isLoading: boolean`.

### `AIGenerationView` (Komponent Strony)
-   **Opis:** Główny kontener dla widoku generowania fiszek przez AI (`/flashcards/generate`). Zarządza stanem procesu generowania (ładowanie, status, błędy). Renderuje `AIGenerationInput`.
-   **Główne elementy:** Wrapper `div`, `AIGenerationInput`.
-   **Obsługiwane interakcje:** Przechwytuje zdarzenie `onSubmit` z `AIGenerationInput`, inicjuje wywołanie API generowania.
-   **Obsługiwana walidacja:** Brak (delegowana do `AIGenerationInput`).
-   **Typy:** Stan lokalny: `isLoading: boolean`, `error: string | null`, `isSuccess: boolean`, `generationStatus: string | null` (np. 'idle', 'loading', 'success', 'error', 'timeout').
-   **Propsy:** Brak.

### `AIGenerationInput` (Komponent Wejścia AI)
-   **Opis:** Komponent zawierający pole tekstowe ("wkład") do wprowadzenia danych dla AI, walidację i przycisk inicjujący generowanie. Wyświetla również status operacji.
-   **Główne elementy:** `form`, `label`, `textarea` (dla "wkład"), `CharacterCounter`, `ValidationMessage`, `SubmitButton`, `ProgressIndicator`. Zalecane użycie komponentów `Shadcn/ui`.
-   **Obsługiwane interakcje:** `onChange` na polu textarea, `onSubmit` na formularzu.
-   **Obsługiwana walidacja:**
    -   `input`: Wymagane, Maks. 10 000 znaków.
    -   Walidacja w czasie rzeczywistym po zmianie wartości (z potencjalnym debouncingiem).
-   **Typy:** `ViewModel: AIGenerationData`, `ViewModel: AIGenerationValidation`.
-   **Propsy:** `onSubmit: (data: AIGenerationData) => void`, `isLoading: boolean`, `generationStatus: string | null`.

### `CharacterCounter` (Komponent Pomocniczy)
-   **Opis:** Wyświetla licznik znaków w formacie `aktualna / maksymalna`. Zmienia styl (np. kolor na czerwony), gdy limit zostanie przekroczony.
-   **Główne elementy:** `span` lub `p`.
-   **Obsługiwane interakcje:** Brak.
-   **Obsługiwana walidacja:** Wizualna informacja o przekroczeniu limitu.
-   **Typy:** Brak.
-   **Propsy:** `current: number`, `max: number`.

### `ValidationMessage` (Komponent Pomocniczy)
-   **Opis:** Wyświetla komunikat błędu walidacji dla powiązanego pola formularza. Widoczny tylko gdy istnieje błąd.
-   **Główne elementy:** `p` lub `span` (często z czerwoną czcionką).
-   **Obsługiwane interakcje:** Brak.
-   **Obsługiwana walidacja:** Brak.
-   **Typy:** Brak.
-   **Propsy:** `message: string | null`.

### `ProgressIndicator` (Komponent Pomocniczy)
-   **Opis:** Wyświetla wizualną informację o stanie procesu generowania AI (np. spinner, tekst "Przetwarzanie...", komunikat o błędzie/sukcesie).
-   **Główne elementy:** Ikona ładowania (spinner), tekst (`p` lub `span`).
-   **Obsługiwane interakcje:** Brak.
-   **Obsługiwana walidacja:** Brak.
-   **Typy:** Brak.
-   **Propsy:** `status: 'idle' | 'loading' | 'success' | 'error' | 'timeout' | string`.

### `SubmitButton` (Komponent Pomocniczy)
-   **Opis:** Przycisk do wysyłania formularza. Powinien obsługiwać stan ładowania (wyświetlanie spinnera) i deaktywacji (np. gdy formularz jest niepoprawny lub trwa ładowanie). Zalecane użycie `Button` z `Shadcn/ui`.
-   **Główne elementy:** `button`.
-   **Obsługiwane interakcje:** `onClick`.
-   **Obsługiwana walidacja:** Zmiana stanu wizualnego (`disabled`, `loading`).
-   **Typy:** Brak.
-   **Propsy:** `isLoading: boolean`, `isDisabled: boolean`, `onClick?: () => void`, `type: 'submit' | 'button'`.

## 5. Typy

Wykorzystane zostaną istniejące typy z `src/types.ts`:
-   `FlashcardDTO`: Dla odpowiedzi z `POST /api/flashcards`.
-   `CreateFlashcardCommand`: Dla payloadu żądania `POST /api/flashcards`.
-   `FlashcardGenerateCommand`: Dla payloadu żądania `POST /api/flashcards/generate`.
-   `GenerationDTO`: Potencjalnie dla odpowiedzi z `POST /api/flashcards/generate` (lub podobna struktura).

Nowe typy ViewModel (do zdefiniowania lokalnie w komponentach lub w dedykowanym pliku typów frontendowych):
-   **`FlashcardFormData`**:
    ```typescript
    interface FlashcardFormData {
      front: string;
      back: string;
    }
    ```
-   **`FlashcardFormValidation`**:
    ```typescript
    interface FlashcardFormValidation {
      front?: string | null; // Komunikat błędu lub null/undefined
      back?: string | null;
    }
    ```
-   **`AIGenerationData`**:
    ```typescript
    interface AIGenerationData {
      input: string;
    }
    ```
-   **`AIGenerationValidation`**:
    ```typescript
    interface AIGenerationValidation {
      input?: string | null;
    }
    ```

## 6. Zarządzanie stanem

-   Zarządzanie stanem będzie realizowane głównie za pomocą hooka `useState` wewnątrz komponentów funkcyjnych React.
-   **`FlashcardForm`** będzie zarządzał stanem pól `front` i `back` oraz ich błędami walidacji (`formData`, `validationErrors`).
-   **`AIGenerationInput`** będzie zarządzał stanem pola `input` i jego błędem walidacji (`inputValue`, `validationError`).
-   Komponenty stron (`ManualFlashcardCreateView`, `AIGenerationView`) będą zarządzać stanem związanym z wywołaniami API (`isLoading`, `error`, `isSuccess`, `generationStatus`).
-   Nie przewiduje się potrzeby tworzenia dedykowanych custom hooków na tym etapie, chyba że logika walidacji lub obsługi API okaże się wyjątkowo skomplikowana lub powtarzalna.

## 7. Integracja API

-   **Tworzenie Manualne:**
    -   Komponent `ManualFlashcardCreateView` (po otrzymaniu danych z `FlashcardForm`) wywoła `fetch` na endpoint `POST /api/flashcards`.
    -   **Żądanie:**
        -   Metoda: `POST`
        -   Headers: `{ 'Content-Type': 'application/json' }`
        -   Body: `JSON.stringify({ front: data.front, back: data.back, metoda_tworzna: 'manual' } as CreateFlashcardCommand)`
    -   **Odpowiedź:**
        -   Sukces (201): Oczekiwany obiekt `FlashcardDTO` (lub tablica `FlashcardDTO[]`). Wyświetlenie komunikatu sukcesu, potencjalne wyczyszczenie formularza lub nawigacja.
        -   Błąd (400, 500): Odpowiedź z polem `error`. Wyświetlenie komunikatu błędu.
-   **Generowanie AI:**
    -   Komponent `AIGenerationView` (po otrzymaniu danych z `AIGenerationInput`) wywoła `fetch` na endpoint `POST /api/flashcards/generate`.
    -   **Żądanie:**
        -   Metoda: `POST`
        -   Headers: `{ 'Content-Type': 'application/json' }`
        -   Body: `JSON.stringify({ input: data.input } as FlashcardGenerateCommand)`
    -   **Odpowiedź:**
        -   Sukces (201): Oczekiwany obiekt zawierający status i ID generacji (np. `GenerationDTO` lub podobny `{ generationId: string, status: string }`). Aktualizacja `generationStatus`, wyświetlenie wskaźnika postępu/informacji.
        -   Błąd (400, 500, 504): Odpowiedź z polem `error`. Wyświetlenie odpowiedniego komunikatu błędu (np. walidacja, timeout, błąd serwera). Aktualizacja `generationStatus`.

## 8. Interakcje użytkownika

-   **Wpisywanie tekstu:** W polach `front`, `back`, `input` tekst pojawia się natychmiast. Licznik znaków aktualizuje się w czasie rzeczywistym. Komunikaty walidacyjne pojawiają/znikają dynamicznie.
-   **Kliknięcie "Zapisz" / "Generuj":**
    -   Jeśli formularz jest poprawny: Przycisk przechodzi w stan ładowania, wywoływane jest API. Po odpowiedzi API stan ładowania znika, wyświetlany jest komunikat o sukcesie lub błędzie. W przypadku sukcesu generowania AI, pojawia się `ProgressIndicator`.
    -   Jeśli formularz jest niepoprawny: Przycisk może być zdezaktywowany lub kliknięcie spowoduje wyświetlenie/podświetlenie błędów walidacji bez wywołania API.

## 9. Warunki i walidacja

Walidacja odbywa się w czasie rzeczywistym w komponentach `FlashcardForm` i `AIGenerationInput` oraz przed wysłaniem formularza.
-   **Warunki:**
    -   Pole "Przód": niepuste, długość <= 200.
    -   Pole "Tył": niepuste, długość <= 500.
    -   Pole "Wkład": niepuste, długość <= 10 000.
-   **Wpływ na interfejs:**
    -   Wyświetlanie/ukrywanie komunikatów błędów (`ValidationMessage`).
    -   Zmiana stylu licznika znaków (`CharacterCounter`).
    -   Potencjalna deaktywacja przycisku "Zapisz"/"Generuj" (`SubmitButton`).

## 10. Obsługa błędów

-   **Błędy walidacji klienta:** Obsługiwane przez wyświetlanie komunikatów przy polach i blokowanie wysyłki.
-   **Błędy API (400, 500, 504):** Przechwytywane w bloku `catch` wywołania `fetch`. Komunikat błędu z odpowiedzi API (jeśli dostępny) lub generyczny komunikat jest wyświetlany użytkownikowi (np. w dedykowanym miejscu w widoku/komponencie strony). Stan `error` komponentu strony jest aktualizowany.
-   **Błędy sieciowe:** Przechwytywane w bloku `catch`. Wyświetlany jest generyczny komunikat o problemie z połączeniem.
-   **Specyficzny błąd timeout (504) dla AI:** Wyświetlany jest dedykowany komunikat sugerujący skrócenie tekstu lub ponowienie próby.

## 11. Kroki implementacji

1.  **Konfiguracja Routingu:** Dodać ścieżki `/flashcards/create` i `/flashcards/generate` w systemie routingu Astro, wskazując na odpowiednie pliki stron/komponentów Astro.
2.  **(Nowy Krok) Implementacja Nawigacji:** W głównym widoku/layoucie aplikacji dodać przyciski "Utwórz fiszkę manualnie" i "Generuj fiszki z AI", które będą linkować do ścieżek zdefiniowanych w kroku 1.
3.  **Stworzenie Komponentów Stron:** Utworzyć komponenty React (wewnątrz Astro lub jako osobne pliki `.tsx`) dla `ManualFlashcardCreateView` i `AIGenerationView`. Zaimplementować podstawową strukturę i zarządzanie stanem (loading, error, success).
4.  **Implementacja Komponentów Pomocniczych:** Stworzyć reużywalne komponenty: `CharacterCounter`, `ValidationMessage`, `ProgressIndicator`, `SubmitButton`. Wykorzystać `Shadcn/ui` tam, gdzie to możliwe.
5.  **Implementacja `FlashcardForm`:**
    -   Zbudować strukturę formularza z polami "Przód", "Tył" (używając `Shadcn/ui`).
    -   Dodać `CharacterCounter` i `ValidationMessage` do każdego pola.
    -   Zaimplementować logikę `useState` dla `formData` i `validationErrors`.
    -   Dodać funkcje walidujące wywoływane przy `onChange`.
    -   Dodać `SubmitButton` z odpowiednimi propsami `isLoading`, `isDisabled`.
    -   Podłączyć prop `onSubmit`.
6.  **Implementacja `AIGenerationInput`:**
    -   Zbudować strukturę z polem `textarea` ("wkład").
    -   Dodać `CharacterCounter` i `ValidationMessage`.
    -   Zaimplementować logikę `useState` dla `inputValue` i `validationError` (rozważyć debouncing dla walidacji).
    -   Dodać `SubmitButton` i `ProgressIndicator` z odpowiednimi propsami.
    -   Podłączyć prop `onSubmit`.
7.  **Integracja API w `ManualFlashcardCreateView`:**
    -   Zaimplementować funkcję `handleSubmit`, która pobiera dane z `FlashcardForm`.
    -   Wywołać `POST /api/flashcards` używając `fetch`.
    -   Obsłużyć stany `isLoading`, `isSuccess`, `error` na podstawie odpowiedzi API.
    -   Przekazać `isLoading` do `FlashcardForm`.
8.  **Integracja API w `AIGenerationView`:**
    -   Zaimplementować funkcję `handleSubmit`, która pobiera dane z `AIGenerationInput`.
    -   Wywołać `POST /api/flashcards/generate` używając `fetch`.
    -   Obsłużyć stany `isLoading`, `isSuccess`, `error`, `generationStatus` na podstawie odpowiedzi API.
    -   Przekazać `isLoading` i `generationStatus` do `AIGenerationInput`.
9.  **Styling:** Dopracować wygląd komponentów (w tym nowych przycisków nawigacyjnych) przy użyciu Tailwind CSS, upewniając się, że są zgodne z resztą aplikacji i `Shadcn/ui`.
10. **Testowanie:** Przetestować oba widoki oraz nawigację do nich pod kątem funkcjonalności, walidacji, obsługi błędów i różnych scenariuszy użytkownika (puste pola, przekroczenie limitów, błędy API).
11. **Refaktoryzacja:** Przejrzeć kod pod kątem czytelności, reużywalności i potencjalnych optymalizacji. 