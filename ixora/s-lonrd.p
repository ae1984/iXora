/* s-lonrd.p
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
        01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        02/02/04 nataly добавлен признак валюты индекс v-crc, курс по контракту v-rate, признак индекс кредита lnindex
        25.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        28/05/2004 madiyar - открытие нового ссудного счета - проверяется не физ/юр лицо, сектор экономики
        03/06/2004 madiyar - открытие нового ссудного счета - проверяется наличие корректного признака физ/юр лицо
        03/08/2004 tsoy   - добавил в сохранение истории новые параметры ( Комм15/10/2009исисия за кред.линию, Пролонгация 1,
                                                                           Пролонгация 2, Валюта индексации, Курс договора)
        11.08.2004 tsoy Добавил Вид, Договор, Выбрать до, Причину
        01.09.2004 tsoy Изменить редакдирующее лицо, только когда изменяются важные параметры
        03.09.2004 tsoy а также если карточка не подписана
        09.09.2004 tsoy Добавил сохранение истории для Валюты Схемы и Дня расчета.
        17.09.2004 sasco Добавил проверку на дату окончания >= g-today и убрал ограничение на
                         проверку группы кредита и его срока только для новых кредитов
        20.09.2004 sasco Проверка на пролонгацию при проверке duedt
        07/06/2005 madiyar - автоматическое проставление признака 'lnindex' (индексированный кредит) при введении фиксированного курса индексации
        30/01/2006 Natalya D. - добавлено поле Депозит
        07/04/2006 Natalya D. - добавила сохранение старых % и штрафов в поля prem1 и sods2 при ручном обнулении или восстановлении ставок
        04/05/06 marinav Увеличить размерность поля суммы
        12/06/2007 madiyar - читка библиотеки - удалил неработающий код
        12/12/2008 galina - перекомпиляция
        25/03/2009 galina - добавила поле Поручител
        23.04.2009 galina - убираем поле поручитель
        03/08/2009 madiyar - если группа 90 или 92 - не правим графики после изменения сроков или сумм
        15/10/2009 madiyar - редактирование тек. счета, запись в историю
        20/10/2009 madiyar - перекомпиляция
        25/03/2010 galina - тип нового кредита по умолчанию 2 Коммерческий кредит
        13/05/2010 galina - добавила просталение статуса "C" lnprohis при редактирование ставки по штрафам
        09/06/2010 galina- добавила ставку по штарфам до и после 7 дней просрочки
        22/06/2010 galina - записываем ставку по штрафам до 7-ми дней в loncon.sods1
        02/07/2010 galina - пишем историю по обнулению loncon.sods1
        24/07/2010 madiyar - возможность изменения lon.day
        23/08/2010 madiyar - ставка по комиссии prem_s
        24/08/2010 madiyar - premsdt
        16/10/2010 madiyar - теперь возможна привязка счета другого клиента
        19/10/2010 madiyar - penprem7 по овердрафтам (группы 70 и 80)
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме
        09/12/2010 madiyar - убрал проверку срока по овердрафтам
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX; автоматическое проставление признаков lnshifr и lnovdcd
        14/07/2011 madiyar - снятие признака однородности по кредитам бывших сотрудников (при смене группы с 81,82 на 20,60)
        15/07/2011 kapar - 390 строке ((longrp = 81) or (lon.grp = 82) -> (lon.grp = 81) or (lon.grp = 82))
        01/09/2011 madiyar - добавил группы
        21/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        13/06/2012 kapar - ARP счет не обязательный
        18/06/2012 kapar - новое поле (Дата прекращения дополнительной % ставки)
        20/06/2012 kapar - новое поле (Дата начала дополнительной % ставки)
        28/06/2012 kapar - добавил группы (95,96,13,23,53,63)
        15.08.2012 kapar - ДОП ТЗ 1246
        11.01.2013 evseev - ТЗ-1530
        25/02/2013 sayat(id01143) - добавлены поля loncon.dtsub - ТЗ 1669 от 28/01/2013 (дата договора субсидирования),
                                                   loncon.obes-pier - ТЗ 1696 04/02/2013 (отвественный по обеспечению),
                                                   loncon.lcntdop и loncon.dtdop - ТЗ 1706 от 07/02/2013 (номер и дата доп.соглашения).
*/

{mainhead.i}
{lonlev.i}
{get-kod.i}

def shared variable s-newrec as logi.

define shared variable s-lon    like lon.lon.
define shared variable s-longrp like longrp.longrp.
define shared variable grp-name as character.
define shared variable crc-code as character.
define shared variable cat-des  as character.
define shared variable v-cif    like cif.cif.
define shared variable v-lcnt   like loncon.lcnt.
define shared variable v-vards  like cif.name format "x(36)".
define shared variable s-cat as character.
define shared variable s-apr as character.
define shared frame cif.
define variable v-uno  like uno.uno no-undo.
define variable clcif  like cif.cif no-undo.
define variable clname like cif.name no-undo.
define shared variable s-prem as character.
define shared variable d-prem as character.
define var is-newlon as logical no-undo.
define var tmpstr as char no-undo.

def shared var v-crc like crc.crc.
def shared var v-rate like crc.rate[1].
def shared var v-komcl as deci.

def shared var v-edit as logical.

def var v-komcl-old as deci.

def var old-rate as deci.
def var old-objekts like  loncon.objekts.
/*def var old-deps like loncon.deposit.*/
def var old-plan like lon.plan.
def var old-day  like lon.day.
def var old-crc  like lon.crc.

{s-lonrdl.f}.

define variable ja-ne2 as logical no-undo.
def buffer b-cif for cif.
def buffer b-lon for lon.
def var v-aaaname as char no-undo.

define new shared variable grp as integer init 2.
/*define new shared variable deps as char.*/
define new shared variable rc  as integer.
define variable v-f0 as integer no-undo.
define variable o-basedy as integer no-undo.
define variable o-idt15 as date no-undo.
define variable o-idt35 as date no-undo.
define variable old-duedt15 like lon.duedt.
define variable old-duedt35 like lon.duedt.
define variable o-paraksts as logical no-undo.
define variable o-prnmos as decimal no-undo.
define variable o-deps as char no-undo.
define variable os-prem as character no-undo.
define variable od-prem as character no-undo.
define new shared variable su-min as integer.
define new shared variable su-max as integer.
def var v-londam1 like lon.dam[1] no-undo.
def var old-prem_s as deci no-undo.
def var old-premsdt as date no-undo.

def var lonsrok as int no-undo.
def var londays as int no-undo.
def var dn2 as deci no-undo.

find lon where lon.lon = s-lon.
find loncon where loncon.lon = s-lon.
/*galina 25/03/2009*/
/*v-guarantor = trim(loncon.rez-char[8]).*/
find cif where cif.cif = lon.cif no-lock.
find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 exclusive-lock no-error.
if not available lonhar
then do:
     create lonhar.
     lonhar.lon = lon.lon.
     lonhar.ln = 1.
     lonhar.fdt = date(1,1,1).
     lonhar.cif = lon.cif.
     lonhar.rez-int[3] = 0.
     lonhar.lonstat = 1.
end.
find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = "lnsrok" no-lock no-error.
if not avail sub-cod or (avail sub-cod and (sub-cod.ccode = "msc"))
       then is-newlon = yes.
       else is-newlon = no.

old-noz = string(lonhar.rez-int[3]).
s-cat = old-noz.
if s-cat = "59101"
then s-cat = "50101".
else if s-cat = "59102"
then s-cat = "50201".
else if s-cat = "59103"
then s-cat = "50401".
else if s-cat >= "69101" and s-cat <= "69199"
then s-cat = "6" + substring(s-cat,4,2) + "01".

old-noz = s-cat.
s-prem = lon.base + string(lon.prem).
d-prem = lon.base + string(lon.dprem).
os-prem = s-prem.
od-prem = d-prem.
o-idt15 = lon.idt15.
o-idt35 = lon.idt35.
o-prnmos = lon.prnmos.
o-deps = loncon.deposit.
if index(loncon.rez-char[10],"&") > 0 then do:
     if substring(loncon.rez-char[10],index(loncon.rez-char[10],"&") + 1,3) = "yes" then paraksts = yes.
     else paraksts = no.
end.
else paraksts = no.
o-paraksts = paraksts.

s-longrp = lon.grp.
v-deposit = loncon.deposit.
readkey pause 0.



/*
dam1-cam1 = lon.dam[1] - lon.cam[1].
*/
dam1-cam1 = 0.
v-londam1 = 0.
for each trxbal where trxbal.subled eq "LON" and trxbal.acc = lon.lon no-lock :
    if trxbal.level = 1 then v-londam1 = trxbal.dam.
    if lookup(string(trxbal.level) , v-lonprnlev , ";") > 0 then
    dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam).
end.
if lon.prnmos > 0 then v-uno = lon.prnmos.
else v-uno = 2.
v-deposit = loncon.deposit.

find first lons where lons.lon = lon.lon no-lock no-error.
if avail lons then assign prem_s = lons.prem premsdt = lons.rdt. else assign prem_s = 0 premsdt = ?.

assign clcif = '' clname = ''.
find first b-lon where b-lon.lon = lon.clmain no-lock no-error.
if avail b-lon then do:
 find first b-cif where b-cif.cif = b-lon.cif no-lock no-error.
 if avail b-cif then assign clcif = b-cif.cif clname = b-cif.name.
end.

run lonbalcrc('lon',lon.lon,g-today,'15',yes,lon.crc,output cl-voz).
cl-voz = - cl-voz.
run lonbalcrc('lon',lon.lon,g-today,'35',yes,lon.crc,output cl-nevoz).
cl-nevoz = - cl-nevoz.

display v-cif
        v-lcnt
        loncon.lon
        s-longrp
        v-uno
        lon.crc
        crc-code
        lon.trtype
        lon.gua
        loncon.lcntdop
        loncon.dtdop
        loncon.lcntsub
        loncon.dtsub
        lon.clmain
        clcif
        clname
        loncon.objekts
        lon.rdt
        lon.duedt
        lon.duedt15
        lon.duedt35
        lon.opnamt
        dam1-cam1
        cl-voz
        cl-nevoz
        s-prem
        d-prem
        lon.rdate
        lon.ddate
        lon.ddt[5]
        loncon.proc-no
        loncon.sods1
        lon.penprem
        lon.penprem7
        prem_s
        premsdt
        lon.idt15
        lon.idt35
        paraksts
        loncon.vad-amats
        loncon.vad-vards
        loncon.galv-gram
        loncon.rez-char[9]
        lon.aaa
        lon.aaad
        v-deposit
        lon.plan
        lon.day
        lon.basedy
      /*  v-crc
        v-rate*/
        loncon.who
        loncon.pase-pier
        /*v-guarantor*/
        loncon.obes-pier
        with frame lon.
 /*31/01/04 nataly*/
 find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock no-error.
 if avail lonhar then do:
     v-crc = lonhar.rez-int[1].
     v-rate = lonhar.rez-dec[1].
     v-komcl = lonhar.rez-dec[2].
 end.
 display v-komcl v-crc v-rate with frame lon.

display v-vards with frame cif.
o-basedy    = lon.basedy.
old-lcnt    = loncon.lcnt.
old-lcntdop = loncon.lcntdop.
old-dtdop   = loncon.dtdop.
old-lcntsub = loncon.lcntsub.
old-dtsub   = loncon.dtsub.
old-gua     = lon.gua.
old-cat     = lon.loncat.
old-rdt     = lon.rdt.
old-duedt   = lon.duedt.
old-duedt15 = lon.duedt15.
old-duedt35 = lon.duedt35.
old-opnamt  = lon.opnamt.
old-prem    = lon.prem.
old-rdate   = lon.rdate.
old-ddate   = lon.ddate.
old-ddt     = lon.ddt[5].
old-cdt     = lon.cdt[5].
old-lonaaa  = lon.aaa.
old-lonaaad  = lon.aaad.
old-sods1   = loncon.sods1.
old-penprem = lon.penprem.
old-penprem7 = lon.penprem7.
old-prem_s = prem_s.
old-premsdt = premsdt.
old-objekts = loncon.objekts.
old-obes-pier = loncon.obes-pier.
/*old-deps    = loncon.deposit. */
old-plan  = lon.plan.
old-day   = lon.day.

do on endkey undo, leave:
   {s-lonrd.i &vecais = "lon.cif" &jaunais = "v-cif"}.

   if ja-ne then do:
       {lnparhis.i &parm = "cif" &oldval = "lon.cif" &newval = "v-cif"}.
       v-edit = true.
   end.

   if frame lon v-cif entered
   then do:
        find cif where cif.cif = v-cif no-lock.
        cif-kod = get-kod ("", cif.cif).
        v-vards = trim(trim(cif.prefix) + " " + trim(cif.name)).
        display v-vards with frame cif.
        lon.cif = v-cif.
        loncon.cif = v-cif.
        if v-londam1 <> 0 and loncon.lcnt <> " "
        then for each loncon1 where loncon1.lcnt = loncon.lcnt and
             loncon1.lon <> lon.lon:
             find lon1 where lon1.lon = loncon1.lon.
             loncon1.cif = v-cif.
             lon1.cif = v-cif.
        end.
   end.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-lcnt" &jaunais = "v-lcnt"}.

   if ja-ne then do:
      {lnparhis.i &parm = "lcnt" &oldval = "old-lcnt" &newval = "v-lcnt"}.
             v-edit = true.
   end.

   if frame lon v-lcnt entered and v-londam1 <> 0
   then do:
        for each loncon1 where loncon1.lcnt = loncon.lcnt and
                 loncon.lcnt <> " " and loncon1.lon <> loncon.lon:
            loncon1.lcnt = v-lcnt.
        end.
   end.
   loncon.lcnt = v-lcnt.
end. /*tr*/
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   if lon.gua <> 'CL' and lon.gua <> 'LO' and lon.gua <> 'OD' and
      lon.gua <> 'LK' and lon.gua <> 'FK'
   then lon.gua = 'LO'.
   old-gua = lon.gua.
   {s-lonrd.i &vecais = "old-gua" &jaunais = "lon.gua"}.
   if lon.gua = "OD"
   then do:
        if v-londam1 <> 0
        then do:
             bell.
             undo.
             display lon.gua.
        end.
        else do:
             {s-lonrd.i &vecais = "old-ddt" &jaunais = "lon.ddt[5]"}.
        end.
   end.
/**
   if old-gua = "OD" and lon.gua <> "OD"
   then do:
        lon.lcr = "".
        display lon.lcr with frame lon.
   end.
**/
   if ja-ne then do:
      {lnparhis.i &parm = "gua" &oldval = "old-gua" &newval = "lon.gua"}.
             v-edit = true.
   end.

end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "lon.grp" &jaunais = "s-longrp"}.
   if ja-ne then do:
       {lnparhis.i &parm = "grp" &oldval = "lon.grp" &newval = "s-longrp"}.
              v-edit = true.
   end.
   if is-newlon then do: /* is-newlon */
      find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = v-cif and sub-cod.d-cod = "clnsts" no-lock no-error.
      if sub-cod.ccode <> "0" and sub-cod.ccode <> "1" then do:
        message "У клиента не проставлен корректный признак физ./юр. лицо!".
        undo, leave.
      end.
      find longrp where longrp.longrp = s-longrp no-lock no-error.
      if substr(string(longrp.stn), 1, 1) = "1" then do: /* собираются выдать кредит для физ. лиц */
         if substr(get-kod("", v-cif), 2, 1) <> "9" then do:
           message "Группа не соответствует CIF (сектор экономики)!".
           undo, leave.
         end.
      end.
      if substr(string(longrp.stn), 1, 1) = "2" then do: /* собираются выдать кредит для юр. лиц */
         if substr(get-kod("", v-cif), 2, 1) = "9" then do:
           message "Группа не соответствует CIF (сектор экономики)!".
           undo, leave.
         end.
      end.
   end. /* is-newlon */
   else do: /* не новый кредит */
        if ((lon.grp = 81) or (lon.grp = 82)) and ((s-longrp = 20) or (s-longrp = 60)) then do:
            /* если кредит бывшего сотрудника и проставлен признак однородности - снимем */
            find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = "lnodnor" and sub-cod.ccode = "01" no-lock no-error.
            if avail sub-cod then do:
                find current sub-cod exclusive-lock.
                sub-cod.ccode = "msc".
                find current sub-cod no-lock.
            end.
        end.
   end.

   if frame lon s-longrp entered
   then do:
        find longrp where longrp.longrp = s-longrp no-lock.
        if v-londam1 <> 0 and lon.gl <> longrp.gl
        then do:
             bell.
             s-longrp = lon.grp.
             display s-longrp with frame lon.
        end.
        else do:
             grp-name = longrp.des.
             if loncon.lcnt <> " "
             then for each loncon1 where loncon1.lcnt = loncon.lcnt and
                      loncon1.lon <> lon.lon no-lock:
                  find lon1 where lon1.lon = loncon1.lon.
                  lon1.grp = s-longrp.
                  lon1.gl = longrp.gl.
             end.
             lon.grp = s-longrp.
             lon.gl = longrp.gl.
        end.
   end.
end. /*tr*/

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:

   {s-lonrd.i &vecais = "old-lcntdop" &jaunais = "loncon.lcntdop"}.

   if ja-ne then do:
      {lnparhis.i &parm = "lcntdop" &oldval = "old-lcntdop" &newval = "loncon.lcntdop"}.
             v-edit = true.
   end.

/*   update loncon.objekts with frame lon. */
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:

   {s-lonrd.i &vecais = "old-dtdop" &jaunais = "loncon.dtdop"}.

   if ja-ne then do:
      {lnparhis.i &parm = "dtdop" &oldval = "old-dtdop" &newval = "loncon.dtdop"}.
             v-edit = true.
   end.

/*   update loncon.objekts with frame lon. */
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and lookup(string(s-longrp),'13,23,53,63') > 0 then
do on endkey undo, leave:

   {s-lonrd.i &vecais = "old-lcntsub" &jaunais = "loncon.lcntsub"}.

   if ja-ne then do:
      {lnparhis.i &parm = "lcntsub" &oldval = "old-lcntsub" &newval = "loncon.lcntsub"}.
             v-edit = true.
   end.

    {s-lonrd.i &vecais = "old-dtsub" &jaunais = "loncon.dtsub"}.

   if ja-ne then do:
      {lnparhis.i &parm = "dtsub" &oldval = "old-dtsub" &newval = "loncon.dtsub"}.
             v-edit = true.
   end.

/*   update loncon.objekts with frame lon. */
end.



if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-prnmos" &jaunais = "v-uno"}.
   if frame lon v-uno entered
   then do:
        find first uno where uno.grupa = 2 and uno.uno = v-uno no-lock no-error.
        if not available uno
        then do:
             bell.
             undo,retry.
        end.
        lon.prnmos = v-uno.
   end.
end.



if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and lon.dam[1] = 0 then
do on endkey undo, leave:

{s-lonrd.i &vecais = "old-plan" &jaunais = "lon.plan"}.
   if ja-ne then do:
      {lnparhis.i &parm = "plan" &oldval = "old-plan" &newval = "lon.plan"}.
             v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") /*and lon.dam[1] = 0*/ then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-day" &jaunais = "lon.day"}.
   if ja-ne then do:
      {lnparhis.i &parm = "day" &oldval = "old-day" &newval = "lon.day"}.
             v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   if v-londam1 = 0 then do:
     {s-lonrd.i &vecais = "old-crc" &jaunais = "lon.crc"}.
        if ja-ne then do:
             {lnparhis.i &parm = "crc" &oldval = "old-crc" &newval = "lon.crc"}.
             v-edit = true.
        end.
   end.

  find crc where crc.crc = lon.crc no-lock.
  crc-code = string(crc.code,"xxxx") + substring(crc-code,5).
  display crc-code with frame lon.

end. /*tr*/

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:

   {s-lonrd.i &vecais = "old-objekts" &jaunais = "loncon.objekts"}.

   if ja-ne then do:
      {lnparhis.i &parm = "object" &oldval = "old-objekts" &newval = "loncon.objekts"}.
             v-edit = true.
   end.

/*   update loncon.objekts with frame lon. */
end.


if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   find first lnscg where lnscg.lng = s-lon and lnscg.flp > 0 and lnscg.fpn = 0
        and lnscg.f0 > -1 no-lock no-error.
   find first lnsch where lnsch.lnn = s-lon and lnsch.flp > 0 and lnsch.f0 > -1
        and lnsch.fpn = 0 no-lock no-error.
   find first lnsci where lnsci.lni = s-lon and lnsci.flp > 0 and lnsci.fpn = 0
        and lnsci.f0 > -1 no-lock no-error.
   datt = date(1,1,3000).
   if available lnscg then datt = lnscg.stdat.
   if available lnsch and lnsch.stdat < datt then datt = lnsch.stdat.
   if available lnsci and lnsci.idat < datt then datt = lnsci.idat.
   {s-lonrd.i &vecais = "old-rdt" &jaunais = "lon.rdt"}.
   if ja-ne then do:
      {lnparhis.i &parm = "rdt" &oldval = "old-rdt" &newval = "lon.rdt"}.
             v-edit = true.
   end.
end. /*tr*/
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   find last lnscg where lnscg.lng = s-lon and lnscg.flp > 0 and lnscg.fpn = 0
        and lnscg.f0 > -1 no-lock no-error.
   find last lnsch where lnsch.lnn = s-lon and lnsch.flp > 0 and lnsch.f0 > -1
        and lnsch.fpn = 0 no-lock no-error.
   find last lnsci where lnsci.lni = s-lon and lnsci.flp > 0 and lnsci.fpn = 0
        and lnsci.f0 > -1 no-lock no-error.
   datt = date(1,1,1000).
   if available lnscg then datt = lnscg.stdat.
   if available lnsch and lnsch.stdat > datt then datt = lnsch.stdat.
   if available lnsci and lnsci.idat > datt then datt = lnsci.idat.

   {s-lonrd.i &vecais = "old-duedt" &jaunais = "lon.duedt"}.

   lonsrok = ABS (lon.duedt - lon.rdt).

   /* обработка кредитов на ровное количество лет */
   if DAY (lon.duedt) = DAY (lon.rdt) and
      MONTH (lon.duedt) = MONTH (lon.rdt) then lonsrok = 365 * ABS (YEAR (lon.duedt) - YEAR (lon.rdt)).

/*   if is-newlon then
   DO: /* is-newlon */  */

   /* если изменили дату окончания */
   if lon.duedt <> old-duedt and lon.duedt < g-today then do:
      message "Неверная дата окончания! Не может быть меньше сегодняшней даты!".
      undo, leave.
   end.

   find longrp where longrp.longrp = s-longrp no-lock no-error.
   /* краткосрочный */
   if substr(string(longrp.stn), 2, 1) = "1" then if lonsrok > 365 then do:
      message "Неверный срок окончания! У вас краткосрочная группа!".
      undo, leave.
   end.
   /* долгосрочный */
   if substr(string(longrp.stn), 2, 1) = "2" then if lonsrok <= 365 then do:
      message "Неверный срок окончания! У вас долгосрочная группа!".
      undo, leave.
   end.
   /* овердрафт */
   /*
   if substr(string(longrp.stn), 2, 1) = "3" then if lonsrok > 31 then do:
      message "Не верный срок окончания! У вас группа с овердрафтом!".
      undo, leave.
   end.
   */

/*   END. /* is-newlon */ */

   /* признак срока кредита */
   find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = "lnsrok" no-error.
   if not avail sub-cod then do:
      create sub-cod.
      assign sub-cod.sub = "LON"
             sub-cod.acc = lon.lon
             sub-cod.d-cod = "lnsrok"
             no-error.
   end.
   /* определим количество дней для срока кредита - в справочник */
   if lonsrok <= 30 then sub-cod.ccode = "01".
   else
   if lonsrok <= 90 then sub-cod.ccode = "02".
   else
   if lonsrok <= 180 then sub-cod.ccode = "03".
   else
   if lonsrok <= 365 then sub-cod.ccode = "04".
   else
   if lonsrok <= 1095 then sub-cod.ccode = "05".
   else
   if lonsrok <= 1825 then sub-cod.ccode = "06".
   else
   if lonsrok <= 3650 then sub-cod.ccode = "07".
   else
   sub-cod.ccode = "08".


   if ja-ne then do:
       {lnparhis.i &parm = "duedt" &oldval = "old-duedt" &newval = "lon.duedt"}.
              v-edit = true.
   end.

   if lon.duedt <> old-duedt
   then do:
        find lonsa where lonsa.lon = lon.lon no-error.
        if available lonsa
        then lonsa.duedt = lon.duedt.
   end.
end. /*tr*/

if s-newrec then do:
    find first longrp where longrp.longrp = s-longrp no-lock no-error.

    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnshifr' and sub-cod.acc = s-lon exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub = 'lon'
               sub-cod.d-cod = 'lnshifr'
               sub-cod.acc = s-lon
               sub-cod.rdt = g-today.
    end.
    if lon.grp = 10 then do:
        if lon.crc = 1 then sub-cod.ccode = '01'. else sub-cod.ccode = '09'.
    end.
    else
    if lon.grp = 50 then do:
        if lon.crc = 1 then sub-cod.ccode = '02'. else sub-cod.ccode = '10'.
    end.
    else
    if lookup(string(lon.grp),'11,14,15,16') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '03'. else sub-cod.ccode = '11'.
    end.
    else
    if lookup(string(lon.grp),'54,55,56') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '04'. else sub-cod.ccode = '12'.
    end.
    else
    if lookup(string(lon.grp),'20,81') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '05'. else sub-cod.ccode = '13'.
    end.
    else
    if lookup(string(lon.grp),'60,82') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '06'. else sub-cod.ccode = '14'.
    end.
    else
    if lookup(string(lon.grp),'21,24,25,26') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '07'. else sub-cod.ccode = '15'.
    end.
    else
    if lookup(string(lon.grp),'64,65,66') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '08'. else sub-cod.ccode = '16'.
    end.
    else
    if lon.grp = 70 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '03'. else sub-cod.ccode = '04'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '11'. else sub-cod.ccode = '12'.
        end.
    end.
    else
    if lon.grp = 80 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '07'. else sub-cod.ccode = '08'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '15'. else sub-cod.ccode = '16'.
        end.
    end.


    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.d-cod = 'lnovdcd' and sub-cod.acc = s-lon exclusive-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        assign sub-cod.sub = 'lon'
               sub-cod.d-cod = 'lnovdcd'
               sub-cod.acc = s-lon
               sub-cod.rdt = g-today.
    end.
    if lon.grp = 10 then do:
        if lon.crc = 1 then sub-cod.ccode = '25'. else sub-cod.ccode = '33'.
    end.
    else
    if lon.grp = 50 then do:
        if lon.crc = 1 then sub-cod.ccode = '26'. else sub-cod.ccode = '34'.
    end.
    else
    if lookup(string(lon.grp),'11,14,15,16') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '27'. else sub-cod.ccode = '35'.
    end.
    else
    if lookup(string(lon.grp),'54,55,56') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '28'. else sub-cod.ccode = '36'.
    end.
    else
    if lookup(string(lon.grp),'20,81') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '29'. else sub-cod.ccode = '37'.
    end.
    else
    if lookup(string(lon.grp),'60,82') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '30'. else sub-cod.ccode = '38'.
    end.
    else
    if lookup(string(lon.grp),'21,24,25,26') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '31'. else sub-cod.ccode = '39'.
    end.
    else
    if lookup(string(lon.grp),'64,65,66') > 0 then do:
        if lon.crc = 1 then sub-cod.ccode = '32'. else sub-cod.ccode = '40'.
    end.
    else
    if lon.grp = 70 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '27'. else sub-cod.ccode = '28'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '35'. else sub-cod.ccode = '36'.
        end.
    end.
    else
    if lon.grp = 80 then do:
        run day-360(lon.rdt,lon.duedt - 1,360,output londays,output dn2).
        if lon.crc = 1 then do:
            if londays <= 360 then sub-cod.ccode = '31'. else sub-cod.ccode = '32'.
        end.
        else do:
            if londays <= 360 then sub-cod.ccode = '39'. else sub-cod.ccode = '40'.
        end.
    end.

end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-duedt15" &jaunais = "lon.duedt15"}.

   if ja-ne then do:
      {lnparhis.i &parm = "duedt15" &oldval = "old-duedt15" &newval = "lon.duedt15"}.
      v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-duedt35" &jaunais = "lon.duedt35"}.

  if ja-ne then do:
      {lnparhis.i &parm = "duedt35" &oldval = "old-duedt35" &newval = "lon.duedt35"}.
      v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
lon.gua <> "OD" then
do on endkey undo, leave:
   if lon.gua = "CL" or lon.gua = "FK" then do:
      viss = lon.dam[1] - lon.cam[1].
   end.
   else do:
        for each lnscg where lnscg.lng = s-lon and lnscg.flp > 0
                       and lnscg.fpn = 0 and lnscg.f0 > -1:
            viss = viss + lnscg.paid.
        end.
   end.
   {s-lonrd.i &vecais = "old-opnamt" &jaunais = "lon.opnamt"}.

   if ja-ne then do:
      {lnparhis.i &parm = "opnamt" &oldval = "old-opnamt" &newval = "lon.opnamt"}.
             v-edit = true.
   end.

end. /*tr*/
if lon.gua = "LK"
then do:
     if frame lon lon.opnamt entered
     then do:
          find first lonsec1 where lonsec1.lon = lon.lon no-lock no-error.
          if not available lonsec1
          then do:
               create lonsec1.
               lonsec1.lon = lon.lon.
               lonsec1.ln = 1.
               lonsec1.lonsec = 306.
               lonsec1.fdt = lon.rdt.
               lonsec1.tdt = date(12,31,2999).
               lonsec1.secamt = lon.opnamt.
               lonsec1.prm = loncon.objekts + "&" + v-vards + "&&&&&&&&&".
               lonsec1.who = g-ofc.
               lonsec1.whn = g-today.
               lonsec1.vieta = "&&&&&&&&&&".
               lonsec1.novert = lon.opnamt.
               lonsec1.proc = 100.
               lonsec1.vert = lon.opnamt.
               lonsec1.crc = lon.crc.
               lonsec1.uno = 1.
          end.
     end.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   /*if lon.prem = 0 and lon.prem1 ne 0 then
   message "По данному кредиту было автоматическое обнуление % ставки!" view-as alert-box. */
   {s-lonrd.i &vecais = "os-prem" &jaunais = "s-prem"}.
   if frame lon s-prem entered
   then do:
        lon.base = substring(s-prem,1,1).
        find base where base.base = lon.base no-lock no-error.
        if not available base
        then lon.base = "?".
        find rate where rate.base = lon.base no-lock no-error.
        if not available rate
        then do:
             bell.
             undo,retry.
        end.
        lon.prem = decimal(substring(s-prem,2)).
        if decimal(substring(s-prem,2)) = 0 and decimal(substring(os-prem,2)) > 0 then
        lon.prem1 = decimal(substring(os-prem,2)).
        if decimal(substring(s-prem,2)) > 0 and decimal(substring(os-prem,2)) = 0 then
        lon.prem1 = 0.
        if ja-ne then do:
           {lnparhis.i &parm = "intrate" &oldval = "os-prem" &newval = "s-prem"}.
                  v-edit = true.
        end.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   /*if lon.prem = 0 and lon.prem1 ne 0 then
   message "По данному кредиту было автоматическое обнуление % ставки!" view-as alert-box. */
   {s-lonrd.i &vecais = "od-prem" &jaunais = "d-prem"}.
   if frame lon d-prem entered
   then do:
        lon.base = substring(d-prem,1,1).
        find base where base.base = lon.base no-lock no-error.
        if not available base
        then lon.base = "?".
        find rate where rate.base = lon.base no-lock no-error.
        if not available rate
        then do:
             bell.
             undo,retry.
        end.
        lon.dprem = decimal(substring(d-prem,2)).
        if decimal(substring(d-prem,2)) = 0 and decimal(substring(od-prem,2)) > 0 then
        lon.dprem1 = decimal(substring(od-prem,2)).
        if decimal(substring(d-prem,2)) > 0 and decimal(substring(od-prem,2)) = 0 then
        lon.dprem1 = 0.
        if ja-ne then do:
           {lnparhis.i &parm = "intrate" &oldval = "od-prem" &newval = "d-prem"}.
                  v-edit = true.
        end.
   end.
end.

if (lon.gua <> "LK") and (lon.grp <> 90) and (lon.grp <> 92)
then do:
     /* if old-gua = "LK"
     then do:
          for each lnscg where lnscg.lng = s-lon :
              delete lnscg.
          end.
          for each lnsch where lnsch.lnn = s-lon:
              delete lnsch.
          end.
          for each lnsci where lnsci.lni = s-lon:
              delete lnsci.
          end.
     end. */
     if frame lon lon.rdt entered or
        frame lon lon.duedt entered or
        frame lon lon.opnamt entered or
        (old-gua = "LK" and lastkey <> keycode("PF4"))
     then do:
          run ln-sch.
          readkey pause 0.
     end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-rdate" &jaunais = "lon.rdate"}.
   if ja-ne then do:
      {lnparhis.i &parm = "long01" &oldval = "old-rdate" &newval = "lon.rdate"}.
             v-edit = true.
   end.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-ddate" &jaunais = "lon.ddate"}.
   if ja-ne then do:
      {lnparhis.i &parm = "long02" &oldval = "old-ddate" &newval = "lon.ddate"}.
             v-edit = true.
   end.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-ddt" &jaunais = "lon.ddt[5]"}.
   if ja-ne then do:
      {lnparhis.i &parm = "long1" &oldval = "old-ddt" &newval = "lon.ddt[5]"}.
             v-edit = true.
   end.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-cdt" &jaunais = "lon.cdt[5]"}.

   if ja-ne then do:
      {lnparhis.i &parm = "long2" &oldval = "old-cdt" &newval = "lon.cdt[5]"}.
             v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-proc-no" &jaunais = "loncon.proc-no"}.

  if ja-ne then do:
      {lnparhis.i &parm = "proc-no" &oldval = "old-proc-no" &newval = "loncon.proc-no"}.
             v-edit = true.
   end.
end.

/*galina - меняем ставку по штрафам*/
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:

   {s-lonrd.i &vecais = "old-penprem" &jaunais = "lon.penprem"}.
    if ja-ne then do:
        {lnparhis.i &parm = "penprem" &oldval = "old-penprem" &newval = "lon.penprem"}.
         v-edit = true.
    end.

   if (lookup(string(lon.grp),'20,21,23,24,25,26,27,28,60,63,64,65,66,67,68,80,81,82,90,92,95,96') > 0) and (lon.penprem > 0.5)
   then do:
        message "Невозможно проставления неустойки более 0,5%!" view-as alert-box error.
        bell.
        undo,retry.
   end.

    if lookup(string(s-longrp),'14,15,16,24,25,26,54,55,56,64,65,66,70,80,95,96,13,23,53,63') > 0 then do on endkey undo, leave:

       {s-lonrd.i &vecais = "old-penprem7" &jaunais = "lon.penprem7"}.
        if ja-ne then do:
            {lnparhis.i &parm = "penprem7" &oldval = "old-penprem7" &newval = "lon.penprem7"}.
             v-edit = true.
        end.

       if (lookup(string(lon.grp),'20,21,23,24,25,26,27,28,60,63,64,65,66,67,68,80,81,82,90,92,95,96') > 0) and (lon.penprem7 > 0.5)
       then do:
            message "Невозможно проставления неустойки более 0,5%!" view-as alert-box error.
            bell.
            undo,retry.
       end.
    end.
    else do:
      lon.penprem7 = lon.penprem.
      display lon.penprem7 with frame lon.
    end.
    loncon.sods1 = lon.penprem.
    display loncon.sods1 with frame lon.
    {lnparhis.i &parm = "pnlt1" &oldval = "old-sods1" &newval = "loncon.sods1"}.
end.



/*
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:

   --if loncon.sods1 = 0 and loncon.sods2 ne 0 then
          message "По данному кредиту было автоматическое обнуление штрафа!" view-as alert-box. --
   {s-lonrd.i &vecais = "old-sods1" &jaunais = "loncon.sods1"}.
        if decimal(loncon.sods1) = 0 and decimal(old-sods1) > 0 then
        loncon.sods2 = decimal(old-sods1).
        if decimal(loncon.sods1) > 0 and decimal(old-sods1) = 0 then
        loncon.sods2 = 0.
       if ja-ne then do:
          {lnparhis.i &parm = "pnlt1" &oldval = "old-sods1" &newval = "loncon.sods1"}.
                 v-edit = true.
       end.
end.
*/

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and lon.gua = "CL"
then do on endkey undo, leave:
   find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-error.
   if avail lonhar then do:
      v-komcl-old = v-komcl.
      {s-lonrd.i &vecais = "v-komcl-old" &jaunais = "v-komcl"}.
      if ja-ne then do:
         {lnparhis.i &parm = "comln" &oldval = "v-komcl-old" &newval = "v-komcl"}.
                v-edit = true.
      end.
      lonhar.rez-dec[2]  = v-komcl.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1")
then do on endkey undo, leave:

    {s-lonrd.i &vecais = "old-prem_s" &jaunais = "prem_s"}.
    if ja-ne then do:
        if prem_s <> old-prem_s then do:
            {lnparhis.i &parm = "prems" &oldval = "old-prem_s" &newval = "prem_s"}.
            v-edit = true.
            find first lons where lons.lon = lon.lon exclusive-lock no-error.
            if not avail lons then do:
                create lons.
                lons.lon = lon.lon.
            end.
            lons.prem = prem_s.
        end.
    end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and prem_s > 0
then do on endkey undo, leave:

    {s-lonrd.i &vecais = "old-premsdt" &jaunais = "premsdt"}.
    if ja-ne then do:
        if premsdt <> old-premsdt then do:
            {lnparhis.i &parm = "premsdt" &oldval = "old-premsdt" &newval = "premsdt"}.
            v-edit = true.
            find first lons where lons.lon = lon.lon exclusive-lock no-error.
            if not avail lons then do:
                create lons.
                lons.lon = lon.lon.
            end.
            lons.rdt = premsdt.
        end.
    end.
end.

/*
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
   (lon.opnamt - v-londam1 > 0 or lon.gua = "CL" or lon.gua = "OD")
then do on endkey undo, leave:
     {s-lonrd.i &vecais = "o-i-dt" &jaunais = "i-dt"}.
      if ja-ne then do:
         {lnparhis.i &parm = "ldate" &oldval = "o-i-dt" &newval = "i-dt"}.
                v-edit = true.
      end.

     if i-dt <> o-i-dt
     then do:
          if index(loncon.rez-char[10],"&") > 0
          then loncon.rez-char[10] = string(i-dt,"99/99/9999") +
               substring(loncon.rez-char[10],index(loncon.rez-char[10],"&")).
          else loncon.rez-char[10] = string(i-dt,"99/99/9999") + "&".
          if i-dt - lon.rdt > 3
          then do:
               run h-i-dt.
               readkey pause 0.
          end.
     end.
end.
*/

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-idt15" &jaunais = "lon.idt15"}.

  if ja-ne then do:
      {lnparhis.i &parm = "idt15" &oldval = "o-idt15" &newval = "lon.idt15"}.
      v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-idt35" &jaunais = "lon.idt35"}.

  if ja-ne then do:
      {lnparhis.i &parm = "idt35" &oldval = "o-idt35" &newval = "lon.idt35"}.
      v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-lonaaa" &jaunais = "lon.aaa"}.

   find first aaa where aaa.aaa = lon.aaa no-lock no-error.
   if (not available aaa)
   then do:
        message "Некорректный счет!" view-as alert-box error.
        bell.
        undo,retry.
   end.
   ja-ne2 = no.
   if (aaa.cif <> lon.cif) then do:
      find first b-cif where b-cif.cif = aaa.cif no-lock no-error.
      if avail b-cif then v-aaaname = trim(b-cif.name). else v-aaaname = ''.
      message "Счет принадлежит другому клиенту!~n(" + aaa.cif + ") " + v-aaaname + "~nПродолжить?"
        view-as alert-box question buttons yes-no update ja-ne2.
   end.
   if ja-ne and ja-ne2 then do:
      {lnparhis.i &parm = "lonaaa" &oldval = "old-lonaaa" &newval = "lon.aaa"}.
             v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-lonaaad" &jaunais = "lon.aaad"}.

   if lon.aaad <> '' then do:
       find first aaa where aaa.aaa = lon.aaad no-lock no-error.
       if (not available aaa)
       then do:
            message "Некорректный ARP счет!" view-as alert-box error.
            bell.
            undo,retry.
       end.
   end.
   ja-ne2 = no.
   if (aaa.cif <> lon.cif) then do:
      find first b-cif where b-cif.cif = aaa.cif no-lock no-error.
      if avail b-cif then v-aaaname = trim(b-cif.name). else v-aaaname = ''.
      message "ARP счет принадлежит другому клиенту!~n(" + aaa.cif + ") " + v-aaaname + "~nПродолжить?"
        view-as alert-box question buttons yes-no update ja-ne2.
   end.
   if ja-ne and ja-ne2 then do:
      {lnparhis.i &parm = "lonaaad" &oldval = "old-lonaaad" &newval = "lon.aaad"}.
             v-edit = true.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:

        find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-error.
        if avail lonhar then do:
             {s-lonrd.i &vecais = "old-crc" &jaunais = "v-crc"}.
             if ja-ne then do:
                {lnparhis.i &parm = "kcrc" &oldval = "old-crc" &newval = "v-crc"}.
                       v-edit = true.
             end.

             {s-lonrd.i &vecais = "old-rate" &jaunais = "v-rate"}.
             if ja-ne then do:
               {lnparhis.i &parm = "drate" &oldval = "old-rate" &newval = "v-rate"}.
                      v-edit = true.
             end.

             lonhar.rez-int[1] = v-crc.
             lonhar.rez-dec[1] = v-rate.
             if lonhar.rez-dec[1] > 0 then do:
               find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and d-cod = 'lnindex' no-error.
               if not avail sub-cod then do:
                 create sub-cod.
                 sub-cod.sub = 'lon'.
                 sub-cod.acc = lon.lon.
                 sub-cod.d-cod = 'lnindex'.
                 sub-cod.rdt = g-today.
               end.
               sub-cod.ccode = '1'.
               release sub-cod.
             end.
        end.
        else message ' not avail '  s-lon.
end.



/* Утверждение кредита в другом режиме
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
   (v-londam1 = 0 and i-dt <> ? and trim(loncon.lcnt) <> "" and
   lon.crc > 0 and lon.rdt <> ? and lon.duedt <> ? and lon.grp > 0 and
   lon.loncat > 0 and (lon.opnamt > 0 or lon.gua = "OD") or v-londam1 > 0
   and not paraksts)
then do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-paraksts" &jaunais = "paraksts"}.
   if frame lon paraksts entered
   then loncon.rez-char[10] =
        substring(loncon.rez-char[10],1,index(loncon.rez-char[10],"&")) +
        string(paraksts) + "&".
end.
*/

if frame lon lon.rdt entered or
   frame lon lon.duedt entered or
   frame lon lon.opnamt entered or
   frame lon s-prem entered or
   frame lon loncon.sods1 entered or
   frame lon v-komcl    entered or
   frame lon lon.ddt[5] entered or
   frame lon lon.cdt[5] entered or
   frame lon v-crc      entered or
   frame lon v-rate     entered
then do:
     if frame lon loncon.sods1 entered then do:

         find last lnprohis where lnprohis.lon = lon.lon and lnprohis.type = 'pen' and lnprohis.sts = 'A'  use-index lntpsts exclusive-lock no-error.
         if avail lnprohis then lnprohis.sts = 'C'.
     end.
     if v-londam1 > 0
     then do:
          find first ln%his where ln%his.lon = lon.lon and
               ln%his.stdat = g-today no-lock.
          v-f0 = index(loncon.rez-char[4],"/" +
                 string(ln%his.stdat,"99/99/9999") + "&").
          if v-f0 > 0
          then do:
               pap = substring(loncon.rez-char[4],1,v-f0 - 1).
               pap = substring(pap,r-index(pap,"#") + 1).
          end.
          else pap = "".
          v-f1 = index(loncon.rez-char[5],"/" +
                 string(ln%his.stdat,"99/99/9999") + "&").
          if v-f1 > 0
          then do:
               iem = substring(loncon.rez-char[5],1,v-f1 - 1).
               iem = substring(iem,r-index(iem,"#") + 1).
          end.
          else iem = "".
          /* tsoy 11.08.2004
          display pap
                  iem
                  ln%his.stdat
                  ln%his.rdt
                  ln%his.duedt
                  ln%his.opnamt
                  ln%his.intrate
                  ln%his.pnlt1
                  ln%his.pnlt2
                  ln%his.comln
                  ln%his.long1
                  ln%his.long2
                  ln%his.kcrc
                  ln%his.drate  with frame pap.

          update pap iem with frame pap.

          */
          if substring(pap,2,1) = " " or length(pap) = 1
          then pap = " " + substring(pap,1,1).
          if trim(pap) <> ""
          then do:
               if index(loncon.rez-char[4],"#" + pap) > 0
               then do:
                    if index(loncon.rez-char[4],pap + "/" +
                       string(ln%his.stdat,"99/99/9999")) = 0
                    then do:
                         bell.
                         undo,retry.
                    end.
               end.
               else do:
                    if v-f0 > 0
                    then overlay(loncon.rez-char[4],v-f0 - 2,2) = pap.
                    else loncon.rez-char[4] = loncon.rez-char[4] + "#" + pap +
                                  "/" + string(ln%his.stdat,"99/99/9999") + "&".
               end.
          end.
          else if v-f0 > 0
          then loncon.rez-char[4] = substring(loncon.rez-char[4],1,v-f0 - 3) +
                                    substring(loncon.rez-char[4],v-f0 + 12).
          if trim(iem) <> ""
          then do:
               if v-f1 > 0
               then do:
                    v-f0 = r-index(substring(loncon.rez-char[5],1,
                           v-f1 - 1),"#").
                    loncon.rez-char[5] = substring(loncon.rez-char[5],1,v-f0) +
                           iem + substring(loncon.rez-char[5],v-f1).
               end.
               else loncon.rez-char[5] = loncon.rez-char[5] + "#" + iem +
                                  "/" + string(ln%his.stdat,"99/99/9999") + "&".
          end.
          else if v-f1 > 0
          then do:
               v-f0 = r-index(substring(loncon.rez-char[5],1,v-f1 - 1),"#").
               loncon.rez-char[5] = substring(loncon.rez-char[5],1,v-f0 - 1) +
                                    substring(loncon.rez-char[5],v-f1 + 12).
          end.
          hide frame pap.
     end.
     else loncon.rez-char[5] = "#LЁgums/" + string(g-today,"99/99/9999") + "&".
end.
do :
   if loncon.lcnt = ' ' or
      lon.crc = 0 or
      lon.rdt = ? or
      lon.duedt = ?
      or lon.grp = 0
      or lon.opnamt <= 0
      or not paraksts
   then lon.apr = 'NO'.
   else lon.apr = 'OK'.
end.


if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   update
          loncon.vad-amats
          loncon.vad-vards
          loncon.galv-gram
          loncon.rez-char[9]
          with frame lon.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and lon.plan < 3 then
do on endkey undo, leave:
   update  lon.aaa
   with frame lon.
end.

/**          loncon.kods
          loncon.konts
          loncon.talr**/


if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-deps" &jaunais = "v-deposit"}.
   if frame lon v-deposit entered
   then do:
        find first aaa where aaa.aaa = v-deposit no-lock no-error.
        if not available aaa
        then do:
             bell.
             undo,retry.
        end.
        loncon.deposit = v-deposit.
   end.
end.


if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   /*31/01/04 nataly*/
   update  lon.basedy loncon.pase-pier loncon.obes-pier
   with frame lon.

   if v-edit or not paraksts then loncon.who = userid("bank").

end.

