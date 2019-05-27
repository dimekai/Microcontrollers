from socket import *

myHost = '' # '' means all available interfaces on host
myPort = 50007 # listen on a non-reserved port number

# get socket constructor and constants
# '' = all available interfaces on host
sockobj = socket(AF_INET, SOCK_STREAM) # make a TCP socket object
sockobj.bind((myHost, myPort)) 
sockobj.listen(4) # listen, allow 5 pending connections

print("Escuchando en ", myPort)
while True: # listen until process killed
    connection, address = sockobj.accept() # wait for the next client connection
    print('Server connected by', address) 
    while True:
        data = connection.recv(1024) # read next line on client socket
	print(data)        
	if not data: break # send a reply until eof when socket closed
	#connection.send(b'Echo=>' + data)
    connection.close()
