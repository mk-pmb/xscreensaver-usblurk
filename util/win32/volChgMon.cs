/** BEGIN example output **
@ 2018-06-19 20:17:13 watching
@ 2018-06-19 20:17:24 event {
        DriveName       String  G:
        EventType       UInt16  2 inserted
        SECURITY_DESCRIPTOR     (skipped)       (string conversion too slow)
        TIME_CREATED    UInt64  131739922448542331
}
@ 2018-06-19 20:17:38 event {
        DriveName       String  G:
        EventType       UInt16  3 removed
        SECURITY_DESCRIPTOR     (skipped)       (string conversion too slow)
        TIME_CREATED    UInt64  131739922585978572
}
@ 2018-06-19 20:17:46 quit
** ENDOF example output **/

// To watch non-volume devices, see https://stackoverflow.com/a/16245706

using System;

//$ref c:/windows/Microsoft.NET/Framework/v4.0.30319/System.Management.dll ||
//$ref c:/windows/mono/mono-2.0/lib/mono/4.0/System.Management.dll ||
//$ref ./dotnet40/System.Management.dll
using System.Management;

using System.Diagnostics; // <- where MS hides the "Process" class.

namespace volChgMon_win32 {
  class Program {
    static string autorunCmd;
    static string autorunMode;
    static string defaultShell;

    [STAThread] // <- required for safe use of UseShellExecute, says
                //    https://msdn.microsoft.com/en-us/library/h6ak8zt5.aspx
    static void Main() {
      autorunCmd = getEnv("volchg_autorun");
      autorunMode = getEnv("volchg_armode");
      defaultShell = getEnv("COMSPEC");
      if (defaultShell == "") { defaultShell = "cmd.exe"; }
      if (autorunCmd == "") {
        autorunMode = null;
      } else {
        if (autorunMode == "") { autorunMode = "hidden"; }
      }
      ManagementEventWatcher watcher = new ManagementEventWatcher();
      watcher.Query = new WqlEventQuery(
        "SELECT * FROM Win32_VolumeChangeEvent");
      watcher.EventArrived += new EventArrivedEventHandler(volChgEvt);
      watcher.Start();
      atNow("watching");
      Console.ReadLine();
      watcher.Stop();
      atNow("quit");
    }

    static string ifNull(string x, string d = "") {
      return (x == null ? d : x);
    }

    static string getEnv(string vn) {
      return ifNull(Environment.GetEnvironmentVariable(vn));
    }

    static void putEnv(string vn, string val) {
      Environment.SetEnvironmentVariable(vn, val);
    }

    static void atNow(string what) {
      Console.WriteLine("@ {1} {0}", what,
        DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
    }

    static void volChgEvt(object sender, EventArrivedEventArgs evt) {
      atNow("event {");
      foreach (PropertyData prop in evt.NewEvent.Properties) {
        displayEventProp(prop);
      }
      Console.WriteLine("}");
      launchAutorun();
    }

    static void launchAutorun() {
      if (autorunCmd == "") { return; }
      Process proc = new Process();
      ProcessStartInfo psi = proc.StartInfo;
      psi.FileName = autorunCmd;
      psi.ErrorDialog = false; // fail silently if command doesn't work
      psi.UseShellExecute = true; // support CLI arguments in FileName
      psi.WindowStyle = ProcessWindowStyle.Hidden;
      if (autorunMode == "show") {
        psi.WindowStyle = ProcessWindowStyle.Normal;
      }
      if (autorunMode == "shell") {
        psi.FileName = defaultShell;
        psi.Arguments = "/c " + autorunCmd;
      }
      if (autorunMode == "start") {
        psi.FileName = defaultShell;
        psi.Arguments = "/c start \"\" " + autorunCmd;
      }
      putEnv("volchg_datetime", DateTime.Now.ToString("yyyyMMddHHmmss"));
      proc.Start();
    }

    static void displayEventProp(PropertyData prop) {
      string n = prop.Name.ToString();
      string v = null;
      string t = null;
      string a = null;
      // Some .Value.ToString()s seem to block for a long time,
      // so let's print their name early so we can identify and
      // debug (or skip) them.
      Console.Write("\t{0}\t", n);
      if (n == "SECURITY_DESCRIPTOR") { t = "slow!"; }

      if (t == "slow!") {
        t = "(skipped)";
        v = "(string conversion too slow)";
        a = "";
      }
      if (t == null) { t = prop.Value.GetType().Name; }
      if (v == null) { v = prop.Value.ToString(); }
      if (n == "EventType") {
        if (v == "2") { v += " inserted"; }
        if (v == "3") { v += " removed"; }
      }
      if (v == "") { v = "<empty>"; }
      Console.WriteLine("{0}\t{1}", t, v);

      if (autorunMode != "") {
        if (a == null) { a = v; }
        putEnv("volchg_" + n.ToLower(), a);
      }
    }














  }
}
