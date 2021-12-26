import pyotherside
import time
import os
import sys
sys.path.append('deps')
sys.path.append('../deps')
import pexpect
class Installer:
    def install(self,password):
        
        os.chdir("/home/phablet")
        
        #Starting bash and getting root privileges
        print("Starting bash and getting root privileges")
        pyotherside.send('whatState',"=> Starting installer")
        time.sleep(1.5)
        child = pexpect.spawn('bash')
        child.expect(r'\$')
        child.sendline('sudo -s')
        child.expect('[p/P]ass.*')
        child.sendline(str(password))
        child.expect('root.*')

        #remounting filesystem to rw
        print("remounting filesystem to rw")
        pyotherside.send('whatState',"=> remounting filesystem")
        time.sleep(1.5)
        child.sendline('sudo mount -o remount,rw /')
        child.expect('root.*')

        #installing waydroid through apt
        print("installing waydroid through apt")
        pyotherside.send('whatState',"=> installing waydroid")
        child.sendline("sudo apt update")
        child.expect('root.*')
        child.sendline("sudo apt install waydroid -y")
        child.expect('root.*')

        #Initializing waydroid (downloading lineage)
        print("Initializing waydroid (downloading lineage)")
        pyotherside.send('whatState',"=> downloaging LineageOS (This may take a while)")
        child.sendline("sudo waydroid init")
        child.expect('root.*')
        
        #reboot
        print("reboot")
        pyotherside.send('whatState',"=> rebooting")
        child.sendline("reboot")
        child.expect("root.*", timeout=180)
        time.sleep(1000)
        child.close()



        pyotherside.send('whatState',"=> I AM ROOT")
        
        '''
        sudo -s
        sudo mount -o remount,rw /
        sudo apt update 
        sudo apt install waydroid -y
        sudo waydroid init 
        reboot
        '''
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
        pyotherside.send('whatState',"=> remounting filesystem")
        time.sleep(1.5)
        child.sendline('sudo mount -o remount,rw /')
        child.expect('root.*')

        #Purge Waydroid
        print("purging Waydroid")
        pyotherside.send('whatState',"=> uninstalling Waydroid")
        child.sendline("sudo apt purge waydroid -y")
        child.expect('root.*', timeout=480)
        
        #reboot
        print("reboot")
        pyotherside.send('whatState',"=> rebooting")
        child.sendline("reboot")
        child.expect("root.*", timeout=180)
        time.sleep(1000)
        child.close()
installer = Installer()
