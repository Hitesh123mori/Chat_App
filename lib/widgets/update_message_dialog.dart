import 'package:chatapp/models/messages.dart';
import 'package:flutter/material.dart';
import '../apis/Apis.dart';
import '../main.dart';
import '../theme/colors.dart';

class UpdateMessage extends StatefulWidget {
  final Messages message;
  const UpdateMessage({super.key, required this.message});

  @override
  State<UpdateMessage> createState() => _UpdateMessageState();
}

class _UpdateMessageState extends State<UpdateMessage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    String updatedMsg = widget.message.msg ;
    return Form(
      key: _formKey,
      child: AlertDialog(
        actions: [
          TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()){

                  await Api.updateMessage(widget.message, updatedMsg).then((value) {

                    Navigator.pop(context);

                  });

                }
              },
              child: Text(
                "Update",
                style: TextStyle(color: Colors.green),
              )),
          SizedBox(
            width: mq.width * 0.12,
          ),
        ],
        titlePadding: EdgeInsets.only(left: mq.width * 0.17, top: 20),
        backgroundColor: AppColors.theme['backgroundColor'],
        title: Text(
          "Update Message",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white30),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          height: mq.height * 0.09,
          width: mq.width * .6,
          child: Column(
            children: [
              TextFormField(
                onChanged: (value)=>updatedMsg = value ,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Enter Message';
                  }
                  return null;
                },
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                initialValue: updatedMsg,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors.theme['secondaryTextColor']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: AppColors.theme['primaryTextColor']),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.red),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
