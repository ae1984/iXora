/* odeltrx.p
 * MODULE
        Контроль удаленных транзакции
 * DESCRIPTION
        Заведение контроллирующих лиц по департаментам.
 * RUN
        П.м. 2-7-3
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        2-7-3
 * AUTHOR
        04.03.05 saltanat
 * CHANGES
        25/06/2009 madiyar - расширил фрейм
*/
{mainhead.i}

define variable v-dep as char.
define variable v-depname as char.
def var v-cod as char init '000,001,002,003,004,msc'.
def var v-ex as logical.

define frame fr
       v-dep label 'Департамент' format 'x(3)' help ' F2 - список Департаментов'
             validate(can-find(codfr where codfr.codfr = 'sproftcn' and
                               codfr.code = v-dep and codfr.code matches '...' and lookup(codfr.code,v-cod) = 0 no-lock), ' Ошибочный код Департамента - повторите ! ')
       v-depname no-label format 'x(50)' skip
       trxdel_control_ofc.control_ofc  label 'Контролирующие лица' format 'x(1000)' view-as fill-in size 86 by 1 skip
       v-ex label 'Выйти'
with side-labels width 110 row 4 title 'Выберите департамент у которого редактируются контролирующие лица'.

on help of v-dep in frame fr do:
  {itemlist.i
       &file = "codfr"
       &frame = "row 6 scroll 1 12 down overlay "
       &where = " codfr.codfr = 'sproftcn' and codfr.code matches '...' and lookup(codfr.code,v-cod) = 0 "
       &flddisp = " codfr.code label 'Код' codfr.name[1] label 'Департамент' format 'x(50)'
                  "
       &chkey = "code"
       &chtype = "string"
       &index  = "cdco_idx"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
  }
  v-dep = codfr.code.
  v-depname = codfr.name[1].
  displ v-dep v-depname with frame fr.
end.

repeat:
v-ex = no.
v-dep = ''.
v-depname = ''.
update v-dep with frame fr.
if v-depname = '' then do:
   find first codfr where codfr.codfr = 'sproftcn' and codfr.code = v-dep no-lock no-error.
   if not avail codfr then do:
      message 'В справочнике нет данных! ' view-as alert-box buttons ok.
      return.
   end.
   else do:
      v-depname = codfr.name[1].
      displ v-dep v-depname with frame fr.
   end.
end.

find trxdel_control_ofc where trxdel_control_ofc.dep = v-dep exclusive-lock no-error.
if not avail trxdel_control_ofc then do:
   create trxdel_control_ofc.
   assign trxdel_control_ofc.dep = v-dep.
end.

update trxdel_control_ofc.control_ofc v-ex with frame fr.

if v-ex then leave.
end.
