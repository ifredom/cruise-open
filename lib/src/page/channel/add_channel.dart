import 'package:cruise/src/common/channel_action.dart';
import 'package:cruise/src/common/net/rest/http_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddChannel extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = useMemoized(() => GlobalKey<FormState>());
    final url = useState("");
    final submitting = useState(false);
    double screenWidth = MediaQuery.of(context).size.width;

    void handleAddChannel() async {
      if (_formKey.currentState!.validate()) {
        submitting.value = true;
        HttpResult result = await ChannelAction.addChannel(
          url: url.value,
        );

        if (result.result == Result.error) {
          Fluttertoast.showToast(
              msg: "RSS添加失败，请检查地址是否正确",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "添加成功",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        submitting.value = false;
      }
    }

    return Scaffold(
        body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                left: 16,
                right: 16,
              ),
              child: TextFormField(
                autocorrect: false,
                onChanged: (value) {
                  url.value = value;
                },
                obscureText: false,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  labelText: 'RSS地址',
                  contentPadding: EdgeInsets.all(10.0), //控制输入控件高度
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "RSS地址不能为空";
                  }
                  return null;
                },
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Builder(
                    builder: (context) {
                      return ButtonTheme(
                          minWidth: screenWidth * 0.85,
                          height: 50.0,
                          child: Center(
                              child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                            onPressed: () async {
                              handleAddChannel();
                            },
                            child: submitting.value
                                ? SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                : Text("添加RSS"),
                          )));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
