/* vccardd.p
 * MODULE
        Валюный контроль
 * DESCRIPTION
        Удаление ЛКБК и истории по ней
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
        14/08/2009 galina
 * BASES
        BANK COMM
 * CHANGES
11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp

*/

{global.i}



def shared var s-contract like vccontrs.contract.
def var v-ans as logi.
find first vccontrs where vccontrs.contract = s-contract no-lock.
if vccontrs.cardnum <> '' then do:

   find first ofc where ofc.ofc = g-ofc no-lock.
   if not avail ofc then return.
   if lookup('P00126', ofc.expr[1]) = 0 then do:
     message 'У вас нет прав на удаление ЛК!' view-as alert-box title 'ВНИМАНИЕ'.
     return.
   end.

   message skip " Удалить ЛК?"
   skip(1) view-as alert-box buttons yes-no title " ВНИМАНИЕ ! " update v-ans.
   if v-ans then do:
        find current vccontrs exclusive-lock.
        assign
        vccontrs.cardsend = no
        vccontrs.cardnum = ''
        vccontrs.cardfirstdt = ?
        vccontrs.cardfirstmsg = ''
        vccontrs.cardsenddt = ?
        vccontrs.cardlastdt = ?
        vccontrs.cardlastmsg = ''
        vccontrs.cardtype = ''
        vccontrs.info[10] = ''.

        find current vccontrs exclusive-lock.

        for each vcdocs where vcdocs.contract = vccontrs.contract and vcdocs.dntype = '40' exclusive-lock:
          delete vcdocs.
        end.
   end.
end.
