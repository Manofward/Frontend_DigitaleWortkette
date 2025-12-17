Everything is from the viewpoint of the Page

### 1. Startseite

**Route:** `/`
**Methods:** `GET`, optionally `POST` (if you host or join a game directly)

**Purpose:**

* Show app title and logo
* Button: “🎮 Spiel hosten” → create a lobby
* Optional: Show list of open lobbies (fetched dynamically)

---

### 2. Host Lobby

**Route:** `/host-lobby`
**Methods:** `GET`, `POST`

**Purpose:**

* Host creates a new lobby and chooses:

  * Thema (topic)
  * Spiellänge (duration)
  * Max. Spieler (max players)
* Backend generates a lobby code and optional QR code.

---

### 3. Join Lobby

**Route:** `/join-lobby/<code>`
**Methods:** `GET`, `POST`

**Purpose:**

* Player joins existing lobby using code (or QR).
* User sets nickname (can be stored in session).
* Waits until host starts game.

---

### 4. Waiting Room (Join View)

**Route:** `/lobby/<code>`
**Methods:** `GET`

**Purpose:**

* Display joined players and waiting status
* Host has button [🟢 Spiel starten]

**Backend tasks:**

* Poll or WebSocket update for player list
* Host triggers `/start-game/<code>`

---

### 5. Start Game

**Route:** `/start-game/<code>`
**Methods:** `POST`

**Purpose:**

* Host starts the game.
* Initializes round timer, sets first letter, marks lobby as “in game”.

---

### 6. Game Page

**Route:** `/game/<code>`
**Methods:** `GET`, `POST`

**Purpose:**

* Show theme, timer, active letter, and input for word.
* Player submits word → validate.

**Data returned:**

* `theme`, `timer`, `current_letter`
* `previous_words` (with player names)
* `player_status` (ready, disconnected, etc.)
* `words_per_minute`, etc.

**Optional API endpoints for real-time updates:**

* `/api/game-state/<code>` → returns JSON of current state
* `/api/submit-word/<code>` → validate and update state

---

### 7. Spielende

**Route:** `/results/<code>`
**Methods:** `GET`

**Purpose:**

* Show end-of-game ranking
* Display achievements and summary
* Buttons: `[🏠 Hauptmenü]`, `[🔁 Neues Spiel]`

**Data returned:**

* `rankings = [{player, words}]`
* `achievements = {...}`
* `topic`

---

### 8. Einstellungen

**Route:** `/settings`
**Methods:** `GET`, `POST`

**Purpose:**

* Change UI preferences (font size, theme, nickname saved flag)

### 9. Anleitung

**Route:** `/manual`
**Methods:** `GET`

**Purpose:**

* Display short description of rules.

---

### 10. QR Code Scanner

**Route:** `/scan-qr`
**Methods:** `GET`

**Purpose:**

* Allow joining via camera and QR recognition → redirect to `/join-lobby/<code>`

---

## 🔄 Example Data Flow

| Page                   | Main Actions                | Next Page            |
| ---------------------- | --------------------------- | -------------------- |
| `/`                    | Host → create lobby         | `/host-lobby`        |
| `/host-lobby`          | Choose settings, start game | `/game/<code>`       |
| `/join-lobby/<code>`   | Wait for start              | `/game/<code>`       |
| `/game/<code>`         | Play game until time ends   | `/results/<code>`    |
| `/results/<code>`      | Back to start or replay     | `/` or `/host-lobby` |
| `/settings`, `/manual` | accessible anytime          | return to previous   |

---

## 🔧 Summary of All Endpoints

| Endpoint                  | Method   | Purpose                       |
| ------------------------- | -------- | ----------------------------- |
| `/`                       | GET      | Start page, show open lobbies |
| `/host-lobby`             | GET/POST | Create lobby                  |
| `/join-lobby/<code>`      | GET/POST | Join lobby                    |
| `/lobby/<code>`           | GET      | Show waiting players          |
| `/start-game/<code>`      | POST     | Start game                    |
| `/game/<code>`            | GET/POST | Play game                     |
| `/api/game-state/<code>`  | GET      | Fetch live game state         |
| `/api/submit-word/<code>` | POST     | Validate word                 |
| `/results/<code>`         | GET      | Show final results            |
| `/settings`               | GET/POST | Change settings               |
| `/manual`                 | GET      | Show rules                    |
| `/scan-qr`                | GET      | Scan to join                  |


## All endpoints with GET/POST values

Endpoint: **/**:
**GET**:
  1. List of the open Lobbys (json)
    1. hostName (string)
    2. lobbyID (int)
    3. subject (string)

---

Endpoint: **/host-lobby**
**GET**:
  1. createdLobbyID (int)
  2. icons/picture for the subjects(?) (Dont know what to use yet)
  3. subjectName (string)
  4. generatedQRCode (?) (backend has to tell me what is available for datatypes so i can determine what i can use.) (can use png with [pretty_qr_code](https://pub.dev/packages/pretty_qr_code))
  5. maxPlayers (int)
  6. maxGameLength (int) (for displaying purposes it should be int)

**Conditional GET**:
  1. PlayersConnected (json)
     1. username (string)
     2. readyPlayer (bool)

**POST**:
  1. chosenSubjectName (string)
  2. chosenGameLength (int)
  3. chosenMaxPlayer (int)

---

Endpoint: **/join-lobby/<code>**:
**GET**:
  1. chosenSubject (string)
  2. chosenMaxPlayer (int)

**POST**:
  1. username (string)
  2. ready (bool)

---

Endpoint: **/lobby/<code>**:
**GET**:
  1. PlayersConnected (json)
     1. username (string)
     2. readyPlayer (bool)

---

Endpoint: **/start-game/<code>**:
**POST**:
  1. startGame (bool)
  2. firstLetter (string)

---

Endpoint: **/game/<code>**:
**GET**:
  1. chosenSubject (string)
  2. timer (date)
  3. currentLetter (string)
  4. previousWords (json)
     1. wordUsed (string)
     2. username (string)
  5. playerStatus (string) (can only be: disconnected, selected, next, connected, suspend round)
  6. wordsPerMinute (double)
  7. usableWord (bool)

**POST**:
  1. wordInput (string)

**Optional POST**:
  1. playerStatus (string)

---

Endpoint: **/api/game-state/<code>**:
Has to be determined by backend

---

Endpoint: **/api/submit-word/<code>**:
Has to be determined by backend

---

Endpoint: **/results/<code>**:
  1. chosenSubject (string)
  2. ranks (json)
     1. username (string)
     2. points (int)
  3. achievements (json)
     1. longestWord (json)
        1. word (string)
        2. username (string)
     2. fastestAnswerUser (string)

---

Endpoint: **/settings**:
Will be done Later not important for now

---

Endpoint: **/manual**:
**GET**:
  1. manual (string)

---

Endpoint: **/scan-qr**:
Dont know how to implement yet