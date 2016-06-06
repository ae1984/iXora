﻿/* s-lonrdu.p
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
        26.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        28/05/2004 madiar - открытие нового ссудного счета - проверяется не физ/юр лицо, сектор экономики
        03/06/2004 madiar - открытие нового ссудного счета - проверяется наличие корректного признака физ/юр лицо
        10/02/06 marinav переломпиляция
        12/12/2008 galina - перекомпилЯциЯ
        20/10/2009 madiyar - изменения, связанные с изменением lnparhis.i
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        28/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        11.01.2013 evseev - ТЗ-1530
*/

{mainhead.i}
{get-kod.i}
{lonlev.i}
define  shared variable s-lon    like lon.lon.
define  shared variable s-longrp like longrp.longrp.
define  shared variable grp-name as character.
define  shared variable crc-code as character.
define  shared variable cat-des  as character.
define  shared variable v-cif    like cif.cif.
define  shared variable v-lcnt   like loncon.lcnt.
define  shared variable v-vards  like cif.name format "x(36)".
define  shared variable s-cat as character.
define  shared variable s-apr as character.
define shared frame cif.
define variable v-uno like uno.uno no-undo.
define variable clcif  like cif.cif no-undo.
define variable clname like cif.name no-undo.
define shared variable s-prem as character.
define shared variable d-prem as character.
define var is-newlon as logical no-undo.
define var tmpstr as char no-undo.

def   shared var v-crc like crc.crc.
def   shared var v-rate like crc.rate[1].
def   shared var v-komcl as deci .


{s-lonrdl.f}.

define new shared variable grp as integer init 2.
define new shared variable rc  as integer.
define variable v-f0 as integer no-undo.
define variable o-basedy as integer no-undo.
define variable o-idt15 as date no-undo.
define variable o-idt35 as date no-undo.
define variable old-duedt15 like lon.duedt.
define variable old-duedt35 like lon.duedt.
define variable o-paraksts as logical no-undo.
define variable o-prnmos as decimal no-undo.
define variable os-prem as character no-undo.
define variable od-prem as character no-undo.
define new shared variable su-min as integer.
define new shared variable su-max as integer.
def var v-londam1 like lon.dam[1] no-undo.

def var lonsrok as int no-undo.

find lon where lon.lon = s-lon.
find loncon where loncon.lon = s-lon.
find cif where cif.cif = lon.cif no-lock.
find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1
     exclusive-lock no-error.
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
if index(loncon.rez-char[10],"&") > 0
then do:
     if substring(loncon.rez-char[10],index(loncon.rez-char[10],"&") + 1,3) = "yes" then paraksts = yes.
     else paraksts = no.
end.
else paraksts = no.

o-paraksts = paraksts.
s-longrp = lon.grp.
readkey pause 0.


dam1-cam1 = 0.
v-londam1 = 0.
for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
no-lock :
    if trxbal.level = 1 then v-londam1 = trxbal.dam.
    if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then
    dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam).
end.

v-uno = lon.prnmos.

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
        loncon.lcntsub
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
        lon.day lon.plan
        lon.basedy
        loncon.who
        loncon.pase-pier
        with frame lon.

         /*31/01/04 nataly*/
          find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock no-error.
          if avail lonhar then do:
             v-crc = lonhar.rez-int[1].
             v-rate = lonhar.rez-dec[1].
             v-komcl = lonhar.rez-dec[2].
          end .
          display v-crc v-rate v-komcl with frame lon.

display v-vards with frame cif.
o-basedy = lon.basedy.
old-lcnt = loncon.lcnt.
old-gua = lon.gua.
old-cat = lon.loncat.
old-rdt = lon.rdt.
old-duedt = lon.duedt.
old-duedt15 = lon.duedt15.
old-duedt35 = lon.duedt35.
old-opnamt = lon.opnamt.
old-prem = lon.prem.
/*old-dprem = lon.dprem.*/
/*old-lcr = lon.lcr.*/
old-sods1 = loncon.sods1.

do on endkey undo, leave:
   {s-lonrd.i &vecais = "lon.cif" &jaunais = "v-cif"}.
   {lnparhis.i &parm = "cif" &oldval = "lon.cif" &newval = "v-cif"}.
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
/*   update v-lcnt with frame lon.
   message trim(v-lcnt). pause 5. */
   {s-lonrd.i &vecais = "old-lcnt" &jaunais = "v-lcnt"}.
   {lnparhis.i &parm = "lcnt" &oldval = "old-lcnt" &newval = "v-lcnt"}.
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
   {lnparhis.i &parm = "gua" &oldval = "old-gua" &newval = "lon.gua"}.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "lon.grp" &jaunais = "s-longrp"}.
   {lnparhis.i &parm = "grp" &oldval = "lon.grp" &newval = "s-longrp"}.
   if is-newlon then
   DO: /* is-newlon */
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
   {s-lonrd.i &vecais = "o-prnmos" &jaunais = "v-uno"}.
   if frame lon v-uno entered
   then do:
        find first uno where uno.grupa = 2 and uno.uno = v-uno
             no-lock no-error.
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
       update
        lon.plan
        lon.day with frame lon.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   if v-londam1 = 0
   then update lon.crc with frame lon.
   if frame lon lon.crc entered
   then do:
        find crc where crc.crc = lon.crc no-lock.
        crc-code = string(crc.code,"xxxx") + substring(crc-code,5).
        display crc-code with frame lon.
   end.
end. /*tr*/
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   su-min = 10100.
   su-max = 19999.
   if cif.cgr = 201 or cif.cgr > 500 and cif.cgr < 699
   then do:
        su-min = 100 * cif.cgr.
        if cif.cgr = 502
        then su-min = 50100.
        if su-min = 50100
        then su-max = 50499.
        else su-max = su-min + 99.
   end.
/*   {s-lonrd.i &vecais = "old-noz" &jaunais = "s-cat"}.
   if frame lon s-cat entered
   then do:
        lon.loncat = integer(s-cat).
        find loncat where loncat.loncat = lon.loncat no-lock no-error.
        if not available loncat
        then lon.loncat = 0.
        if lon.loncat < su-min or lon.loncat > su-max
        then lon.loncat = 0.
        lon.loncat = (lon.loncat - lon.loncat modulo 100) / 100.
        find loncat where loncat.loncat = lon.loncat no-lock no-error.
        if not available loncat
        then do:
             bell.
             undo,retry.
        end.
        cat-des = loncat.des.

        if s-cat = "50101"
        then s-cat = "59101".
        else if s-cat = "50201"
        then s-cat = "59102".
        else if s-cat = "50401"
        then s-cat = "59103".
        else if s-cat >= "60101" and s-cat <= "69100"
        then s-cat = "691" + substring(s-cat,2,2).

        lonhar.rez-int[3] = integer(s-cat).
        find loncat where loncat.loncat = integer(s-cat) no-lock.
        crc-code = substring(crc-code,1,4) + loncat.des.
        display crc-code cat-des with frame lon.
        {lnparhis.i &parm = "loncat" &parmval = "lon.loncat"}
   end.*/
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   update loncon.objekts with frame lon.
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
   {lnparhis.i &parm = "rdt" &oldval = "old-rdt" &newval = "lon.rdt"}.
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

   if is-newlon then
   DO: /* is-newlon */
   find longrp where longrp.longrp = s-longrp no-lock no-error.
   /* краткосрочный */
   if substr(string(longrp.stn), 2, 1) = "1" then if lonsrok > 365 then do:
      message "Не верный срок окончания! У вас краткосрочная группа!".
      undo, leave.
   end.
   /* долгосрочный */
   if substr(string(longrp.stn), 2, 1) = "2" then if lonsrok <= 365 then do:
      message "Не верный срок окончания! У вас долгосрочная группа!".
      undo, leave.
   end.
   /* овердрафт */
   if substr(string(longrp.stn), 2, 1) = "3" then if lonsrok > 31 then do:
      message "Не верный срок окончания! У вас группа с овердрафтом!".
      undo, leave.
   end.
   END. /* is-newlon */

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

   /* признак срока кредита */
   find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = "lnshifr" no-error.
   if not avail sub-cod then do:
      create sub-cod.
      assign sub-cod.sub = "LON"
             sub-cod.acc = lon.lon
             sub-cod.d-cod = "lnshifr"
             no-error.
   end.
   /* краткосроч. */
   if lonsrok <= 365 then do:
      if substr(get-kod("", v-cif), 1, 1) = "1"
         then tmpstr = "Остатки по КСК ФЛ".
         else tmpstr = "Остатки по КСК ЮЛ".
      if lon.crc = 1 then tmpstr = tmpstr + " в тенге".
                     else tmpstr = tmpstr + " в СКВ".
   end.
   /* долгосроч */
   else do:
      if substr(get-kod("", v-cif), 1, 1) = "1"
         then tmpstr = "Остатки по ДСК ФЛ".
         else tmpstr = "Остатки по ДСК ЮЛ".
      if lon.crc = 1 then tmpstr = tmpstr + " в тенге".
                     else tmpstr = tmpstr + " в СКВ".
   end.
   find first sub-cod where sub-cod.sub = "lon" and sub-cod.acc = lon.lon and sub-cod.d-cod = "lnshifr" no-error.
   find codfr where codfr.codfr = "lnshifr" and trim (codfr.name[1]) = tmpstr no-lock no-error.
   if avail codfr then sub-cod.ccode = codfr.code.
/*                  else sub-cod.ccode = "msc".*/

   {lnparhis.i &parm = "duedt" &oldval = "old-duedt" &newval = "lon.duedt"}.
   if lon.duedt <> old-duedt
   then do:
        find lonsa where lonsa.lon = lon.lon no-error.
        if available lonsa
        then lonsa.duedt = lon.duedt.
   end.
end. /*tr*/

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-duedt15" &jaunais = "lon.duedt15"}.

  if ja-ne then do:
      {lnparhis.i &parm = "duedt15" &oldval = "old-duedt15" &newval = "lon.duedt15"}.
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-duedt35" &jaunais = "lon.duedt35"}.

  if ja-ne then do:
      {lnparhis.i &parm = "duedt35" &oldval = "old-duedt35" &newval = "lon.duedt35"}.
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
   {lnparhis.i &parm = "opnamt" &oldval = "old-opnamt" &newval = "lon.opnamt"}.
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
        {lnparhis.i &parm = "intrate" &oldval = "os-prem" &newval = "s-prem"}.
   end.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "od-prem" &jaunais = "d-prem"}.
   if frame lon d-prem entered
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
        lon.dprem = decimal(substring(d-prem,2)).
        {lnparhis.i &parm = "intrate" &oldval = "od-prem" &newval = "d-prem"}.
   end.
end.
if lon.gua <> "LK"
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
   {s-lonrd.i &vecais = "old-proc-no" &jaunais = "loncon.proc-no"}.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-ddt" &jaunais = "lon.ddt[5]"}.
end.
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-cdt" &jaunais = "lon.cdt[5]"}.
end.

if lon.gua = "LK"
then do:
     if frame lon lon.opnamt     entered or
        frame lon lon.rdt        entered or
        frame lon lon.duedt      entered or
        frame lon s-prem         entered or
        frame lon d-prem         entered or
        frame lon loncon.proc-no entered
     then run s-liz(1).
     else run s-liz(0).
     if rc > 0
     then undo,retry.
     readkey pause 0.
end.
if lon.gua = "FK"
then do:
     if frame lon lon.opnamt entered or
        frame lon lon.rdt    entered or
        frame lon lon.duedt  entered or
        frame lon s-prem     entered or
        frame lon d-prem     entered
     then run s-fak(1).
     else run s-fak(0).
     if rc > 0
     then undo,retry.
     readkey pause 0.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "old-sods1" &jaunais = "loncon.sods1"}.
   {lnparhis.i &parm = "pnlt1" &oldval = "old-sods1" &newval = "loncon.sods1"}.
end.

/*
if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
   (lon.opnamt - v-londam1 > 0 or lon.gua = "CL" or lon.gua = "OD")
then do on endkey undo, leave:
     {s-lonrd.i &vecais = "o-i-dt" &jaunais = "i-dt"}.
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
   end.
end.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") then
do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-idt35" &jaunais = "lon.idt35"}.

  if ja-ne then do:
      {lnparhis.i &parm = "idt35" &oldval = "o-idt35" &newval = "lon.idt35"}.
   end.
end.


/* Добавить все остальные проверки*/

/*if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
   (v-londam1 = 0 and i-dt <> ? and trim(loncon.lcnt) <> "" and
   lon.crc > 0 and lon.rdt <> ? and lon.duedt <> ? and lon.grp > 0 and
   lon.loncat > 0 and (lon.opnamt > 0 or lon.gua = "OD") or v-londam1 > 0
   and not paraksts)
*/

find first lonsec1 where lonsec1.lon = s-lon no-lock no-error.
find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = s-lon and ccode ne 'msc' no-lock no-error.

if lastkey <> keycode("PF4") and lastkey <> keycode("PF1") and
   avail lonsec1 and avail sub-cod and not paraksts
then do on endkey undo, leave:
   {s-lonrd.i &vecais = "o-paraksts" &jaunais = "paraksts"}.
   if frame lon paraksts entered
   then loncon.rez-char[10] =
        substring(loncon.rez-char[10],1,index(loncon.rez-char[10],"&")) +
        string(paraksts) + "&".
end.
else do:
   if not avail lonsec1 then do: message "Нет обеспечения". pause 5. end.
   if not avail sub-cod then do: message "Не проставлены признаки по счету". pause 5. end.
end.



if frame lon lon.rdt entered or
   frame lon lon.duedt entered or
   frame lon lon.opnamt entered or
   frame lon s-prem entered or
   frame lon d-prem entered or
   frame lon loncon.sods1 entered
then do:
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
          display pap
                  iem
                  ln%his.stdat
                  ln%his.rdt
                  ln%his.duedt
                  ln%his.opnamt
                  ln%his.intrate
                  ln%his.pnlt1
                  ln%his.pnlt2 with frame pap.
          update pap iem with frame pap.
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
/*          loncon.kods
          loncon.konts
          loncon.talr*/
          lon.basedy

   with frame lon.
   loncon.who = userid('bank').
end.
