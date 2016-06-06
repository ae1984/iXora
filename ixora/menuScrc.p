/* menuScrc.p
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
        31/12/99 pragma
 * CHANGES
*/

/*############################################*/
/* last change: 06/02/2002 sasco 
               + настройка принтера из OFC. 
               + курсы - средневзвешенные! ! ! ! ! ! */
/*############################################*/

def input parameter dt1 as date format "99/99/9999".
def input parameter dt2 as date format "99/99/9999".
define var o_name as character format 'x(18)'.
define var valkod as integer.
DEFINE VARIABLE msg  AS CHARACTER EXTENT 7.
DEFINE VARIABLE i    AS INTEGER INITIAL 1.
DEFINE VARIABLE ikey AS INTEGER INITIAL 1.
DEFINE VARIABLE newi AS INTEGER INITIAL 1.

DISPLAY SKIP(1)
'Доллары США '  @ msg[1] ATTR-SPACE format 'x(12)'
skip(0)
'Немецкие марки'    @ msg[2] ATTR-SPACE format 'x(14)'
skip(0)
'Российские рубли'   @ msg[3] ATTR-SPACE format 'x(16)'
skip(0)
'Евро'      @ msg[4] ATTR-SPACE format 'x(4)'
skip(0)
'Швейцарские франки'    @ msg[5] ATTR-SPACE format 'x(18)'
skip(0)
'Украинские гривны'   @ msg[6] ATTR-SPACE format 'x(17)'
skip(0)
'Выход'     @ msg[7] ATTR-SPACE format 'x(5)'
WITH CENTERED FRAME menu row 10 NO-LABELS 
TITLE '[Выберите валюту : ]' top-only.

REPEAT:
    REPEAT:
        COLOR DISPLAY MESSAGES msg[i] WITH FRAME menu.
        READKEY.
        CASE LASTKEY:
            WHEN KEYCODE('CURSOR-DOWN') THEN 
                DO:
                    newi = i + 1.
                    IF newi > 7 THEN newi = 1.
                END.
            WHEN KEYCODE('CURSOR-UP')  THEN 
                DO:
                    newi = i - 1.
                    IF newi < 1 THEN newi = 7.
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
        WHEN 2 THEN do:
                    o_name='  Немецкие марки  '.
                    valkod = 3.
                    end .
        WHEN 3 THEN do:
                    o_name=' Российские рубли '.
                    valkod = 4.
                    end.
        WHEN 4 THEN do:
                    o_name='       Евро       '.
                    valkod = 3.
                    end.
        WHEN 5 THEN do:
                    o_name='Швейцарские франки'.
                    valkod = 12.
                    end .      
        WHEN 6 THEN do:
                    o_name='Украинские гривны '.
                    valkod = 5.
                    end.
        WHEN 7 THEN leave. 
    END CASE.
   run pois_ist(dt1,dt2,valkod,o_name).
   pause 0 before-hide.
   run menu-prt('valutr.txt').
   pause before-hide.
/*    unix silent value( 'clear' ).
    PAUSE 0 no-message.*/

END.

RETURN.
/***/

procedure pois_ist.
def input parameter dt11 as date format "99/99/9999".
def input parameter dt12 as date format "99/99/9999".
def input parameter vak as int.
def input parameter cnamev as char format 'x(18)'.
def var zagol as char format 'x(28)'.
zagol = 'С ' + string( dt11, '99/99/9999' ) + 'г ПО ' + string( dt12, '99/99/9999' ) + 'г'.
output to 'valutr.txt'.
 display space(13) 'КУРСЫ ВАЛЮТ ' skip(1)
         space(4) zagol no-label skip(1)
         space(10) cnamev no-label skip(1)
         space(4) 'Валюта      Курс   Установлен  '
         with centered frame aass.
   
for each crchis where crchis.crc = vak and crchis.rdt >= dt11 and crchis.rdt <= dt12 no-lock  :
             /* if not avail crchis then next.*/
             displ 
             crchis.crc     no-label
             crchis.code    no-label
             crchis.rate[1] no-label
             crchis.rdt     no-label   with no-label centered .
           /*  crchis.des     no-label with no-label centered .*/
end.

/* прогонка принтера, чтобы бумагу не выкручивать вручную */
find first ofc where ofc.ofc = userid('bank').
if ofc.mday[2] = 1 then put skip(14).
                   else put skip(1).

output close.
end procedure.             
