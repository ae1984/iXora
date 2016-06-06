/* jaa_tcom.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

/**  jaa_tcom.p  
    KOMISIJA NO KASES  **/



define output parameter j_param as character.
define output parameter j_templ as character.

define shared variable v_doc like joudoc.docnum.

define variable vdel as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
define variable jparr   as character format "x(20)".


find joudoc where joudoc.docnum eq v_doc no-lock no-error.
find tarif2 where tarif2.num + tarif2.kod eq joudoc.comcode and tarif2.stat = 'r' no-lock.

j_param = joudoc.docnum + vdel + string (joudoc.comamt) + vdel +
    string (joudoc.comcur) + vdel + string (tarif2.kont) + vdel + 
    tarif2.pakalp.

j_templ = "JOU0025".
