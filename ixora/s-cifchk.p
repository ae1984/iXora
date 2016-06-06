/* s-cifchk.p
 * MODULE
     Клиентская база
 * DESCRIPTION
     Контроль признаков клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.11
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   01.10.2002 nadejda - введено поле Форма собств - cif.prefix
   ...05.2003 nataly  - добавлены поля "дата рождения/регистрации", "место рег/должность"
   25.06.2003 nadejda - добавлено поле "категория клиента"
   04.11.2003 sasco - переделал весь пункт так, чтобы выводилось через верхние кнопки меню
   29.01.2004 nadejda - установка льготной группы вынесена в cif-lgot.p по ТЗ 707
   25.06.2004 dpuchkov - убрал второе поле обслуживает
   08.12.2004 saltanat - Вместо удаления исключении в тарификаторе запись отправляется в архив.
   03.05.2006 sasco    - убрал TRIM из поиска crg а то индекс не работал
   21/04/2008 madiyar - закомментил run несуществующей проги defexcl
   25/02/2010 galina - добавила поле место рождения
   11/04/2011 dmitriy - убрал cif.dba, добавил cif.coregdt, изменил в &update порядок вывода, если тип=B и группа=403.
   04.01.2012 damir - перекомпиляция в связи с изменением cif.f
   22.02.2013 dmitriy - ТЗ 1717. Ограничение доступа для просмотра карточки с типом B
   11.03.2013 Lyubov  - ТЗ 1742, не отображался срок действия УЛ, добавила поле в displ
   29.11.2013 Lyubov - ТЗ №2209, проставление признака VIP
*/

{mainhead.i}
define new shared stream cifedt.
define variable pcif like bcif.cif.
define variable vacc like jl.acc.

define new shared variable cif like cif.cif.
define new shared variable type like cif.type.
/*define new shared variable regdt like cif.regdt format "99/99/9999".*/
define new shared variable regdt as date format "99/99/9999".

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
define new shared variable who like cif.who.
define new shared variable cgr like cif.cgr.
define new shared variable stn like cif.stn.
define new shared variable jame like cif.jame.
define new shared var ofc like cif.ofc.
def new shared var tlx like cif.tlx.
def new shared var fname like cif.fname.
def new shared var fax like cif.fax.
define variable v-del as log.
def var vdep0 like ppoint.depart.
def var v-access as logi.
def var v-clnkat as char format "x(3)".

{sisn.i

&head="cif"

&headkey="cif"

&option = "CIFCHK"

&start = "g-cif = s-cif."

&end = "g-cif = ' '."

&noedt = false

&nodel = true

&postupdate = "if
/*cif.geo = '25' or cif.geo = '12' or cif.geo = '13' */
(substring(string(integer(cif.geo),'999'),3) eq '2'
or substring(string(integer(cif.geo),'999'),3) eq '3')
then do: v-ans = substring(cif.lgr,1,1) = 'Y'.
message 'Налогоплательщик?' update v-ans. if v-ans then substr(cif.lgr,1,1) = 'Y'.
else substr(cif.lgr,1,1) = 'N'. end. if cif.type entered or cif.mname entered or
/*regis2 entered or*/ regis1 entered or vpoint entered or vdep entered or cif.prefix entered or
 cif.sname entered or cif.coregdt entered or  cif.cust-since entered
or cif.pss entered or cif.addr[1] entered or cif.addr[2] entered
or cif.geo entered or cif.tel entered or apkal1 entered or cif.attn
entered or cif.cgr entered or cif.stn entered then do: cif.whn = g-today.
cif.who = g-ofc. end. cif.jame = string(vpoint * 1000 + vdep).
cif.citi = string(rezdate).
run cifproft. /*run defexcl.*/ "

&predelete = "v-del = false. run fcif(input g-cif, output v-del).
if not v-del then do: {imesg.i 2200}. next. end. "

&delete = " run cifdelete. "

&predisplay = " run accessB. if not v-access then return. if cif.type = 'X' then leave.
find ofc where ofc.ofc = g-ofc no-lock.
if not ((ofc.expr[5] matches ('*' + cif.type + '*')) or s-newrec) then leave.
if cif.jame <> '' then do : vpoint = integer(cif.jame) / 1000 - 0.5.
vdep = integer(cif.jame) - vpoint * 1000. end. else do:
find last ofchis where ofchis.ofc = g-ofc no-lock.
vpoint = ofchis.point. vdep = ofchis.dep. end. vdep0 = vdep.
find point where point.point = vpoint no-lock no-error.
if available point then pname = point.addr[1]. else pname = ''.
find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
if available ppoint then dname = ppoint.name. else dname = ''.
apkal1 = substr(cif.fname,1,8). regis1 = substr(cif.name,1,60).
regis2 = substr(cif.name,61,60). rezdate = date(cif.citi).
v-crgwho = ''. v-crgwhn = ?.
v-clnkat = cif.mname.
if cif.crg <> '' then do:
  find last crg where crg.crg = cif.crg and crg.stn = 1 use-index crg no-lock no-error.
  if available crg then do: v-crgwho = crg.who. v-crgwhn = crg.whn. end.
  else v-crgwho = '(нет)'. end.
"

displ c1 with frame cif.

&display = "display cif.cif cif.type cif.mname cif.regdt vpoint pname cif.pres cif.legal cif.ofc vdep dname cif.prefix cif.cust-since
  regis1 regis2 cif.sname v-crgwhn cif.ref[8] cif.sufix cif.expdt cif.dtsrokul cif.addr[1] v-crgwho cif.addr[2] cif.whn /* cif.addr[3]*/
cif.coregdt cif.who cif.pss cif.geo cif.tel cif.cgr cif.tlx apkal1 cif.fax rezdate
cif.attn cif.stn cif.bplace with frame cif."

&update = "update cif.type cif.mname with frame cif.
if cif.mname = 'VIP' then do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if not can-do(ofc.expr[1],'p00185') then do:
        message 'Нет прав для устновления клиенту VIP категории' view-as alert-box.
        cif.mname = v-clnkat.
        display cif.mname with frame cif.
    end.
end.
update vpoint validate(can-find(point where point.point = vpoint),'') with frame cif. find point where point.point = vpoint no-lock.
pname = point.addr[1].  display pname with frame cif.
update vdep validate(can-find(ppoint where ppoint.point = vpoint and
ppoint.dep = vdep),'') with frame cif. find ppoint where ppoint.point =
vpoint and ppoint.dep = vdep no-lock . dname = ppoint.name.
display dname with frame cif.

update cif.prefix when cif.type = 'b' cif.cust-since when cif.type = 'b'
regis1 validate(regis1 <> '','') /*regis2*/
cif.sname validate(cif.sname <> '','') cif.ref[8] cif.sufix  cif.expdt
cif.addr[1] cif.addr[2]  cif.coregdt cif.pss cif.tel cif.tlx cif.fax cif.geo
validate(can-find(geo where geo.geo = cif.geo),'') cif.cgr apkal1
validate(can-find(ofc where ofc.ofc = apkal1) or apkal1 = '','') rezdate
cif.attn cif.stn with frame cif.

cif.fname = apkal1 + fill(' ',9 - length(apkal1)) .
cif.name = regis1 + fill(' ',60 - length(regis1)) + regis2." }

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

procedure accessB:
    v-access = yes.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc and (lookup("P00178", ofc.expr[1]) > 0 or lookup("P00179", ofc.expr[1]) > 0 or lookup("P00180", ofc.expr[1]) > 0) and cif.type = "B" then do:
         message "Нет прав для просмотра карточки клиента с типом B" view-as alert-box buttons OK title "Внимание!".
         v-access = no.
    end.
end procedure.