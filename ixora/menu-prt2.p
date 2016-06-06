/* menu-prt2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        06.03.2012 damir - changing copy menu-prt.p
        07.03.2012 damir - добавил новую кнопку возможность печати на матричный принтер. (Просьба ДВО)
        11.09.2012 damir - Тестирование ИИН/БИН.
        19.01.2013 damir - Изменения по форме и выводе данных в WORD пенсионных и социальных отчислений.
*/

DEFINE INPUT PARAMETER cFile  AS char.
DEFINE INPUT PARAMETER tValue AS char.

def shared var V-OFILEINPUT_1 AS CHAR INIT "Orderplat.htm".
def shared var V-OFILEINPUT_2 AS CHAR INIT "SWTREG.htm".
def shared var V-OFILEINPUT_3 AS CHAR INIT "Pension.htm".

def shared var s-Print_1 as logi.
def shared var s-Print_2 as logi.
def shared var s-Print_3 as logi.

DEFINE VARIABLE msg  AS CHARACTER EXTENT 9.
DEFINE VARIABLE i    AS INTEGER INITIAL 1.
DEFINE VARIABLE j    AS INTEGER.
DEFINE VARIABLE ikey AS INTEGER INITIAL 1.
DEFINE VARIABLE newi AS INTEGER INITIAL 1.
DEFINE VARIABLE ret  AS logical init false.

function test_email RETURNS logical (input em as char).
def var ret as log init true.
def var err as char init ',~!@#$%^&*()=+\/?|<>:;`'.
def var i as integer.
err = err + "'".
err = err + '"'.

 do i=1 to length(err):
    if index(err,substr(em,i,1)) > 0 then ret = false.
   i = i + 1.
 end.
 return ret.
end.

procedure email-prt.
 def var ourdomen as char init '@metrocombank.kz'.
 def var email    as char init '' format "x(14)".
 unix SILENT value('cat ' + cFile + ' | koi2win  > tmp.txt; mv -f tmp.txt ' + 'mail-' + trim(cFile) ).

 update "Введите емайл" email validate(test_email(email),"Вы ввели недопустимые символы !") no-label
        "@metrocombank.kz" with overlay centered frame email title " Введите email ".

 run mail(email + "@metrocombank.kz", userid("bank") + "@metrocombank.kz",
          "You have mail from " + userid("bank") + " (" + string(time,"HH:MM:SS") + " " +
          string(day(today),'99.') + string(month(today),'99.') + string(year(today),'9999') + ")",
          "", "", "", 'mail-' + trim(cFile)).

 run savelog("email", "menu-prt " + userid("bank") + " " + cFile + " " + email).
 unix SILENT value('rm -f mail-' + trim(cFile)).
 hide frame email.
 pause 0.
end.

DISPLAY SKIP(1)
'[Просмотр]'  @ msg[1] ATTR-SPACE format 'x(8)'
'[Печать]'    @ msg[2] ATTR-SPACE format 'x(6)'
'[Windows]'   @ msg[3] ATTR-SPACE format 'x(7)'
'[WORD]'      @ msg[4] ATTR-SPACE format 'x(4)'
'[EXCEL]'     @ msg[5] ATTR-SPACE format 'x(4)'
'[Dos]'       @ msg[6] ATTR-SPACE format 'x(3)'
'[Email]'     @ msg[7] ATTR-SPACE format 'x(5)'
'[Выход]'     @ msg[8] ATTR-SPACE format 'x(5)'
'[Матричный]' @ msg[9] ATTR-SPACE format 'x(9)'
WITH CENTERED FRAME menu ROW 05 NO-LABELS
TITLE '[ Документ сформирован! Выберите: ]' overlay.

REPEAT WITH FRAME menu:
    REPEAT:
        COLOR DISPLAY MESSAGES msg[i] WITH FRAME menu.
        READKEY.
        CASE KEYFUNCTION(LASTKEY):
            WHEN 'CURSOR-RIGHT' THEN
                DO:
                    newi = i + 1.
                    IF newi > 9 THEN newi = 1.
                END.
            WHEN 'CURSOR-LEFT' THEN
                DO:
                    newi = i - 1.
                    IF newi < 1 THEN newi = 9.
                END.
            WHEN 'RETURN'    THEN LEAVE.
            WHEN 'GO'        THEN LEAVE.
            WHEN 'END-ERROR' THEN do: HIDE FRAME menu no-pause. return. end.
            WHEN 'ENDKEY'    THEN do: HIDE FRAME menu no-pause. return. end.
        END CASE.

        IF i <> newi THEN COLOR DISPLAY NORMAL msg[i] WITH FRAME menu.
        i = newi.
    END.

    CASE i:
        WHEN 1 THEN unix value( 'joe -rdonly ' + cFile ).
        WHEN 2 THEN do:
            if s-Print_1 then do: unix silent cptwin value(V-OFILEINPUT_1) winword. end.
            if s-Print_2 then do: unix silent cptwin value(V-OFILEINPUT_2) winword. end.
            if s-Print_3 then do: unix silent cptwin value(V-OFILEINPUT_3) winword. end.
        END.
        WHEN 3 THEN unix silent value( 'cptw ' + cFile ).
        WHEN 4 THEN unix silent value( 'cptwin ' + cFile + ' winword.exe').
        WHEN 5 THEN unix silent value( 'cptwin ' + cFile + ' excel.exe').
        WHEN 6 THEN unix silent value( 'cptwd ' + cFile ).
        WHEN 7 THEN run email-prt.
        WHEN 8 THEN DO: HIDE FRAME menu no-pause. return. end.
        WHEN 9 THEN unix silent value( 'prit ' + cFile ).
        Otherwise leave.
    END CASE.

END.

HIDE FRAME menu no-pause.


