# Przewodnik Implementacji Usługi OpenRouter

## 1. Opis Usługi

Usługa OpenRouter (`OpenRouterService`) będzie działać jako pośrednik między aplikacją a API OpenRouter.ai. Jej głównym celem jest ułatwienie wysyłania żądań do różnych modeli językowych (LLM) dostępnych przez OpenRouter, zarządzanie konfiguracją (jak klucze API, nazwy modeli, parametry) oraz obsługa odpowiedzi, w tym parsowanie ustrukturyzowanych danych (JSON). Usługa będzie zaimplementowana zgodnie z zasadami czystego kodu i strukturą projektu opisaną w `@shared.mdc`.

## 2. Opis Konstruktora

Konstruktor usługi będzie odpowiedzialny za inicjalizację klienta HTTP oraz załadowanie konfiguracji, w tym klucza API OpenRouter.

```typescript
// Lokalizacja: src/lib/services/OpenRouterService.ts

import { openRouterApiKey } from '@/config'; // Zakładając plik konfiguracyjny

export class OpenRouterService {
  private apiKey: string;
  private baseUrl: string = 'https://openrouter.ai/api/v1'; // Bazowy URL API

  constructor() {
    if (!openRouterApiKey) {
      throw new Error('OpenRouter API key is not configured.');
    }
    this.apiKey = openRouterApiKey;
    // Można tu dodać inicjalizację klienta HTTP (np. axios, fetch z opcjami)
  }

  // ... reszta implementacji
}
```

**Zasady implementacji:**
- Klucz API powinien być ładowany z bezpiecznego źródła (np. zmienne środowiskowe, Supabase secrets), a nie hardkodowany. Plik `@/config` jest tylko przykładem.
- Konstruktor powinien rzucać błąd, jeśli klucz API nie jest dostępny, zgodnie z zasadą `fail-fast`.

## 3. Publiczne Metody i Pola

### Metody Publiczne

1.  `async getChatCompletion(options: ChatCompletionOptions): Promise<ChatCompletionResponse>`
    -   **Cel:** Główna metoda do wysyłania żądania uzupełnienia czatu do API OpenRouter.
    -   **Funkcjonalność:**
        -   Przyjmuje obiekt `ChatCompletionOptions` zawierający m.in. `model`, `messages` (w tym `system` i `user`), `response_format`, `temperature`, `max_tokens` itp.
        -   Buduje ciało żądania zgodnie ze specyfikacją API OpenRouter.
        -   Wysyła żądanie POST do punktu końcowego `/chat/completions`.
        -   Obsługuje odpowiedź, w tym potencjalne błędy API.
        -   Zwraca sparsowaną odpowiedź w formacie `ChatCompletionResponse`.
        -   Implementuje logikę ponawiania prób (retry) w przypadku błędów przejściowych (np. 5xx).
    -   **Parametry (`ChatCompletionOptions`):**
        -   `model: string`: Nazwa modelu do użycia (np. "openai/gpt-4o").
        -   `messages: Array<{ role: 'system' | 'user' | 'assistant'; content: string }>`: Historia konwersacji.
        -   `response_format?: { type: 'json_schema', json_schema: { name: string; strict?: boolean; schema: object } }`: Opcjonalna definicja schematu JSON dla odpowiedzi.
        -   `temperature?: number`: Parametr kontrolujący losowość (0-2).
        -   `max_tokens?: number`: Maksymalna liczba tokenów w odpowiedzi.
        -   *Inne parametry API OpenRouter...*
    -   **Zwracany typ (`ChatCompletionResponse`):**
        -   Powinien mapować strukturę odpowiedzi API OpenRouter, w tym `id`, `choices`, `usage` itp. Jeśli użyto `response_format`, pole `content` w `choices` będzie zawierać string JSON.

**Przykład użycia `response_format`:**

```typescript
// Przykład schematu do ekstrakcji danych użytkownika
const userSchema = {
  type: 'object',
  properties: {
    name: { type: 'string', description: 'Imię użytkownika' },
    email: { type: 'string', format: 'email', description: 'Adres email użytkownika' },
    age: { type: 'integer', description: 'Wiek użytkownika' }
  },
  required: ['name', 'email']
};

// Wywołanie metody z response_format
const response = await openRouterService.getChatCompletion({
  model: 'openai/gpt-4o',
  messages: [
    { role: 'system', content: 'Extract user details from the following text. Respond using the provided JSON schema.' },
    { role: 'user', content: 'Nazywam się Jan Kowalski, mój email to jan.kowalski@example.com, mam 30 lat.' }
  ],
  response_format: {
    type: 'json_schema',
    json_schema: {
      name: 'userDetailsExtractor', // Dowolna nazwa schematu
      strict: true, // Wymuś zgodność ze schematem
      schema: userSchema
    }
  }
});

// Oczekiwana odpowiedź (w response.choices[0].message.content):
// "{"name": "Jan Kowalski", "email": "jan.kowalski@example.com", "age": 30}"
```

## 4. Prywatne Metody i Pola

### Pola Prywatne

1.  `apiKey: string`: Przechowuje klucz API OpenRouter.
2.  `baseUrl: string`: Bazowy URL API OpenRouter.
3.  `httpClient: HttpClient`: (Opcjonalnie) Instancja klienta HTTP do obsługi żądań (np. skonfigurowany `axios` lub natywny `fetch`).

### Metody Prywatne

1.  `async _request(endpoint: string, options: RequestInit): Promise<Response>`
    -   **Cel:** Wewnętrzna metoda do wykonywania żądań HTTP do API.
    -   **Funkcjonalność:**
        -   Dodaje nagłówki autoryzacyjne (`Authorization: Bearer ${this.apiKey}`, `HTTP-Referer`, `X-Title`). Wartości `HTTP-Referer` i `X-Title` powinny pochodzić z konfiguracji aplikacji.
        -   Obsługuje serializację ciała żądania (np. `JSON.stringify`).
        -   Wykonuje żądanie `fetch` lub za pomocą `httpClient`.
        -   Może zawierać logikę ponawiania prób (retry) lub obsługę limitów API (rate limiting).
        -   Zwraca surową odpowiedź HTTP (`Response`).

2.  `_handleApiResponse<T>(response: Response): Promise<T>`
    -   **Cel:** Przetwarzanie surowej odpowiedzi HTTP z API.
    -   **Funkcjonalność:**
        -   Sprawdza status odpowiedzi (`response.ok`).
        -   Jeśli status wskazuje na błąd (np. 4xx, 5xx), odczytuje ciało błędu, tworzy odpowiedni obiekt błędu (np. `OpenRouterApiError`) i go rzuca.
        -   Jeśli status jest poprawny, parsuje ciało odpowiedzi jako JSON.
        -   Zwraca sparsowane dane typu `T`.

## 5. Obsługa Błędów

Usługa powinna implementować robustną obsługę błędów zgodnie z `@shared.mdc`.

1.  **Brak klucza API:** Rzucany przez konstruktor, jeśli klucz nie jest skonfigurowany. Należy go obsłużyć na poziomie inicjalizacji aplikacji.
2.  **Błędy Walidacji Danych Wejściowych:** Przed wysłaniem żądania, metoda `getChatCompletion` powinna walidować `ChatCompletionOptions` (np. czy `messages` nie jest puste, czy `model` jest podany). Należy rzucać błędy typu `ValidationError`.
3.  **Błędy API OpenRouter (4xx):**
    -   `401 Unauthorized`: Nieprawidłowy klucz API. Usługa powinna rzucić `AuthenticationError`. Aplikacja powinna zalogować błąd i powiadomić administratora.
    -   `400 Bad Request`: Nieprawidłowe parametry żądania (np. zły format `messages`, niepoprawny `response_format`). Usługa powinna rzucić `BadRequestError` z komunikatem z API.
    -   `429 Too Many Requests`: Przekroczono limit zapytań. Usługa powinna zaimplementować strategię ponawiania prób z `exponential backoff` lub rzucić `RateLimitError`.
    -   Inne błędy 4xx: Rzucić generyczny `ClientRequestError` z kodem statusu i komunikatem.
4.  **Błędy Serwera OpenRouter (5xx):** Wewnętrzne błędy OpenRouter. Usługa powinna zaimplementować strategię ponawiania prób (np. 3 próby z `exponential backoff`) i jeśli błąd nadal występuje, rzucić `ServerError` lub `OpenRouterApiError`.
5.  **Błędy Sieciowe:** Problemy z połączeniem do API. Klient HTTP powinien obsłużyć te błędy (np. `fetch` rzuca `TypeError`). Usługa powinna je przechwycić i rzucić jako `NetworkError`.
6.  **Błędy Parsowania Odpowiedzi:** Jeśli odpowiedź API (nawet ze statusem 200) nie jest poprawnym JSON-em lub odpowiedź ze schematem JSON nie pasuje do niego (gdy `strict: true`). Usługa powinna rzucić `ParsingError`.

**Implementacja:**
- Zdefiniować niestandardowe klasy błędów (np. `OpenRouterApiError`, `AuthenticationError`, `RateLimitError`, `ValidationError`, `NetworkError`, `ParsingError`) dziedziczące po `Error`.
- Używać `try...catch` w metodach publicznych i prywatnych do przechwytywania i mapowania błędów.
- Logować szczegóły błędów (bez wrażliwych danych) dla celów diagnostycznych.

## 6. Kwestie Bezpieczeństwa

1.  **Zarządzanie Kluczem API:** Klucz API OpenRouter jest wrażliwym danym. **NIGDY** nie umieszczaj go bezpośrednio w kodzie frontendowym ani w repozytorium kodu.
    -   **Rekomendacja:** Przechowuj klucz jako sekret w Supabase (jeśli używasz Edge Functions) lub jako zmienną środowiskową na serwerze (`process.env.OPENROUTER_API_KEY`). Dostęp do niego powinien mieć tylko backend.
2.  **Ochrona przed Wstrzykiwaniem Danych (Prompt Injection):** Chociaż usługa jest pośrednikiem, należy uważać na dane wejściowe od użytkowników (`messages`), które mogą być częścią promptu. Jeśli aplikacja pozwala użytkownikom na tworzenie części promptów systemowych lub manipulowanie parametrami, należy zastosować odpowiednie mechanizmy sanityzacji lub walidacji.
3.  **Kontrola Dostępu:** Usługa powinna być wywoływana tylko przez autoryzowane części aplikacji. Jeśli jest to publiczny endpoint API (np. w `src/pages/api`), powinien być zabezpieczony (np. przez middleware sprawdzające sesję użytkownika Supabase Auth).
4.  **Logowanie:** Loguj zdarzenia i błędy, ale unikaj logowania pełnych treści wiadomości użytkowników lub kluczy API. Loguj metadane (np. ID użytkownika, ID żądania, nazwa modelu, status błędu).
5.  **Limity Użycia (Rate Limiting):** Zaimplementuj mechanizmy ograniczania liczby żądań na poziomie aplikacji (per użytkownik lub globalnie), aby zapobiec nadużyciom i przekroczeniu limitów OpenRouter.

## 7. Plan Wdrożenia Krok po Kroku

Przy założeniu implementacji jako serwis TypeScript w `src/lib/services/` używany przez backend Astro (`src/pages/api`) lub Supabase Edge Functions.

1.  **Konfiguracja:**
    -   Dodaj klucz API OpenRouter do zmiennych środowiskowych (np. w pliku `.env` dla lokalnego rozwoju, w ustawieniach hostingu/Supabase dla produkcji). Upewnij się, że jest dostępny w środowisku wykonawczym (np. `process.env.OPENROUTER_API_KEY` lub odpowiednik w Deno/Supabase).
    -   Skonfiguruj `HTTP-Referer` i `X-Title` (nazwa Twojej aplikacji/URL) w pliku konfiguracyjnym lub zmiennych środowiskowych.

2.  **Definicja Typów:**
    -   W pliku `src/types.ts` (lub dedykowanym pliku np. `src/lib/services/openrouter.types.ts`) zdefiniuj interfejsy TypeScript dla:
        -   `ChatCompletionOptions` (wejście do `getChatCompletion`)
        -   `ChatMessage` (element tablicy `messages`)
        -   `ResponseFormat` (w tym `JsonSchemaFormat`)
        -   `ChatCompletionResponse` (wyjście z `getChatCompletion`, mapujące odpowiedź API)
        -   `ApiErrorResponse` (struktura błędu zwracanego przez API OpenRouter)

3.  **Implementacja Klasy Usługi (`src/lib/services/OpenRouterService.ts`):**
    -   Stwórz plik `OpenRouterService.ts`.
    -   Zaimplementuj konstruktor (`constructor`) ładujący klucz API i sprawdzający jego obecność.
    -   Zaimplementuj prywatną metodę `_request` do wysyłania żądań HTTP z odpowiednimi nagłówkami (`Authorization`, `HTTP-Referer`, `X-Title`). Rozważ użycie biblioteki `ky` lub `axios` dla ułatwienia, lub standardowego `fetch`.
    -   Zaimplementuj prywatną metodę `_handleApiResponse` do obsługi odpowiedzi i błędów API (sprawdzanie statusu, parsowanie JSON, rzucanie niestandardowych błędów).
    -   Zaimplementuj publiczną metodę `getChatCompletion`:
        -   Przyjmij `ChatCompletionOptions`.
        -   Zwaliduj podstawowe opcje (np. obecność `model` i `messages`).
        -   Zbuduj ciało żądania (`body`) zgodnie ze specyfikacją OpenRouter, włączając `model`, `messages`, `response_format` (jeśli podano), `temperature`, `max_tokens` itp.
        -   Wywołaj `this._request('/chat/completions', { method: 'POST', body: JSON.stringify(body), headers: { 'Content-Type': 'application/json' } })`.
        -   Przekaż odpowiedź do `this._handleApiResponse<ChatCompletionResponse>`.
        -   Zwróć wynik.

4.  **Implementacja Obsługi Błędów:**
    -   Zdefiniuj niestandardowe klasy błędów (`OpenRouterApiError`, `AuthenticationError`, `RateLimitError`, etc.) w osobnym pliku (np. `src/lib/errors.ts`).
    -   W metodach `_request`, `_handleApiResponse` i `getChatCompletion` użyj `try...catch` do przechwytywania błędów (sieciowych, API, parsowania) i rzucania odpowiednich niestandardowych błędów.

5.  **Integracja z Aplikacją (Przykład dla Astro API Route):**
    -   Stwórz endpoint API, np. `src/pages/api/chat.ts`.
    -   Wewnątrz endpointu:
        -   Zaimportuj i utwórz instancję `OpenRouterService`.
        -   Pobierz dane z żądania przychodzącego (np. treść wiadomości użytkownika).
        -   Zabezpiecz endpoint (sprawdź autentykację użytkownika, jeśli wymagane).
        -   Przygotuj obiekt `ChatCompletionOptions`:
            -   **Komunikat systemowy:** Zdefiniuj go na stałe lub dynamicznie na podstawie kontekstu aplikacji.
            -   **Komunikat użytkownika:** Użyj danych wejściowych od użytkownika.
            -   **Nazwa modelu:** Wybierz model (może być konfigurowalny lub stały).
            -   **Parametry modelu:** Ustaw `temperature`, `max_tokens` itp. zgodnie z potrzebami.
            -   **`response_format`:** Zdefiniuj schemat JSON, jeśli potrzebujesz ustrukturyzowanej odpowiedzi.
        -   Wywołaj `openRouterService.getChatCompletion(options)`.
        -   Obsłuż potencjalne błędy zwrócone przez serwis (użyj `try...catch`).
        -   Zwróć odpowiedź (lub błąd) do klienta frontendowego.

    ```typescript
    // Przykład: src/pages/api/chat.ts
    import type { APIRoute } from 'astro';
    import { OpenRouterService } from '@/lib/services/OpenRouterService';
    import { getUserSession } from '@/lib/auth'; // Przykładowa funkcja autoryzacji

    const openRouterService = new OpenRouterService();

    export const POST: APIRoute = async ({ request }) => {
      const session = await getUserSession(request);
      if (!session) {
        return new Response('Unauthorized', { status: 401 });
      }

      try {
        const { userMessage, context } = await request.json(); // Pobierz wiadomość i kontekst

        if (!userMessage) {
          return new Response('Bad Request: Missing userMessage', { status: 400 });
        }

        // Przygotuj opcje dla OpenRouter
        const options = {
          model: 'openai/gpt-4o', // Wybierz model
          messages: [
            { role: 'system', content: `Jesteś pomocnym asystentem. Kontekst: ${context}` }, // Komunikat systemowy
            { role: 'user', content: userMessage } // Komunikat użytkownika
          ],
          temperature: 0.7,
          // response_format: { ... } // Opcjonalnie, jeśli potrzebny JSON
        };

        const response = await openRouterService.getChatCompletion(options);

        // Przetworzenie odpowiedzi - np. zwrócenie treści pierwszej wiadomości
        const assistantMessage = response.choices[0]?.message?.content;

        return new Response(JSON.stringify({ reply: assistantMessage }), {
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        });

      } catch (error: any) {
        console.error('Chat API Error:', error); // Logowanie błędu po stronie serwera
        // Mapowanie błędów na odpowiedzi HTTP
        if (error.name === 'AuthenticationError') {
          return new Response('Internal Server Error: API Authentication Failed', { status: 500 }); // Nie ujawniaj problemu z kluczem
        } if (error.name === 'RateLimitError') {
           return new Response('Too Many Requests', { status: 429 });
        } else {
          return new Response(`Internal Server Error: ${error.message || 'Unknown error'}`, { status: 500 });
        }
      }
    };
    ```

6.  **Testowanie:**
    -   Napisz testy jednostkowe dla `OpenRouterService`, mockując klienta HTTP, aby przetestować logikę budowania żądań, parsowania odpowiedzi i obsługi błędów.
    -   Napisz testy integracyjne dla endpointu API (`/api/chat`), aby sprawdzić przepływ od żądania frontendowego do odpowiedzi z (mockowanego lub rzeczywistego, w środowisku testowym) OpenRouter.

7.  **Wdrożenie:**
    -   Wdróż aplikację na platformie hostingowej (np. DigitalOcean, Vercel, Netlify).
    -   Skonfiguruj zmienne środowiskowe (klucz API, URL referera, tytuł aplikacji) w środowisku produkcyjnym.
    -   Monitoruj logi i wydajność usługi. 