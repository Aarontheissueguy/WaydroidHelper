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
import os

class Appdrawer:
    def return_apps(self):
        text = os.listdir("/home/phablet/.local/share/applications")
        wdapplist = []
        for i in text:
            if "waydroid" in i and ".desktop" in i:
                wdapplist.append(i)
            else:
                pass
        wdapplist.remove("waydroidhelper.aaronhafer_waydroidhelper_2.0.2.desktop")


        return wdapplist

    def clean(self):
        print("hello")
        wdapplist = self.return_apps()
        cleannames = []

        for i in wdapplist:
            try:
                f = open("/home/phablet/.local/share/applications/" + i,"r")
                lines = f.readlines()
                for line in lines:
                    if "Name=" in line:
                        line = str(line).replace("Name=", "")
                        cleannames.append(line)
                    else:
                        pass
                f.close()
            except:
                pass

        return cleannames

    def clean_to_path(self, appname):
        wdapplist = self.return_apps()
        for i in wdapplist:
            try:
                f = open("/home/phablet/.local/share/applications/" + i,"r")
                lines = f.readlines()
                for line in lines:
                    if appname in line:
                        f.close()
                        return i
                    else:
                        pass
                f.close()
            except:
                pass

    def show(self, appname):
        path = self.clean_to_path(appname)
        os.system("for i in ~/.local/share/applications/" + path +"; do echo 'NoDisplay=false' >> $i; done")

    def hide(self, appname):
        path = self.clean_to_path(appname)
        os.system("for i in ~/.local/share/applications/" + path +"; do echo 'NoDisplay=true' >> $i; done")

appdrawer = Appdrawer()

class StopApp:
    def create(self):
        f = open("/home/phablet/.local/share/applications/stop-waydroid.desktop", mode = "w")
        f.write("[Desktop Entry]\nType=Application\nName=Waydroid Stop\nExec=waydroid session stop\nIcon=/usr/lib/waydroid/data/AppIcon.png")
        f.close
    def remove(self):
        os.system("rm /home/phablet/.local/share/applications/stop-waydroid.desktop")
stopapp = StopApp()
