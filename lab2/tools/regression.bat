@echo off
setlocal enabledelayedexpansion

set DATESTAMP=%DATE%
echo Test run on: %DATESTAMP% >>  ..\reports\regression_status.txt

FOR /L %%G IN (0,1,2) DO (
    FOR /L %%H IN (0,1,2) DO (
        SET /A WR_NR=%RANDOM% %% 50 + 1
        SET /A RD_NR=%RANDOM% %% 50 + 1

        IF %%H == 0 (
            SET write_order=inc
        ) ELSE IF %%H == 1 (
            SET write_order=dec
        ) ELSE IF %%H == 2 (
            SET write_order=rnd
        )

        IF %%G == 0 (
            SET read_order=inc
        ) ELSE IF %%G == 1 (
            SET read_order=dec
        ) ELSE IF %%G == 2 (
            SET read_order=rnd
        )

        call run_test.bat !WR_NR! !RD_NR! %%G %%H case_!write_order!_!read_order! c
    )
)