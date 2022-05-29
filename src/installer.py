import pyotherside
import time
import os
import threading
import sys
sys.path.append('deps')
sys.path.append('../deps')
import pexpect

import password_type

class Installer:
    def get_password_type(self):
        return password_type.get_password_type()

    def install(self,password,gAPPS):
        
        os.chdir("/home/phablet")
        
        #Starting bash and getting root privileges
        print("Starting bash and getting root privileges")
        pyotherside.send('whatState',"=> Starting installer")
        time.sleep(1.5)
        child = pexpect.spawn('bash')
        child.expect(r'\$')
        child.sendline('sudo -s')
        if password != '':
            child.expect('[p/P]ass.*')
            child.sendline(str(password))
        child.expect('root.*')

        #remounting filesystem to rw
        print("remounting filesystem to rw")
        pyotherside.send('whatState',"=> remounting filesystem as readwrite")
        time.sleep(1.5)
        child.sendline('mount -o remount,rw /')
        child.expect('root.*')

        #installing waydroid through apt
        print("installing waydroid through apt")
        pyotherside.send('whatState',"=> installing waydroid")
        child.sendline("apt update")
        child.expect('root.*')
        child.sendline("apt install waydroid python3-gbinder -y")
        child.expect('root.*')

        #remounting filesystem to ro
        print("remounting filesystem to ro")
        pyotherside.send('whatState',"=> remounting filesystem as read-only")
        time.sleep(1.5)
        child.sendline('mount -o remount,ro /')
        child.expect('root.*')

        #Initializing waydroid (downloading lineage)
        def download():

            if gAPPS == True:
                print("Initializing waydroid wit GAPPS (downloading lineage)")
                pyotherside.send('whatState',"=> downloading LineageOS with GAPPS (This may take a while)")
                child.sendline("waydroid init -s GAPPS")
            else:
                print("Initializing waydroid (downloading lineage)")
                pyotherside.send('whatState',"=> downloading LineageOS (This may take a while)")
                child.sendline("waydroid init")
        
        def dlstatus():
            print("Download status running")
            run = True
            time.sleep(5)
            while run:
                time.sleep(1)
                size = 0
                Folderpath = '/var/lib/waydroid/cache_http'
                
                
                # get size
                for path, dirs, files in os.walk(Folderpath):
                    for f in files:
                        fp = os.path.join(path, f)
                        size += os.path.getsize(fp)
               
                
                pyotherside.send('whatState',"=> "+ str(size) +"/687180204 bytes (" + str(round(size / 687180204 * 100, 2)) + "%)")
                
                if size >= 687180200:
                    pyotherside.send('whatState',"=> 5 Minutes Left!")
                    print("Download status stops now")
                    run = False
                else: pass
            
        trd1 = threading.Thread(target=download)
        trd2 = threading.Thread(target=dlstatus)
        
        trd1.start()
        trd2.start()

        #wait for the threads to finish
        trd1.join()
        trd2.join()
        child.expect("root.*", timeout=300)
        child.close()



        pyotherside.send('runningStatus',"=> Installation complete!")
        
        return ""
    
    def uninstall(self, password):
        os.chdir("/home/phablet")
        
        #Starting bash and getting root privileges
        print("Starting bash and getting root privileges")
        pyotherside.send('whatState',"=> Starting uninstaller")
        time.sleep(1.5)
        child = pexpect.spawn('bash')
        child.expect(r'\$')
        child.sendline('sudo -s')
        child.expect('[p/P]ass.*')
        child.sendline(str(password))
        child.expect('root.*')

        #remounting filesystem to rw
        print("remounting filesystem to rw")
        pyotherside.send('whatState',"=> remounting filesystem as readwrite")
        time.sleep(1.5)
        child.sendline('mount -o remount,rw /')
        child.expect('root.*')

        #Stop Waydroid Container
        print("stopping waydroid container")
        pyotherside.send('whatState',"=> stopping waydroid container")
        child.sendline("service waydroid-container stop")
        child.expect("root.*", timeout=180)
     
        #Purge Waydroid
        print("purging Waydroid")
        pyotherside.send('whatState',"=> uninstalling Waydroid")
        child.sendline("apt purge --autoremove waydroid -y")
        child.expect('root.*', timeout=480)

        #do cleanup
        print("cleaning")
        pyotherside.send('whatState',"=> cleaning up")
        time.sleep(1.5)
        child.sendline("rm -rf /var/lib/waydroid")
        child.expect('root.*')

        #remounting filesystem to ro
        print("remounting filesystem to ro")
        pyotherside.send('whatState',"=> remounting filesystem as read-only")
        time.sleep(1.5)
        child.sendline('mount -o remount,ro /')
        child.expect('root.*')
        pyotherside.send('runningStatus',"=> Uninstallation complete!")
        child.close()
installer = Installer()
