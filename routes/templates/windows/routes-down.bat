@echo off

net session >nul 2>&1
if not %errorlevel% == 0 (
  echo ��ʹ���Ҽ� "�ѹ���Ա�������" �˽ű�
  pause
  exit 1
)

cd /d %~dp0
echo �Ƴ�·�ɱ�...
rundll32.exe cmroute.dll,SetRoutes /STATIC_FILE_NAME del.txt /DONT_REQUIRE_URL /IPHLPAPI_ACCESS_DENIED_OK
pause
