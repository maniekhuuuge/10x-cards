# Plan implementacji widoku Lista fiszek

## 1. Przegląd
Widok "Lista fiszek" umożliwia zarejestrowanym użytkownikom przeglądanie, edytowanie i usuwanie swoich fiszek. Widok prezentuje fiszki w formie listy lub tabeli, oferuje paginację do nawigacji po większych zbiorach danych oraz opcje filtrowania (np. według statusu recenzji, metody utworzenia) i sortowania. Zapewnia również interfejs do modyfikacji i usuwania poszczególnych fiszek.

## 2. Routing widoku
Widok powinien być dostępny pod ścieżką: `/flashcards`

## 3. Struktura komponentów
```
/src/pages/flashcards.astro
└── FlashcardsListView (React Component)
    ├── LoadingIndicator (Conditional, Shadcn/ui?)
    ├── ErrorMessage (Conditional, Custom/Shadcn/ui?)
    ├── FlashcardFilters (React Component)
    │   └── (Dropdowns/Inputs for Status, Method, Sort - Shadcn/ui)
    ├── FlashcardTable (React Component, using Shadcn/ui Table)
    │   └── FlashcardRow (React Component, repeated)
    │       ├── (Table Cells for Front, Back, Status, Method, CreatedAt - Shadcn/ui)
    │       └── (Action Buttons: Edit, Delete - Shadcn/ui Button, DropdownMenu?)
    ├── PaginationControls (React Component)
    │   └── (Next/Prev Buttons, Page Info - Shadcn/ui Button)
    ├── EditFlashcardModal (React Component, using Shadcn/ui Dialog)
    │   └── (Form with Input/Textarea for Front/Back, Validation - Shadcn/ui Form, Input, Textarea)
    └── DeleteConfirmationModal (React Component, using Shadcn/ui AlertDialog)
        └── (Confirmation Text, Confirm/Cancel Buttons - Shadcn/ui AlertDialog)

```

## 4. Szczegóły komponentów

### `FlashcardsListView` (Komponent Główny Strony)
- **Opis komponentu:** Główny kontener strony `/flashcards`. Odpowiedzialny za pobieranie danych fiszek, zarządzanie stanem (ładowanie, błędy, paginacja, filtry, modale), obsługę logiki biznesowej (edycja, usuwanie) oraz renderowanie komponentów podrzędnych.
- **Główne elementy:** Kontener div, komponenty `LoadingIndicator`, `ErrorMessage`, `FlashcardFilters`, `FlashcardTable`, `PaginationControls`, `EditFlashcardModal`, `DeleteConfirmationModal`.
- **Obsługiwane interakcje:**
    - Inicjalizacja pobierania danych przy montowaniu komponentu.
    - Obsługa zmian paginacji z `PaginationControls`.
    - Obsługa zmian filtrów z `FlashcardFilters`.
    - Obsługa żądań edycji z `FlashcardRow` (otwarcie `EditFlashcardModal`).
    - Obsługa żądań usunięcia z `FlashcardRow` (otwarcie `DeleteConfirmationModal`).
    - Obsługa zapisu zmian z `EditFlashcardModal`.
    - Obsługa potwierdzenia usunięcia z `DeleteConfirmationModal`.
- **Obsługiwana walidacja:** Brak bezpośredniej walidacji, deleguje do API i modala edycji.
- **Typy:** `FlashcardsListViewModel`, `FlashcardViewModel`, `PaginationParams`, `FlashcardDTO`, `PaginatedResponse<FlashcardDTO>`, `UpdateFlashcardCommand`.
- **Propsy:** Brak (jest to komponent strony).

### `FlashcardFilters`
- **Opis komponentu:** Zawiera kontrolki do filtrowania i sortowania listy fiszek (np. status, metoda, data utworzenia).
- **Główne elementy:** Formularz lub div z komponentami `Select` lub `DropdownMenu` (Shadcn/ui) dla statusu, metody, sortowania.
- **Obsługiwane interakcje:** Zmiana wartości w kontrolkach filtra/sortowania.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `FlashcardsListViewModel['filters']`.
- **Propsy:**
    - `filters: FlashcardsListViewModel['filters']` (aktualne wartości filtrów)
    - `onFilterChange: (newFilters: Partial<FlashcardsListViewModel['filters']>) => void` (callback do aktualizacji filtrów w rodzicu)
    - `onSortChange: (sortKey: string | null) => void` (callback do aktualizacji sortowania w rodzicu)

### `FlashcardTable`
- **Opis komponentu:** Wyświetla listę fiszek w formie tabeli (np. używając komponentu `Table` z Shadcn/ui).
- **Główne elementy:** Komponent `Table`, `TableHeader`, `TableBody` (Shadcn/ui). Renderuje komponent `FlashcardRow` dla każdej fiszki.
- **Obsługiwane interakcje:** Brak bezpośrednich, propaguje zdarzenia z `FlashcardRow`.
- **Obsługiwana walidacja:** Brak.
- **Typy:** `FlashcardViewModel[]`.
- **Propsy:**
    - `flashcards: FlashcardViewModel[]` (lista fiszek do wyświetlenia)
    - `onEdit: (flashcardId: string) => void` (callback inicjujący edycję)
    - `onDelete: (flashcardId: string) => void` (callback inicjujący usuwanie)

### `FlashcardRow`
- **Opis komponentu:** Reprezentuje pojedynczy wiersz w tabeli fiszek. Wyświetla dane fiszki i przyciski akcji.
- **Główne elementy:** Komponent `TableRow`, `TableCell` (Shadcn/ui) do wyświetlania `front` (może być skrócony), `back` (może być skrócony), `status`, `method`, `createdAt`. Komponenty `Button` lub `DropdownMenu` (Shadcn/ui) dla akcji "Edytuj" i "Usuń".
- **Obsługiwane interakcje:** Kliknięcie przycisku "Edytuj", kliknięcie przycisku "Usuń".
- **Obsługiwana walidacja:** Brak.
- **Typy:** `FlashcardViewModel`.
- **Propsy:**
    - `flashcard: FlashcardViewModel` (dane fiszki)
    - `onEdit: (flashcardId: string) => void` (przekazanie żądania edycji do rodzica)
    - `onDelete: (flashcardId: string) => void` (przekazanie żądania usunięcia do rodzica)

### `PaginationControls`
- **Opis komponentu:** Wyświetla przyciski nawigacji paginacyjnej ("Poprzednia", "Następna") oraz opcjonalnie informacje o bieżącej stronie i całkowitej liczbie stron/elementów.
- **Główne elementy:** Kontener div, komponenty `Button` (Shadcn/ui) dla "Poprzednia" i "Następna", tekst wyświetlający np. "Strona X z Y".
- **Obsługiwane interakcje:** Kliknięcie przycisku "Poprzednia", kliknięcie przycisku "Następna".
- **Obsługiwana walidacja:** Przyciski "Poprzednia"/"Następna" są wyłączone (`disabled`), jeśli użytkownik jest odpowiednio na pierwszej/ostatniej stronie.
- **Typy:** `FlashcardsListViewModel['pagination']`.
- **Propsy:**
    - `pagination: FlashcardsListViewModel['pagination']` (aktualne dane paginacji)
    - `onPageChange: (newPage: number) => void` (callback do zmiany strony w rodzicu)

### `EditFlashcardModal`
- **Opis komponentu:** Modal (okno dialogowe, np. `Dialog` z Shadcn/ui) zawierający formularz do edycji pól `front` i `back` wybranej fiszki.
- **Główne elementy:** Komponent `Dialog`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogFooter` (Shadcn/ui). Formularz (`Form` z Shadcn/ui lub standardowy) z polami `Input` (dla `front`) i `Textarea` (dla `back`), etykietami, komunikatami walidacyjnymi i przyciskami "Zapisz" i "Anuluj".
- **Obsługiwane interakcje:** Wprowadzanie tekstu w polach `front` i `back`, kliknięcie "Zapisz", kliknięcie "Anuluj" lub zamknięcie modala.
- **Obsługiwana walidacja:**
    - Pole `front`: Wymagane, maksymalnie 200 znaków.
    - Pole `back`: Wymagane, maksymalnie 500 znaków.
    - Walidacja w czasie rzeczywistym z wyświetlaniem komunikatów o błędach (np. przy użyciu biblioteki typu `react-hook-form` z `zod` i integracją z Shadcn/ui `Form`). Przycisk "Zapisz" jest wyłączony, jeśli formularz jest niepoprawny.
- **Typy:** `FlashcardViewModel` (do pre-populacji), `UpdateFlashcardCommand` (do wysłania).
- **Propsy:**
    - `isOpen: boolean` (czy modal jest otwarty)
    - `flashcard: FlashcardViewModel | null` (dane fiszki do edycji)
    - `onSave: (flashcardId: string, data: UpdateFlashcardCommand) => Promise<void>` (asynchroniczny callback zapisu)
    - `onClose: () => void` (callback zamknięcia modala)
    - `isSaving: boolean` (informacja o trwającym zapisie, do wyłączenia przycisku)

### `DeleteConfirmationModal`
- **Opis komponentu:** Prosty modal potwierdzenia (np. `AlertDialog` z Shadcn/ui) pytający użytkownika, czy na pewno chce usunąć wybraną fiszkę.
- **Główne elementy:** Komponent `AlertDialog`, `AlertDialogContent`, `AlertDialogHeader`, `AlertDialogTitle`, `AlertDialogDescription`, `AlertDialogFooter`, `AlertDialogAction` (Potwierdź), `AlertDialogCancel` (Anuluj) (Shadcn/ui).
- **Obsługiwane interakcje:** Kliknięcie "Potwierdź", kliknięcie "Anuluj".
- **Obsługiwana walidacja:** Brak.
- **Typy:** Brak specyficznych.
- **Propsy:**
    - `isOpen: boolean` (czy modal jest otwarty)
    - `onConfirm: () => Promise<void>` (asynchroniczny callback potwierdzenia usunięcia)
    - `onClose: () => void` (callback zamknięcia modala)
    - `isDeleting: boolean` (informacja o trwającym usuwaniu, do wyłączenia przycisku)


## 5. Typy

### Istniejące typy (z `src/types.ts`)
- `FlashcardDTO`: Interfejs danych fiszki zwracanych przez API.
  ```typescript
  interface FlashcardDTO {
    uuid: string;
    userId: string;
    createdAt: string;
    generationId?: string | null;
    front: string; // from database field `przód`
    back: string; // from database field `tył`
    method: 'ai' | 'manual'; // from database field `metoda_tworzna`
    status: 'pending' | 'accepted' | 'rejected'; // from database field `status_recenzji`
  }
  ```
- `UpdateFlashcardCommand`: Interfejs danych wysyłanych do API przy aktualizacji fiszki.
  ```typescript
  interface UpdateFlashcardCommand {
    front: string; // max 200
    back: string; // max 500
  }
  ```
- `PaginationParams`: Parametry paginacji dla API.
  ```typescript
  interface PaginationParams {
    page: number;
    limit: number;
    sort?: string;
  }
  ```
- `PaginatedResponse<T>`: Struktura odpowiedzi paginowanej z API.
  ```typescript
  interface PaginatedResponse<T> {
    data: T[];
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  }
  ```

### Nowe typy ViewModel (dla stanu i UI)
- `FlashcardViewModel`: Reprezentacja fiszki w UI, potencjalnie z dodatkowymi polami lub formatowaniem. Może być tożsama z `FlashcardDTO` lub rozszerzona.
  ```typescript
  interface FlashcardViewModel {
    uuid: string;
    front: string;
    back: string;
    method: 'ai' | 'manual';
    status: 'pending' | 'accepted' | 'rejected';
    createdAt: string; // Może być sformatowana data np. 'DD.MM.YYYY HH:mm'
    // Opcjonalne flagi UI (jeśli potrzebne)
    // isDeleting?: boolean;
  }
  ```
- `FlashcardsListViewModel`: Główny obiekt stanu dla widoku `FlashcardsListView`.
  ```typescript
  interface FlashcardsListViewModel {
    flashcards: FlashcardViewModel[];
    isLoading: boolean;
    error: string | null;
    pagination: {
      currentPage: number;
      totalPages: number;
      limit: number;
      totalItems: number;
    };
    filters: {
      status: 'pending' | 'accepted' | 'rejected' | null;
      method: 'ai' | 'manual' | null;
      // sort jest stringiem, mapowanie na klucze API odbywa się przy wywołaniu
      sort: string | null; // np. 'createdAt', 'front', 'status'
    };
    editingFlashcard: FlashcardViewModel | null; // Dane fiszki w modal'u edycji
    isEditModalOpen: boolean;
    deletingFlashcardId: string | null; // ID fiszki w modal'u potwierdzenia usunięcia
    isDeleteModalOpen: boolean;
    isSaving: boolean; // Flaga dla stanu zapisu w modalu edycji
    isDeleting: boolean; // Flaga dla stanu usuwania w modalu potwierdzenia
  }
  ```

## 6. Zarządzanie stanem
Stan widoku `FlashcardsListView` będzie zarządzany lokalnie w komponencie React (`FlashcardsListView`) przy użyciu hooków `useState` i `useEffect`, lub `useReducer` jeśli logika stanie się bardziej złożona.

Alternatywnie, można stworzyć customowy hook `useFlashcardsList`, który enkapsuluje całą logikę pobierania danych, filtrowania, paginacji, obsługi modali oraz operacji edycji i usuwania.

- **Hook `useFlashcardsList` (propozycja):**
    - **Cel:** Centralizacja logiki zarządzania stanem listy fiszek.
    - **Stan wewnętrzny:** Zarządza wszystkimi polami z `FlashcardsListViewModel`.
    - **Zwracane wartości:**
        - `state: FlashcardsListViewModel` (aktualny stan widoku)
        - `actions: {`
            - `setPage: (page: number) => void`
            - `setFilters: (newFilters: Partial<FlashcardsListViewModel['filters']>) => void`
            - `setSort: (sortKey: string | null) => void`
            - `openEditModal: (flashcard: FlashcardViewModel) => void`
            - `closeEditModal: () => void`
            - `saveEdit: (flashcardId: string, data: UpdateFlashcardCommand) => Promise<void>`
            - `openDeleteModal: (flashcardId: string) => void`
            - `closeDeleteModal: () => void`
            - `confirmDelete: () => Promise<void>`
            - `retryFetch: () => void` // Do ponowienia pobierania w razie błędu
        - `}`
    - **Logika:** Zawiera `useEffect` do pobierania danych przy zmianie strony, filtrów, sortowania. Obsługuje wywołania API dla GET, PUT, DELETE, aktualizuje stan `isLoading`, `error` i dane.

## 7. Integracja API

### Pobieranie listy fiszek
- **Endpoint:** `GET /api/flashcards`
- **Akcja Frontend:** Wywoływane przy inicjalizacji widoku oraz przy zmianie strony, filtrów lub sortowania.
- **Parametry Zapytania:** `page`, `limit`, `sort` (np. 'createdAt', 'front'), `status` ('pending'/'accepted'/'rejected'), `method` ('ai'/'manual'). Parametry pobierane ze stanu `FlashcardsListViewModel`.
- **Typ Żądania:** Brak (GET).
- **Typ Odpowiedzi:** `PaginatedResponse<FlashcardDTO>`. Dane są mapowane na `FlashcardViewModel[]` i aktualizowany jest stan `pagination`.
- **Obsługa:** Aktualizacja stanu `flashcards`, `pagination`, `isLoading`, `error`.

### Aktualizacja fiszki
- **Endpoint:** `PUT /api/flashcards/{id}`
- **Akcja Frontend:** Wywoływane po zatwierdzeniu zmian w `EditFlashcardModal`.
- **Parametry Zapytania:** `id` fiszki w ścieżce URL.
- **Typ Żądania:** `UpdateFlashcardCommand` (zawiera `front` i `back`).
- **Typ Odpowiedzi:** `FlashcardDTO` (zaktualizowana fiszka).
- **Obsługa:** Aktualizacja odpowiedniej fiszki w stanie `flashcards`, zamknięcie modala, ustawienie `isSaving` na false. Obsługa błędów w modalu.

### Usunięcie fiszki
- **Endpoint:** `DELETE /api/flashcards/{id}`
- **Akcja Frontend:** Wywoływane po potwierdzeniu usunięcia w `DeleteConfirmationModal`.
- **Parametry Zapytania:** `id` fiszki w ścieżce URL.
- **Typ Żądania:** Brak (DELETE).
- **Typ Odpowiedzi:** Status 2xx (np. 204 No Content) lub prosty JSON potwierdzający sukces.
- **Obsługa:** Usunięcie fiszki ze stanu `flashcards`, zamknięcie modala, aktualizacja `totalItems` w paginacji, ustawienie `isDeleting` na false. Obsługa błędów (np. przez toast).

## 8. Interakcje użytkownika
- **Przeglądanie listy:** Użytkownik widzi tabelę z fiszkami. Może przewijać (jeśli tabela jest długa) lub używać paginacji.
- **Zmiana strony:** Kliknięcie "Następna"/"Poprzednia" w `PaginationControls` ładuje odpowiednią stronę danych.
- **Filtrowanie/Sortowanie:** Wybranie opcji w `FlashcardFilters` odświeża listę zgodnie z nowymi kryteriami.
- **Edycja fiszki:**
    1. Kliknięcie przycisku "Edytuj" w `FlashcardRow`.
    2. Otwiera się `EditFlashcardModal` z danymi wybranej fiszki.
    3. Użytkownik modyfikuje pola `front` i/lub `back` (zgodnie z walidacją).
    4. Kliknięcie "Zapisz" wysyła żądanie PUT. Po sukcesie modal się zamyka, a lista aktualizuje.
    5. Kliknięcie "Anuluj" zamyka modal bez zmian.
- **Usuwanie fiszki:**
    1. Kliknięcie przycisku "Usuń" w `FlashcardRow`.
    2. Otwiera się `DeleteConfirmationModal`.
    3. Kliknięcie "Potwierdź" wysyła żądanie DELETE. Po sukcesie modal się zamyka, a element znika z listy.
    4. Kliknięcie "Anuluj" zamyka modal bez usuwania.

## 9. Warunki i walidacja
- **Paginacja:** Przyciski "Poprzednia" i "Następna" są wyłączone (`disabled`), gdy użytkownik jest odpowiednio na pierwszej lub ostatniej stronie (`currentPage === 1` lub `currentPage === totalPages`).
- **Filtry:** Kontrolki filtrów powinny oferować tylko dozwolone wartości (np. 'pending', 'accepted', 'rejected' dla statusu).
- **Formularz Edycji (`EditFlashcardModal`):**
    - Pole `front` nie może być puste i musi mieć <= 200 znaków.
    - Pole `back` nie może być puste i musi mieć <= 500 znaków.
    - Komunikaty o błędach są wyświetlane pod polami w czasie rzeczywistym.
    - Przycisk "Zapisz" jest wyłączony, jeśli formularz jest niepoprawny lub trwa zapis (`isSaving`).
- **Przyciski Akcji:** Przyciski "Edytuj" i "Usuń" w `FlashcardRow` powinny być dostępne dla każdej fiszki. Przycisk "Potwierdź" w `DeleteConfirmationModal` jest wyłączony podczas trwania operacji usuwania (`isDeleting`).

## 10. Obsługa błędów
- **Błąd pobierania listy:** Jeśli `GET /api/flashcards` zwróci błąd (np. 500, 401, problem sieciowy), w `FlashcardsListView` wyświetlany jest komponent `ErrorMessage` z informacją o problemie i ewentualnie przyciskiem "Spróbuj ponownie". Błąd 401 powinien skutkować przekierowaniem do logowania.
- **Błąd aktualizacji:** Jeśli `PUT /api/flashcards/{id}` zwróci błąd, komunikat o błędzie jest wyświetlany w `EditFlashcardModal`, modal pozostaje otwarty, a stan `isSaving` jest resetowany.
- **Błąd usuwania:** Jeśli `DELETE /api/flashcards/{id}` zwróci błąd, wyświetlany jest komunikat (np. toast), modal `DeleteConfirmationModal` jest zamykany, a stan `isDeleting` jest resetowany.
- **Brak fiszek:** Jeśli API zwróci pustą listę (`data: []`), zamiast tabeli wyświetlany jest komunikat typu "Nie znaleziono fiszek pasujących do kryteriów" lub "Nie masz jeszcze żadnych fiszek. Utwórz nową!".

## 11. Kroki implementacji
1.  **Utworzenie struktury plików:** Stwórz plik strony `src/pages/flashcards.astro` oraz pliki dla komponentów React (np. `src/components/flashcards/FlashcardsListView.tsx`, `FlashcardTable.tsx`, `FlashcardRow.tsx`, `FlashcardFilters.tsx`, `PaginationControls.tsx`, `EditFlashcardModal.tsx`, `DeleteConfirmationModal.tsx`).
2.  **Implementacja `FlashcardsListView`:**
    - Zdefiniuj stan (`FlashcardsListViewModel`) używając `useState`/`useReducer` lub stwórz hook `useFlashcardsList`.
    - Zaimplementuj logikę pobierania danych (`useEffect`) wywołującą `GET /api/flashcards`.
    - Dodaj obsługę stanów ładowania (`isLoading`) i błędów (`error`).
    - Zrenderuj podstawową strukturę z komponentami podrzędnymi.
3.  **Implementacja `FlashcardTable` i `FlashcardRow`:**
    - Użyj komponentów `Table` z Shadcn/ui.
    - `FlashcardRow` powinien renderować dane z `FlashcardViewModel`.
    - Dodaj przyciski "Edytuj" i "Usuń" w `FlashcardRow` i podłącz je do callbacków `onEdit`/`onDelete`.
4.  **Implementacja `PaginationControls`:**
    - Wyświetl przyciski "Poprzednia"/"Następna" i informacje o stronie.
    - Wyłącz przyciski odpowiednio na pierwszej/ostatniej stronie.
    - Podłącz przyciski do callbacka `onPageChange`.
5.  **Implementacja `FlashcardFilters`:**
    - Dodaj kontrolki `Select` (Shadcn/ui) dla statusu, metody, sortowania.
    - Podłącz zmiany wartości do callbacków `onFilterChange`/`onSortChange`.
6.  **Implementacja `EditFlashcardModal`:**
    - Użyj komponentu `Dialog` z Shadcn/ui.
    - Zbuduj formularz (np. z `react-hook-form` i `zod` dla walidacji).
    - Zaimplementuj walidację pól `front` (max 200) i `back` (max 500).
    - Podłącz przycisk "Zapisz" do akcji wysyłającej `PUT /api/flashcards/{id}`.
    - Obsłuż stany `isSaving` i błędy zapisu.
7.  **Implementacja `DeleteConfirmationModal`:**
    - Użyj komponentu `AlertDialog` z Shadcn/ui.
    - Podłącz przycisk "Potwierdź" do akcji wysyłającej `DELETE /api/flashcards/{id}`.
    - Obsłuż stany `isDeleting` i błędy usuwania.
8.  **Połączenie logiki w `FlashcardsListView`:**
    - Zaimplementuj funkcje otwierania/zamykania modali (`openEditModal`, `closeEditModal`, etc.).
    - Zaimplementuj funkcje obsługi zapisu (`saveEdit`) i usuwania (`confirmDelete`), które wywołują odpowiednie metody API i aktualizują stan.
    - Przekaż odpowiednie propsy (stan i akcje) do komponentów podrzędnych.
9.  **Styling i UX:**
    - Użyj Tailwind i Shadcn/ui do stylizacji komponentów zgodnie z resztą aplikacji.
    - Dodaj komunikaty zwrotne (np. toasty dla sukcesu/błędu operacji edycji/usuwania).
    - Upewnij się, że widok jest responsywny.
10. **Testowanie:** Przetestuj wszystkie przepływy użytkownika (ładowanie, paginacja, filtrowanie, edycja, usuwanie) oraz obsługę błędów i przypadków brzegowych (np. pusta lista). 