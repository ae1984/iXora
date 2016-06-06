/* applhelp.p
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
        07/06/2007 madiyar - удалил вызов image.p - не нужен
*/

/* applhelp.p
   Application Help
*/

define var v-fields    as cha initial "gl,bank,cif,base,lon,lcr,bill,code".
define var v-addprog   as cha.
define var v-listprog  as cha initial
       "gllst,h-bank,ciflst,baselst,lonlst,lcrlst,q-bill,nmbrlst,
h-calc,amort,h_calend,vouadv,aaalst,h-crc,v-crc".

define var v-slct    as int format "99".
define var position  as int.
define var support   as log.
define var procedure as cha.
define var v-fldname as cha.

if frame-field begins "v-" or frame-field begins "s-" or
   frame-field begins "g-" then do:
  v-fldname = substring(frame-field,3).
end.
else
  v-fldname = frame-field.

   def var trxsts as log init no.
   trxsts = TRANSACTION.
/*   message "Транзакция? " trxsts "Процедура" PROGRAM-NAME(3). */

if frame-file ne "" and search("h-" + frame-file + v-fldname + ".r") ne ?
  then run value("h-" + frame-file + v-fldname).
else if search("h-" + v-fldname + ".r") ne ?
  then run value("h-" + v-fldname).
else do:
  position = lookup(v-fldname,v-fields).

  if position > 0 then do:
    support = true.
  end.

  {applhelp.f}

  if support eq false then do on error undo,retry:
    view frame heading.
    set v-slct validate(v-slct ge 0 and v-slct le 15 ,"Enter 1 to 14")
        with frame menu.
    procedure = entry(v-slct,v-listprog).

    run value(procedure).
  end.
  else do:
    procedure = entry(position,v-listprog).
    pause 0.
    run value(procedure).
  end.
end.
