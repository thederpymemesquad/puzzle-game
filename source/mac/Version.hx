package mac;

import haxe.display.Display.Package;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;

class Version {
    public static macro function getBuildTime() {
        return Context.parse('${Math.floor(Date.now().getTime() / 1000)}', Context.currentPos());
    }

    public static macro function getVersionString() {
        var versionString = "Unknown";
        #if !display
        if (!FileSystem.exists("./version.txt")) {
            return macro $v{versionString};
        }
        else {
            versionString = File.getContent("./version.txt");
            // File.saveContent("./build.txt", Std.string(buildNumber + 1));
        }
        #end

        // File.saveContent("./test.txt", #if display "display" #else "not display" #end + " " + Std.string(buildNumber));
        return macro $v{versionString};
    }
}
