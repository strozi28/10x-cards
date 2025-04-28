# Schemat bazy danych dla 10x-cards

## 1. Tabele

### 1.1. Tabela `users`

Ta tabela jest zarządzana przez Supabase Auth i zawiera standardowe pola autentykacyjne.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | uuid | PRIMARY KEY | Unikalny identyfikator użytkownika, generowany przez Supabase Auth |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Adres email użytkownika |
| created_at | timestamptz | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data i czas utworzenia konta |
| encrypted_password | text | NOT NULL | Zaszyfrowane hasło użytkownika |
| confirmed_at | timestamptz | | Data i czas potwierdzenia adresu email |

### 1.2. Tabela `flashcards`

Przechowuje informacje o fiszkach utworzonych przez użytkowników.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | bigserial | PRIMARY KEY | Unikalny identyfikator fiszki |
| front | varchar(200) | NOT NULL | Zawartość przedniej strony fiszki |
| back | varchar(500) | NOT NULL | Zawartość tylnej strony fiszki |
| source | varchar | NOT NULL, CHECK (source IN ('ai-full', 'ai-edited', 'manual')) | Źródło fiszki |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator właściciela fiszki |
| generated_at | timestamptz | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data i czas utworzenia fiszki |
| updated_at | timestamptz | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data i czas ostatniej aktualizacji fiszki |
| generation_id | bigint | REFERENCES generation_sessions(id) ON DELETE SET NULL | Powiązanie z sesją generowania (NULL dla ręcznie utworzonych fiszek) |

### 1.3. Tabela `generation_sessions`

Przechowuje informacje o sesjach generowania fiszek przy użyciu AI.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | bigserial | PRIMARY KEY | Unikalny identyfikator sesji generowania |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator użytkownika inicjującego sesję |
| model_used | varchar | NOT NULL | Model językowy użyty do generowania fiszek |
| generated_count | integer | NOT NULL DEFAULT 0 | Liczba wygenerowanych fiszek |
| accepted_without_edits | integer | NULLABLE | Liczba fiszek zaakceptowanych bez edycji |
| accepted_with_edits | integer | NULLABLE | Liczba fiszek zaakceptowanych po edycji |
| source_text_hash | varchar | NOT NULL | Hash tekstu źródłowego |
| source_text_length | integer | NOT NULL CHECK (source_text_length BETWEEN 1000 AND 10000) | Długość tekstu źródłowego w znakach |
| generation_time_ms | integer | NOT NULL | Czas generowania w milisekundach |
| created_at | timestamptz | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data i czas sesji generowania |
| updated_at | timestamptz | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data i czas sesji generowania |

### 1.4. Tabela `generation_error_logs`

Rejestruje błędy występujące podczas generowania fiszek.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | bigserial | PRIMARY KEY | Unikalny identyfikator wpisu błędu |
| user_id | uuid | NOT NULL, REFERENCES users(id) ON DELETE CASCADE | Identyfikator użytkownika, którego dotyczy błąd |
| model | varchar | | Model językowy, który spowodował błąd |
| source_text_hash | varchar | NOT NULL | Hash tekstu źródłowego |
| source_text_length | integer | NOT NULL CHECK (source_text_length BETWEEN 1000 AND 10000) | Długość tekstu źródłowego w znakach |
| error_code | varchar | NOT NULL | Kod błędu |
| error_message | text | NOT NULL | Treść komunikatu błędu |
| created_at | timestamptz | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data i czas wystąpienia błędu |

## 2. Relacje między tabelami

### 2.1. Relacja `users` ↔ `flashcards`
- Kardynalność: jeden-do-wielu (1:N)
- Użytkownik może mieć wiele fiszek
- Każda fiszka należy dokładnie do jednego użytkownika
- Implementacja: klucz obcy `user_id` w tabeli `flashcards` z kaskadowym usuwaniem

### 2.2. Relacja `users` ↔ `generation_sessions`
- Kardynalność: jeden-do-wielu (1:N)
- Użytkownik może mieć wiele sesji generowania
- Każda sesja generowania należy dokładnie do jednego użytkownika
- Implementacja: klucz obcy `user_id` w tabeli `generation_sessions` z kaskadowym usuwaniem

### 2.3. Relacja `users` ↔ `generation_error_logs`
- Kardynalność: jeden-do-wielu (1:N)
- Dla użytkownika może istnieć wiele logów błędów
- Każdy log błędu dotyczy dokładnie jednego użytkownika
- Implementacja: klucz obcy `user_id` w tabeli `generation_error_logs` z kaskadowym usuwaniem

### 2.4. Relacja `generation_sessions` ↔ `flashcards`
- Kardynalność: jeden-do-wielu (1:N)
- Sesja generowania może wygenerować wiele fiszek
- Fiszka może być powiązana z maksymalnie jedną sesją generowania (lub z żadną, jeśli utworzona ręcznie)
- Implementacja: klucz obcy `generation_id` w tabeli `flashcards`, który może przyjmować wartość NULL

## 3. Indeksy

### 3.1. Indeksy dla tabeli `flashcards`

```sql
CREATE INDEX idx_flashcards_user_id ON flashcards(user_id);
CREATE INDEX idx_flashcards_generation_id ON flashcards(generation_id);
CREATE INDEX idx_flashcards_source ON flashcards(source);
```

### 3.2. Indeksy dla tabeli `generation_sessions`

```sql
CREATE INDEX idx_generation_sessions_user_id ON generation_sessions(user_id);
CREATE INDEX idx_generation_sessions_created_at ON generation_sessions(created_at);
```

### 3.3. Indeksy dla tabeli `generation_error_logs`

```sql
CREATE INDEX idx_generation_error_logs_user_id ON generation_error_logs(user_id);
CREATE INDEX idx_generation_error_logs_created_at ON generation_error_logs(created_at);
```

## 4. Wyzwalacze

### 4.1. Automatyczna aktualizacja pola `updated_at` w tabeli `flashcards`

```sql
CREATE OR REPLACE FUNCTION set_updated_at_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_flashcards_updated_at
BEFORE UPDATE ON flashcards
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();
```

## 5. Zasady bezpieczeństwa na poziomie wiersza (RLS)

### 5.1. RLS dla tabeli `flashcards`

```sql
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own flashcards"
ON flashcards
FOR ALL
USING (auth.uid() = user_id);
```

### 5.2. RLS dla tabeli `generation_sessions`

```sql
ALTER TABLE generation_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own generation sessions"
ON generation_sessions
FOR ALL
USING (auth.uid() = user_id);
```

### 5.3. RLS dla tabeli `generation_error_logs`

```sql
ALTER TABLE generation_error_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own error logs"
ON generation_error_logs
FOR ALL
USING (auth.uid() = user_id);
```