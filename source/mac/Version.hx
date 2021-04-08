package mac;

import haxe.display.Display.Package;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;

class Version {
    public static macro function getBuildTime() {
        return Context.parse('${Math.floor(Date.now().getTime() / 1000)}', Context.currentPos());
    }

    public static macro function getBuildNumber() {
        var buildNumber = 0;
        #if !display
        if (!FileSystem.exists("./build.txt")) {
            // File.saveContent("./build.txt", Std.string(buildNumber));
        }
        else {
            buildNumber = Std.parseInt(File.getContent("./build.txt"));
            // File.saveContent("./build.txt", Std.string(buildNumber + 1));
        }
        #end

        // File.saveContent("./test.txt", #if display "display" #else "not display" #end + " " + Std.string(buildNumber));
        return macro $v{buildNumber + 1};
    }
}
