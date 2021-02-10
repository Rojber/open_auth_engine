# open_auth_engine

## Charakterystyka systemu

Open Authentication Engine to proste API, którego głównym zadaniem jest uwierzytelnianie użytkowników za pomocą kodu w SMS. Służy jako zewnętrzne narzędzie wspierające developerów przy tworzeniu rejestracji do serwisów internetowych i aplikacji mobilnych.
Uwierzytelnienie następuje poprzez wysłanie kodu do użytkownika. Następnie kod jest odsyłany przez użytkownika do API z serwisu na którym nastąpiła rejestracja, co umożliwia uwierzytelnienie użytkownika.

Autoryzacja dostępu do konta odbywa się za pomocą sześciocyfrowego kodu bezpieczeństwa, który jest wysyłany SMSem. Taka weryfikacja jest jednym z najprostszych środków zapewniającym, że osoba, która loguje się na konto, jest naprawdę tym, za kogo się podaje.
Potwierdzenie tożsamości za pomocą telefonu znacznie ogranicza możliwość zalogowania się przez niepowołaną osobę. Nie będzie ona miała możliwości zalogowania się na konto dopóki nie ma dostępu również do jego telefonu.

## Opis architektury

Najważniejszym komponentem systemu jest aplikacja internetowa zaimplementowana przy użyciu platformy Flask oraz udostępniona za pomocą serwisu hostingowego Heroku. Umożliwia ona komunikację z klientami za pomocą interfejsu webowego oraz udostępnia panel administracyjny w postaci aplikacji internetowej. Cała komunikacja zabezpieczona jest protokołem Transport Layer Security (TLS). Jej prawidłowe działanie zależne jest od dwóch usług chmurowych: MongoDB Atlas przechowującej bazę danych systemu oraz Twilio pełniącej funkcję systemu wysyłania wiadomości SMS. 

Wszelkie aplikacje klienckie zależne są od Web API napisanego w Flasku. Na potrzeby testów utworzono przykładową aplikacje mobilną na system iOS (do znalezienia w branchu `iOS`).

## Konfiguracja

Do uruchomienie naszego API potrzeba tylko podać dane z Twillio oraz connection string bazy danych MongoDB lub MongoDB Atlas. Kod jest gotowy do publikacji w serwisie Heroku.

## Baza danych

Jako naszą bazę danych wykorzystaliśmy nierelacyjną bazę danych MongoDB wraz z jej pythonowym sterownikiem - PyMongo. Baza jest stosunkowo prosta, ponieważ nasz system nie wymaga zbierania dużej liczby informacji. Posiadamy w niej tylko 2 kolekcje (odpowiednik SQL - owych tablic):

`registered_clients` - przechowująca informacje o klientach (czyli serwisach, które będą korzystać z naszego API). Znajdują się tam podstawowe informacje na temat klienta jak jego adres email, hasło, nazwa, którą podamy w SMS - ach weryfikacyjnych oraz jego token autoryzacyjny - za pomocą tego tokenu klient będzie mógł używać naszego API. Dodatkowo przechowujemy tam też informacje o ilości wysłanych przez API smsów dla tego klienta w celu ułatwienia późniejszego rozliczenia z nim.
`user_verification` - przechowująca numer telefonu użytkownika wraz z wygenerowanym dla niego numerem weryfikacyjnym oraz id klienta. Po poprawnej weryfikacji rekord zostaje usunięty z bazy danych.

Poniższe przedstawiono budowę dokumentów tych kolekcji

#### registered_clients
    
    {
        "_id": ObjectId,
        "client_name": string,
        "client_password": string,
        "client_email": string,
        "client_auth_token": string,
        "sms_sent": int
    }


#### user_verification
    
    {
        "_id": ObjectId,
        "user_number": string,
        "user_verification_code": string
    }


## Opis endpointów API
    
W celu uczynienia API lekkim i prostym w integracji z aplikacjami klientów zdecydowano się na wykorzystanie tylko dwóch endpointów. Pierwszy odpowiada za wysłanie wiadomości SMS na numer użytkownika serwisu klienta, a drugi za weryfikacje zwróconego przez użytkownika kodu uzyskanego w wiadomości SMS. Poniżej przedstawiono szczegółowe informacje o tych endpointach. 


#### /api/send_sms
    
    POST - wyślij wiadomość SMS z kodem na podany numer użytkownika.

    Ciało zapytania:
    {
        “auth_token”: String - token autoryzacyjny klienta uzyskiwany po rejestracji w serwisie API,,
        “user_number”: String - numer użytkownika (bez numeru kierunkowego - domyślnie jest to polski)
    }

    Możliwe odpowiedzi:
    'SMS SENT', 200
    'UNAUTHORIZED', 400


#### /api/verify_sms

    POST - zweryfikuj poprawność kodu uzyskanego przez użytkownika..

    Ciało zapytania:
    {
        “auth_token”: String - token autoryzacyjny klienta uzyskiwany po rejestracji w serwisie API,
        “user_number”: String - numer użytkownika (bez numeru kierunkowego - domyślnie jest to polski),
        “user_verification_code”: String - kod podany przez użytkownika
    }

    Możliwe odpowiedzi:
    'VERIFIED SUCCESSFULLY', 200
    'UNAUTHORIZED', 400
    'WRONG CODE', 400

## Autorzy
- Robert Molenda - API w języku Python, integracja z Twilio, MongoDB Atlas oraz Heroku,
- Robert Moryson - aplikacja testowa w iOS,
- Konrad Kęciński - administracyjna aplikacja internetowa.
