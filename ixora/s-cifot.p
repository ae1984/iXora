/* s-cifot.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Главная процедура для меню Информация о клиентах и их счетах
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-1-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   01.10.2002 nadejda - введено поле Форма собств - cif.prefix
   ...05.2003 nataly  - добавлены поля "дата рождения/регистрации", "место рег/должность"
   25.06.2003 nadejda - добавлено поле "категория клиента"
   21.06.2004 dpuchkov - заменил поле "обслуживает" датой регистрации нерезидента
   07.09.2004 dpuchkov - добавил ограничение доступа на просмотр реквизитов клиента
   08.09.2004 dpuchkov - запись удачных попыток доступа
   03.05.2006 sasco    - убрал TRIM из поиска crg а то индекс не работал
   25/02/2010 galina - добавила поле место рождения
   11/04/2011 dmitriy - убрал cif.dba, добавил cif.coregdt, изменил в &update порядок вывода, если тип=B и группа=403
   24.05.2011 aigul - добавила срок действия УЛ
   13.06.2011 aigul - перекомпиляция в связи с изменениями с cif.f
   10.01.2012 damir - убрал редактирование regis2
   30.01.2013 evseev - tz-1646
   22.02.2013 dmitriy - ТЗ 1717. Ограничение доступа для просмотра карточки с типом B
   21/05/2013 Luiza  - ТЗ 1841. Ограничение доступа для просмотра карточки с типом B для пакета P00185
*/


{mainhead.i}
define new shared stream cifedt.
define variable pcif like bcif.cif.
define variable vacc like jl.acc.
define new shared variable cif like cif.cif.
define new shared variable type like cif.type.
define new shared variable regdt like cif.regdt.
define new shared variable name like cif.name.
define new shared variable sname like cif.sname.
define new shared variable dba like cif.dba.
define new shared variable coregdt like cif.coregdt.
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
define variable tdepth as character.
def var v-access as logi.

/*
def shared var apkal1 as char format "x(8)".
def shared var apkal2 as char format "x(8)".
def shared var regis1 as char format "x(60)".
def shared var regis2 as char format "x(60)".
  */
output stream cifedt to cifedt.out append.

{sisn.i
&head="cif"
&headkey="cif"
&option = "CIFSUBot"
&start = "g-cif = s-cif. "
&end = "g-cif = "" ""."
&noedt = true
&nodel = true
&postupdate = "/*
/*if cif.cif entered or cif.type entered or cif.mname entered or cif.regdt entered or
cif.name entered or cif.sname entered or cif.coregdt entered or
cif.pss entered or cif.addr[1] entered or cif.addr[2] entered or
cif.addr[3] entered or cif.geo entered or cif.tel entered or
cif.attn entered or cif.ofc entered or cif.cgr entered /* or
cif.jame entered */ then run cifdiff. */
cif.jame = string(vpoint * 1000 + vdep).*/"
&preupdate = "/* cif.who = g-ofc. cif.whn = g-today.  run cifset. */"
&delete = "/*delete cif.*/"
&predisplay = " run accessB. if not v-access then return. run cifsecure. if not l-cifsec then return.  find ofc where ofc.ofc = g-ofc no-lock.
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
   regis2 = substring(cif.name,61,60). rezdate = date(cif.citi).  /* apkal2 = substring(cif.fname,10,8).  */
if cif.crg <> '' then do:
  find last crg where crg.crg = cif.crg and crg.stn = 1 use-index crg no-lock no-error.
  if available crg then do: v-crgwho = crg.who. v-crgwhn = crg.whn. end.
  else v-crgwho = '(нет)'. end.
"
&display = " display cif.cif
cif.type  cif.mname cif.regdt vpoint  pname cif.ofc  vdep  dname cif.pres cif.legal cif.prefix cif.cust-since regis1 regis2
cif.sname v-crgwhn cif.ref[8] cif.sufix cif.expdt cif.addr[1] v-crgwho cif.addr[2] cif.whn /*cif.addr[3]*/
cif.coregdt cif.who cif.pss cif.geo cif.dtsrokul cif.doctype cif.tel cif.cgr cif.tlx
apkal1 cif.fax /*apkal2*/rezdate cif.attn cif.stn cif.bplace with frame cif.
"
&update = "/* update cif.type cif.mname vpoint
validate(can-find(point where point.point = vpoint),'') with frame cif.
find point where point.point = vpoint no-lock no-error.
pname = point.addr[1].  display pname with frame cif.
update vdep validate
(can-find(ppoint where ppoint.point = vpoint and ppoint.dep = vdep),'')
with frame cif. find ppoint where ppoint.point = vpoint and
ppoint.dep = vdep no-lock no-error. dname = ppoint.name.
display dname with frame cif. update regis1 validate(regis1 <> '','')
/*regis2*/ cif.sname validate(cif.sname <> '','')
cif.addr[1] cif.addr[2] cif.whn  cif.addr[3]
cif.whn cif.coregdt cif.pss
cif.geo cif.dtsrokul cif.doctype cif.tel cif.cgr cif.tlx apkal1 cif.fax apkal2
cif.attn cif.stn with frame cif.*/" }
output stream cifedt close.


procedure cifsecure.
   l-cifsec = True.
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
             ciflog.menu = "1.1 Информация о клиентах и их счетах" .
             message "Клиент не Вашего Департамента" view-as alert-box buttons OK .
             leave.
       end.
       else
       do:
         create ciflogu.
         assign
           ciflogu.ofc = g-ofc
           ciflogu.jdt = today
           ciflogu.sectime = time
           ciflogu.cif = s-cif
           ciflogu.menu = "1.1 Информация о клиентах и их счетах" .
           l-cifsec = True.
       end.
   end.

end procedure.

procedure accessB:
    v-access = yes.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc and (lookup("P00178", ofc.expr[1]) > 0 or lookup("P00179", ofc.expr[1]) > 0 or lookup("P00180", ofc.expr[1]) > 0 or lookup("P00185", ofc.expr[1]) > 0) and cif.type = "B" then do:
         message "Нет прав для просмотра карточки клиента с типом B" view-as alert-box buttons OK title "Внимание!".
         v-access = no.
    end.
end procedure.

/*  run menudepth ("", nmenu.fname, output tdepth). */












