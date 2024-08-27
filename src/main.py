'''
 Copyright (C) 2021  Aaron Hafer

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 waydroidhelper is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''
import os, re
import configparser

class Appdrawer:
    def return_apps(self):
        wdapplist = os.listdir("/home/phablet/.local/share/applications")
        return [i for i in wdapplist if i.startswith("waydroid.") and i.endswith(".desktop")]

    def clean(self):
        wdapplist = self.return_apps()
        cleannames = []

        for i in wdapplist:
            abs_path = os.path.join("/home/phablet/.local/share/applications/", i)
            if not os.path.isfile(abs_path):
                pass
            with open(abs_path, "r") as f:
                re_name = re.search(r"Name=(.*)", f.read())
                if re_name:
                    appname = re_name.group(1)
                    cleannames.append(appname)

        return sorted(cleannames)

    def clean_to_path(self, appname):
        wdapplist = self.return_apps()
        path = None
        for i in wdapplist:
            abs_path = os.path.join("/home/phablet/.local/share/applications/", i)
            if not os.path.isfile(abs_path):
                pass
            with open(abs_path, "r") as f:
                re_name = re.search(r"Name=%s" % appname, f.read())
                if re_name:
                    path = i
                    break
        return path

    def show(self, appname):
        path = self.clean_to_path(appname)
        abs_path = os.path.join("/home/phablet/.local/share/applications/", path)
        if not os.path.isfile(abs_path):
            return
        desktop = configparser.ConfigParser()
        desktop.optionxform = str  # Keep case of keys
        desktop.read(abs_path)
        if desktop["Desktop Entry"].getboolean("NoDisplay", fallback=False):
            desktop["Desktop Entry"]["NoDisplay"] = "false"
            with open(abs_path, "w") as f:
                desktop.write(f, space_around_delimiters=False)
    
    def hide(self, appname):
        path = self.clean_to_path(appname)
        abs_path = os.path.join("/home/phablet/.local/share/applications/", path)
        if not os.path.isfile(abs_path):
            return
        desktop = configparser.ConfigParser()
        desktop.optionxform = str  # Keep case of keys
        desktop.read(abs_path)
        if not desktop["Desktop Entry"].getboolean("NoDisplay", fallback=False):
            desktop["Desktop Entry"]["NoDisplay"] = "true"
            with open(abs_path, "w") as f:
                desktop.write(f, space_around_delimiters=False)

appdrawer = Appdrawer()

class StopApp:
    def create(self):
        with open("/home/phablet/.local/share/applications/stop-waydroid.desktop", "w") as f:
            f.write("[Desktop Entry]\nType=Application\nName=Waydroid Stop\nExec=waydroid session stop\nIcon=/usr/lib/waydroid/data/AppIcon.png")
    def remove(self):
        if os.path.isfile("/home/phablet/.local/share/applications/stop-waydroid.desktop"):
            os.remove("/home/phablet/.local/share/applications/stop-waydroid.desktop")
stopapp = StopApp()
