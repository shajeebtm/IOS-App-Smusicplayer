# Smusicplayer
A music player for IOS devices which can record history of last played tracks in every catgory and groups.

<p align="center">
  <img src="Images/S_MusicPlayer_icon_3x.png">
</p>

#### The motive behind this IOS music player app

I do have lots of songs in my  collection , consisting of hundreds of singers, composers, playlists and lyricists. There are hundreds of songs in each of the categories  & groups  (say playlist or singer) . I do have the habit of playing songs from one group (say playlist names “malayalam-2000” ) , stop playing that playlist after listening to a few songs and  switch to another group (say playlist names “malayalam-1990”).  Later I would like to stop playing playlist “malayalam-1990” and go back to playlist “malayalam-2000” . The problem I face during this return activity is that either I have to start playing from the first song in the playlist “malayalam-2000” or I have to remember where I left previously on the playlist “malayalam-2000”.

This made me think of developing a music player which can record the last item played in each category  & group. 

**Main features of “S music player” are**

- A database is maintained for storing the last played item . An entry is  created for every grouping in each category (Playlists,  Composer , Lyricist , Singer)
- History  data is browsable , can resume any item  and can delete any item from history.
- S music player takes advantage of ‘system music player’ . It provides features like play in Lock Screen, queue management etc. 
- After unlocking the screen, S music player will continue to play (if S music player was the last app in use before screen got locked) , history information also gets updated with the current running track information.
- All grouping information is pulled from the system music library, hence no additional work needed for maintaining grouping.
- Upon restarting , the app  automatically loads the last played song, ready to start from there.
- Works with a manually managed library or Apple music managed library.

<br/>
<br/>

### Screenshots - Main
<p align="center">
  <img src="Images/Launch and now playing.png">
</p>
 
<br/>
<br/>

### Screenshots - Choose category
<p align="center">
  <TABLE border=3>
    <TR>
       <TD>
        <img src="Images/select playlist screen_1.png" width="288">
      </TD>
      <TD>
        Select singer screen 
      </TD>
      <TD>
        Select composer screen 
      </TD>
    </TR>
    <TR>
      <TD border=3>
         <img src="Images/Select Playlist.PNG" height="626" width="288">
      </TD>
      <TD>
        <img src="Images/Select Singer.PNG" height="626" width="288">
      </TD>
      <TD>
        <img src="Images/Select Composer.PNG" height="626" width="288">
      </TD>
    </TR>
 
  </TABLE>
</p>

<p align="center">
</p>

<br/>
<br/>

### Screenshots - History management
<p align="center">
  <TABLE border=3>
    <TR>
       <TD>
        View history screen
      </TD>
      <TD>
        Delete history screen
      </TD>
      <TD>
        Select song from category screen 
      </TD>
    </TR>
    <TR>
      <TD border=3>
         <img src="Images/Manage History.PNG" height="626" width="288">
      </TD>
      <TD>
        <img src="Images/Manage History - Delete.PNG" height="626" width="288">
      </TD>
      <TD>
        <img src="Images/Select Song from Category.PNG" height="626" width="288">
      </TD>
    </TR>
 
  </TABLE>
</p>
  
<br/>
<br/>
  
### Details of View controllers , Database model and the program flow
<p align="center">
  <img src="Images/S music player - flow.png">
</p>
  
