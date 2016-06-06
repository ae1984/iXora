/* jaa_ncom.p
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
    KOMISIJA NO KASES  за обналичку **/



define output parameter j_param as character.
define output parameter j_templ as character.

define shared variable v_doc like joudoc.docnum.

define variable vdel as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
define variable jparr   as character format "x(20)".


find joudoc where joudoc.docnum eq v_doc no-lock no-error.


find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
if avail aaa then do:
   find sub-cod where sub-cod.sub eq "cln" and sub-cod.acc eq aaa.cif and
                     sub-cod.d-cod eq "clnsts" no-lock no-error.
                                
   if available sub-cod and sub-cod.ccode eq "1" then
      find tarif2 where tarif2.num + tarif2.kod eq "419" and tarif2.stat = 'r' no-lock.
   else find tarif2 where tarif2.num + tarif2.kod eq "409" and tarif2.stat = 'r' no-lock.
end.   

j_param = joudoc.docnum + vdel + string (joudoc.nalamt) + vdel +
    string (joudoc.comcur) + vdel + string (tarif2.kont) + vdel + 
    tarif2.num + tarif2.kod + " - " + tarif2.pakalp.

    j_templ = "JOU0025".
