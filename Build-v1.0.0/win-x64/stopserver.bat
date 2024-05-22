@echo off

:Main
    setlocal
    set /a serverport=0
    set /a httpport=0
    
    call :ProcessPropPortId
    call :StopServerApp
    GOTO ENDMain
GOTO :eof


:ProcessPropPortId
    rem Process the properties port file: application.properties
    if not exist config\application.properties GOTO PropPortError
    (findstr /R "^server.port=[0-9][0-9]*" config\application.properties & echo.) >4 & (set /p propserverport=)<4
    (findstr /R "^server.http-port=[0-9][0-9]*" config\application.properties & echo.) >5 & (set /p prophttpport=)<5
    del /F /Q 4 2>NUL >NUL
    del /F /Q 5 2>NUL >NUL

    if defined propserverport set /a serverport=%propserverport:~12%
    if defined prophttpport set /a httpport=%prophttpport:~17%
    EXIT /B 0
    
    :PropPortError
        EXIT /B 1

:StopServerApp
    rem Stop the application
    @echo off
    if %serverport% gtr 0 ( call :ClosePortByPortId %serverport% )
    if %httpport% gtr 0 ( call :ClosePortByPortId %httpport% )
    echo eln-server-stop-ok
    EXIT /B 0
    
:ClosePortByPortId
    rem Close port in use
    set "port=%1"
    set "pidSet="
    for /f "usebackq tokens=*" %%I in (`netstat -ano ^| findstr /I "LISTENING" ^| findstr /R ":%port%\>"`) do ( call :closePortByPid %%I ) 
    
    EXIT /B 0
    
:closePortByPid
    SET "tmpprocessid="
    :loop
        if "%1"=="" GOTO LoopEnd
        SET tmpprocessid=%1
        SHIFT
        GOTO loop
        
    :LoopEnd
        if "%tmpprocessid%" == "" GOTO :eof
        if not defined pidSet.%tmpprocessid% (
          set pidSet.%tmpprocessid%=1
          call :CloseProcessByPid %tmpprocessid%
        )
        
        EXIT /B 0

:CloseProcessByPid
    rem Terminate the process by process id
    set kpid=%1
    IF NOT DEFINED kpid goto :eof
    taskkill /F /PID %kpid% 2>NUL >NUL
    exit /b 0


:EndMain
    endlocal
    GOTO :eof

