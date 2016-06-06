/* ibplm4a.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Контроль кодового слова платежа Интернет-офиса - автоматически
        подтягивается из оригинального документа 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
       ibplm4.p
 * MENU
            5.2.8
 * AUTHOR
            30.07.2003 sasco
 * CHANGES
        31/10/03 sasco проверка кодовой фразы на принадлежность данному CIF
*/

define shared variable s-remtrz like remtrz.remtrz.

find ib.doc where ib.doc.remtrz = s-remtrz no-lock no-error.
if not avail ib.doc then do:
   message "Нет документа в Интернет Офисе для" s-remtrz view-as alert-box title "".
   return.
end.

find ib.usr where ib.usr.id = ib.doc.id_usr no-lock no-error.

run ibchkke1(ib.doc.ibinfo[4], (if available ib.usr then ib.usr.cif else '?') ).
