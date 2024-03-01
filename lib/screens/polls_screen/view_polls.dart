import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/cutom_circular.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/dialog/select_channel.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/poll.dart';
import 'package:firebase_calendar/screens/polls_screen/add_new_pool.dart';
import 'package:firebase_calendar/screens/polls_screen/view_poll_screen.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../anim/slide_in_right.dart';
import '../../services/poll_services.dart';
import '../../shared/constants.dart';

class ViewPollsScreen extends StatefulWidget {
  final String userRole;
  final CurrentUserData currentUserData;

  const ViewPollsScreen(
      {Key? key, required this.userRole, required this.currentUserData})
      : super(key: key);

  @override
  State<ViewPollsScreen> createState() => _ViewPollsScreenState();
}

class _ViewPollsScreenState extends State<ViewPollsScreen> {
  late MyProvider provider;
  late PollServices pollServices;

  @override
  void initState() {
    provider = Provider.of<MyProvider>(context, listen: false);
    pollServices = PollServices(
        organizationId: widget.currentUserData.currentOrganizationId);
    pollServices.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    return BaseScaffold(
      appBarName: 'Polls'.tr(),
      body: buildBody(provider),
      shouldScroll: false,
      floatingActionButton: buildFab(context),
    );
  }

  List<Poll> getMyPolls(List<Poll> polls) {
    List<Poll> myPolls = [];
    if (widget.userRole == '4' || widget.userRole == '3') {
      myPolls = polls;
    } else {
      polls.forEach((element) {
        bool isToMe = false;
        if (widget.currentUserData.groupIds
                    .toSet()
                    .intersection(element.toWHo.toSet())
                    .length !=
                0 ||
            element.toWHo.contains(widget.userRole)) {
          isToMe = true;
        }
        if (isToMe) {
          myPolls.add(element);
        }
      });
    }
    return myPolls;
  }

  Widget buildBody(MyProvider provider) => StreamBuilder<List<Poll>>(
      stream: pollServices.getPolls(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = getMyPolls(snapshot.data!);
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final pool = data[index];
                final createdBy = provider.getUserById(pool.createdById);
                int totalVotes = 0;
                data[index].pollItems.forEach((element) {
                  totalVotes += element.answeredUserId.length;
                });
                return buildPollTile(
                    context, pool, createdBy, totalVotes, data, index);
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else
          return Center(child: ProgressWithIcon());
      });

  Widget buildPollTile(BuildContext context, Poll pool,
      CurrentUserData createdBy, int totalVotes, List<Poll> data, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    SlideInRight(ViewPollScreen(
                        currentUserData: widget.currentUserData,
                        pollId: pool.pollId,
                        poll: pool)));
              },
              title: Text(pool.pollQuestion),
              leading: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 30,
                  height: 30,
                  imageUrl: createdBy.userUrl,
                  placeholder: (context, url) => new LinearProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
              subtitle: Text('${pool.pollItems.length} ' + 'choices'.tr()),
              trailing: !pool.seenBy.contains(widget.currentUserData.uid)
                  ? Icon(Icons.info, color: Constants.CANCEL_COLOR)
                  : null,
            ),
            pool.createdById == widget.currentUserData.uid ||
                    widget.userRole == '4'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child:
                            Text('Total votes: '.tr() + totalVotes.toString()),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    SlideInRight(AddEditPoll(
                                        currentUserData: widget.currentUserData,
                                        poll: pool)));
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Constants.BUTTON_COLOR,
                              )),
                          IconButton(
                              onPressed: () =>
                                  showDeletePollDialog(pool, provider),
                              icon: Icon(
                                Icons.delete,
                                color: Constants.CANCEL_COLOR,
                              )),
                          IconButton(
                              onPressed: () => showShareChannelDialog(
                                  data[index], widget.currentUserData),
                              icon: Icon(
                                Icons.share,
                                color: Constants.CANCEL_COLOR,
                              )),
                        ],
                      )
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget? buildFab(BuildContext context) {
    return widget.userRole == '4' || widget.userRole == '3'
        ? AvatarGlow(
            animate: true,
            repeat: true,
            glowColor: Constants.BUTTON_COLOR,
            child: FloatingActionButton(
              backgroundColor: Constants.BUTTON_COLOR,
              onPressed: () {
                Navigator.push(
                    context,
                    SlideInRight(
                        AddEditPoll(currentUserData: widget.currentUserData)));
              },
              child: Icon(Icons.add),
            ),
          )
        : null;
  }

  showShareChannelDialog(Poll poll, CurrentUserData currentUserData) {
    showDialog(
        context: context,
        builder: (context) {
          return SelectChannelDialog(
            poll: poll,
            currentUserData: currentUserData,
          );
        });
  }

  showDeletePollDialog(Poll poll, MyProvider provider) {
    final dialog = BlurryDialogNew(
        title: 'Delete this poll?'.tr(),
        continueCallBack: () {
          pollServices.deletePoll(
              poll.pollId, provider, poll.toWHo, poll.seenBy);
          Navigator.pop(context);
        });
    showDialog(
        context: context,
        builder: (_) {
          return dialog;
        });
  }
}
