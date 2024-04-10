@echo off
setlocal enabledelayedexpansion

set DATESTAMP=%DATE%
echo Test run on: %DATESTAMP% >>  ..\reports\regression_status.txt

@REM FOR /L %%G IN (0,1,2) DO (
@REM     FOR /L %%H IN (0,1,2) DO (
@REM         SET /A WR_NR=%RANDOM% %% 50 + 1
@REM         SET /A RD_NR=%RANDOM% %% 50 + 1

@REM         IF %%H == 0 (
@REM             SET write_order=inc
@REM         ) ELSE IF %%H == 1 (
@REM             SET write_order=dec
@REM         ) ELSE IF %%H == 2 (
@REM             SET write_order=rnd
@REM         )

@REM         IF %%G == 0 (
@REM             SET read_order=inc
@REM         ) ELSE IF %%G == 1 (
@REM             SET read_order=dec
@REM         ) ELSE IF %%G == 2 (
@REM             SET read_order=rnd
@REM         )

@REM         call run_test.bat !WR_NR! !RD_NR! %%G %%H case_!write_order!_!read_order! c
@REM     )
@REM )


call run_test.bat 50 32 2 2 case1 c 9994698
call run_test.bat 50 32 2 2 case2 c 24637671
call run_test.bat 50 32 2 2 case3 c 26858295
call run_test.bat 50 32 2 2 case4 c 16108990
call run_test.bat 50 32 2 2 case5 c 34415705
call run_test.bat 50 32 2 2 case6 c 30703603
call run_test.bat 50 32 2 2 case7 c 24901526
call run_test.bat 50 32 2 2 case8 c 27347791
call run_test.bat 50 32 2 2 case9 c 28895036
call run_test.bat 50 32 2 2 case10 c 4881117
