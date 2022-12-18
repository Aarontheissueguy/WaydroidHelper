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
        pyotherside.send('state', 'starting', False)
        child = pexpect.spawn('bash')
        child.expect(r'\$')
        child.sendline('sudo -s')
        if password != '':
            child.expect('[p/P]ass.*')
            child.sendline(str(password))
        child.expect('root.*')

        #remounting filesystem to rw
        print("remounting filesystem to rw")
        pyotherside.send('state', 'remount.rw', False)
        child.sendline('mount -o remount,rw /')
        child.expect('root.*')

        #installing waydroid through apt
        print("installing waydroid through apt")
        pyotherside.send('state', 'apt.install', False)
        child.sendline("apt update")
        child.expect('root.*')
        child.sendline("apt install waydroid python3-gbinder -y")
        child.expect('root.*')

        #remounting filesystem to ro
        print("remounting filesystem to ro")
        pyotherside.send('state', 'remount.ro', False)
        child.sendline('mount -o remount,ro /')
        child.expect('root.*')

        #Initializing waydroid (downloading lineage)
        def download():
            if gAPPS == True:
                print("Initializing waydroid wit GAPPS (downloading lineage)")
                pyotherside.send('state', 'dl.init.gapps', True)
                child.sendline("waydroid init -s GAPPS")
            else:
                print("Initializing waydroid (downloading lineage)")
                pyotherside.send('state', 'dl.init.vanilla', True)
                child.sendline("waydroid init")
        
        def dlstatus():
            print("Download status running")
            downloaded = []

            def wait_for_extract(image):
                if not image in downloaded:
                    pyotherside.send('state', 'validate.' + image, False)
                    child.expect("Extracting to")
                    pyotherside.send('state', 'extract.' + image, False)
                    downloaded.append(image)

            while True:
                
                index = child.expect(['\r\[Downloading\]\s+([\d\.]+) MB/([\d\.]+) MB\s+([\d\.]+) ([km]bps)\(approx.\)$', pexpect.EOF, pexpect.TIMEOUT], timeout=1)
                if index == 0:
                    if 'system' in downloaded:
                        pyotherside.send('state', 'dl.vendor', True)
                    else:
                        pyotherside.send('state', 'dl.gapps' if gAPPS == True else 'dl.vanilla', True)
                    
                    progress = float(child.match.group(1))
                    target = float(child.match.group(2))
                    speed = float(child.match.group(3))
                    unit = child.match.group(4)
                    
                    pyotherside.send('downloadProgress', progress, target, speed, unit)

                index = child.expect(["Validating system image", pexpect.EOF, pexpect.TIMEOUT], timeout=0.5)
                if index == 0:
                    wait_for_extract('system')
                index = child.expect(["Validating vendor image", pexpect.EOF, pexpect.TIMEOUT], timeout=0.5)
                if index == 0:
                    wait_for_extract('vendor')

                if 'system' in downloaded and 'vendor' in downloaded:
                    break
            
        trd1 = threading.Thread(target=download)
        trd2 = threading.Thread(target=dlstatus)
        
        trd1.start()
        trd2.start()

        #wait for the threads to finish
        trd1.join()
        trd2.join()
        child.expect("root.*", timeout=300)
        child.close()

        pyotherside.send('state', 'complete', False)
        
        return ""
    
    def uninstall(self, password):
        os.chdir("/home/phablet")
        
        #Starting bash and getting root privileges
        print("Starting bash and getting root privileges")
        pyotherside.send('state', 'starting', False)
        child = pexpect.spawn('bash')
        child.expect(r'\$')
        child.sendline('sudo -s')
        if password != '':
            child.expect('[p/P]ass.*')
            child.sendline(str(password))
        child.expect('root.*')

        #Stop Waydroid Container
        print("stopping waydroid container")
        pyotherside.send('state', 'container', False)
        child.sendline("service waydroid-container stop")
        child.expect("root.*", timeout=180)
     
        #remounting filesystem to rw
        print("remounting filesystem to rw")
        pyotherside.send('state', 'remount.rw', False)
        child.sendline('mount -o remount,rw /')
        child.expect('root.*')

        #Purge Waydroid
        print("purging Waydroid")
        pyotherside.send('state', 'apt.purge', False)
        child.sendline("apt purge --autoremove waydroid -y")
        child.expect('root.*', timeout=480)

        #remounting filesystem to ro
        print("remounting filesystem to ro")
        pyotherside.send('state', 'remount.ro', False)
        child.sendline('mount -o remount,ro /')
        child.expect('root.*')

        #do cleanup
        print("cleaning")
        pyotherside.send('state', 'cleanup', False)
        child.sendline("rm -rf /var/lib/waydroid")
        child.expect('root.*')
        pyotherside.send('state', 'complete', False)
        child.close()

installer = Installer()
