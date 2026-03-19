
import sys
import ctypes

def lock():
    login_exe = '/System/Library/PrivateFrameworks/login.framework/Versions/Current/login'
    try:
        dll = ctypes.CDLL( login_exe )
        dll.SACLockScreenImmediate()
    except OSError:
        sys.stderr.writelines( "I|mac: Fail to load framework -> " + login_exe  + "\n" )
    except AttributeError:
        sys.stderr.writelines( "I|mac: Function unavailable -> " + login_exe + "\n" )

if __name__ == "__main__":
    lock()

