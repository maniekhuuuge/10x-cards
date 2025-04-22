<conversation_summary>
<decisions>
1. Tabela użytkowników (users) będzie zawierać kolumny: email, nazwa, data rejestracji, encrypted_password oraz confirmed_at, bez dodatkowych pól, takich jak rola użytkownika.
2. W tabeli flashcards kolumna status_recenzji będzie typu enum zawierając wyłącznie wartości "pending", "accepted" i "rejected".
3. W tabeli flashcards kolumna metoda_tworzna będzie typu enum z wartościami "AI" i "manual".
4. Zostaną wprowadzone klucze obce między tabelami: flashcards.user_id, generations.user_id oraz generations_error_log.user_id odnoszące się do users.uuid.
5. Dodatkowe ograniczenia oraz indeksy zostaną dodane na kolumnach user_id oraz timestamp we wszystkich tabelach, gdzie mają one zastosowanie.
6. W tabeli generations_error_log kolumna error_message nie będzie miała określonego maksymalnego rozmiaru tekstu.
</decisions>

<matched_recommendations>
1. Utworzenie tabeli users z użyciem UUID jako klucza głównego oraz kolumn: email, nazwa, data_rejestracji, encrypted_password i confirmed_at.
2. Utworzenie tabeli flashcards z kolumnami: uuid, user_id (FK do users), przód (VARCHAR(200)), tył (VARCHAR(500)), timestamp utworzenia, metoda_tworzna (ENUM: "AI", "manual") oraz status_recenzji (ENUM: "pending", "accepted", "rejected").
3. Utworzenie tabeli generations z minimalnymi kolumnami: uuid, user_id (FK do users), timestamp oraz status operacji.
4. Utworzenie tabeli generations_error_log z kolumnami: uuid, user_id (FK do users), timestamp oraz error_message.
5. Dodanie indeksów na kolumnach "przód", user_id oraz timestamp w odpowiednich tabelach w celu optymalizacji wyszukiwania.
6. Wdrożenie RLS przy użyciu mechanizmu autoryzacji Supabase, aby zapewnić, że użytkownicy mają dostęp wyłącznie do swoich danych.
</matched_recommendations>

<database_planning_summary>
Główne wymagania dotyczące schematu bazy danych obejmują stworzenie czterech kluczowych encji: users, flashcards, generations oraz generations_error_log. Każda tabela będzie używać UUID jako kluczy głównych dla zapewnienia skalowalności i unikalności. Tabela users przechowuje dane profilowe użytkowników, w tym email, nazwę, datę rejestracji, zaszyfrowane hasło i datę potwierdzenia konta. Tabela flashcards będzie przechowywać fiszki z ograniczeniami długości dla pól "przód" i "tył", zawierać kolumnę dla metody tworzenia (enum: "AI", "manual") oraz kolumnę statusu recenzji (enum: "pending", "accepted", "rejected"). Tabele generations oraz generations_error_log służą do śledzenia operacji generowania fiszek i logowania błędów operacji, gdzie error_message ma przyjmować krótkie komunikaty, a brak jest wymogu ograniczenia rozmiaru tekstu. Relacje między tabelami zostaną zaimplementowane poprzez klucze obce odnoszące się do users.uuid. W celu optymalizacji zapytań planowane jest dodanie indeksów na kolumnach user_id oraz timestamp. Wdrożenie polityk RLS będzie bazować na mechanizmach autoryzacji Supabase.
</database_planning_summary>

<unresolved_issues>
Brak nierozwiązanych kwestii – wszystkie aspekty omówione w rozmowie zostały jednoznacznie określone.
</unresolved_issues>
</conversation_summary>

/* Schemat bazy danych PostgreSQL */

/* 1. Lista tabel z ich kolumnami, typami danych i ograniczeniami */

/** Tabela: users (zarządzana przez Supabase Auth) **/
/*
  Tabela auth.users jest zarządzana automatycznie przez Supabase Auth.
  Klucz główny: id (UUID) oraz kolumny takie jak email, itp.
  Dodatkowe metadane użytkownika są dostępne w auth.users.
*/

/** Tabela: flashcards **/
-- Definicja typów ENUM
CREATE TYPE flashcards_metoda AS ENUM ('AI', 'manual');
CREATE TYPE flashcards_status AS ENUM ('pending', 'accepted', 'rejected');

CREATE TABLE flashcards (
    uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    "przód" VARCHAR(200) NOT NULL,
    "tył" VARCHAR(500) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    metoda_tworzna flashcards_metoda NOT NULL,
    status_recenzji flashcards_status NOT NULL DEFAULT 'pending'
);

-- Indeksy poprawiające wydajność zapytań
CREATE INDEX idx_flashcards_user_id ON flashcards(user_id);
CREATE INDEX idx_flashcards_created_at ON flashcards(created_at);
CREATE INDEX idx_flashcards_przod ON flashcards("przód");


/** Tabela: generations **/
CREATE TABLE generations (
    uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL
);

-- Indeksy
CREATE INDEX idx_generations_user_id ON generations(user_id);
CREATE INDEX idx_generations_created_at ON generations(created_at);


/** Tabela: generations_error_log **/
CREATE TABLE generations_error_log (
    uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    error_message TEXT NOT NULL
);

-- Indeksy
CREATE INDEX idx_generror_user_id ON generations_error_log(user_id);
CREATE INDEX idx_generror_created_at ON generations_error_log(created_at);


/* 2. Relacje między tabelami */
/*
  - W tabelach flashcards, generations i generations_error_log kolumna user_id odnosi się do auth.users(id)
*/


/* 3. Indeksy */
/*
  - flashcards: idx_flashcards_user_id, idx_flashcards_created_at, idx_flashcards_przod
  - generations: idx_generations_user_id, idx_generations_created_at
  - generations_error_log: idx_generror_user_id, idx_generror_created_at
*/


/* 4. Zasady PostgreSQL (Row Level Security - RLS) */
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE generations ENABLE ROW LEVEL SECURITY;
ALTER TABLE generations_error_log ENABLE ROW LEVEL SECURITY;

/*
  RLS: Polityki należy zdefiniować opierając się o autoryzację Supabase, aby zapewnić,
  że użytkownik ma dostęp wyłącznie do swoich danych.
*/


/* 5. Dodatkowe uwagi */
/*
  - Tabela auth.users jest zarządzana przez Supabase Auth.
  - Wszystkie tabele korzystają z UUID jako klucza głównego oraz domyślnego ustawienia czasu (NOW())
    dla pól created_at.
  - Typy ENUM w tabeli flashcards (metoda_tworzna: 'AI', 'manual'; status_recenzji: 'pending', 'accepted', 'rejected')
    zapewniają ścisłe ograniczenia wartości.
  - Schemat zaprojektowany jest z myślą o wydajności i skalowalności dzięki wykorzystaniu kluczy obcych, indeksów oraz RLS.
*/
