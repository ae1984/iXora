/*balup.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Здесь пишутся истории за каждый день по всем таблицам счетов! - aab, hisarp, hisfun, hisock, hisast
        и история справочника sub-cod - hissc
        История пишется в том случае, если менялась хоть одна сумма из dam[i], cam[i]
        Замечание: по ссудным счетам изменение dam[2] не отслеживается, кому надо - см. таблицу acr
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
        11.11.2003 marinav Добавила в т-цу hislon поля tdam[5] tcam[5]
                      tdam[1] для ежедневной записи 7 ур (просрочка ОД)
                      tdam[2] для ежедневной записи 9 ур (проср %%)
                      tdam[3] для ежеднев записи штрафов 16 ур.

        15.12.03 nataly добавила в таблицу hisfun запись значений hisfun.rate
        05.01.04 marinav - переделала запись в историю просрочки
        04.02.04 nataly - были добавлены записи в историю для индексации и ее просрочки
                      tdam[4] для ежедневной записи 20 ур (индексация)
                      tdam[5] для ежедневной записи 21 ур (проср индексация)
        04.03.04 valery - запись истории для trxbal
        29.03.2004 nadejda - перенесла запись в histrxbal в предыдущий цикл
        23.03.2005 suchkov - иправил проставление даты в aab.fdt
        29/09/05 nataly проставление кодов ГК + кода департамента в таблице accr
        05.10.06 nataly добавила getdep.i
        24/04/2009 madiyar - закомментил поиск lgr (нигде не используется)
*/


{global.i}
{getdep.i}


define var v-dep as char format 'x(5)'.
def var i as inte.
define var v-fl as log.
def  shared var s-bday as logical.
def  shared var s-intday as int.

def buffer b-accr for accr.
def buffer blgr for lgr.
/*def shared var g-today as date.*/

/*s-bday = true.
s-intday = 1.
 */

def buffer b-trxbal for trxbal.
def buffer trxlevgl11 for trxlevgl .

for each trxbal no-lock :
    if trxbal.dam <> trxbal.pdam or trxbal.cam <> trxbal.pcam then do:
        find b-trxbal where recid(b-trxbal) eq recid(trxbal) exclusive-lock.
        assign b-trxbal.pdam = b-trxbal.dam
               b-trxbal.pcam = b-trxbal.cam.
        find current b-trxbal no-lock.

        /* 29.03.2004 nadejda - создаем запись в histrxbal на текущую дату */
        create histrxbal.
        buffer-copy trxbal to histrxbal.
        histrxbal.dt = g-today.
    end.

/* 29.03.2004 nadejda - перенесла запись в histrxbal в предыдущий цикл
    find last histrxbal where histrxbal.subled = trxbal.subled and   / * ищем в histrxbal запись c одинаковыми полями : subled, acc, level, crc * /
                         histrxbal.acc = trxbal.acc and
                         histrxbal.level = trxbal.level and
                         histrxbal.crc = trxbal.crc and histrxbal.dt < g-today use-index trxbal no-error.
    if avail histrxbal then / * если такая запись найдена * /
    do: / *проверяем дебет/кредит в histrxbal отличаются от дебет/кредит на конец дня из trxbal* /
        if histrxbal.dam = trxbal.pdam and histrxbal.cam = trxbal.pcam then next. / *если нет то переходим на следующую запись trxbal* /
        else
        do: / *Иначе, если есть отличие, то создаем запись в histrxbal на текущую дату с измененными дебетом/кредитом* /
            create histrxbal.
            buffer-copy trxbal to histrxbal.
            histrxbal.dt = g-today.
        end.
    end.
    else do:
            create histrxbal.
            buffer-copy trxbal to histrxbal.
            histrxbal.dt = g-today.
         end.
*/
end.



for each aaa transaction:
  /*find lgr where lgr.lgr = aaa.lgr no-lock.*/
  if aaa.sta eq "N" then do :
     if g-today - aaa.regdt ge 30 then aaa.sta = "A".
  end.

  if aaa.cbal lt 0 then aaa.rsv-dec[2] = aaa.rsv-dec[2] - aaa.cbal * s-intday.

  if aaa.cr[1] - aaa.dr[1] lt 0 then aaa.rsv-dec[1] = aaa.rsv-dec[1] + (aaa.dr[1] - aaa.cr[1]) * s-intday.

  assign aaa.mtdavl = aaa.mtdavl + aaa.cbal * s-intday
         aaa.mtdacc = aaa.mtdacc + (aaa.cr[1] - aaa.dr[1]) * s-intday
         aaa.minbal = min(aaa.minbal[1],aaa.cr[1] - aaa.dr[1])
         aaa.maxbal = max(aaa.maxbal[1],aaa.cr[1] - aaa.dr[1])
         aaa.ddr[1] = aaa.dr[1]
         aaa.ddr[2] = aaa.dr[2]
         aaa.ddr[3] = aaa.dr[3]
         aaa.ddr[4] = aaa.dr[4]
         aaa.ddr[5] = aaa.dr[5]
         aaa.pdr[month(g-today)] = aaa.pdr[month(g-today)] + aaa.dr[1] * s-intday
         aaa.dcr[1] = aaa.cr[1]
         aaa.dcr[2] = aaa.cr[2]
         aaa.dcr[3] = aaa.cr[3]
         aaa.dcr[4] = aaa.cr[4]
         aaa.dcr[5] = aaa.cr[5]
         aaa.pcr[month(g-today)] = aaa.pcr[month(g-today)] + aaa.cr[1] * s-intday.

 find last accr where accr.aaa eq aaa.aaa no-error.
 if not available accr then do:
      create accr.
          {accr.i} /*28/09/05 nataly*/
      assign accr.aaa = aaa.aaa
             accr.fdt = g-today
             accr.bal = aaa.cr[1] - aaa.dr[1]
             accr.rate = aaa.rate
             accr.accrued = 0.
 end.

 if available accr then do:
   if accr.fdt <> g-today and accr.bal ne (aaa.cr[1] - aaa.dr[1]) then  do:
     create accr.
                    {accr.i} /*28/09/05 nataly*/
     assign accr.aaa = aaa.aaa
            accr.fdt = g-today
            accr.bal = aaa.cr[1] - aaa.dr[1]
            accr.rate = aaa.rate
            accr.accrued = 0.
   end.

   if accr.fdt = g-today and accr.bal ne (aaa.cr[1] - aaa.dr[1]) then do:
     accr.bal = aaa.cr[1] - aaa.dr[1].
    /*message 'расхождение по счету ' aaa.aaa g-today. pause 100.*/
   end.
 end. /*if available accr*/

  find last aab where aab.aaa eq aaa.aaa no-error.
  if not available aab
    then do:
      create aab.
      assign aab.aaa = aaa.aaa
             aab.bal = aaa.cr[1] - aaa.dr[1]
             aab.avl = aaa.cbal
             aab.rate = aaa.rate
             aab.fdt = g-today.

/*      if lgr.led <> "TDA" then aab.fdt = g-today.
                           else aab.fdt = aaa.cltdt. */
    end.
  else if aab.bal ne aaa.cr[1] - aaa.dr[1] or aab.avl ne aaa.cbal
                                           or aab.rate <> aaa.rate
    then do:
      create aab.
      assign aab.aaa = aaa.aaa
             aab.bal = aaa.cr[1] - aaa.dr[1]
             aab.avl = aaa.cbal
             aab.rate = aaa.rate
             aab.fdt = g-today.

/*      if lgr.led <> "TDA" then aab.fdt = g-today.
      else do:
        if can-find(aab where aab.aaa = aaa.aaa and aab.fdt = aaa.cltdt) then aab.fdt = g-today.
                   else aab.fdt = aaa.cltdt.
      end. */
    end.
if s-bday then do:
  aaa.cbal = aaa.cbal + aaa.fbal[1].
  aaa.fbal[1] = aaa.fbal[2].
  aaa.fbal[2] = aaa.fbal[3].
  aaa.fbal[3] = aaa.fbal[4].
  aaa.fbal[4] = aaa.fbal[5].
  aaa.fbal[5] = aaa.fbal[6].
  aaa.fbal[6] = aaa.fbal[7].
  aaa.fbal[7] = 0.
 end.
end.

/** обнуление или уменьшение процентов CDA предыдущего года
for each aal where aal.regdt eq g-today no-lock use-index regdt:
    if aal.aax eq 66 then do transaction on error undo, retry:
        find aaa where aaa.aaa eq aal.aaa.
        find lgr where lgr.lgr eq aaa.lgr no-lock.
            if lgr.led eq "CDA" then do:
                if (aaa.ratmin - aal.amt) lt 0 then aaa.ratmin = 0.
                else aaa.ratmin = aaa.ratmin - aal.amt.
            end.
    end.
end.***********   FOR_SVL   ***********/

/* History for ARP subledger - file HISARP */
for each arp no-lock:
  find last hisarp where hisarp.arp eq arp.arp no-lock no-error.
  if not available hisarp
  then do:
      create hisarp.
      assign hisarp.arp  = arp.arp
             hisarp.fdt  = g-today.
      do i = 1 to 5:
         assign hisarp.dam[i]  = arp.dam[i]
                hisarp.cam[i]  = arp.cam[i]
                hisarp.ncrc[i] = arp.ncrc[i].
      end.
      hisarp.ncrc[1] = arp.crc.
  end.
  else if
    hisarp.dam[1] ne arp.dam[1] or hisarp.cam[1] ne arp.cam[1] or
    hisarp.dam[2] ne arp.dam[2] or hisarp.cam[2] ne arp.cam[2] or
    hisarp.dam[3] ne arp.dam[3] or hisarp.cam[3] ne arp.cam[3] or
    hisarp.dam[4] ne arp.dam[4] or hisarp.cam[4] ne arp.cam[4] or
    hisarp.dam[5] ne arp.dam[5] or hisarp.cam[5] ne arp.cam[5]
    then do:
      create hisarp.
      assign hisarp.arp  = arp.arp
             hisarp.fdt  = g-today.
      do i = 1 to 5:
         assign hisarp.dam[i]  = arp.dam[i]
                hisarp.cam[i]  = arp.cam[i]
                hisarp.ncrc[i] = arp.ncrc[i].
      end.
      hisarp.ncrc[1] = arp.crc.
  end.
end.

/* History for FUN subledger - file HISFUN */
for each fun no-lock:
  find gl where gl.gl eq fun.gl no-lock no-error.
  find last hisfun where hisfun.fun eq fun.fun no-lock no-error.
  if not available hisfun
  then do:
      create hisfun.
      assign hisfun.fun  = fun.fun
             hisfun.rate = fun.intrate /*15.12.03 nataly*/
            /* hisfun.duedt = fun.duedt*/
             hisfun.fdt  = g-today.
      do i = 1 to 5:
         assign hisfun.dam[i]  = fun.dam[i]
                hisfun.cam[i]  = fun.cam[i]
                hisfun.ncrc[i] = fun.ncrc[i].
      end.
      hisfun.ncrc[1] = fun.crc.
  end.
  else if
    hisfun.rate ne fun.intrate or /*hisfun.duedt ne fun.duedt or*/ /*15.12.03 nataly*/
    hisfun.dam[1] ne fun.dam[1] or hisfun.cam[1] ne fun.cam[1] or
    (hisfun.dam[2] ne fun.dam[2] and gl.type eq "L") or
    (hisfun.cam[2] ne fun.cam[2] and gl.type eq "A") or
    hisfun.dam[3] ne fun.dam[3] or hisfun.cam[3] ne fun.cam[3] or
    hisfun.dam[4] ne fun.dam[4] or hisfun.cam[4] ne fun.cam[4] or
    hisfun.dam[5] ne fun.dam[5] or hisfun.cam[5] ne fun.cam[5]
    then do:
      create hisfun.
      assign hisfun.fun  = fun.fun
             hisfun.rate = fun.intrate /*15.12.03 nataly*/
           /*  hisfun.duedt = fun.duedt*/
             hisfun.fdt  = g-today.
      do i = 1 to 5:
         assign hisfun.dam[i]  = fun.dam[i]
                hisfun.cam[i]  = fun.cam[i]
                hisfun.ncrc[i] = fun.ncrc[i].
      end.
      hisfun.ncrc[1] = fun.crc.
  end.
end.

/* History for DFB subledger - file HISDFB */
for each dfb no-lock:
  find last hisdfb where hisdfb.dfb eq dfb.dfb no-lock no-error.
  if not available hisdfb
  then do:
      create hisdfb.
      assign hisdfb.dfb  = dfb.dfb
             hisdfb.fdt  = g-today.
      do i = 1 to 5:
         assign hisdfb.dam[i]  = dfb.dam[i]
                hisdfb.cam[i]  = dfb.cam[i]
                hisdfb.ncrc[i] = dfb.ncrc[i].
      end.
      hisdfb.ncrc[1] = dfb.crc.
  end.
  else if
    hisdfb.dam[1] ne dfb.dam[1] or hisdfb.cam[1] ne dfb.cam[1] or
    hisdfb.dam[2] ne dfb.dam[2] or hisdfb.cam[2] ne dfb.cam[2] or
    hisdfb.dam[3] ne dfb.dam[3] or hisdfb.cam[3] ne dfb.cam[3] or
    hisdfb.dam[4] ne dfb.dam[4] or hisdfb.cam[4] ne dfb.cam[4] or
    hisdfb.dam[5] ne dfb.dam[5] or hisdfb.cam[5] ne dfb.cam[5]
    then do:
      create hisdfb.
      assign hisdfb.dfb  = dfb.dfb
             hisdfb.fdt  = g-today.
      do i = 1 to 5:
         assign hisdfb.dam[i]  = dfb.dam[i]
                hisdfb.cam[i]  = dfb.cam[i]
                hisdfb.ncrc[i] = dfb.ncrc[i].
      end.
      hisdfb.ncrc[1] = dfb.crc.
  end.
end.

/* History for OCK subledger - file HISOCK */
for each ock no-lock:
  find last hisock where hisock.ock eq ock.ock no-lock no-error.
  if not available hisock
  then do:
      create hisock.
      assign hisock.ock  = ock.ock
             hisock.fdt  = g-today.
      do i = 1 to 5:
         assign hisock.dam[i]  = ock.dam[i]
                hisock.cam[i]  = ock.cam[i]
                hisock.ncrc[i] = ock.ncrc[i].
      end.
      hisock.ncrc[1] = ock.crc.
  end.
  else if
    hisock.dam[1] ne ock.dam[1] or hisock.cam[1] ne ock.cam[1] or
    hisock.dam[2] ne ock.dam[2] or hisock.cam[2] ne ock.cam[2] or
    hisock.dam[3] ne ock.dam[3] or hisock.cam[3] ne ock.cam[3] or
    hisock.dam[4] ne ock.dam[4] or hisock.cam[4] ne ock.cam[4] or
    hisock.dam[5] ne ock.dam[5] or hisock.cam[5] ne ock.cam[5]
    then do:
      create hisock.
      assign hisock.ock  = ock.ock
             hisock.fdt  = g-today.
      do i = 1 to 5:
         assign hisock.dam[i]  = ock.dam[i]
                hisock.cam[i]  = ock.cam[i]
                hisock.ncrc[i] = ock.ncrc[i].
      end.
      hisock.ncrc[1] = ock.crc.
  end.
end.

/* History for AST subledger - file HISAST */
for each ast no-lock:
  find last hisast where hisast.ast eq ast.ast no-lock no-error.
  if not available hisast
  then do:
      create hisast.
      assign hisast.ast  = ast.ast
             hisast.fdt  = g-today
             hisast.ncrc[1] = ast.crc.
      do i = 1 to 5:
         assign hisast.dam[i]  = ast.dam[i]
                hisast.cam[i]  = ast.cam[i].
      end.
  end.
  else if
    hisast.dam[1] ne ast.dam[1] or hisast.cam[1] ne ast.cam[1] or
    hisast.dam[2] ne ast.dam[2] or hisast.cam[2] ne ast.cam[2] or
    hisast.dam[3] ne ast.dam[3] or hisast.cam[3] ne ast.cam[3] or
    hisast.dam[4] ne ast.dam[4] or hisast.cam[4] ne ast.cam[4] or
    hisast.dam[5] ne ast.dam[5] or hisast.cam[5] ne ast.cam[5]
    then do:
      create hisast.
      assign hisast.ast  = ast.ast
             hisast.fdt  = g-today
             hisast.ncrc[1] = ast.crc.
      do i = 1 to 5:
         assign hisast.dam[i]  = ast.dam[i]
                hisast.cam[i]  = ast.cam[i].
      end.
  end.
end.

/* History for LON subledger - file HISLON */
define var m as inte.
define var v-dam as deci extent 5.
define var v-cam as deci extent 5.

for each lon no-lock:
  find last hislon where hislon.lon eq lon.lon no-error.
  if not available hislon
  then do:
      create hislon.
      assign hislon.lon  = lon.lon
             hislon.fdt  = g-today
             hislon.ncrc[1]  = lon.crc
             hislon.ncrc[3]  = integer(lon.prnyrs).
      do i = 1 to 5:
         assign hislon.dam[i]  = lon.dam[i]
                hislon.cam[i]  = lon.cam[i].
         assign hislon.tdam[i]  = 0
                hislon.tcam[i]  = 0.
      end.
  end.
  else if
    hislon.dam[1] ne lon.dam[1] or hislon.cam[1] ne lon.cam[1] or
    /*
    hislon.dam[2] ne lon.dam[2] or */ hislon.cam[2] ne lon.cam[2] or

    hislon.dam[3] ne lon.dam[3] or hislon.cam[3] ne lon.cam[3] or
    hislon.dam[4] ne lon.dam[4] or hislon.cam[4] ne lon.cam[4] or
    hislon.dam[5] ne lon.dam[5] or hislon.cam[5] ne lon.cam[5]
    then do:
      create hislon.
      assign hislon.lon  = lon.lon
             hislon.fdt  = g-today
             hislon.ncrc[1]  = lon.crc
             hislon.ncrc[3]  = integer(lon.prnyrs).
      do i = 1 to 5:
         assign hislon.dam[i]  = lon.dam[i]
                hislon.cam[i]  = lon.cam[i].
         assign hislon.tdam[i]  = 0
                hislon.tcam[i]  = 0.
      end.
    end.

/* 07.01.04 marinav - переделала запись в историю*/

    v-fl = no.
    do i = 1 to 5:
       assign v-dam[i]  = 0
              v-cam[i]  = 0.
    end.

    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon
          and trxbal.level = 7 no-lock no-error.
    if avail trxbal and (hislon.tdam[1] ne trxbal.dam or hislon.tcam[1] ne trxbal.cam) then v-fl = yes.
    if avail trxbal then assign v-dam[1] = trxbal.dam
                                v-cam[1] = trxbal.cam .

    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon
          and trxbal.level = 9 no-lock no-error.
    if avail trxbal and (hislon.tdam[2] ne trxbal.dam or hislon.tcam[2] ne trxbal.cam) then v-fl = yes.
    if avail trxbal then assign v-dam[2] = trxbal.dam
                                v-cam[2] = trxbal.cam .

    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon
          and trxbal.level = 16 no-lock no-error.
    if avail trxbal and (hislon.tdam[3] ne trxbal.dam or hislon.tcam[3] ne trxbal.cam) then v-fl = yes.
    if avail trxbal then assign v-dam[3] = trxbal.dam
                                v-cam[3] = trxbal.cam .

   /*03/02/04 nataly индексация*/
    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon
          and trxbal.level = 20 no-lock no-error.
    if avail trxbal and (hislon.tdam[4] ne trxbal.dam or hislon.tcam[4] ne trxbal.cam) then v-fl = yes.
    if avail trxbal then assign v-dam[4] = trxbal.dam
                                v-cam[4] = trxbal.cam .

    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon
          and trxbal.level = 21 no-lock no-error.
    if avail trxbal and (hislon.tdam[5] ne trxbal.dam or hislon.tcam[5] ne trxbal.cam) then v-fl = yes.
    if avail trxbal then assign v-dam[5] = trxbal.dam
                                v-cam[5] = trxbal.cam .

    if v-fl = yes then do:

    find last hislon where hislon.lon eq lon.lon and hislon.fdt = g-today no-error.
    if not avail hislon then do:
      create hislon.
      assign hislon.lon  = lon.lon
             hislon.fdt  = g-today
             hislon.ncrc[1]  = lon.crc
             hislon.ncrc[3]  = integer(lon.prnyrs).
      do i = 1 to 5:
         assign hislon.dam[i]  = lon.dam[i]
                hislon.cam[i]  = lon.cam[i].
         assign hislon.tdam[i]  = v-dam[i]
                hislon.tcam[i]  = v-cam[i].
      end.
    end.
    else do:
      do i = 1 to 5:
         assign hislon.tdam[i]  = v-dam[i]
                hislon.tcam[i]  = v-cam[i].
      end.
    end.
    end.

end.
