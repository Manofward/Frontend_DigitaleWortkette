# User stories von dem Frontend:

## Anforderungen:
1. Themen: Tiere, Begriffe aus meinem Beruf, Pflanzen, berühmte Personen, Weltall, Rundfunk und Lichtspielhäuser, Städte, Länder
2. Folgender Begriff mit dem Endbuchstaben des Vorgängerbegriffs beginnen muss, z.B. beim Thema Tiere: Hase, Elefant, Tiger, Reh, Habicht, T...
3. Eingabe von Begriffen 
4. Ausgabe der schon genutzen Begriffen
5. Nicht möglich einen schon genutzten Begriff nochmal einzugeben
6. neue Begriffe sollen einer Liste Hinzugefügt werden (vieleicht per Datenbank. Wurde noch nicht besprochen)
7. keine personenbezogenen Daten dauerhaft auf einem Server speichern
 

## Dev user Stories:

### Auserhalb des Spiels:
- Der Nutzer möchte eine Spielanleitung haben für eine Erklärung der Spielregeln
- [Man möchte einen Spiel zu einem Thema hosten können. (z.B.: Tiere, Städte, Pflanzen)](#erstellung-der-lobby)
- Man möchte einem gehosteten Spiel beitreten können
- Als Spieler möchte ich möglichst wenig lesen müssen und die App vorwiegend durch Piktogramme bedienen können.

#### Optionale User Stories
- Man möchte Einstellungen für Textgröße haben
- Man möchte als Nutzer eine Liste haben der schon gehosteten Spiele die noch nicht gestartet sind.(z.B.: Lobby Nummer | Spieleranzahl | Thema)
- Als Spieler möchte ich meinen Nickname in der App speichern können, damit ich ihn nicht jedes Mal erneut eingeben muss.

### Erstellung der Lobby:
- Man möchte als Hoster die Daten für die Mitspieler bekommen.(z.B.: Nummer die Mitspieler eingeben müssen um Beizutreten)
- Als Host möchte ich das Thema Einstellen können.
- Man möchte als Host die Spiellänge einstellen können.
- Als Host möchte ich das Spiel starten können.
- Als Host möchte ich das Spiel manuell beenden können.
- Als Spieler möchte ich live informiert werden, wenn der Host die Konfiguration des Spiels vor dem Start ändert.
- Als Host möchte ich einen QR-Code erzeugen mit einem Link, über den ich einem Spiel beitreten kann.
- Als Host möchte ich eine maximale Spieleranzahl einstellen.

#### Optionale User Stories 
- Als Host möchte ich die Anzahl der Spieler sehen und Namen

### Innerhalb des Spiels:
- Man möchte Begriffe Eingeben können in eine Liste.
- Diese eingegebenen Begriffe werden in einer Liste unter der Eingabe Ausgegeben
- Man möchte als Nutzer beim Eingeben eines Begriffes gezeigt bekommen, ob der Begriff erlaubt ist.(z.B.: Begriff wurde schon verwendet, begriff fängt nicht mit dem benötigten anfangsbuchstaben an, ...)
- Man möchte als Nutzer einen timer haben für die allgemeine Spiellänge.
- Als Spieler möchte ich das Spiel manuell verlassen können.
- Als Spieler möchte ich eine Runde aussetzen können, wenn mir kein passender Begriff einfällt.
- Als Spieler möchte ich sehen können, wer welchen Begriff gewählt hat.
- Als Spieler möchte ich während des Spiels die durchschnittliche Spielgeschwindigkeit sehen (z. B. 3,7 Wörter pro Minute).
- Als Spieler möchte ich alle bisher eingegebenen Begriffe sehen können.
- Als Host möchte ich eine Abstimmung darüber starten können, ob das Spiel vorzeitig beendet werden soll.

#### Optionale User Stories
- Man möchte als Nutzer einen timer haben für die Zeit ein Spieler hat einen Begriff zu nennen.
- Man möchte Als Nutzer bei Ablauf des allgemeinen Timers eine highscore Liste haben. (wieviele Begriffe hat ein Spieler zu dem Thema gebracht in diesem Spiel)
- Als Host möchte ich Spieler aus einem laufenden Spiel entfernen können (z. B. bei Fehlverhalten oder technischen Problemen).

### Nach dem Spiel
- Nach dem Spiel will man als Nutzer auf die Haupseite weitergeleitet werden.
- Als Spieler möchte ich am Ende des Spiels eine Übersicht sehen, wer welche "Achievements" gewonnen hat (z. B. längstes Wort, kürzestes Wort, schnellste Antwort, ...)

#### Optionale User Stories
- Als Nutzer möchte ich mir einen Verlauf der Spiele anschauen können.
- Als Nutzer möchte ich gerne nach dem Spiel ein neues Spiel mit anderem Thema starten können
