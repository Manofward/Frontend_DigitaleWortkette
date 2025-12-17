# TODOs:
1. The Title: "Digitale Wortkette" and "offene Spiele" have to be edited so that maybe the big title is similar to the other
2. linkings to the settings page and qr-Code scanner have to be made and the pages itself too
3. automatic update has to be added everywhere
4. need to add that when i go from host-lobby/join-lobby or any other page that polls data that it stops when leaving the corresponding page
5. **AGBs** need to be added [Datenschutzerklärungsbeispiele]()
   1. the DSGVO site should be made before you can go on the homepage of the app in the main.dart file

# Playthings needed for main programm:
1. When you want to leave the lobby as a player or close the lobby as a host a post is made for leaving the lobby
   1. so that the lobby is deleted(host)
      1. when you go from host-lobby page back to homepage through the back or home button the lobby needs to be deleted *(partly added)*
   2. so that the player is deleted from the player list (player)
      1. feature for leaving lobby needs to be added that when you leave the lobby as a player your username is deleted from the playerlist of the lobby *(partly added)*
   3. in the lobby, that you can only start the lobby when all players are ready needs to be added. **Before starting with the main game!!!**

# Important:
1. use Multithreading for the GET/POST and the posts
2. handling permissions for phone so its possible to make a release build which can use the permissions


# For the usernames to solve the bugs we have and to make it more efficient the backend needs to add a new object in which hostids will be saved so that it can be determined who is the Host and can close the lobby and non hosts can only leave the lobby.
1. userids in generell are needed in the backend and then the endpoints need to be updated to get the ids
2. all sites need to be changed to use the userids and the hostids.