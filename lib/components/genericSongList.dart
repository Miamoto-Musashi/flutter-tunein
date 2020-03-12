import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



class GenericSongList extends StatelessWidget {

  List<int> bgColor;
  ScrollController controller;
  List<Tune> songs;
  List<ContextMenuOptions> contextMenuOptions;
  void Function(ContextMenuOptions,Tune) onContextOptionSelect;
  void Function(Tune) onSongCardTap;
  final musicService = locator<MusicService>();


  GenericSongList({this.bgColor, controller, this.songs, contextMenuOptions, this.onContextOptionSelect, this.onSongCardTap}){
    if(controller!=null){
      this.controller=controller;
    }else{
      this.controller= ScrollController();
    }
    if(contextMenuOptions!=null){
      this.contextMenuOptions= contextMenuOptions;
    }else{
      this.contextMenuOptions= songCardContextMenulist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: bgColor!=null?Color(bgColor[0]).withRed(30).withGreen(30).withBlue(30):MyTheme.darkBlack,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.all(0).add(EdgeInsets.only(
                        left:10
                    )),
                    controller: controller,
                    shrinkWrap: true,
                    itemExtent: 62,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<MapEntry<PlayerState, Tune>>(
                        stream: musicService.playerState$,
                        builder: (BuildContext context,
                            AsyncSnapshot<MapEntry<PlayerState, Tune>>
                            snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          int newIndex = index;
                          final PlayerState _state = snapshot.data.key;
                          final Tune _currentSong = snapshot.data.value;
                          final bool _isSelectedSong =
                              _currentSong == songs[newIndex];

                          return MyCard(
                            song: songs[newIndex],
                            choices: contextMenuOptions,
                            onContextSelect: (choice){
                              onContextOptionSelect!=null?onContextOptionSelect(choice,songs[newIndex]):null;
                            },
                            onContextCancel: (choice){
                              print("Cancelled");
                            },
                            onTap: (){
                              if(this.onSongCardTap!=null){
                                this.onSongCardTap(_currentSong);
                              }else{
                                musicService.updatePlaylist(songs);
                                switch (_state) {
                                  case PlayerState.playing:
                                    if (_isSelectedSong) {
                                      musicService.pauseMusic(_currentSong);
                                    } else {
                                      musicService.stopMusic();
                                      musicService.playMusic(
                                        songs[newIndex],
                                      );
                                    }
                                    break;
                                  case PlayerState.paused:
                                    if (_isSelectedSong) {
                                      musicService.playMusic(songs[newIndex]);
                                    } else {
                                      musicService.stopMusic();
                                      musicService.playMusic(
                                        songs[newIndex],
                                      );
                                    }
                                    break;
                                  case PlayerState.stopped:
                                    musicService.playMusic(songs[newIndex]);
                                    break;
                                  default:
                                    break;
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          MyScrollbar(
            controller: controller,
            color: bgColor!=null?Color(bgColor[0]).withRed(30).withGreen(30).withBlue(30):null,
          ),
        ],
      ),
    );
  }
}
