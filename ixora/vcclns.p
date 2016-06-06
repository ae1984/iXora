/* vcclns.p
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

/* vcclns.p Валютный контроль
 * Модуль
     Валютный контроль
 * Назначение
     Просмотр данных клиента, переход к контрактам
 * Применение
     Отдел валютного контроля и менеджеры СПФ
 * Вызов
     vccln.p
 * Меню
     15.1

 * Автор
     nadejda
 * Дата создания:
     18.10.2002
 * Изменения
     25.06.2004 - dpuchkov убрал второе поле обслуживает
     03.09.2004 dpuchkov - добавил ограничение доступа для менеджеров на просмотр реквизитов клиентов
     08.08.2004 dpuchkov - перекомпиляция.
     25/02/2010 galina - добавила поле место рождения
     14.04.2011 aigul - в связи с изменениями проги cif.f изменила cif.dba на cif.coregdt
*/

{vc.i}

{mainhead.i}

define variable pcif like bcif.cif.
define variable vacc like jl.acc.
define new shared variable cif like cif.cif.
define new shared variable type like cif.type.
define new shared variable regdt like cif.regdt.
define new shared variable name like cif.name.
define new shared variable sname like cif.sname.
define new shared variable dba like cif.dba.
define new shared variable pss like cif.pss.
define new shared variable addr like cif.addr.
define new shared variable geo like cif.geo.
define new shared variable tel like cif.tel.
define new shared variable attn like cif.attn.
define new shared variable ofc like cif.ofc.
define new shared variable cgr like cif.cgr.
define new shared variable jame like cif.jame.
def new shared var tlx like cif.tlx.
def new shared var fname like cif.fname.
def new shared var lname like cif.lname.
def var v-del as log.
define var l-cifsec as logical init false.

{sisn.i
&head="cif"
&headkey="cif"
&option = "VCCLNS"
&start = "g-cif = s-cif. "
&end = "g-cif = "" ""."
&noedt = true
&nodel = true
&postupdate = " "
&preupdate = " "
&delete = " "
&predisplay = "  run cifsecure. if not l-cifsec then return.  find ofc where ofc.ofc = g-ofc no-lock.
if not ((ofc.expr[5] matches ('*' + cif.type + '*')) or s-newrec) then leave.
if cif.jame <> '' then do :
   vpoint =  integer(cif.jame) / 1000 - 0.5 .
   vdep = integer(cif.jame) - vpoint * 1000.
end. else do :
  find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
  vpoint = ofchis.point. vdep = ofchis.dep.
end.
   find point where point.point = vpoint no-lock no-error.
   if available point then pname = point.addr[1]. else pname = ''.
   find ppoint where ppoint.point = vpoint and ppoint.dep = vdep
        no-lock no-error.
   if available ppoint then dname = ppoint.name. else dname = ''.
   apkal1 = substring (cif.fname,1,8). regis1 = substring(cif.name,1,60).
   regis2 = substring(cif.name,61,60). rezdate = date(cif.citi).
if cif.crg <> '' then do:
  find crg where trim(crg.crg) = trim(cif.crg) and crg.stn = 1 use-index crg no-lock no-error.
  if available crg then do: v-crgwho = crg.who. v-crgwhn = crg.whn. end.
  else v-crgwho = '(нет)'. end. "
&display = " display cif.cif
cif.type  cif.regdt vpoint  pname cif.ofc  vdep  dname cif.prefix cif.cust-since regis1 regis2
cif.sname v-crgwhn cif.ref[8] v-crgwho cif.addr[1] cif.addr[2] cif.whn /*cif.addr[3]*/ cif.who
cif.coregdt cif.pss cif.geo cif.tel cif.cgr cif.tlx
apkal1 cif.fax rezdate cif.attn cif.stn cif.bplace with frame cif. "
&update = " " }



procedure cifsecure.
   find last cifsec where cifsec.cif = s-cif no-lock no-error .
   if avail cifsec then do: /*логины есть*/
       find last cifsec where cifsec.cif = s-cif and cifsec.ofc = g-ofc no-lock no-error.
       if not avail cifsec then
       do:
          l-cifsec = False.
          create ciflog.
          assign
             ciflog.ofc = g-ofc
             ciflog.jdt = today
             ciflog.sectime = time
             ciflog.cif = s-cif
             ciflog.menu = "15.1 Клиенты и контракты" .
             message "Клиент не Вашего Департамента" view-as alert-box buttons OK .
             leave.
       end. else
       do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = s-cif
            ciflogu.menu = "15.1 Клиенты и контракты" .
          l-cifsec = True.
       end.
   end.
   else
     l-cifsec = True.
end procedure.










