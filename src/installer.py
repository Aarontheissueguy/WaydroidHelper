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
        child.logfile_read = sys.stdout.buffer
        child.expect(r'\$')
        child.sendline('sudo -s')
        if password != '':
            child.expect('[p/P]ass.*')
            child.sendline(str(password))
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
            startedDownload = False

            def wait_for_extract(image):
                if not image in downloaded:
                    pyotherside.send('state', 'validate.' + image, False)
                    child.expect("Extracting to")
                    pyotherside.send('state', 'extract.' + image, False)
                    downloaded.append(image)

            while True:
                if not startedDownload:
                    index = child.expect(['Already initialized', pexpect.EOF, pexpect.TIMEOUT], timeout=1)
                    if index == 0:
                        # already initialized
                        break

                index = child.expect(['\r\[Downloading\]\s+([\d\.]+) MB/([\d\.]+) MB\s+([\d\.]+) ([km]bps)\(approx.\)$', pexpect.EOF, pexpect.TIMEOUT], timeout=1)
                if index == 0:
                    startedDownload = True
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
        child.logfile_read = sys.stdout.buffer
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

        #do cleanup
        print("cleaning")
        pyotherside.send('state', 'cleanup', False)
        child.sendline("rm -rf /var/lib/waydroid")
        child.expect('root.*')
        pyotherside.send('state', 'complete', False)
        child.close()

installer = Installer()
