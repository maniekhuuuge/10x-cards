# Dokument wymagań produktu (PRD) - Fiszki AI
## 1. Przegląd produktu
Opis:
- Produkt ma na celu uproszczenie i przyspieszenie procesu tworzenia fiszek edukacyjnych.
- Umożliwia tworzenie fiszek zarówno manualnie, jak i za pomocą AI, co pozwala na efektywne stosowanie metody spaced repetition.
- Aplikacja oferuje prosty interfejs do zarządzania fiszkami (przeglądanie, edycja, usuwanie) oraz podstawowy system kont użytkowników (rejestracja, logowanie, zmiana hasła, usuwanie konta).
- Dedykowany komponent "wkład" umożliwia przekazywanie tekstowego wkładu do modelu AI z limitem 10 000 znaków, z walidacją w czasie rzeczywistym.
- Proces generowania fiszek przez AI inicjowany jest ręcznie, z wyświetlaniem statusu operacji i minimalną animacją.
- Operacje generowania i recenzji fiszek są logowane w dedykowanej tabeli bazy danych.

## 2. Problem użytkownika
Opis:
- Ręczne tworzenie wysokiej jakości fiszek jest czasochłonne i skomplikowane, co zniechęca użytkowników do korzystania z metody spaced repetition.
- Początkujący użytkownicy mają trudności z optymalnym dzieleniem informacji na fiszki, co utrudnia efektywną naukę.

## 3. Wymagania funkcjonalne
Wymagania:
- Formularz tworzenia fiszek z dwoma polami tekstowymi:
  - "Przód" – maksymalnie 200 znaków, z natychmiastową walidacją i komunikatami o błędach.
  - "Tył" – maksymalnie 500 znaków, z natychmiastową walidacją i komunikatami o błędach.
- Osobny komponent "wkład":
  - Przeznaczony wyłącznie do przekazywania danych wejściowych do modelu AI.
  - Limit 10 000 znaków, walidacja w czasie rzeczywistym oraz możliwość edycji przed wysłaniem.
- Generowanie fiszek przez AI:
  - Inicjowane ręcznie przez użytkownika przy użyciu domyślnych ustawień.
  - Wyświetlanie statusu operacji (postęp, minimalna animacja) w trakcie generowania.
- Mechanizm recenzji fiszek generowanych przez AI:
  - Umożliwia użytkownikowi akceptację, edycję (z potwierdzeniem, która nadpisuje istniejące dane) lub odrzucenie wygenerowanych propozycji.
- Zarządzanie kontem użytkownika:
  - Rejestracja, logowanie, zmiana hasła oraz usunięcie konta.
  - Podstawowe mechanizmy bezpieczeństwa, m.in. bezpieczne przesyłanie danych logowania.
- Przechowywanie fiszek w postaci czysto tekstowej, bez dodatkowych metadanych czy formatowania.
- Logowanie operacji generowania fiszek w dedykowanej tabeli bazy danych.

## 4. Granice produktu
Co nie wchodzi w zakres MVP:
- Własny, zaawansowany algorytm powtórek (np. SuperMemo, Anki); wykorzystany zostanie gotowy algorytm.
- Import fiszek z wielu formatów (PDF, DOCX, itp.).
- Współdzielenie zestawów fiszek między użytkownikami.
- Integracje z innymi platformami edukacyjnymi.
- Aplikacje mobilne – początkowo tylko wersja web.
- Zaawansowane funkcje eksportu danych oraz filtrowania logów.

## 5. Historyjki użytkowników

US-001
Tytuł: Rejestracja użytkownika
Opis: Jako nowy użytkownik chcę móc się zarejestrować, aby korzystać z funkcjonalności przechowywania i generowania fiszek.
Kryteria akceptacji:
- Użytkownik wypełnia formularz rejestracyjny.
- Proces rejestracji kończy się powodzeniem i wyświetla komunikat potwierdzający.

US-002
Tytuł: Logowanie do systemu
Opis: Jako zarejestrowany użytkownik chcę mieć możliwość zalogowania się, aby uzyskać dostęp do swoich fiszek.
Kryteria akceptacji:
- Użytkownik loguje się przy użyciu poprawnych danych.
- System uwierzytelnia dane i umożliwia dostęp do konta.

US-003
Tytuł: Zmiana hasła
Opis: Jako użytkownik chcę móc zmienić swoje hasło, aby aktualizować dane logowania.
Kryteria akceptacji:
- Użytkownik wprowadza stare oraz nowe hasło.
- System potwierdza poprawność i zmienia hasło, komunikując sukces operacji.

US-004
Tytuł: Usuwanie konta
Opis: Jako użytkownik chcę móc usunąć swoje konto, aby moje dane zostały trwale usunięte z systemu.
Kryteria akceptacji:
- Użytkownik przechodzi proces potwierdzenia usunięcia konta.
- System usuwa konto i wszystkie powiązane dane, wyświetlając komunikat o powodzeniu.

US-005
Tytuł: Manualne tworzenie fiszek
Opis: Jako użytkownik chcę móc tworzyć fiszki manualnie, wprowadzając dane do pól "przód" i "tył".
Kryteria akceptacji:
- Pole "przód" akceptuje do 200 znaków, a pole "tył" do 500 znaków.
- System wyświetla natychmiastową walidację i komunikaty o przekroczeniu limitu znaków.

US-006
Tytuł: Generowanie fiszek przez AI
Opis: Jako użytkownik chcę móc generować fiszki przez AI na podstawie wprowadzonego tekstu w polu "wkład", aby usprawnić proces tworzenia fiszek.
Kryteria akceptacji:
- Pole "wkład" umożliwia wprowadzenie maksymalnie 10 000 znaków z walidacją w czasie rzeczywistym.
- Proces generowania jest inicjowany ręcznie i wyświetla status operacji (postęp, animacja).

US-007
Tytuł: Recenzja fiszek generowanych przez AI
Opis: Jako użytkownik chcę móc recenzować fiszki wygenerowane przez AI, aby zaakceptować, edytować lub odrzucić proponowane fiszki.
Kryteria akceptacji:
- System prezentuje wygenerowane fiszki jako kandydatów do recenzji.
- Użytkownik ma możliwość zaakceptowania fiszki.
- Użytkownik może edytować fiszkę po wyświetleniu dialogu potwierdzającego, nadpisując istniejące dane.
- Użytkownik może odrzucić fiszkę, usuwając ją z listy propozycji.

US-008
Tytuł: Edycja fiszek
Opis: Jako użytkownik chcę mieć możliwość edytowania już istniejących fiszek, aby modyfikować ich zawartość zgodnie z moimi potrzebami.
Kryteria akceptacji:
- Użytkownik wybiera fiszkę do edycji.
- Edycja pól "przód" i "tył" odbywa się z zachowaniem walidacji długości.
- System zapisuje zmodyfikowaną fiszkę i wyświetla komunikat o powodzeniu operacji.

US-009
Tytuł: Przeglądanie i usuwanie fiszek
Opis: Jako użytkownik chcę móc przeglądać listę fiszek oraz usuwać wybrane fiszki, aby zarządzać zawartością mojego konta.
Kryteria akceptacji:
- System prezentuje listę wszystkich fiszek użytkownika.
- Użytkownik ma możliwość usunięcia wybranej fiszki, przy czym operacja jest potwierdzana komunikatem.

US-010
Tytuł: Bezpieczne uwierzytelnianie i dostęp do konta
Opis: Jako użytkownik chcę mieć pewność, że moje dane są bezpieczne, a dostęp do konta jest ograniczony tylko do autoryzowanych użytkowników.
Kryteria akceptacji:
- Dane logowania są przesyłane przy użyciu bezpiecznych protokołów.
- System zapewnia, że dostęp do konta uzyskują wyłącznie autoryzowani użytkownicy.

## 6. Metryki sukcesu
Metryki:
- Co najmniej 75% fiszek generowanych przez AI zostanie zaakceptowanych przez użytkowników.
- 75% wszystkich tworzonych fiszek powinno pochodzić z funkcji generowania przez AI.
- Sukces operacji generowania fiszek monitorowany jest poprzez logi przechowywane w dedykowanej tabeli bazy danych. 