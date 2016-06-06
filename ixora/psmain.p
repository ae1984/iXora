/* psmain.p
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

{global.i}
{ps-prmt.i}
/* psmain.p
*/

define var v-fields    as cha initial "gl,bank,cif,base,lon,lcr,bill,code".
define var v-addprog   as cha.
define var v-listprog  as cha initial
       "ps-setup,k0-ptyp,k-fproc,k-route,k-bankl,
remtrz,psprt,pssecset,psdclose,psprt1,movedarc".

define var v-slct    as int format "99".
define var position  as int.
define var support   as log.
define var procedure as cha.
define var v-fldname as cha.
repeat :

  {psmain.f}
 do on error undo,retry:
    view frame heading.
    set v-slct validate(v-slct ge 0 and v-slct le 15 ,"Введите от 1 до 14")
        with frame menu.
    procedure = entry(v-slct,v-listprog).
    run value(procedure).
  end.
end .
