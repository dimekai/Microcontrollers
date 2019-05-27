#include <Windows.h>
#include <stdio.h>
#include <iostream>
using namespace std;

int main(){
	cout << "Dispositivo: ";
	string disp;
	getline(cin, disp);
	disp = "\\\\.\\COM" + disp;

	cout << "Baudaje: ";
	int baudios;
	cin >> baudios;
	cin.ignore();

	HANDLE hComm = CreateFile(disp.c_str(),
		GENERIC_READ | GENERIC_WRITE,
		0,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		NULL);
	if(hComm == INVALID_HANDLE_VALUE){
		cout << "Error al abrir el dispositivo.\n";
		exit(0);
	}else{
		cout << "Dispositivo abierto correctamente.\n";
	}

	DCB dcbSerialParams = { 0 };
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	if(GetCommState(hComm, &dcbSerialParams) == FALSE){
		cout << "Error en GetCommState()\n";
		exit(0);
	}

	dcbSerialParams.BaudRate = baudios;      // Setting BaudRate = 9600
	dcbSerialParams.ByteSize = 8;             // Setting ByteSize = 8
	dcbSerialParams.StopBits = ONESTOPBIT;    // Setting StopBits = 1
	dcbSerialParams.Parity   = NOPARITY;      // Setting Parity = None 
	if(SetCommState(hComm, &dcbSerialParams) == FALSE){
		cout << "Error al configurar los parametros.\n";
		exit(0);
	}

	COMMTIMEOUTS timeouts = { 0 };
	timeouts.ReadIntervalTimeout         = 50;
	timeouts.ReadTotalTimeoutConstant    = 50;
	timeouts.ReadTotalTimeoutMultiplier  = 10;
	timeouts.WriteTotalTimeoutConstant   = 50;
	timeouts.WriteTotalTimeoutMultiplier = 10;
	if(SetCommTimeouts(hComm, &timeouts) == FALSE){
		cout << "Error! in Setting Time Outs\n";
		exit(0);
	}

	string send, received;
	char buff[100];
	while(1){
		getline(cin, send);
		if(send == "-") break;
		DWORD escritos = 0, leidos = 0;
		send += "\r\n";
		BOOL Status = WriteFile(hComm, send.c_str(), send.size(), &escritos, NULL);
		if(Status == FALSE || send.size() != escritos){
			cout << "Error al escribir.\n";
		}

		ReadFile(hComm, buff, sizeof(buff), &leidos, NULL);
		received = string(buff, leidos);
		cout << received << "\n";
	}

	CloseHandle(hComm);
	return 0;
}