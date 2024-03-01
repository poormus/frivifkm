import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/poll.dart';
import '../../services/poll_services.dart';
import '../../shared/my_provider.dart';
import '../../shared/utils.dart';

class ViewPollScreen extends StatefulWidget {
  final Poll poll;
  final CurrentUserData currentUserData;
  final String pollId;

  const ViewPollScreen(
      {Key? key, required this.currentUserData, required this.pollId, required this.poll})
      : super(key: key);

  @override
  State<ViewPollScreen> createState() => _ViewPollScreenState();
}

class _ViewPollScreenState extends State<ViewPollScreen> {
  late MyProvider provider;
  late PollServices pollServices;
  late Stream<Poll> getPoll;
  late bool isVoted;


  @override
  void initState() {
    pollServices = PollServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    pollServices.init();
    provider = Provider.of<MyProvider>(context, listen: false);
    getPoll = pollServices.getSinglePoll(widget.pollId);
    isVoted=widget.poll.expiresAt.isBefore(DateTime.now())?true:isVotedOrNot(widget.poll);
    if(!widget.poll.seenBy.contains(widget.currentUserData.uid)){
      pollServices.updateSeenBy(widget.poll,widget.currentUserData.uid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Vote'.tr(), body: buildBody(size), shouldScroll: false);
  }

  Widget buildBody(Size size) {
    return StreamBuilder<Poll>(
        stream: getPoll,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final poll = snapshot.data!;
            return buildPollDetail(poll, size);
          } else
            return Center(child: CircularProgressIndicator());
        });
  }

  Widget buildPollDetail(Poll poll, Size size) {
    if (!isVoted) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(6),
                height: 60,
                child: Text(poll.pollQuestion,
                    style: appTextStyle.copyWith(fontSize: 20))),
            Expanded(
              child: ListView.builder(
                  itemCount: poll.pollItems.length,
                  itemBuilder: (_, index) {
                    return buildPoolItem(size, poll, index);
                  }),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(6),
                height: 60,
                child: Text(poll.pollQuestion,
                    style: appTextStyle.copyWith(fontSize: 20))),
            Expanded(
              child: ListView.builder(
                  itemCount: poll.pollItems.length,
                  itemBuilder: (_, index) {
                    return buildPollItemAfterVote(size, poll, index);
                  }),
            )
          ],
        ),
      );
    }
  }

  List<CurrentUserData> getUsersForPollVote(MyProvider provider, List<String> uids) {
    List<CurrentUserData> pollVotedUsers = [];
    provider
        .getCurrentOrganizationUserList(widget.currentUserData.currentOrganizationId)
        .forEach((element) {
      if (uids.contains(element.uid)) {
        pollVotedUsers.add(element);
      }
    });

    return pollVotedUsers;
  }



  Widget buildPollItemAfterVote(Size size, Poll poll, int index){
    final userList=getUsersForPollVote(provider, poll.pollItems[index].answeredUserId);
    return InkWell(
      onTap: (){
         if(widget.poll.expiresAt.isBefore(DateTime.now())){
           Utils.showToastWithoutContext('Poll expired'.tr());
           return;
         }
         int myVoteIndex=0;
         for(var i=0; i<poll.pollItems.length; i++){
           if(poll.pollItems[i].answeredUserId.contains(widget.currentUserData.uid)){
             myVoteIndex=i;
             break;
           }
         }
         if(myVoteIndex==index){
           Utils.showToastWithoutContext('Already voted this'.tr());
           return;
         }

         poll.pollItems[myVoteIndex].answeredUserId.remove(widget.currentUserData.uid);

         // if(poll.pollItems[index].answeredUserId.contains(widget.currentUserData.uid)){
         //   final uidList=poll.pollItems[index].answeredUserId;
         //   uidList.remove(widget.currentUserData.uid);
         //   final item=poll.pollItems[index].item;
         //   final newPollItem=PollItem(item: item, answeredUserId: uidList);
         //   poll.pollItems[index]=newPollItem;
         //   pollServices.updatePollForVote(poll.pollId, poll.pollItems);
         //   setState(() {
         //     isVoted=false;
         //   });
         //   return;
         // }else{
         //   if(isVoted){
         //     Utils.showToastWithoutContext('You have voted already');
         //     return;
         //   }
           final uidList=poll.pollItems[index].answeredUserId;
           uidList.add(widget.currentUserData.uid);
           final item=poll.pollItems[index].item;
           final newPollItem=PollItem(item: item, answeredUserId: uidList);
           poll.pollItems[index]=newPollItem;
           pollServices.updatePollForVote(poll.pollId, poll.pollItems);
         //}

      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Container(
                width: size.width * 0.8,
                height: 40,
                decoration: BoxDecoration(
                    color: poll.pollItems[index].answeredUserId.contains(widget.currentUserData.uid)?Constants.BACKGROUND_COLOR:null,
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(poll.pollItems[index].item)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  width: size.width*0.8,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userList.length,
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: 30,
                              height: 50,
                              imageUrl: userList[index].userUrl,
                              placeholder: (context, url) =>
                              new LinearProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                            ),
                          ),
                        );
                      }),
                ),
                Text(poll.pollItems[index].answeredUserId.length.toString())
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget buildPoolItem(Size size, Poll poll, int index) {
    return InkWell(
      onTap: (){
        final uidList=poll.pollItems[index].answeredUserId;
        uidList.add(widget.currentUserData.uid);
        final item=poll.pollItems[index].item;
        final newPollItem=PollItem(item: item, answeredUserId: uidList);
        poll.pollItems[index]=newPollItem;
        pollServices.updatePollForVote(poll.pollId, poll.pollItems);
        setState(() {
          isVoted=true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            width: size.width * 0.8,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(poll.pollItems[index].item)),
          ),
        ),
      ),
    );
  }





  bool isVotedOrNot(Poll poll) {
    bool isVoted = false;
    poll.pollItems.forEach((element) {
      if (element.answeredUserId.contains(widget.currentUserData.uid)) {
        isVoted = true;
      }
    });
    return isVoted;
  }
}
