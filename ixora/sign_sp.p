/* sign_sp.p
 * MODULE
        История выгрузки батчей в ПКБ
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
        08/08/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared var s-sp as integer.

DEFINE QUERY q-ppoint FOR ppoint.

DEFINE BROWSE b-ppoint QUERY q-ppoint DISPLAY ppoint.depart label '№' format '>>>9' ppoint.name label 'Наименование' format "x(50)" WITH 15 DOWN /*SEPARATORS*/.
DEFINE BUTTON bexit label 'Выход'.


DEFINE FRAME f-ppoint
    b-ppoint SKIP(1)
    bexit
    WITH 1 COLUMN SIDE-LABELS COLUMN 10 /*NO-BOX*/.



OPEN QUERY q-ppoint FOR EACH ppoint where ppoint.info[8] <> "1" and ppoint.name matches "*СП*" .


ON ENTRY OF b-ppoint do:
   message ppoint.depart.
end.

ON VALUE-CHANGED OF b-ppoint do:
   message ppoint.depart.
end.

ON return OF b-ppoint do:
   s-sp = ppoint.depart.
   hide FRAME f-ppoint.
   run sign_sp_ed.
   ENABLE ALL WITH FRAME f-ppoint.
end.




ENABLE ALL WITH FRAME f-ppoint.
WAIT-FOR CHOOSE OF bexit.
