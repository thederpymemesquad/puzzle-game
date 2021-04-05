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
        #if display
        return macro $v{-1};
        #else
        if (!FileSystem.exists("./build.txt")) {
            File.saveContent("./build.txt", "0");
            return macro $v{0};
        }
        else {
            return macro $v{Std.parseInt(File.getContent("./build.txt"))};
        }
        #end
    }
}
