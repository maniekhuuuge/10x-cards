# Plan implementacji widoku Recenzji Fiszek AI

## 1. Przegląd
Widok recenzji fiszek AI umożliwia użytkownikom przeglądanie, akceptowanie, edytowanie lub odrzucanie fiszek wygenerowanych przez AI, które oczekują na weryfikację (mają status "pending"). Jest to kluczowy element procesu kontroli jakości fiszek tworzonych automatycznie.

## 2. Routing widoku
Widok powinien być dostępny pod ścieżką: `/flashcards/review`

## 3. Struktura komponentów
```
FlashcardReviewPage (src/pages/flashcards/review.astro)
└── FlashcardReviewList (src/components/flashcards/FlashcardReviewList.tsx)
    └── FlashcardReviewItem (src/components/flashcards/FlashcardReviewItem.tsx)
        └── FlashcardEditModal (src/components/flashcards/FlashcardEditModal.tsx)
```

## 4. Szczegóły komponentów

### `FlashcardReviewPage` (.astro + .tsx client directive)
- **Opis komponentu:** Główny kontener strony recenzji. Odpowiedzialny za pobieranie danych fiszek oczekujących na recenzję, zarządzanie stanem ładowania/błędu oraz renderowanie listy fiszek.
- **Główne elementy:** Komponent `FlashcardReviewList`. Może zawierać nagłówek strony, wskaźnik ładowania, komunikaty o błędach lub informację o braku fiszek do recenzji.
- **Obsługiwane interakcje:** Inicjalizacja pobierania danych przy ładowaniu strony.
- **Obsługiwana walidacja:** Brak bezpośredniej walidacji, obsługuje stan ładowania/błędu z API.
- **Typy:** `PaginatedResponse<FlashcardDTO>` (dla odpowiedzi API), `FlashcardDTO` (dla danych fiszek).
- **Propsy:** Brak (komponent strony).

### `FlashcardReviewList` (.tsx)
- **Opis komponentu:** Renderuje listę fiszek oczekujących na recenzję. Otrzymuje listę fiszek jako props i mapuje je do komponentów `FlashcardReviewItem`.
- **Główne elementy:** Lista (np. `ul` lub `div`), iteracja po elementach `FlashcardReviewItem`. Wyświetla komunikat, jeśli lista jest pusta.
- **Obsługiwane interakcje:** Przekazuje akcje (accept, reject, edit) z `FlashcardReviewItem` do `FlashcardReviewPage` (lub obsługuje je bezpośrednio, jeśli stan jest zarządzany tutaj lub przez hook).
- **Obsługiwana walidacja:** Brak.
- **Typy:** `FlashcardDTO[]`.
- **Propsy:**
  - `flashcards: FlashcardDTO[]` - Lista fiszek do wyświetlenia.
  - `onAccept: (id: string) => void` - Funkcja wywoływana po akceptacji fiszki.
  - `onReject: (id: string) => void` - Funkcja wywoływana po odrzuceniu fiszki.
  - `onEdit: (flashcard: FlashcardDTO) => void` - Funkcja wywoływana przy próbie edycji fiszki (otwiera modal).

### `FlashcardReviewItem` (.tsx)
- **Opis komponentu:** Reprezentuje pojedynczą fiszkę na liście recenzji. Wyświetla przód i tył fiszki oraz przyciski akcji (Akceptuj, Edytuj, Odrzuć).
- **Główne elementy:** Dwa bloki tekstowe (dla przodu i tyłu), `Button` (z Shadcn/ui) dla akcji Akceptuj, Edytuj, Odrzuć.
- **Obsługiwane interakcje:** Kliknięcie przycisków Akceptuj, Edytuj, Odrzuć. Wywołuje odpowiednie funkcje zwrotne przekazane przez propsy (`onAccept`, `onReject`, `onEdit`).
- **Obsługiwana walidacja:** Brak.
- **Typy:** `FlashcardDTO`.
- **Propsy:**
  - `flashcard: FlashcardDTO` - Dane fiszki do wyświetlenia.
  - `onAccept: (id: string) => void` - Funkcja wywoływana po kliknięciu "Akceptuj".
  - `onReject: (id: string) => void` - Funkcja wywoływana po kliknięciu "Odrzuć".
  - `onEdit: (flashcard: FlashcardDTO) => void` - Funkcja wywoływana po kliknięciu "Edytuj".

### `FlashcardEditModal` (.tsx)
- **Opis komponentu:** Modal (dialog) do edycji fiszki w trakcie recenzji. Używa komponentów `Dialog`, `Input`, `Textarea`, `Button` z Shadcn/ui. Pozwala zmodyfikować przód i tył fiszki przed jej zaakceptowaniem.
- **Główne elementy:** `Dialog` (Shadcn), `Input` (dla przodu), `Textarea` (dla tyłu), `Button` (Zapisz, Anuluj). Wyświetla komunikaty walidacyjne.
- **Obsługiwane interakcje:** Wprowadzanie tekstu w polach, kliknięcie przycisków Zapisz i Anuluj.
- **Obsługiwana walidacja:**
    - Przód: wymagany, maksymalnie 200 znaków.
    - Tył: wymagany, maksymalnie 500 znaków.
    Walidacja powinna odbywać się w czasie rzeczywistym (np. przy zmianie wartości) i przy próbie zapisu. Komunikaty o błędach powinny być wyświetlane przy odpowiednich polach. Przycisk "Zapisz" powinien być nieaktywny, jeśli formularz jest nieprawidłowy.
- **Typy:** `FlashcardDTO` (do inicjalizacji), `UpdateFlashcardCommand` (do budowy payloadu).
- **Propsy:**
  - `isOpen: boolean` - Kontroluje widoczność modala.
  - `flashcard: FlashcardDTO | null` - Dane fiszki do edycji (lub `null`, jeśli modal jest zamknięty).
  - `onSave: (id: string, data: UpdateFlashcardCommand) => void` - Funkcja wywoływana po pomyślnym zapisie zmian.
  - `onClose: () => void` - Funkcja wywoływana przy zamknięciu modala (przez Anuluj lub X).

## 5. Typy
- **`FlashcardDTO`:** (Istniejący) Używany do reprezentacji danych fiszek pobranych z API i przekazywanych między komponentami.
  ```typescript
  export interface FlashcardDTO {
    uuid: string;
    userId: string;
    createdAt: string;
    generationId?: string | null;
    front: string;
    back: string;
    method: 'ai' | 'manual';
    status: 'pending' | 'accepted' | 'rejected';
  }
  ```
- **`FlashcardReviewCommand`:** (Istniejący) Używany jako payload dla żądania `POST /flashcards/{id}/review`.
  ```typescript
  export interface FlashcardReviewCommand {
    action: 'accept' | 'reject' | 'edit';
    front?: string; // Wymagane tylko dla action: 'edit'
    back?: string;  // Wymagane tylko dla action: 'edit'
  }
  ```
- **`UpdateFlashcardCommand`:** (Istniejący) Używany jako typ danych przekazywanych z `FlashcardEditModal` przy zapisie edytowanej fiszki. Może być częścią `FlashcardReviewCommand` dla akcji 'edit'.
  ```typescript
  export interface UpdateFlashcardCommand {
    front: string;
    back: string;
  }
  ```
- **`PaginatedResponse<T>`:** (Istniejący) Używany do typowania odpowiedzi z paginowanego endpointu `GET /flashcards`.

Nie przewiduje się potrzeby tworzenia nowych, specyficznych typów ViewModel dla tego widoku. Istniejące DTO i Command Models są wystarczające.

## 6. Zarządzanie stanem
- **Stan główny (`FlashcardReviewPage`):**
    - Lista fiszek (`FlashcardDTO[]`): Przechowuje pobrane fiszki.
    - Stan ładowania (`boolean`): Wskazuje, czy dane są aktualnie pobierane.
    - Stan błędu (`string | null`): Przechowuje komunikat błędu, jeśli wystąpił problem z API.
    - Stan modala edycji (`{ isOpen: boolean; flashcardToEdit: FlashcardDTO | null }`): Zarządza widocznością i danymi dla `FlashcardEditModal`.
- **Stan lokalny (`FlashcardEditModal`):**
    - Wartości pól formularza (`front: string`, `back: string`).
    - Stany walidacji dla pól (`{ frontError: string | null; backError: string | null }`).
    - Stan zapisu (`boolean`): Wskazuje, czy trwa proces zapisu zmian.
- **Custom Hook:** Można rozważyć stworzenie hooka `useFlashcardReview(userId)` do enkapsulacji logiki pobierania danych, obsługi stanu (ładowanie, błędy) oraz akcji (accept, reject, edit). Hook ten zarządzałby stanem listy fiszek i udostępniałby funkcje do interakcji z API.

## 7. Integracja API
- **Pobieranie fiszek do recenzji:**
    - **Endpoint:** `GET /api/flashcards`
    - **Parametry:** `status=pending`, `page=1`, `limit=X` (np. 20, lub inna rozsądna wartość; można dodać paginację w przyszłości).
    - **Typ odpowiedzi:** `PaginatedResponse<FlashcardDTO>`
    - **Obsługa:** Wywołanie w `FlashcardReviewPage` przy montowaniu komponentu. Aktualizacja stanu listy fiszek, ładowania i błędów.
- **Akceptacja fiszki:**
    - **Endpoint:** `POST /api/flashcards/{id}/review`
    - **Metoda HTTP:** `POST`
    - **Payload:** `{ action: 'accept' }` (`FlashcardReviewCommand`)
    - **Typ odpowiedzi:** `FlashcardDTO` (zaktualizowana fiszka)
    - **Obsługa:** Wywołanie z `FlashcardReviewItem` (przez `FlashcardReviewPage` lub hook). Po sukcesie, usunięcie fiszki z listy w UI.
- **Odrzucenie fiszki:**
    - **Endpoint:** `POST /api/flashcards/{id}/review`
    - **Metoda HTTP:** `POST`
    - **Payload:** `{ action: 'reject' }` (`FlashcardReviewCommand`)
    - **Typ odpowiedzi:** `FlashcardDTO` (zaktualizowana fiszka)
    - **Obsługa:** Wywołanie z `FlashcardReviewItem` (przez `FlashcardReviewPage` lub hook). Po sukcesie, usunięcie fiszki z listy w UI.
- **Edycja i akceptacja fiszki:**
    - **Endpoint:** `POST /api/flashcards/{id}/review`
    - **Metoda HTTP:** `POST`
    - **Payload:** `{ action: 'edit', front: '...', back: '...' }` (`FlashcardReviewCommand` z danymi z `UpdateFlashcardCommand`)
    - **Typ odpowiedzi:** `FlashcardDTO` (zaktualizowana fiszka)
    - **Obsługa:** Wywołanie z `FlashcardEditModal` po kliknięciu "Zapisz". Po sukcesie, zamknięcie modala i usunięcie fiszki z listy w UI.

*Uwaga: Zakładamy istnienie endpointu `POST /api/flashcards/{id}/review` zgodnie z opisem API. Jeśli go brakuje w implementacji backendu, należy go dodać lub dostosować plan (np. używając `PUT /api/flashcards/{id}` i dodatkowego mechanizmu zmiany statusu).*

## 8. Interakcje użytkownika
- **Wejście na stronę:** Użytkownik nawiguje do `/flashcards/review`. System automatycznie pobiera listę fiszek ze statusem "pending". Wyświetlany jest wskaźnik ładowania.
- **Przeglądanie listy:** Użytkownik widzi listę fiszek, każda z przodem, tyłem i przyciskami akcji.
- **Akceptacja:** Użytkownik klika "Akceptuj". Fiszka znika z listy. Wyświetlane jest powiadomienie o sukcesie (opcjonalnie).
- **Odrzucenie:** Użytkownik klika "Odrzuć". Fiszka znika z listy. Wyświetlane jest powiadomienie o sukcesie (opcjonalnie).
- **Edycja:**
    - Użytkownik klika "Edytuj". Otwiera się `FlashcardEditModal` z wypełnionymi polami.
    - Użytkownik modyfikuje tekst w polach. Walidacja (limit znaków) jest widoczna na bieżąco.
    - Użytkownik klika "Zapisz". Jeśli walidacja przejdzie pomyślnie:
        - Wykonywane jest zapytanie API.
        - Modal zostaje zamknięty.
        - Fiszka znika z listy recenzji.
        - Wyświetlane jest powiadomienie o sukcesie (opcjonalnie).
    - Użytkownik klika "Anuluj" lub zamyka modal. Modal zostaje zamknięty bez zapisywania zmian.
- **Pusta lista:** Jeśli nie ma fiszek do recenzji, wyświetlany jest odpowiedni komunikat.
- **Błąd API:** Jeśli wystąpi błąd podczas pobierania danych lub wykonywania akcji, wyświetlany jest komunikat błędu.

## 9. Warunki i walidacja
- **Pobieranie danych:** Komponent `FlashcardReviewPage` weryfikuje stan ładowania (wyświetla spinner/skeleton) i stan błędu (wyświetla komunikat).
- **Modal edycji (`FlashcardEditModal`):**
    - **Pole "Przód":** Wymagane. Maksymalnie 200 znaków. Komunikat błędu wyświetlany, jeśli puste lub za długie.
    - **Pole "Tył":** Wymagane. Maksymalnie 500 znaków. Komunikat błędu wyświetlany, jeśli puste lub za długie.
    - **Przycisk "Zapisz":** Jest nieaktywny (`disabled`), jeśli którekolwiek pole jest nieprawidłowe (puste lub przekracza limit znaków). Aktywuje się, gdy oba pola są poprawne.
- **Stan interfejsu:** Przyciski akcji na `FlashcardReviewItem` mogą być tymczasowo dezaktywowane po kliknięciu, aby zapobiec wielokrotnym wywołaniom API.

## 10. Obsługa błędów
- **Błąd pobierania listy:** W `FlashcardReviewPage`, jeśli `GET /api/flashcards` zwróci błąd, należy przechwycić go, zaktualizować stan błędu i wyświetlić użytkownikowi czytelny komunikat (np. "Nie udało się załadować fiszek do recenzji. Spróbuj ponownie później.") zamiast listy.
- **Błąd akcji (Accept/Reject/Edit):** Jeśli `POST /api/flashcards/{id}/review` zwróci błąd:
    - Należy wyświetlić powiadomienie o błędzie (np. używając Shadcn `Toast`).
    - Fiszka nie powinna być usuwana z listy.
    - Przyciski akcji powinny zostać ponownie aktywowane.
- **Błąd walidacji w modalu:** Obsługiwane lokalnie w `FlashcardEditModal` poprzez wyświetlanie komunikatów przy polach i dezaktywację przycisku "Zapisz".
- **Przypadki brzegowe:**
    - **Brak fiszek:** Wyświetlenie komunikatu "Brak fiszek oczekujących na recenzję."
    - **Konflikt (np. fiszka została już zrecenzowana):** API powinno zwrócić odpowiedni błąd (np. 404 lub 409), który należy obsłużyć, informując użytkownika i usuwając fiszkę z listy.

## 11. Kroki implementacji
1.  **Routing:** Zdefiniuj trasę `/flashcards/review` w systemie routingu Astro, wskazując na plik strony `src/pages/flashcards/review.astro`.
2.  **Strona Główna (`FlashcardReviewPage`):**
    - Stwórz plik `src/pages/flashcards/review.astro`.
    - Wewnątrz `<script>` (lub w komponencie .tsx z `client:load`) zaimplementuj logikę pobierania danych (`GET /api/flashcards?status=pending`) przy użyciu `fetch` lub biblioteki do zapytań (np. TanStack Query).
    - Zarządzaj stanami `loading`, `error`, `flashcards`.
    - Wyrenderuj szkielet strony (np. nagłówek).
3.  **Komponent Listy (`FlashcardReviewList`):**
    - Stwórz komponent `src/components/flashcards/FlashcardReviewList.tsx`.
    - Zdefiniuj propsy (`flashcards`, `onAccept`, `onReject`, `onEdit`).
    - Implementuj renderowanie listy, mapując `flashcards` do `FlashcardReviewItem`.
    - Dodaj obsługę pustej listy.
    - Użyj w `FlashcardReviewPage`, przekazując dane i callbacki.
4.  **Komponent Elementu Listy (`FlashcardReviewItem`):**
    - Stwórz komponent `src/components/flashcards/FlashcardReviewItem.tsx`.
    - Zdefiniuj propsy (`flashcard`, `onAccept`, `onReject`, `onEdit`).
    - Wyświetl `flashcard.front` i `flashcard.back`.
    - Dodaj przyciski "Akceptuj", "Edytuj", "Odrzuć" (używając `Button` z Shadcn/ui).
    - Podłącz `onClick` przycisków do odpowiednich propsów (`onAccept(flashcard.uuid)`, etc.).
5.  **Modal Edycji (`FlashcardEditModal`):**
    - Stwórz komponent `src/components/flashcards/FlashcardEditModal.tsx`.
    - Użyj komponentów Shadcn/ui: `Dialog`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogDescription`, `DialogFooter`, `Input`, `Textarea`, `Button`, `Label`.
    - Zdefiniuj propsy (`isOpen`, `flashcard`, `onSave`, `onClose`).
    - Implementuj stan lokalny dla pól formularza i błędów walidacji.
    - Implementuj logikę walidacji (max długość) on-change i on-submit.
    - Podłącz przycisk "Zapisz" do `onSave`, przekazując ID i zwalidowane dane.
    - Podłącz przycisk "Anuluj" i zamknięcie dialogu do `onClose`.
6.  **Integracja Modala:**
    - W `FlashcardReviewPage`, dodaj stan do zarządzania widocznością modala i fiszką do edycji.
    - Przekaż odpowiednie propsy do `FlashcardEditModal`.
    - Zaktualizuj `onEdit` w `FlashcardReviewList`/`FlashcardReviewItem`, aby otwierał modal.
7.  **Logika Akcji (w `FlashcardReviewPage` lub hooku):**
    - Zaimplementuj funkcje `handleAccept(id)`, `handleReject(id)`, `handleSaveEdit(id, data)`.
    - Wewnątrz tych funkcji:
        - Wywołaj odpowiednie API (`POST /api/flashcards/{id}/review`).
        - Obsłuż sukces: zaktualizuj stan `flashcards` (usuń element).
        - Obsłuż błąd: zaktualizuj stan `error`, wyświetl powiadomienie (`Toast`).
8.  **Obsługa Stanów UI:**
    - Dodaj wskaźniki ładowania (np. `Spinner` lub `Skeleton`) w `FlashcardReviewPage` i potencjalnie przy przyciskach akcji.
    - Wyświetlaj komunikaty o błędach pobierania danych.
    - Wyświetlaj komunikat o pustej liście.
    - Dezaktywuj przyciski podczas operacji API.
9.  **Styling:** Użyj TailwindCSS i klas Shadcn/ui do stylizacji komponentów zgodnie z designem aplikacji.
10. **Testowanie:** Dodaj testy jednostkowe i integracyjne dla komponentów i logiki pobierania/aktualizacji danych.
11. **Refaktoryzacja (Opcjonalnie):** Rozważ wydzielenie logiki zarządzania stanem i API do customowego hooka `useFlashcardReview`. 