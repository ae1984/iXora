/* menu-crc.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma.
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 aigul - добавила новые курсы валют
        13.04.2012 aigul - добавила новые курсы валют, output only in excel
        02.05.2012 aigul - исправила вывод валюты
        18.06.2012 damir - добавил Южно-африканский ранд (ZAR).
        26.07.2012 damir - поправка по CAD.
*/

/*############################################*/
/* last change: 06/02/2002 sasco
               + настройка принтера из OFC.
               + курсы - по НацБанку! ! ! ! ! ! */
/*############################################*/

def input parameter dt1 as date format "99/99/9999".
def input parameter dt2 as date format "99/99/9999".

DEFINE VARIABLE o_name AS CHARACTER format 'x(18)'.
DEFINE VARIABLE valkod AS INTEGER.
DEFINE VARIABLE msg    AS CHARACTER EXTENT 12.
DEFINE VARIABLE i      AS INTEGER INITIAL 1.
DEFINE VARIABLE ikey   AS INTEGER INITIAL 1.
DEFINE VARIABLE newi   AS INTEGER INITIAL 1.

def stream valut1.

DISPLAY SKIP(1)
    'Доллары США '  @ msg[1] ATTR-SPACE format 'x(12)'
    skip(0)
    /*'Немецкие марки'    @ msg[2] ATTR-SPACE format 'x(14)'
    skip(0)*/
    'Российские рубли'   @ msg[2] ATTR-SPACE format 'x(16)'
    skip(0)
    'Евро'      @ msg[3] ATTR-SPACE format 'x(4)'
    skip(0)
    'Швейцарские франки'    @ msg[4] ATTR-SPACE format 'x(18)'
    skip(0)
    'Украинские гривны'   @ msg[5] ATTR-SPACE format 'x(17)'
    skip(0)
    'Английский фунт стерлингов'   @ msg[6] ATTR-SPACE format 'x(17)'
    skip(0)
    'Шведская крона'   @ msg[7] ATTR-SPACE format 'x(17)'
    skip(0)
    'Австралийский доллар'   @ msg[8] ATTR-SPACE format 'x(17)'
    skip(0)
    'Японская йена'   @ msg[9] ATTR-SPACE format 'x(17)'
    skip(0)
    'Канадский доллар'   @ msg[10] ATTR-SPACE format 'x(17)'
    skip(0)
    'Южно-африканский ранд'   @ msg[11] ATTR-SPACE format 'x(17)'
    skip(0)
    'Выход'     @ msg[12] ATTR-SPACE format 'x(5)'
WITH CENTERED FRAME menu row 10 NO-LABELS TITLE '[Выберите валюту : ]' top-only.

REPEAT:
    REPEAT:
        COLOR DISPLAY MESSAGES msg[i] WITH FRAME menu.
        READKEY.
        CASE LASTKEY:
            WHEN KEYCODE('CURSOR-DOWN') THEN
                DO:
                    newi = i + 1.
                    IF newi > 12 THEN newi = 1.
                END.
            WHEN KEYCODE('CURSOR-UP')  THEN
                DO:
                    newi = i - 1.
                    IF newi < 1 THEN newi = 12.
                END.
            WHEN KEYCODE('RETURN') THEN LEAVE.
            WHEN KEYCODE('GO')     THEN LEAVE.
        END CASE.

        IF i <> newi THEN COLOR DISPLAY NORMAL
        msg[i] WITH FRAME menu.
        i = newi.
    END.

    CASE i:
        WHEN 1 THEN do:
            o_name='   Доллары США    '.
            valkod = 2.
        end .
        /*WHEN 2 THEN do:
            o_name='  Немецкие марки  '.
            valkod = .
        end .*/
        WHEN 2 THEN do:
            o_name=' Российские рубли '.
            valkod = 4.
        end.
        WHEN 3 THEN do:
            o_name='       Евро       '.
            valkod = 3.
        end.
        WHEN 4 THEN do:
            o_name='Швейцарские франки'.
            valkod = 9.
        end .
        WHEN 5 THEN do:
            o_name='Украинские гривны '.
            valkod = 5.
        end.
        WHEN 6 THEN do:
            o_name='Английский фунт стерлингов '.
            valkod = 6.
        end.
        WHEN 7 THEN do:
            o_name='Шведская крона '.
            valkod = 7.
        end.
        WHEN 8 THEN do:
            o_name='Австралийский доллар '.
            valkod = 8.
        end.
        WHEN 9 THEN do:
            o_name='Японская йена '.
            valkod = 18.
        end.
        WHEN 10 THEN do:
            o_name='Канадский доллар '.
            valkod = 11.
        end.
        WHEN 11 THEN do:
            o_name='Южно-африканский ранд '.
            valkod = 10.
        end.
        WHEN 12 THEN leave.
    END CASE.
    run pois_ist(dt1,dt2,valkod,o_name).
    pause 0 before-hide.
    /*run menu-prt('valutr.txt').*/
    pause before-hide.
    /*unix silent value( 'clear' ).
    PAUSE 0 no-message.*/
END.

RETURN.
/***/

procedure pois_ist.
def input parameter dt11    as date format "99/99/9999".
def input parameter dt12    as date format "99/99/9999".
def input parameter vak     as inte.
def input parameter cnamev  as char format 'x(18)'.

def var zagol  as char format 'x(28)'.
def var v-code as char.
zagol = 'С ' + string( dt11, '99/99/9999' ) + 'г ПО ' + string( dt12, '99/99/9999' ) + 'г'.

/*output to 'valutr.txt'.
 display space(8) 'КУРСЫ ВАЛЮТ НАЦ. БАНКА' skip(1)
         space(4) zagol no-label skip(1)
         space(10) cnamev no-label skip(1)
         space(4) 'Валюта      Курс   Установлен  '
         with centered frame aass.*/

/*for each ncrchis where ncrchis.crc = vak and ncrchis.rdt >= dt11 and ncrchis.rdt <= dt12 no-lock  :*/
             /* if not avail crchis then next.*/
            /* displ
             ncrchis.crc     no-label
             ncrchis.code    no-label
             replace(string(ncrchis.rate[1]),".",",") no-label
             ncrchis.rdt     no-label   with no-label centered .*/
           /*  crchis.des     no-label with no-label centered .*/
/*end.*/
/*for each crcpro where crcpro.crc = vak and crcpro.regdt >= dt11 and crcpro.regdt <= dt12 no-lock  :*/
             /* if not avail crchis then next.*/
             /*find first crc where crc.crc = crcpro.crc no-lock no-error.
             if avail crc then v-code = crc.code.
             displ
             crcpro.crc     no-label
             v-code    no-label
             replace(string(crcpro.rate[1]),".",",") no-label
             crcpro.regdt     no-label   with no-label centered .*/
           /*  crchis.des     no-label with no-label centered .*/
/*end.*/
/* прогонка принтера, чтобы бумагу не выкручивать вручную */
/*find first ofc where ofc.ofc = userid('bank').
if ofc.mday[2] = 1 then put skip(14).
                   else put skip(1).

output close.*/

    output stream valut1 to valut1.html.
    {html-title.i
    &title = "Курсы валют Нац. банка" &stream = "stream valut1" &size-add = "x-"}
    /*hide frame datokn.*/
    /*message 'ха - ха'.*/
    put stream valut1 unformatted
    "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
    "<B> Курсы валют Нац. банка <br>" + zagol + " <br>" +  cnamev + "</FONT></P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
    put stream valut1 unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Курс</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Установлен</B></FONT></TD>" skip
    "</TR>" skip.
    if (dt11 <= 01/05/12 and dt12 <= 01/05/12) then do:
        for each ncrchis where ncrchis.crc = vak and ncrchis.rdt >= dt11 and ncrchis.rdt <= dt12 no-lock break by ncrchis.rdt:
            if last-of(ncrchis.rdt) then do:
                put stream valut1 unformatted
                "<TR align=""center"">" skip
                "<TD><FONT size=""2""><B>" + string(ncrchis.crc) + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + ncrchis.code + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + replace(string(ncrchis.rate[1]),".",",")    + "</B></FONT></TD>" skip
                "<TD><FONT size=""2""><B>" + string(ncrchis.rdt,"99/99/9999") + "</B></FONT></TD>" skip.
            end.
        end.
    end.
    if (dt11 >= 01/05/12 or dt12 <= 01/05/12) then do:
        for each crcpro where crcpro.crc = vak and crcpro.regdt >= dt11 and crcpro.regdt <= dt12 no-lock  :
            find first crc where crc.crc = crcpro.crc no-lock no-error.
            if avail crc then v-code = crc.code.
            put stream valut1 unformatted
            "<TR align=""center"">" skip
            "<TD><FONT size=""2""><B>" + string(crcpro.crc) + "</B></FONT></TD>" skip
            "<TD><FONT size=""2""><B>" + v-code + "</B></FONT></TD>" skip
            "<TD><FONT size=""2""><B>" + replace(string(crcpro.rate[1]),".",",")    + "</B></FONT></TD>" skip
            "<TD><FONT size=""2""><B>" + string(crcpro.regdt,"99/99/9999") + "</B></FONT></TD>" skip.
        end.
    end.
    put stream valut1 unformatted
    "</TABLE>" skip.

    {html-end.i "stream valut1" }

    output stream valut1 close.
    unix silent cptwin valut1.html excel.exe.
    pause 0.
end procedure.
