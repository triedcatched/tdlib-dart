package in.betaturtle.flugram;

import android.annotation.TargetApi;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "channel/to/betaturtle/in";
  long client_id;
  private AsyncTask<Void, Void, String> task;

  @Override
  public void onDestroy() {
    Log.i("TAG", "Destroying stuff");
    Log.i("TAG", String.valueOf(client_id));
    if (!task.isCancelled())
      task.cancel(true);
    destroyNativeClient(client_id);
    super.onDestroy();
  }

  @SuppressWarnings (value="unchecked")
  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // getWindow().setStatusBarColor(0x00000000); // use when that shadow thing is a pain
    GeneratedPluginRegistrant.registerWith(this);

    setLogVerbosity(0);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
              switch (call.method) {
                case "createClient":
                  long cli = createNativeClient();
                  client_id = cli;
                  result.success(cli);
                  break;
                case "clientSend": {
                  HashMap<String, Object> arg = (HashMap<String, Object>) call.arguments;
                  long client_id = (long) arg.get("client_id");
                  String to_send = (String) arg.get("to_send");
                  nativeClientSend(client_id, to_send);
                  result.success(null);
                  break;
                }
                case "clientExecute": {
                  HashMap<String, Object> arg = (HashMap<String, Object>) call.arguments;
                  long client_id = (long) arg.get("client_id");
                  String to_send = (String) arg.get("to_send");
                  String res = nativeClientExecute(client_id, to_send);
                  result.success(res);
                  break;
                }
                case "clientReceive": {
                  HashMap<String, Object> arg = (HashMap<String, Object>) call.arguments;
                  final long client_id = (long) arg.get("client_id");
//                  if client_id
                  task = new MyTask(result, client_id).execute();
                  break;
                }
                default:
                  result.notImplemented();
                  break;
              }
            });
  }

  @TargetApi(Build.VERSION_CODES.CUPCAKE)
  private static class MyTask extends AsyncTask<Void, Void, String> {

    MethodChannel.Result mResult;
    long client_id;
    MyTask(MethodChannel.Result result, long client_id) {
      this.mResult = result;
      this.client_id = client_id;
    }

    @Override
    protected String doInBackground(Void... params) {
      String res = nativeClientReceive(client_id, 60 );
      if (res != null) {
        mResult.success(res);
      }else{
        mResult.error("No updates", "This is not an error", null);
      }
      return "task finished";
    }
  }

  // Used to load the 'native-lib' library on application startup.
  static {
    System.loadLibrary("native-lib");
  }

  public native long createNativeClient();
  public native void nativeClientSend(long client_id,  String json);
  public static native String nativeClientReceive(long client_id, double wait_timeout);
  public native String nativeClientExecute(long client_id,  String json);
  public native void destroyNativeClient(long client_id);
  public native void setLogVerbosity(int level);
}
