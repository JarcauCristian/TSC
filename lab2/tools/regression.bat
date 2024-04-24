@echo off
setlocal enabledelayedexpansion

set DATESTAMP=%DATE%
echo Test run on: %DATESTAMP% >>  ..\reports\regression_status.txt

FOR /L %%G IN (1,1,10) DO (
    SET /A seed=%RANDOM%
    echo Seed: !seed!

    call run_test.bat 50 32 2 2 transcript_case_%%G c !seed!
)


@REM call run_test.bat 50 32 2 2 case1 gui 9994698
@REM call run_test.bat 50 32 2 2 case2 c 24637671
@REM call run_test.bat 50 32 2 2 case3 c 26858295
@REM call run_test.bat 50 32 2 2 case4 c 16108990
@REM call run_test.bat 50 32 2 2 case5 c 34415705
@REM call run_test.bat 50 32 2 2 case6 c 30703603
@REM call run_test.bat 50 32 2 2 case7 c 24901526
@REM call run_test.bat 50 32 2 2 case8 c 27347791
@REM call run_test.bat 50 32 2 2 case9 c 28895036
@REM call run_test.bat 50 32 2 2 case10 c 4881117
