import 'dart:ffi';
import 'dart:io';

import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/albumSongList.dart';
import 'package:Tunein/components/cards/optionsCard.dart';
import 'package:Tunein/components/itemListDevider.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/components/selectableTile.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:upnp/upnp.dart' as upnp;

class SingleAlbumPage extends StatelessWidget {
  final Tune song;
  final Album album;
  final musicService = locator<MusicService>();
  final castService = locator<CastService>();
  final themeService = locator<ThemeService>();



  SingleAlbumPage(song,{album}):
        this.song=song,
        this.album=album,
        assert((song!=null && album==null) || (song==null && album !=null) || (song==null && album==null));

  @override
  Widget build(BuildContext context){
    Size screenSize = MediaQuery.of(context).size;
    if(album!=null){
      bool songsFound = album.songs.length!=0;
      return new Container(
        child: Column(
          children: <Widget>[
            Material(
              child: StreamBuilder(
                stream:  themeService.getThemeColors(songsFound?album.songs[0]:null).asStream(),
                builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot){
                  List<int> bgColor;
                  if(!snapshot.hasData || snapshot.data.length==0){
                    return Container(

                      child: new Container(
                        margin: EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: FadeInImage(
                                  placeholder: AssetImage('images/track.png'),
                                  fadeInDuration: Duration(milliseconds: 200),
                                  fadeOutDuration: Duration(milliseconds: 100),
                                  image: album.albumArt != null
                                      ? FileImage(
                                    new File(album.albumArt),
                                  )
                                      : AssetImage('images/track.png'),
                                ),
                              ),
                              flex: 4,
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8))
                                    .add(EdgeInsets.only(top: 10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        (album.title == null)
                                            ? "Unknon Title"
                                            : album.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      (album.artist == null)
                                          ? "Unknown Artist"
                                          : album.artist,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      margin: EdgeInsets.all(5)
                                          .add(EdgeInsets.only(top: 2)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: Text(
                                              album.songs.length.toString(),
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.audiotrack,
                                            color: Colors.white70,
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      margin: EdgeInsets.all(5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              "${Duration(milliseconds: sumDurationsofAlbum(album).floor()).inMinutes} min",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            margin: EdgeInsets.only(right: 5),
                                          ),
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.white70,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.topCenter,
                              ),
                            )
                          ],
                        ),
                        height: 200,
                      ),
                      color: bgColor!=null?Color(bgColor[0]):MyTheme.bgBottomBar,
                    );
                  }

                  bgColor=snapshot.data;

                  return Container(
                    child: new Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: FadeInImage(
                                placeholder: AssetImage('images/track.png'),
                                fadeInDuration: Duration(milliseconds: 200),
                                fadeOutDuration: Duration(milliseconds: 100),
                                image: album.albumArt != null
                                    ? FileImage(
                                  new File(album.albumArt),
                                )
                                    : AssetImage('images/track.png'),
                              ),
                            ),
                            flex: 4,
                          ),
                          Expanded(
                            flex: 7,
                            child: Container(
                              margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8))
                                  .add(EdgeInsets.only(top: 10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      (album.title == null)
                                          ? "Unknon Title"
                                          : album.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.w700,
                                        color: bgColor!=null?Color(bgColor[2]).withAlpha(200):Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    (album.artist == null)
                                        ? "Unknown Artist"
                                        : album.artist,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w400,
                                      color: bgColor!=null?Color(bgColor[2]):Colors.white,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    margin: EdgeInsets.all(5)
                                        .add(EdgeInsets.only(top: 2)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 5),
                                          child: Text(
                                            album.songs.length.toString(),
                                            style: TextStyle(
                                              color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.audiotrack,
                                          color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    margin: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            "${Duration(milliseconds: sumDurationsofAlbum(album).floor()).inMinutes} min",
                                            style: TextStyle(
                                              color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          margin: EdgeInsets.only(right: 5),
                                        ),
                                        Icon(
                                          Icons.access_time,
                                          color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(10),
                              alignment: Alignment.topCenter,
                            ),
                          )
                        ],
                      ),
                    ),
                    height: 200,
                    color: bgColor!=null?Color(bgColor[0]):MyTheme.bgBottomBar,
                  );
                },
              ),
              elevation: 12.0,
            ),
            songsFound?Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height-200-60,
                child: CustomScrollView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  slivers: <Widget>[
                    SliverAppBar(
                      elevation: 0,
                      expandedHeight: 131,
                      backgroundColor: MyTheme.bgBottomBar,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: <Widget>[
                            ItemListDevider(DeviderTitle: "More choices"),
                            Container(
                              color:MyTheme.bgBottomBar,
                              height: 120,
                              child: ListView.builder(
                                itemExtent: 180,
                                itemCount: 1,
                                cacheExtent:MediaQuery.of(context).size.width ,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: false,

                                scrollDirection: Axis.horizontal,

                                itemBuilder: (context, index){
                                  return MoreOptionsCard(
                                    imageUri: album.albumArt,
                                    colors: album.songs[0].colors,
                                    bottomTitle: "Most Played",
                                    onPlayPressed: (){
                                      musicService.playMostPlayedOfAlbum(album);
                                    },
                                    onSavePressed: () async{
                                      Playlist newPlaylsit = Playlist(
                                          "Most played of ${album.title}",
                                          musicService.getMostPlayedOfAlbum(album),
                                          PlayerState.stopped,
                                          null
                                      );
                                      /// This is a temporary way fo handling until we incorporate the name changing in playlists
                                      /// The better way is that the passed playlist gets modified inside the dialog return function and then is returned
                                      /// instead of the listofSongsToBeDeleted TODO
                                      List<Tune> songsToBeDeleted = await openEditPlaylistBeforeSaving(context, newPlaylsit);
                                      if(songsToBeDeleted!=null){
                                        if(songsToBeDeleted.length!=0){
                                          List<String> idList = songsToBeDeleted.map((elem)=>elem.id);
                                          newPlaylsit.songs.removeWhere((elem){
                                            return idList.contains(elem.id);
                                          });
                                          musicService.addPlaylist(newPlaylsit).then(
                                                  (data){
                                                DialogService.showToast(context,
                                                    backgroundColor: MyTheme.darkBlack,
                                                    color: MyTheme.darkRed,
                                                    message: "Playlist : ${"Most played of ${newPlaylsit.name}"} has been saved"
                                                );
                                              }
                                          );
                                        }else{
                                          DialogService.showToast(context,
                                              backgroundColor: MyTheme.darkBlack,
                                              color: MyTheme.darkRed,
                                              message: "Chosen playlist is Empty"
                                          );
                                        }

                                      }else{
                                        print("NO SONGS FOUND");
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      stretch: true,
                      stretchTriggerOffset: 100,
                      floating: true,
                    ),
                    SliverPersistentHeader(
                      delegate: DynamicSliverHeaderDelegate(
                        child: Material(
                          child: ItemListDevider(DeviderTitle: "Tracks"),
                          color: Colors.transparent,
                        ),
                        minHeight: 35,
                        maxHeight: 35
                      ),
                      pinned: true,
                    ),
                    SliverFixedExtentList(
                      itemExtent: 62,
                      delegate: SliverChildBuilderDelegate((context, index){
                        if (index == 0) {
                          return Material(
                            child: PageHeader(
                              "Suffle",
                              "All Tracks",
                              MapEntry(
                                  IconData(Icons.shuffle.codePoint,
                                      fontFamily: Icons.shuffle.fontFamily),
                                  Colors.white),
                            ),
                            color: Colors.transparent,
                          );
                        }

                        int newIndex = index - 1;
                        return MyCard(
                          song: album.songs[newIndex],
                          choices: songCardContextMenulist,
                          ScreenSize: screenSize,
                          StaticContextMenuFromBottom: 0.0,
                          onContextSelect: (choice) async{
                            switch(choice.id){
                              case 1: {
                                musicService.playOne(album.songs[newIndex]);
                                break;
                              }
                              case 2:{
                                musicService.startWithAndShuffleQueue(album.songs[newIndex], album.songs);
                                break;
                              }
                              case 3:{
                                musicService.startWithAndShuffleAlbum(album.songs[newIndex]);
                                break;
                              }
                              case 4:{
                                musicService.playAlbum(album.songs[newIndex]);
                                break;
                              }
                              case 5:{
                                if(castService.currentDeviceToBeUsed.value==null){
                                  upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                  if(result!=null){
                                    castService.setDeviceToBeUsed(result);
                                  }
                                }
                                musicService.castOrPlay(album.songs[newIndex], SingleCast: true);
                                break;
                              }
                              case 6:{
                                upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                if(result!=null){
                                  musicService.castOrPlay(album.songs[newIndex], SingleCast: true, device: result);
                                }
                                break;
                              }

                            }
                          },
                          onContextCancel: (choice){
                            print("Cancelled");
                          },
                          onTap: (){
                            musicService.updatePlaylist(album.songs);
                            musicService.playOrPause(album.songs[newIndex]);
                          },
                        );
                      },
                          childCount: album.songs.length+1
                      ),
                    )
                    /*AlbumSongList(album)*/
                  ],
                ),
              ),

            ):Container(
              color: MyTheme.darkgrey,
            )
          ],
        ),
      );

    }else
    return StreamBuilder(
      stream: musicService.fetchAlbum(artist: song.artist, title: song.album),
      builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.data.length == 0) {
          return new Container();
        }
        Album album = snapshot.data[0];

        return new Container(
          child: Column(
            children: <Widget>[
              Material(
                child: StreamBuilder(
                  stream:  themeService.getThemeColors(song).asStream(),
                  builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot){
                    List<int> bgColor;
                    if(!snapshot.hasData || snapshot.data.length==0){
                      return Container(

                        child: new Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: FadeInImage(
                                    placeholder: AssetImage('images/track.png'),
                                    fadeInDuration: Duration(milliseconds: 200),
                                    fadeOutDuration: Duration(milliseconds: 100),
                                    image: album.albumArt != null
                                        ? FileImage(
                                      new File(album.albumArt),
                                    )
                                        : AssetImage('images/track.png'),
                                  ),
                                ),
                                flex: 4,
                              ),
                              Expanded(
                                flex: 7,
                                child: Container(
                                  margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8))
                                      .add(EdgeInsets.only(top: 10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          (album.title == null)
                                              ? "Unknon Title"
                                              : album.title,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 17.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        (album.artist == null)
                                            ? "Unknown Artist"
                                            : album.artist,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        margin: EdgeInsets.all(5)
                                            .add(EdgeInsets.only(top: 2)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: Text(
                                                album.songs.length.toString(),
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.audiotrack,
                                              color: Colors.white70,
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        margin: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                "${Duration(milliseconds: sumDurationsofAlbum(album).floor()).inMinutes} min",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              margin: EdgeInsets.only(right: 5),
                                            ),
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.white70,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.topCenter,
                                ),
                              )
                            ],
                          ),
                          height: 200,
                        ),
                        color: bgColor!=null?Color(bgColor[0]):MyTheme.bgBottomBar,
                      );
                    }

                    bgColor=snapshot.data;

                    return Container(
                      child: new Container(
                        margin: EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: FadeInImage(
                                  placeholder: AssetImage('images/track.png'),
                                  fadeInDuration: Duration(milliseconds: 200),
                                  fadeOutDuration: Duration(milliseconds: 100),
                                  image: album.albumArt != null
                                      ? FileImage(
                                    new File(album.albumArt),
                                  )
                                      : AssetImage('images/track.png'),
                                ),
                              ),
                              flex: 4,
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8))
                                    .add(EdgeInsets.only(top: 10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        (album.title == null)
                                            ? "Unknon Title"
                                            : album.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.w700,
                                          color: bgColor!=null?Color(bgColor[2]).withAlpha(200):Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      (album.artist == null)
                                          ? "Unknown Artist"
                                          : album.artist,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w400,
                                        color: bgColor!=null?Color(bgColor[2]):Colors.white,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      margin: EdgeInsets.all(5)
                                          .add(EdgeInsets.only(top: 2)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: Text(
                                              album.songs.length.toString(),
                                              style: TextStyle(
                                                color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.audiotrack,
                                            color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      margin: EdgeInsets.all(5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              "${Duration(milliseconds: sumDurationsofAlbum(album).floor()).inMinutes} min",
                                              style: TextStyle(
                                                color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            margin: EdgeInsets.only(right: 5),
                                          ),
                                          Icon(
                                            Icons.access_time,
                                            color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.topCenter,
                              ),
                            )
                          ],
                        ),
                      ),
                      height: 200,
                      color: bgColor!=null?Color(bgColor[0]):MyTheme.bgBottomBar,
                    );
                  },
                ),
                elevation: 12.0,
              ),
              Flexible(
                child: Container(
                  color: MyTheme.darkBlack,
                  child: CustomScrollView(
                    scrollDirection: Axis.vertical,
                    slivers: <Widget>[
                      SliverAppBar(
                        elevation: 0,
                        expandedHeight: 131,
                        backgroundColor: MyTheme.bgBottomBar,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            children: <Widget>[
                              ItemListDevider(DeviderTitle: "More choices"),
                              Container(
                                color:MyTheme.bgBottomBar,
                                height: 120,
                                child: ListView.builder(
                                  itemExtent: 180,
                                  itemCount: 1,
                                  cacheExtent:MediaQuery.of(context).size.width ,
                                  addAutomaticKeepAlives: true,
                                  shrinkWrap: false,

                                  scrollDirection: Axis.horizontal,

                                  itemBuilder: (context, index){
                                    return MoreOptionsCard(
                                      imageUri: album.albumArt,
                                      colors: album.songs[0].colors,
                                      bottomTitle: "Most Played",
                                      onPlayPressed: (){
                                        musicService.playMostPlayedOfAlbum(album);
                                      },
                                      onSavePressed: () async{
                                        Playlist newPlaylsit = Playlist(
                                            "Most played of ${album.title}",
                                            musicService.getMostPlayedOfAlbum(album),
                                            PlayerState.stopped,
                                            null
                                        );
                                        /// This is a temporary way fo handling until we incorporate the name changing in playlists
                                        /// The better way is that the passed playlist gets modified inside the dialog return function and then is returned
                                        /// instead of the listofSongsToBeDeleted TODO
                                        List<Tune> songsToBeDeleted = await openEditPlaylistBeforeSaving(context, newPlaylsit);
                                        if(songsToBeDeleted!=null){
                                          if(songsToBeDeleted.length!=0){
                                            List<String> idList = songsToBeDeleted.map((elem)=>elem.id);
                                            newPlaylsit.songs.removeWhere((elem){
                                              return idList.contains(elem.id);
                                            });
                                            musicService.addPlaylist(newPlaylsit).then(
                                                    (data){
                                                  DialogService.showToast(context,
                                                      backgroundColor: MyTheme.darkBlack,
                                                      color: MyTheme.darkRed,
                                                      message: "Playlist : ${"Most played of ${newPlaylsit.name}"} has been saved"
                                                  );
                                                }
                                            );
                                          }else{
                                            DialogService.showToast(context,
                                                backgroundColor: MyTheme.darkBlack,
                                                color: MyTheme.darkRed,
                                                message: "Chosen playlist is Empty"
                                            );
                                          }

                                        }else{
                                          print("NO SONGS FOUND");
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        automaticallyImplyLeading: false,
                        stretch: true,
                        stretchTriggerOffset: 166,
                        floating: true,
                      ),
                      SliverPersistentHeader(
                        delegate: DynamicSliverHeaderDelegate(
                            child: Material(
                              child: ItemListDevider(DeviderTitle: "Tracks"),
                              color: Colors.transparent,
                            ),
                            minHeight: 35,
                            maxHeight: 35
                        ),
                        pinned: true,
                      ),
                      SliverFixedExtentList(
                        itemExtent: 62,
                        delegate: SliverChildBuilderDelegate((context, index){
                          if (index == 0) {
                            return Material(
                              child: PageHeader(
                                "Suffle",
                                "All Tracks",
                                MapEntry(
                                    IconData(Icons.shuffle.codePoint,
                                        fontFamily: Icons.shuffle.fontFamily),
                                    Colors.white),
                              ),
                              color: Colors.transparent,
                            );
                          }

                          int newIndex = index - 1;
                          return MyCard(
                            song: album.songs[newIndex],
                            choices: songCardContextMenulist,
                            ScreenSize: screenSize,
                            StaticContextMenuFromBottom: 0.0,
                            onContextSelect: (choice) async{
                              switch(choice.id){
                                case 1: {
                                  musicService.playOne(album.songs[newIndex]);
                                  break;
                                }
                                case 2:{
                                  musicService.startWithAndShuffleQueue(album.songs[newIndex], album.songs);
                                  break;
                                }
                                case 3:{
                                  musicService.startWithAndShuffleAlbum(album.songs[newIndex]);
                                  break;
                                }
                                case 4:{
                                  musicService.playAlbum(album.songs[newIndex]);
                                  break;
                                }
                                case 5:{
                                  if(castService.currentDeviceToBeUsed.value==null){
                                    upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                    if(result!=null){
                                      castService.setDeviceToBeUsed(result);
                                    }
                                  }
                                  musicService.castOrPlay(album.songs[newIndex], SingleCast: true);
                                  break;
                                }
                                case 6:{
                                  upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                  if(result!=null){
                                    musicService.castOrPlay(album.songs[newIndex], SingleCast: true, device: result);
                                  }
                                  break;
                                }
                              }
                            },
                            onContextCancel: (choice){
                              print("Cancelled");
                            },
                            onTap: (){
                              musicService.updatePlaylist(album.songs);
                              musicService.playOrPause(album.songs[newIndex]);
                            },
                          );
                        },
                          childCount: album.songs.length+1
                        ),
                      )
                    ],
                  ),
                ),

              )
            ],
          ),
        );
      },
    );
  }

  double sumDurationsofAlbum(Album album) {
    return ConversionUtils.songListToDuration(album.songs);
  }

  Future<List<Tune>> openEditPlaylistBeforeSaving(context,Playlist playlist) async{
    String keyword="";
    List<Tune> songsToBeDeleted=[];
    List<Artist> selectedArtists=List<Artist>();
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Editing Playlist${playlist!=null?" : "+playlist.name:""}",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Container(
              height: MediaQuery.of(context).size.height/2.5,
              width: MediaQuery.of(context).size.width/1.2,
              child: GridView.builder(
                padding: EdgeInsets.all(3),
                itemBuilder: (context, index){
                  Tune songs = playlist.songs[index];
                  return SelectableTile(
                    imageUri: songs.albumArt,
                    title: songs.title,
                    isSelected: true,
                    selectedBackgroundColor: MyTheme.darkRed,
                    onTap: (willItBeSelected){
                      print("Selected ${songs.title}");
                      if(willItBeSelected){
                        songsToBeDeleted.add(songs);
                      }else{
                        songsToBeDeleted.removeAt(songsToBeDeleted.indexWhere((elem)=>elem.title==songs.title));
                      }
                    },
                    placeHolderAssetUri: "images/track.png",
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                  childAspectRatio: 3,
                ),
                semanticChildCount: playlist.songs.length,
                cacheExtent: 120,
                itemCount: playlist.songs.length,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Save Playlist",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(songsToBeDeleted);
                },
              ),
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop())
            ],
          );
        });
  }


}

