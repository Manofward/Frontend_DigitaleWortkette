# TODOs:
1. The Title: "Digitale Wortkette" and "offene Spiele" have to be edited so that maybe the big title is similar to the other
2. linkings to the settings page and qr-Code scanner have to be made and the pages itself too
3. automatic update has to be added everywhere
4. need to add that when i go from host-lobby/join-lobby or any other page that polls data that it stops when leaving the corresponding page
5. **AGBs** need to be added [Datenschutzerklärungsbeispiele]()
   1. the DSGVO site should be made before you can go on the homepage of the app in the main.dart file

# Playthings needed for main programm:
1. in the lobby, that you can only start the lobby when all players are ready needs to be added. **Before starting with the main game!!!**
2. Game Screen:
   1. In the Game Screen the max time will be counted from the host which will end the game then.
   2. in the Game Screen the word list will have the user_id so that the player list can be used to show the username of the one who said the word.
   3. In the Game Screen the player list will be scrambled and then given out as the list which player is the next one in the list.
   4. For the Game Screen when the host starts the game he sends a post to the backend for starting the game and the backend sends it to the other players per post. (if possible)
   5. For the Game Screen a player should only be able to input a word into the backend, when he is in the list for the player who is the next one to input.
   6. When the player inputs a word that already exists or has not the right letter in the beginning the backend will give back a message which should be shown on the screen.

   7. When the Player who inputs a word posts something the backend makes a variable for update for all and on the next poll form the players flask gives back when the update all is true all the updated things