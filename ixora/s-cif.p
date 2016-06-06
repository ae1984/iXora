/* s-cif.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Ввод и редактирование данных клиента, открытие счетов
        для ФЛ - менеджеры
        для ЮЛ - только старшие менеджеры
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        01.10.2002 nadejda  - введено поле Форма собств - cif.prefix
        ...05.2003 nataly   - добавлены поля "дата рождения/регистрации", "место рег/должность"
        25.06.2003 nadejda  - добавлено поле "категория клиента"
        05.11.2003 sasco    - проверка cif.crg при редактировании данных.
                              Если cif.crg есть, то запрет редактирования и вызова пунктов верхнего меню.
        29.01.2004 nadejda  - установка льготной группы вынесена в cif-lgot.p по ТЗ 707
        03.06.2004 dpuchkov - добавил возможность ввода даты регистрации нерезидента
        24.06.2004 dpuchkov - убрал поле "обслуживает"
        01.09.2004 dpuchkov - добавил ограничение доступа для менеджеров на просмотр реквизитов клиентов
        02.09.2004 dpuchkov - запись неудачных попыток в лог.
        23.11.2004 dpuchkov - можно редактировать адрес и телефон без акцепта ст менеджера ТЗ 1220.
        08.12.2004 saltanat - Вместо удаления исключении в тарификаторе запись отправляется в архив.
        21.12.2004 dpuchkov - добавил возможность редактирования поля 'Внимание' без акцепта ст менеджера ТЗ 1258
        03.05.2006 sasco    - убрал TRIM из поиска crg а то индекс не работал
        04/08/06 nataly     - нулевая комиссия для сотрудников
        09/07/08 marinav перекомпил
        05.08.08 galina - ввод сведений по удостоверению личности для физического лица в определенном формате
                          ввод геокода клиента перед вводом сведений по удостоверению личности
        13.08.2008 galina - проверка на колличество введенных цифр в номере удостоверения убрана
                            добавлен ЗАГС в органы выдачи документов
        19.08.2008 galina - отображение сведений по удостоверению личности для физического лица в форме редактирования
        22/08/08 marinav - при изменении ФИО старое сохраняется в т-це clfilials
        10.10.2008 alex     - возможность работать без акцепта
        12/03/09 marinav - проверка клиента на специнструкции
        29.04.2009 galina - редактируем паспортные данные ИП как для физ. лица в определенном формате
        22.06.2009 galina - редактируем группу клиента до ввода паспортных данных
        24/11/2009 galina - Мадияр поправил ввод паспортных данных
        25/11/2009 galina - перекомпеляция
        25/02/2010 galina - вынесла ввод адреса в новую форму и добавила поле место рождения для ФЛ
        01/03/2010 madiyar - перекомпиляция
        10/03/2010 galina - перекомпиляция
        11/03/2010 galina - перекомпиляция
        15/03/2010 galina - перекомпиляция
        24/01/2011 evseev - добавил шареные переменные s-name s-geo. Автозаполнение кода страны в юр.адресе, гео-кода, полного наименования
        02/02/2011 evseev - добавил условие если переменная s-geo не имеет значение, то не срабатывает Автозаполнение кода страны в юр.адресе,
                            гео-кода, полного наименования
        09/03/2011 madiyar,evseev - отработку {adres.i} сделали через getAddr из-за переполнения буфера &update
        09/03/2011 evseev - убрал отадочный message
        11/04/2011 dmitriy - убрал cif.dba, добавил cif.coregdt, изменил в &update порядок вывода, если тип=B и группа=403.
        13/04/2011 madiyar - не редактировался номер документа, исправил
        24.05.2011 aigul - добавила срок действия УЛ
        13.06.2011 aigul - перекомпиляция в связи с изменениями с cif.f
        13/06/2011 lyubov - убрала возможность редактирования гео-кода и группы при открытии счета бездействующему налогоплательщику
        20/06/2011 lyubov - вернула старую версию (Служебная записка от 17.06.2011 г. об отмене ТЗ)
        10.01.2012 damir - убрал редактирование regis2
        06/02/2012 dmitriy - автозаполнение справочника (ТЗ 1076)
        29.03.2012 aigul - если факт адрес совпадает с юр адресом, то скопировать данные из юр адреса в факт адрес
        31/05/2012 dmitriy - при заведении карточки поле Паспорт не активно для заполнения, если тип "В" и группа 403,405,501
        20/12/2012 madiyar - добавил проверку на связанность сразу после заведения карточки
        30.01.2013 evseev - tz-1646
        22.02.2013 dmitriy - ТЗ 1717. Ограничение доступа для просмотра карточки с типом B
        13.06.2013 damir - Внедрено Т.З. № 1876..
        02/08/2013 Zhasulan - ТЗ 1993. Корректировка поля "МЕСТО РЕГ/ДОЛ"
        23.09.2013 damir - Внедрено Т.З. № 2098.
        18.10.2013 Lyubov - ТЗ 1999, ввод ФИО в три отдельные поля
        30.10.2013 evseev - tz1890
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

def var v-pss as char format "x(9)".
def var v-issuredby as char format "x(9)".
def var v-pssdt  as date format "99/99/9999".
def var v-famil  as char format "x(30)".
def var v-imya   as char format "x(30)".
def var v-otches as char format "x(30)".
def var v-clnkat as char format "x(3)".
def var v-sel as integer.
def var i as integer.
def var j as integer.
def var v-vyd as char.
def var id as inte.
define var l-cifsec as logical init false.
def var v-access as logi.

def var badChars as char init '`()!@№#$%^&?*_+=:;}<>|/[]'.
def var currIndex as inte.
def var correct as logi.
def var v-oldfax as char.

badChars = badChars + chr(123) + chr(126) + chr(92).

define frame newFrame skip(1) cif.sufix format "x(255)" view-as fill-in size 100 by 1 skip
             with width 105 overlay row 10 no-label title "Место регистрации/Должность".

def shared var s-name like cif.name.
def shared var s-geo as char.

/***********************/
/***********************/

def buffer b-pcstaff0 for comm.pcstaff0.

def var v-addr as char no-undo.
def var v-days as int.

def var v-adr as logical.
{adres.f}

procedure getAddr.
    def input-output parameter v-adres_o as char no-undo.
    v-adres = v-adres_o.
    {adres.i}
    v-adres_o = v-adres.
end procedure.

def var v-our as logical init false no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and  sysc.chval  = 'TXB00' then v-our = true.

/*29.01.2004 nadejda def var v-pres as char.*/

form
 v-pss label "Номер" format "x(16)" validate(v-pss <> '', "Введите номер документа!") skip
 v-pssdt label "Дата" format "99/99/9999" validate(v-pssdt <> ?, "Введите дату регистрации документа!") skip
 v-issuredby label "Кем выдано" format "x(15)" help "F2 - справочник" skip
 with side-label overlay row 17 column 14 title "ПАСПОРТ/УДОС " frame f-pass.

form
 v-famil  label "Фамилия  " format "x(30)" validate(v-famil <> '', "Введите фамилию!") skip
 v-imya   label "Имя      " format "x(30)" validate(v-imya  <> '', "Введите имя!") skip
 v-otches label "Отчество " format "x(30)" skip
 with side-label overlay row 9 column 14 title "ФИО клиента " frame f-fio.

do transaction on error undo, retry:
{cifnoacc.i}
end.


{sisn-crg.i

&head="cif"

&headkey="cif"

&option = "CIFSUB"

&start = "g-cif = s-cif."

&end = "g-cif = ' '."

&noedt = false

&nodel = false

&checkpermission = " permis () "

&nopermission = "
                  v-title = 'Юридический адрес'. v-addr = cif.addr[1]. run getAddr(input-output v-addr). cif.addr[1] = v-addr.
                  v-title = 'Фактический адрес'. v-addr = cif.addr[2]. run getAddr(input-output v-addr). cif.addr[2] = v-addr.
                  display cif.addr[1] cif.addr[2] with frame cif.
                  v-oldfax = cif.fax.
                  update cif.dtsrokul cif.tel cif.tlx cif.fax cif.attn with frame cif.
                  if cif.type = 'P' then update cif.doctype with frame cif.
                  message 'У вас нет прав делать это! Необходимо снять ацепт клиента ст. менеджером' view-as alert-box title ''.

                  if cif.fax entered and v-oldfax <> cif.fax then do:
                      find last b-pcstaff0 where b-pcstaff0.cif = cif.cif exclusive-lock no-error.
                      if avail b-pcstaff0 then b-pcstaff0.tel[2] = trim(cif.fax).
                  end.
                  "
&postupdate = "if
(substring(string(integer(cif.geo),'999'),3) eq '2'
or substring(string(integer(cif.geo),'999'),3) eq '3')
then do: v-ans = substring(cif.lgr,1,1) = 'Y'.
message 'Налогоплательщик?' update v-ans. if v-ans then substr(cif.lgr,1,1) = 'Y'.
else substr(cif.lgr,1,1) = 'N'. end. if cif.type entered or cif.mname entered or
/*regis2 entered or*/ regis1 entered or vpoint entered or vdep entered or cif.prefix entered or
 cif.sname entered or cif.coregdt entered or cif.cust-since entered
or cif.pss entered or cif.addr[1] entered or cif.addr[2] entered
or cif.geo entered or cif.tel entered or apkal1 entered or cif.attn
entered or cif.cgr entered or cif.stn entered /*or cif.pres entered or cif.legal entered*/ then do: cif.whn = g-today.
cif.who = g-ofc. end. cif.jame = string(vpoint * 1000 + vdep).
cif.citi = string(rezdate).
run cifproft. /*run defexcl.*/ "

&predelete = "v-del = false. run fcif(input g-cif, output v-del).
if not v-del then do: {imesg.i 2200}. next. end. "

&delete = " run cifdelete. "

&predisplay = " run accessB. if not v-access then return.  run cifsecure. if not l-cifsec then return. if cif.type = 'X' then leave.
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
regis2 = substr(cif.name,61,60).
if cif.crg <> '' then run crgfnd.
rezdate = date(cif.citi).
v-clnkat = cif.mname.
"

displ c1 with frame cif.

&display = " display cif.cif cif.type cif.mname cif.regdt vpoint pname cif.pres cif.legal cif.ofc vdep dname cif.prefix cif.cust-since
  regis1 regis2 cif.sname v-crgwhn cif.ref[8] cif.sufix cif.expdt cif.addr[1] v-crgwho cif.addr[2] cif.whn /* cif.addr[3]*/
cif.coregdt cif.who cif.pss cif.geo cif.dtsrokul cif.doctype cif.tel cif.cgr cif.tlx apkal1 cif.fax
cif.attn rezdate cif.stn cif.bplace with frame cif.
"

&update = "run bnkrel-chk.
update cif.type cif.mname with frame cif.
if cif.mname <> 'EMP' and v-our  then  run iskl2.
if cif.mname = 'VIP' then do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if not can-do(ofc.expr[1],'p00185') then do:
        message 'Нет прав для устновления клиенту VIP категории' view-as alert-box.
        cif.mname = v-clnkat.
        display cif.mname with frame cif.
    end.
end.
update vpoint validate(can-find(point where point.point = vpoint),'') with frame cif.
find point where point.point = vpoint no-lock. pname = point.addr[1].  display pname with frame cif.
if s-geo = '1' or s-geo = '2' then do:
if cif.type = 'p' and cif.name = '' then do: regis1 = substr(s-name,1,60). regis2 = substr(s-name,61,60). end.
if cif.addr[1] = '' and  s-geo = '1' then cif.addr[1] = 'Казахстан (KZ),-,-,-,-,-,-'.
if cif.type = 'p' then cif.cgr = 501. if s-geo = '1' then cif.geo = '021'. else if s-geo = '2' then cif.geo = '022'.
end.
find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock . dname = ppoint.name. display dname with frame cif.
update vdep validate(can-find(ppoint where ppoint.point = vpoint and ppoint.dep = vdep),'') with frame cif.
update cif.prefix when cif.type = 'b' cif.cust-since when cif.type = 'b' with frame cif.
if cif.type = 'p' then do:
    assign v-famil = cif.famil v-imya = cif.imya v-otches = cif.otches.
    /*display v-famil v-imya v-otches with frame f-fio.*/
    update v-famil v-imya v-otches with frame f-fio.
    regis1 = caps(v-famil + ' ' + v-imya + ' ' + v-otches).
    displ regis1 with frame cif.
    hide frame f-fio.
end.
else update regis1 validate(regis1 <> '','') with frame cif.
update cif.sname validate(cif.sname <> '','') cif.ref[8] with frame cif.

repeat:
   update cif.sufix with frame newFrame.
   correct = true.
   do currIndex = 1 to length(badChars):
      if index(cif.sufix, substring(badChars,currIndex,1)) > 0 then do:
         correct = false.
         leave.
      end.
   end.
   if correct = false then message 'Значение поля содержит недопустимый символ!' view-as alert-box button OK.
   else leave.
end.

hide frame newFrame.
display cif.sufix with frame cif.
update cif.expdt with frame cif.

v-title = 'Юридический адрес'. v-addr = cif.addr[1]. run getAddr(input-output v-addr). cif.addr[1] = v-addr.
message 'Фактический адрес соответствует юридическому?' view-as alert-box question buttons yes-no title '' update v-adr.
                  if v-adr then cif.addr[2] = cif.addr[1].
v-title = 'Фактический адрес'. v-addr = cif.addr[2]. run getAddr(input-output v-addr). cif.addr[2] = v-addr.
display cif.addr[1] cif.addr[2] with frame cif.
update cif.geo
validate(can-find(geo where geo.geo = cif.geo),'') cif.cgr with frame cif.
if cif.type = 'B' and cif.cgr = 403 then update cif.coregdt with frame cif.
if cif.type = 'P' or (cif.type = 'B' and cif.cgr = 403) then do:
update cif.bplace with frame cif.
if v-vyd = '' then do:
for each bookcod where bookcod.bookcod = 'pkankvyd' no-lock:
if v-vyd <> '' then v-vyd = v-vyd + '|'.
v-vyd = v-vyd + bookcod.name.
end.
v-vyd = v-vyd + '|ЗАГС'.
end.
if cif.geo = '021' then do:
on help of v-issuredby in frame f-pass do:
v-sel = 0.
run sel2 (' КЕМ ВЫДАНО ', v-vyd, output v-sel).
if v-sel <> 0 then v-issuredby = entry(v-sel,v-vyd, '|').
display v-issuredby with frame f-pass.
end.
end.
if cif.pss <> '' then do:
case num-entries(trim(cif.pss),' '):
when 1 then v-pss = cif.pss.
when 2 then do: v-pss = entry(1,cif.pss, ' '). v-pssdt = date(entry(2,cif.pss,' ')) no-error. end.
when 3 then do: v-pss = entry(1,cif.pss, ' '). v-pssdt = date(entry(2,cif.pss, ' ')) no-error. v-issuredby  = entry(3,cif.pss, ' '). end.
when 4 then do: v-pss = entry(1,cif.pss, ' '). v-pssdt = date(entry(2,cif.pss, ' ')) no-error. v-issuredby  = entry(3,cif.pss, ' ') + ' ' +  entry(4,cif.pss, ' '). end.
end.
end.
display v-pss v-pssdt v-issuredby with frame f-pass.
update v-pss with frame f-pass.
update v-pssdt with frame f-pass.
if cif.geo = '021' then do:
repeat:
update v-issuredby with frame f-pass.
if lookup(v-issuredby,v-vyd,'|') > 0 then leave.
if trim(v-issuredby) = '' then message 'Введите орган выдачи документа!' view-as alert-box.
if lookup(v-issuredby,v-vyd,'|') = 0 and trim(v-issuredby) <> '' then message 'Некорректное значение!' view-as alert-box.
end.
end.
else update v-issuredby with frame f-pass.
hide frame f-pass.
cif.pss = trim(v-pss) + ' ' + string(v-pssdt,'99/99/9999') + ' ' + trim(v-issuredby).
display cif.pss with frame cif.
end. /*для физ.л*/
if (cif.type = 'B' and (cif.cgr = 403 or cif.cgr = 405 or cif.cgr = 501)) then do:
update cif.pss with frame cif.
end.
if cif.type = 'P' then update cif.dtsrokul cif.doctype with frame cif.
v-days  = cif.dtsrokul - today.
if v-days <= 30  then message 'Срок действия УЛ истекает в течении ' v-days ' дней!' view-as alert-box.
v-oldfax = cif.fax.
update cif.tel cif.tlx cif.fax apkal1 validate(can-find(ofc where ofc.ofc = apkal1) or apkal1 = '','') cif.attn rezdate cif.stn with frame cif.
cif.fname = apkal1 + fill(' ',9 - length(apkal1)).
if cif.type = 'P' and trim(cif.name) <> '' and cif.name <> regis1 + fill(' ',60 - length(regis1)) + regis2 then do:
find last clfilials no-lock no-error.
if not avail clfilials then id = 1.
else id = clfilials.id + 1.
create clfilials.
assign clfilials.id = id
clfilials.cif = s-cif
clfilials.who = g-ofc
clfilials.whn = g-today
clfilials.namefil = cif.name
clfilials.forma_sobst = g-ofc
clfilials.rnn = string(g-today).
end.
cif.name   = regis1 + fill(' ',60 - length(regis1)) + regis2.
cif.famil  = caps(v-famil).
cif.imya   = caps(v-imya).
cif.otches = caps(v-otches).
if rezdate entered and cif.geo = '022' and cif.type <> 'B' then
cif.citi = string(rezdate).
if cif.type = 'P' and cif.cgr <> 403 then run avto_p.

if cif.fax entered and v-oldfax <> cif.fax then do:
    find last b-pcstaff0 where b-pcstaff0.cif = cif.cif exclusive-lock no-error.
    if avail b-pcstaff0 then b-pcstaff0.tel[2] = trim(cif.fax).
end.
"
}


procedure crgfnd.
do:
  find last crg where crg.crg = cif.crg and crg.stn = 1 use-index crg no-lock no-error.
  if available crg then do: v-crgwho = crg.who. v-crgwhn = crg.whn. end.
  else v-crgwho = '(нет)'.
end.
end procedure.
/* если не указан Профит-центр для клиента - указать по логину менеджера счета */
procedure cifproft.
def var prof-prefix as char.
  find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = s-cif no-error.
  if not available sub-cod then do:
    create sub-cod.
    assign sub-cod.sub = "cln"
           sub-cod.d-cod = "sproftcn"
           sub-cod.acc = s-cif
           sub-cod.ccode = ofc.titcd
           sub-cod.rdt = g-today
           sub-cod.ccode = "msc".
  end.

  if sub-cod.ccode = "msc" or vdep0 <> vdep then do:
    /* по департаменту - если центр.офис, то 103 */
    if vdep = 1 then
      sub-cod.ccode = "103".
    else do:
      /* коды РКО в зависимости от филиала - Алматы A, Астана B, Уральск C */
      find sysc where sysc.sysc = "PCRKO" no-lock no-error.
      if not available sysc then prof-prefix = "U".
      else prof-prefix = trim(sysc.chval).
      sub-cod.ccode = prof-prefix + string(vdep, '99').
    end.
  end.
end procedure.

procedure cifdelete.
/* удалить связанные записи  */
  for each sub-cod where sub-cod.sub = "cln" and sub-cod.acc = s-cif. delete sub-cod. end.
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


procedure cifsecure.
   find last cifsec where cifsec.cif = s-cif no-lock no-error .
   if avail cifsec then do: /*логины есть*/
       find last cifsec where cifsec.cif = s-cif and cifsec.ofc = g-ofc no-lock no-error.
       if not avail cifsec then
       do:
          message "Клиент не Вашего Департамента" view-as alert-box buttons OK .
          l-cifsec = False.
          create ciflog.
          assign
             ciflog.ofc = g-ofc
             ciflog.jdt = today
             ciflog.sectime = time
             ciflog.cif = s-cif
             ciflog.menu = "1.2 Новые клиенты и открытие счетов" .
             leave.
       end. else
       do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = s-cif
            ciflogu.menu = "1.2 Новые клиенты и открытие счетов" .
          l-cifsec = True.
       end.
   end.
   else
     l-cifsec = True.
end procedure.

/* 29.01.2004 nadejda - вынесено в cif-lgot.p по ТЗ 707
/ * обработка вида льготного обслуживания * /
procedure defexcl.
  def var p-ans as logical.

  / * установка льготных тарифов, если выбран вид льготного обслуживания или очистить, если льгота отменена * /
  if cif.pres <> v-pres then do:
    v-ans = yes.
    message skip " Установить/снять ЛЬГОТНЫЕ тарифы для данного клиента?"
            skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.
    if v-ans then do:
      / * очистить старые льготы * /
      if v-pres <> "" then run value("clnlgot-" + v-pres) (cif.cif, "", no).
      / * установить новые льготы * /
      if cif.pres = "" then do:
        cif.legal = "".
        displ cif.legal with frame cif.
        pause 0.
      end.
      else run value("clnlgot-" + cif.pres) (cif.cif, "", yes).

      run clntarifex (cif.cif).
    end.
    else cif.pres = v-pres.
  end.
end procedure.
*/
procedure avto_p.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnsts' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'clnsts'.
        sub-cod.ccode = '1'.
        sub-cod.rdt = g-today.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'ecdivis' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'ecdivis'.
        sub-cod.ccode = '0'.
        sub-cod.rdt = g-today.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'regionkz' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'regionkz'.
        sub-cod.rdt = g-today.
        find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
        if avail sysc then do:
            if sysc.chval = 'RKC00' or sysc.chval = 'TXB00' then sub-cod.ccode = '75'.
            if sysc.chval = 'TXB01' then sub-cod.ccode = '15'.
            if sysc.chval = 'TXB02' then sub-cod.ccode = '39'.
            if sysc.chval = 'TXB03' then sub-cod.ccode = '31'.
            if sysc.chval = 'TXB04' then sub-cod.ccode = '27'.
            if sysc.chval = 'TXB05' then sub-cod.ccode = '35'.
            if sysc.chval = 'TXB06' then sub-cod.ccode = '63'.
            if sysc.chval = 'TXB07' then sub-cod.ccode = '11'.
            if sysc.chval = 'TXB08' then sub-cod.ccode = '71'.
            if sysc.chval = 'TXB09' then sub-cod.ccode = '55'.
            if sysc.chval = 'TXB10' then sub-cod.ccode = '59'.
            if sysc.chval = 'TXB11' then sub-cod.ccode = '23'.
            if sysc.chval = 'TXB12' then sub-cod.ccode = '47'.
            if sysc.chval = 'TXB13' then sub-cod.ccode = '35'.
            if sysc.chval = 'TXB14' then sub-cod.ccode = '63'.
            if sysc.chval = 'TXB15' then sub-cod.ccode = '51'.
            if sysc.chval = 'TXB16' then sub-cod.ccode = '19'.
        end.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'rnnsp' no-lock no-error.
    if not avail sub-cod then do:
        find first codfr where codfr.codfr = 'rnnsp' and codfr.code = substring(cif.jss,1,4) no-lock no-error.
        if avail codfr then do:
            create sub-cod.
            sub-cod.acc = cif.cif.
            sub-cod.sub = 'cln'.
            sub-cod.d-cod = 'rnnsp'.
            sub-cod.rdt = g-today.
            sub-cod.ccode = codfr.code.
        end.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'secek' no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.acc = cif.cif.
        sub-cod.sub = 'cln'.
        sub-cod.d-cod = 'secek'.
        sub-cod.ccode = '9'.
        sub-cod.rdt = g-today.
    end.
    else do:
        sub-cod.ccode = '9'.
    end.
    release sub-cod.
end procedure.

procedure accessB:
    v-access = yes.
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc and (lookup("P00178", ofc.expr[1]) > 0 or lookup("P00179", ofc.expr[1]) > 0 or lookup("P00180", ofc.expr[1]) > 0) and cif.type = "B" then do:
         message "Нет прав для просмотра карточки клиента с типом B" view-as alert-box buttons OK title "Внимание!".
         v-access = no.
    end.
end procedure.