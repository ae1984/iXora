/* s-cifcod.p
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
        29.01.2004 nadejda - установка льготной группы вынесена в cif-lgot.p по ТЗ 707
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        08.12.2004 saltanat - Вместо удаления исключении в тарификаторе запись отправляется в архив
        11/04/2011 dmitriy - убрал cif.dba, добавил cif.coregdt, изменил в &update порядок вывода, если тип=B и группа=403.
        10.01.2012 damir - убрал редактирование regis2
*/

 /* s-cifcod.p
 * Модуль
     Клиентская база
 * Назначение
     Ввод и редактирование данных КОДИРОВАННЫХ клиента, открытие счетов
 * Применение
     только старшие менеджеры
 * Вызов
     cifedtc.p
 * Меню
     1.4

 * Автор
     ...
 * Дата создания:
     ...
 * Изменения
   01.10.2002 nadejda - введено поле Форма собств - cif.prefix
   25.06.2003 nadejda - добавлено поле "категория клиента"
*/

{mainhead.i}
define new shared stream cifedt.
define variable pcif like bcif.cif.
define variable vacc like jl.acc.

define new shared variable cif like cif.cif.
define new shared variable r-cif like cif.cif.
define new shared variable type like cif.type.
define new shared variable regdt like cif.regdt.
def new shared var lname like cif.lname.
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
define new shared variable stn like cif.stn.
define new shared variable jame like cif.jame.
def new shared var tlx like cif.tlx.
def new shared var fname like cif.fname.
def new shared var fax like cif.fax.
define variable v-del as log.
def new shared temp-table wcif like cif.
def var vdep0 like ppoint.depart.

{sisn.i
&head="cif"
&headkey="cif"
&post="cod"
&option = "CIFSUB"
&start = "g-cif = s-cif. find cif where cif.cif = s-cif.
create wcif. r-cif = cif.cif. wcif.cif = r-cif. run xdatain. "
&end = "g-cif = "" "". r-cif = cif.cif. run xdataou. delete wcif."
&noedt = false
&nodel = false
&postupdate = "if
/*cif.geo eq '25' or cif.geo eq '12' or cif.geo eq '13' */
(substring(string(integer(cif.geo),'999'),3) eq '2'
or substring(string(integer(cif.geo),'999'),3) eq '3')
then do: v-ans = substring(cif.lgr,1,1) eq 'Y'.
message 'Налогоплательщик ? ' update v-ans.
if v-ans then substring(cif.lgr,1,1) = 'Y'. else substring(cif.lgr,1,1) = 'N'.
end. cif.jame = string(vpoint * 1000 + vdep). run cifproft. run defexcl."
&predelete = " v-del = false.
run fcif(input g-cif, output v-del).
if not v-del then do: {imesg.i 2200}. pause. next. end. "
&preupdate = "cif.whn = g-today. cif.who = g-ofc .  "
&delete = " run cifdelete. "
&predisplay = "if (cif.type ne 'X') and (not s-newrec) then leave.
if s-newrec then cif.type = 'X'. find ofc where ofc.ofc = g-ofc no-lock.
if not ((ofc.expr[5] matches ('*' + cif.type + '*')) or s-newrec) then leave.
if cif.jame <> '' then do :
   vpoint =  integer(cif.jame) / 1000 - 0.5 .
   vdep = integer(cif.jame) - vpoint * 1000.
end. else do :
  find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
  vpoint = ofchis.point. vdep = ofchis.dep. end.  vdep0 = vdep.
   find point where point.point = vpoint no-lock no-error.
   if available point then pname = point.addr[1]. else pname = ''.
   find ppoint where ppoint.point = vpoint and ppoint.dep = vdep
        no-lock no-error.
   if available ppoint then dname = ppoint.name. else dname = ''.
   apkal1 = substring (cif.fname,1,8). regis1 = substring(wcif.name,1,60).
  regis2 = substring(wcif.name,61,60). apkal2 = substring(cif.fname,10,8).   "
&display = " display cif.cif cif.type cif.mname cif.regdt vpoint pname cif.ofc
vdep dname cif.pres cif.legal cif.prefix cif.cust-since regis1
regis2 wcif.sname wcif.addr[1] wcif.addr[2] cif.whn
wcif.addr[3] cif.who wcif.coregdt wcif.pss cif.geo wcif.tel cif.cgr
wcif.tlx apkal1 wcif.fax apkal2 wcif.attn
cif.stn with frame cifcod."
&update = "update vpoint
validate(can-find(point where point.point = vpoint),'') with frame cifcod.
find point where point.point = vpoint no-lock no-error.
pname = point.addr[1]. display pname with frame cifcod.
update vdep validate
(can-find(ppoint where ppoint.point = vpoint and ppoint.dep = vdep),'')
with frame cifcod. find ppoint where ppoint.point = vpoint and
ppoint.dep = vdep no-lock no-error. dname = ppoint.name.
display dname with frame cifcod.
update cif.prefix when cif.type = 'b' cif.cust-since when cif.type = 'b'
regis1 validate(regis1 <> '','')
/*regis2*/ wcif.sname validate(wcif.sname <> '','')
wcif.addr wcif.coregdt wcif.pss wcif.tel wcif.tlx wcif.fax cif.geo
cif.cgr apkal1 validate (can-find(ofc where ofc.ofc = apkal1) or
apkal1 = '' ,'') apkal2 validate (can-find(ofc where ofc.ofc = apkal2)
or apkal2 = '','') wcif.attn   cif.stn with frame cifcod.
cif.fname = apkal1 + fill(' ',9 - length(apkal1)) + apkal2.
wcif.name = regis1 + fill(' ',60 - length(regis1)) + regis2."}
/*output stream cifedt close.*/

/* если не указан Профит-центр для клиента - указать по логину менеджера счета */
procedure cifproft.
def var prof-prefix as char.
  find sub-cod where sub-cod.sub = 'cln' and sub-cod.d-cod = 'sproftcn' and sub-cod.acc = s-cif no-error.
  if not available sub-cod then do:
    create sub-cod.
    assign sub-cod.sub = 'cln'
           sub-cod.d-cod = 'sproftcn'
           sub-cod.acc = s-cif
           sub-cod.ccode = ofc.titcd
           sub-cod.rdt = g-today
           sub-cod.ccode = 'msc'.
  end.

  if sub-cod.ccode = 'msc' or vdep0 <> vdep then do:
    /* по департаменту - если центр.офис, то 103 */
    if vdep = 1 then
      sub-cod.ccode = '103'.
    else do:
      /* коды РКО в зависимости от филиала - Алматы A, Астана B, Уральск C - как в RMZ */
      /* коды РКО в зависимости от филиала - Алматы A, Астана B, Уральск C */
      find sysc where sysc.sysc = "PCRKO" no-lock no-error.
      if not available sysc then prof-prefix = 'U'.
      else prof-prefix = trim(sysc.chval).
      sub-cod.ccode = prof-prefix + string(vdep, '99').
    end.
  end.
end procedure.

procedure cifdelete.
/* удалить связанные записи  */
  for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif. delete sub-cod. end.
  for each tarifex where tarifex.cif = s-cif and tarifex.stat <> 'a' share-lock.
           /*delete tarifex. */
           tarifex.stat = 'a'.
           tarifex.delwho = g-ofc.
           tarifex.delwhn = g-today.
           tarifex.dwtim  = time.
           run tarifexhis_update.
  end.
  find cif where cif.cif = s-cif.
  delete cif.
end procedure.

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
create tarifexhis.
assign tarifexhis.cif    = tarifex.cif
       tarifexhis.kont   = tarifex.kont
       tarifexhis.pakalp = tarifex.pakalp
       tarifexhis.ost    = tarifex.ost
       tarifexhis.proc   = tarifex.proc
       tarifexhis.max1   = tarifex.max1
       tarifexhis.min1   = tarifex.min1
       tarifexhis.str5   = tarifex.str5
       tarifexhis.crc    = tarifex.crc
       tarifexhis.who    = tarifex.who
       tarifexhis.whn    = tarifex.whn
       tarifexhis.wtim   = tarifex.wtim
       tarifexhis.akswho = tarifex.akswho
       tarifexhis.akswhn = tarifex.akswhn
       tarifexhis.awtim  = tarifex.awtim
       tarifexhis.delwho = tarifex.delwho
       tarifexhis.delwhn = tarifex.delwhn
       tarifexhis.dwtim  = tarifex.dwtim
       tarifexhis.stat   = tarifex.stat.
end procedure.

