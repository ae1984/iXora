/* ibplm4b.p
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
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


define shared variable s-remtrz like remtrz.remtrz.

if s-remtrz <> "" then do:
find ib.doc where ib.doc.remtrz = s-remtrz no-lock no-error.
if not avail ib.doc then do:
   message "Нет документа в Интернет Офисе для" s-remtrz view-as alert-box title "".
   return.
end.

find ib.usr where ib.usr.id = ib.doc.id_usr no-lock no-error.

run ibchkke1(ib.doc.ibinfo[4], (if available ib.usr then ib.usr.cif else '?') ).
end.

else run ibchkke1('', '?' ).
