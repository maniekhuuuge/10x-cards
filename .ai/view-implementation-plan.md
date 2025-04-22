/* Plan wdrożenia endpointu REST API */

# API Endpoint Implementation Plan: POST /flashcards

## 1. Przegląd punktu końcowego
Endpoint POST /flashcards umożliwia tworzenie nowych fiszek (flashcards) przez użytkownika. Obsługuje zarówno pojedyncze, jak i zbiorowe (bulk) utworzenie obiektów fiszek. Fiszki mogą być tworzone ręcznie lub generowane przez AI, przy czym podczas tworzenia automatycznie ustawiany jest status "pending" oczekujący na weryfikację.

## 2. Szczegóły żądania
- **Metoda HTTP:** POST
- **Struktura URL:** /flashcards
- **Nagłówki:**
  - `Authorization: Bearer <token>` (wymagany JWT do uwierzytelnienia użytkownika)
- **Parametry:**
  - **Wymagane:** Brak parametrów URL, ale nagłówek autoryzacji jest obowiązkowy.
  - **Request Body:**
    - Może być obiektem pojedynczej fiszki lub tablicą obiektów.
    - **Struktura obiektu:**
      - `front` (string, max 200 znaków) – treść przodu fiszki
      - `back` (string, max 500 znaków) – treść tyłu fiszki
      - `metoda_tworzna` (enum: 'manual' | 'AI') – metoda utworzenia fiszki, gdzie "AI" oznacza generację przez sztuczną inteligencję, a "manual" ręczne tworzenie.

## 3. Wykorzystywane typy
- **DTO:**
  - `FlashcardDTO` – reprezentuje strukturę fiszki zwracaną w odpowiedzi, zawiera m.in. `uuid`, `front`, `back`, `method` (przekształcony odpowiednio), `status` (domyślnie "pending")
- **Command Model:**
  - `CreateFlashcardCommand` – używany do walidacji danych przy tworzeniu fiszki, definiuje `front`, `back` oraz `metoda_tworzna` (akceptuje wartości 'manual' lub 'AI')

## 4. Szczegóły odpowiedzi
- **Sukces:**
  - Kod: 201 (Created)
  - Treść: JSON zawierający utworzone fiszki, np. obiekt lub tablicę obiektów z polami: `uuid`, `front`, `back`, `method`, `status`, `createdAt` itd.
- **Błędy:**
  - 400 – Nieprawidłowe dane wejściowe (np. brak wymaganych pól, przekroczona długość tekstu)
  - 401 – Brak lub nieprawidłowy token uwierzytelniający
  - 500 – Błąd serwera/nieoczekiwany błąd

## 5. Przepływ danych
1. Żądanie trafia do kontrolera endpointu POST /flashcards.
2. Middleware uwierzytelniający weryfikuje token JWT i wyciąga `userId` z kontekstu.
3. Dane wejściowe są walidowane przy użyciu schematu `CreateFlashcardCommand`:
   - Sprawdzane są pola `front`, `back`, `metoda_tworzna`.
   - Walidacja długości: `front` max 200 znaków, `back` max 500 znaków.
4. W warstwie serwisu dane są przetwarzane:
   - Ewentualna konwersja: jeśli `metoda_tworzna` to "AI", przekształcenie do wewnętrznej reprezentacji (np. "ai").
   - Utworzenie rekordu w bazie danych w tabeli `flashcards` z przypisanym `user_id`, ustawieniem domyślnego statusu "pending" i bieżącym timestampem.
5. Po udanej insercji serwis zwraca utworzone fiszki w formacie `FlashcardDTO`.
6. Kontroler zwraca odpowiedź HTTP 201 z danymi fiszek.

## 6. Względy bezpieczeństwa
- **Uwierzytelnienie i autoryzacja:**
  - Token JWT musi być w nagłówku `Authorization` i powinien być wydany przez Supabase Auth.
  - Supabase Auth obsługuje uwierzytelnianie użytkowników, a RLS (Row Level Security) w tabeli `flashcards` zapewnia, że użytkownik widzi tylko swoje dane.
- **Walidacja danych:**
  - Walidacja schematu wejściowego przy użyciu biblioteki walidacyjnej (np. Zod lub Joi), która sprawdza typy danych oraz ogranicza długość pól.
  - Ustal, że pole `front` musi być typu string o maksymalnej długości 200 znaków, a pole `back` musi być typu string o maksymalnej długości 500 znaków.
  - Sanitizacja danych wejściowych oraz wykorzystanie zapytań przygotowanych (prepared statements) zapobiega SQL Injection.
- **Rate Limiting:**
  - Możliwość wdrożenia ograniczenia liczby żądań w określonym czasie.

## 7. Obsługa błędów
- **400 Bad Request:**
  - Błąd walidacji (np. brak pola `front` lub `back`, przekroczenie dopuszczalnej długości).
  - W przypadku operacji bulk: jedno niepoprawne dane wejściowe może spowodować rollback całej transakcji lub częściową akceptację – decyzja zależy od wymagań biznesowych.
- **401 Unauthorized:**
  - Brak lub nieprawidłowy token JWT.
- **500 Internal Server Error:**
  - Błąd podczas operacji na bazie danych, nieoczekiwane wyjątki.
- **Logowanie błędów:**
  - W przypadku wystąpienia błędów serwerowych, szczegóły zapisywane są do systemu logującego lub tabeli błędów (np. `generations_error_log` w kontekście operacji generacji, jeżeli dotyczy).

## 8. Rozważania dotyczące wydajności
- **Indeksy w bazie:**
  - Indeks na kolumnie `user_id` w tabeli `flashcards` przyspiesza operacje wyszukiwania i filtrowania.
- **Bulk Insert:**
  - W przypadku tworzenia wielu fiszek, warto wykorzystać transakcje lub techniki batch insert, aby zminimalizować liczbę połączeń z bazą.
- **Walidacja:**
  - Walidacja danych wejściowych powinna być efektywna, aby nie wprowadzać opóźnień przy dużej liczbie żądań.
- **Timeout wywołań AI i asynchroniczne przetwarzanie:**
  - Ustawienie timeout'u dla wywołań AI uniemożliwi zawieszenie logiki serwera w przypadku opóźnień odpowiedzi od serwisu AI.
  - Asynchroniczne przetwarzanie długotrwałych operacji, takich jak generacja fiszek przez AI, pozwoli skalować endpoint.
- **Optymalizacja zapytań do bazy:**
  - Regularna analiza i optymalizacja zapytań (w tym optymalizacja transakcji, indeksowanie oraz wykorzystanie batch insert) poprawi wydajność operacji na bazie.
- **Monitoring wydajności:**
  - Implementacja mechanizmów monitorowania (APM, logi, metryki) pozwoli na bieżąco śledzić wydajność endpointu oraz serwisu AI i szybkie reagowanie na potencjalne problemy.

## 9. Etapy wdrożenia
0. **Przygotowanie środowiska i konfiguracja endpointu:**
   - Utworzenie pliku endpoint (np. `/src/api/flashcards.ts`) zawierającego definicję routingu oraz kontrolera dla POST /flashcards.
   - Konfiguracja integracji z Supabase Auth: skonfigurowanie SDK Supabase, dodanie middleware weryfikującego token JWT, co umożliwi korzystanie z mechanizmu uwierzytelnienia Supabase oraz implementację RLS w bazie.
1. **Uwierzytelnienie:**
   - Zapewnienie middleware do walidacji tokenu JWT.
2. **Kontroler:**
   - Utworzenie endpointu POST /flashcards, który odbiera żądanie, weryfikuje autoryzację i parsuje dane wejściowe.
3. **Walidacja:**
   - Implementacja walidacji danych wejściowych przy użyciu biblioteki (np. Zod lub inna) zgodnie z `CreateFlashcardCommand`.
4. **Logika serwisu:**
   - Utworzenie (lub rozszerzenie) warstwy serwisowej odpowiedzialnej za przetwarzanie żądania, mapowanie danych, konwersję wartości (np. "AI" -> "ai") i interakcję z bazą.
5. **Operacja na bazie danych:**
   - Wykonanie insercji do tabeli `flashcards` z wykorzystaniem transakcji w przypadku operacji bulk.
6. **Obsługa odpowiedzi:**
   - Zwrot odpowiedzi HTTP 201 z utworzonymi fiszkami lub odpowiednie kody błędów w przypadku niepowodzenia.
7. **Dokumentacja i recenzja:**
   - Aktualizacja dokumentacji API oraz omówienie wdrożenia z zespołem QA przed wdrożeniem produkcyjnym. 