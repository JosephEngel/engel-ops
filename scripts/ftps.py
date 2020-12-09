#!/usr/bin/python3

import ftplib
import ssl

# Extend FTP_TLS to fix session reuse error
class MyFTP_TLS(ftplib.FTP_TLS):
    """Explicit FTPS, with shared TLS session"""
    def ntransfercmd(self, cmd, rest=None):
        conn, size = ftplib.FTP.ntransfercmd(self, cmd, rest)
        if self._prot_p:
            session = self.sock.session
            if isinstance(self.sock, ssl.SSLSocket):
                    session = self.sock.session
            conn = self.context.wrap_socket(conn,
                                            server_hostname=self.host,
                                            session=session)  # this is the fix
        return conn, size
ftpTest = MyFTP_TLS()

USER = "ftpuser"
PASS = "ftpassword"
SERVER = "192.168.1.207"
PORT = 21
BINARY_STORE = True
filepath = '/home/joey'
filename = 'testing'

content = open(filename, 'rb')

ftpTest.set_debuglevel(2)
print (ftpTest.connect(SERVER, PORT))
print (ftpTest.login(USER, PASS))
print (ftpTest.prot_p())
print (ftpTest.set_pasv(True))

print (ftpTest.cwd("files"))
print (ftpTest.storbinary('STOR %s' % filename, content))
ftpTest.quit()

