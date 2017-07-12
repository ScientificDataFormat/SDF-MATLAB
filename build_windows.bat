echo Remember the current folder
set start_dir=%cd%

echo Change into the script's folder
cd %~dp0

echo Set the environment variables
call "%vs140comntools%vsvars32.bat"

echo Build the DLLs
msbuild C\VisualStudio\SDF-MATLAB.sln /t:Clean,Build /p:Configuration=Release /p:Platform=x86
msbuild C\VisualStudio\SDF-MATLAB.sln /t:Clean,Build /p:Configuration=Release /p:Platform=x64

echo Change back to the original folder
cd %start_dir%
