if exist build rmdir /s /q build

mkdir build
mkdir build\terminate-icue

copy setup.bat                      build\terminate-icue
copy terminate-icue.ps1             build\terminate-icue
copy terminate-icue-plugin-host.vbs build\terminate-icue
copy terminate-icue-plugin-host.bat build\terminate-icue
copy terminate-icue.vbs             build\terminate-icue
copy terminate-icue.bat             build\terminate-icue
copy README.MD                      build\terminate-icue\readme.txt
copy LICENSE                        build\terminate-icue\license.txt
pause