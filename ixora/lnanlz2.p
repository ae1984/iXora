/* lnanlz2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Подготовка временной таблицы для анализа кредитного портфеля
 * RUN

 * CALLER
       lnanlz1
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-5-10
 * AUTHOR
        01.03.2003 marinav
 * CHANGES
        21.08.2003 marinav - во временную таблицу добавлены поля :
                             схема начисления, будущие проценты
        08.12.2003 nataly  - заменен счет ГК 1439 -> 1428  в связи с переходом на новый ПС
        02.04.2004 nadejda - добавлен вывод суммы выданных гарантий и провизий по ним,
                             оптимизированы некоторые циклы
        08.04.2004 nadejda - Кузьмичев сказал провизии по гарантиям брать по счету 2874
        07/06/2004 madiyar - с мая 2004 провизии по гарантиям падают на счет 2875 (спец провизии)
        05/07/2004 madiyar - сумма портфеля не бьется с балансом - учтем уровни индексации (новая р-шка lon_txb2)
        01/10/2004 madiyar - отчет формируется НА дату, изменен выбор дат для таблицы в динамике
        07/10/2004 madiyar - расчет ОД по histrxbal (lonbal_txb)
        14/10/2004 madiyar - в связи с изменением lnanlz.p - список дат в массиве dates
                             изменил расчет провизий - теперь фактические
                             статус юр/физ - определяется по сектору экономики
        07/01/2005 madiyar - изменил определение "краткоср/долгоср"
        01/02/2005 madiyar - убрал индексированные уровни из ОД
                             Активы банка - убрал вычет счетов 135100,..
        04/08/2005 madiyar - юр/физ - отдельно; добавил поле wrk.balans_prosr - просрочка ОД
        11/08/2005 madiyar - добавил поле wrk.dolgosr, изменения в расчете средневзвешанной ставки
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        31/01/2006 madiyar - при расчете активов вычитаем остаток по счету 135000
        01/06/2006 madiyar - добавилось поле segm; no-undo
        11/08/2006 madiyar - выданные за период
        05/09/2008 madiyar - явно указал индекс lonhar-idx1 при поиске последней записи lonhar
        11/11/2009 madiyar - актуализировал
        13/11/2009 madiyar - выделил метрокредит, оптимизировал
        11/01/2010 galina - ставку по кредиту берем не нулевую
*/

def input parameter d1 as date no-undo.
def input parameter v-urfiz as integer no-undo.
def shared var g-ofc as char.
def shared var g-today as date.
def shared var suma as decimal no-undo.
def shared var dates as date no-undo extent 6.
def var rat as decimal no-undo.
def var long as int no-undo init 0.
def new shared var bilance as decimal no-undo format "->,>>>,>>>,>>9.99".
def var dlong as date no-undo.
def var srok as deci no-undo.
def var v-sum as decimal no-undo format "->,>>>,>>>,>>9.99".
def var v-sumt as decimal no-undo format "->,>>>,>>>,>>9.99".
def var v-grp as inte no-undo.
def var i as inte no-undo.
def var j as inte no-undo.
def var dat as date no-undo.
def var sumprov as decimal no-undo.

def var lst_grp as char no-undo init ''.
case v-urfiz:
    when 1 then do:
        for each txb.longrp no-lock:
            if substr(string(txb.longrp.stn),1,1) = '1' and txb.longrp.longrp <> 90 and txb.longrp.longrp <> 92 then do:
                if lst_grp <> '' then lst_grp = lst_grp + ','.
                lst_grp = lst_grp + string(txb.longrp.longrp).
            end.
        end.
    end.
    when 2 then do:
      for each txb.longrp no-lock:
          if substr(string(txb.longrp.stn),1,1) = '2' then do:
              if lst_grp <> '' then lst_grp = lst_grp + ','.
              lst_grp = lst_grp + string(txb.longrp.longrp).
          end.
      end.
    end.
    when 3 then lst_grp = "90,92".
    when 4 then do:
        for each txb.longrp no-lock:
            if lst_grp <> '' then lst_grp = lst_grp + ','.
            lst_grp = lst_grp + string(txb.longrp.longrp).
        end.
    end.
end case.

if v-urfiz = 3 then lst_grp = "90,92".
else
if v-urfiz = 1 then do:

end.
else
if v-urfiz = 2 then do:

end.

def shared var krport as deci no-undo extent 6.

def var mesa as int no-undo init 0.

def shared temp-table wrk no-undo
    field datot  like txb.lon.rdt
    field cif    like txb.lon.cif
    field isGL   as logi
    field lon    like txb.lon.lon
    field segm   as char
    field name   like txb.cif.name
    field plan   like txb.lon.plan
    field sts    as char
    field grp    like txb.lon.grp
    field amoun  like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field balans1 like txb.lon.opnamt
    field balans2 like txb.lon.opnamt
    field balans_prosr like txb.lon.opnamt
    field crc    like txb.crc.crc
    field prem   like txb.lon.prem
    field proc   like txb.lon.opnamt
    field duedt  like txb.lon.rdt
    field rez    like txb.lonstat.prc
    field srez   like txb.lon.opnamt
    field zalog  like txb.lon.opnamt
    field srok   as deci
    field dolgosr as logi
    index main is primary datot cif
    index datot datot
    index cif cif
    index segm segm.


def shared temp-table wrkvyd no-undo
    field datot like txb.lon.rdt
    field segm as char
    field name as char
    field sum as deci
    field kol as integer
    index main is primary segm datot.


mesa = 0.
find first txb.cmp no-lock no-error.
do i = 1 to 6:

  dat = dates[i].
  sumprov = 0.

  do j = 1 to num-entries(lst_grp):
      for each txb.lon where txb.lon.grp = integer(entry(j,lst_grp)) no-lock.

        /*
        if v-urfiz = 1 then do:
            if (lookup(string(txb.lon.grp),lst_ur) > 0) or (txb.lon.grp = 90) or (txb.lon.grp = 92) then next.
        end.
        else
        if v-urfiz = 2 then do:
            if lookup(string(txb.lon.grp),lst_ur) = 0 then next.
        end.
        else
        if v-urfiz = 3 then do:
            if txb.lon.grp <> 90 and txb.lon.grp <> 92 then next.
        end.
        */

        run lonbalcrc_txb('lon', txb.lon.lon, dat, "1,7", no, txb.lon.crc, output bilance).

        if bilance <= 0 then next.

         mesa = mesa + 1.
         if (mesa / 200) - integer (mesa / 200) = 0 then do:
            hide message no-pause.
            message " " + txb.cmp.name + ': обработано ' + string(mesa) + ' кредитов '.
         end.

         find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.

         dlong = txb.lon.duedt.
         if txb.lon.ddt[5] <> ? and txb.lon.ddt[5] < dat then dlong = txb.lon.ddt[5].
         if txb.lon.cdt[5] <> ? and txb.lon.cdt[5] < dat then dlong = txb.lon.cdt[5].

      /**/
         find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < dat no-lock no-error.
         krport[i] = krport[i] + bilance * txb.crc.rate[1].

         create wrk.
         assign wrk.datot = dat
                wrk.cif   = txb.lon.cif
                wrk.lon   = txb.lon.lon
                wrk.name  = txb.cif.name
                wrk.plan  = txb.lon.plan
                wrk.grp   = txb.lon.grp
                wrk.amoun = txb.lon.opnamt
                wrk.balans = bilance
                wrk.crc = txb.lon.crc
                wrk.duedt = dlong
                wrk.zalog = v-sum
                wrk.rez = 0
                wrk.srez = 0.

          find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
          if avail txb.sub-cod then wrk.segm = txb.sub-cod.ccode.
          else message " Не задан сегмент кредита! " view-as alert-box error.

          if i < 6 then do:
            find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
            if avail txb.lnscg and txb.lnscg.stdat >= dates[i + 1] then do:
              find first wrkvyd where wrkvyd.datot = dates[i] and wrkvyd.segm = wrk.segm no-lock no-error.
              if not avail wrkvyd then do:
                create wrkvyd.
                wrkvyd.datot = dates[i].
                wrkvyd.segm = wrk.segm.
                find first txb.codfr where txb.codfr.codfr = "lnsegm" and txb.codfr.code = wrk.segm no-lock no-error.
                if avail txb.codfr then wrkvyd.name = txb.codfr.name[1].
              end.
              wrkvyd.kol = wrkvyd.kol + 1.
              for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 and txb.lnscg.stdat >= dates[i + 1] and txb.lnscg.stdat < dates[i] no-lock:
                find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnscg.stdat no-lock no-error.
                wrkvyd.sum = wrkvyd.sum + txb.lnscg.paid * txb.crchis.rate[1].
              end.
            end.
          end.

          run lonbalcrc_txb('lon',txb.lon.lon,dat,"7",no,txb.lon.crc,output wrk.balans_prosr).

          if substring(string(txb.lon.gl),1,4) = "1411" then wrk.dolgosr = no.
          else wrk.dolgosr = yes.
          wrk.srok = txb.lon.duedt - txb.lon.rdt.

          find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
          if txb.sub-cod.ccode = '9' then wrk.sts = '1'.
          else wrk.sts = '0'.
          
          if txb.lon.prem > 0 then wrk.prem = txb.lon.prem.
          else do:
             if txb.lon.prem1 > 0 then wrk.prem = txb.lon.prem1.
             else do: 
               find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < dat and txb.ln%his.intrate > 0 no-lock no-error.
               if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
             end.  
          end.         

         find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < dat use-index lonhar-idx1 no-lock no-error.
         if avail txb.lonhar then do:
         find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            wrk.rez = txb.lonstat.prc.
            run lonbalcrc_txb('lon',txb.lon.lon,dat,"6",no,txb.lon.crc,output wrk.srez).
            wrk.srez = round(wrk.srez * txb.crchis.rate[1],2).
            sumprov = sumprov + wrk.srez.
            wrk.srez = - wrk.srez.
         end.

      end. /* for each txb.lon */
  end.
  create wrk.
  assign wrk.datot = dat
         wrk.cif = "1428"
         wrk.amoun = sumprov
         wrk.isGL = yes.

  suma = 0.
  for each txb.crc no-lock.
      find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < dat no-lock no-error.
      find last txb.glday where txb.glday.gl = 199995 and txb.glday.crc = txb.crc.crc and txb.glday.gdt < dat no-lock no-error.
      if avail txb.glday then suma = suma + txb.glday.bal * txb.crchis.rate[1].

      find last txb.glday where txb.glday.gl = 135000 and txb.glday.crc = txb.crc.crc and txb.glday.gdt < dat no-lock no-error.
      if avail txb.glday then suma = suma - txb.glday.bal * txb.crchis.rate[1].
  end.

  create wrk.
  assign wrk.datot = dat
         wrk.cif = "199995"
         wrk.amoun = suma
         wrk.isGL = yes.

  /* 02.04.2004 nadejda выданные гарантии */
  suma = 0.
  for each txb.crc no-lock.
      find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < dat no-lock no-error.
      find last txb.glday where txb.glday.gl = 655500 and txb.glday.crc = txb.crc.crc and txb.glday.gdt < dat no-lock no-error.
      if avail txb.glday then suma = suma + txb.glday.bal * txb.crchis.rate[1].
  end.

  create wrk.
  assign wrk.datot = dat
         wrk.cif = "655500"
         wrk.amoun = suma
         wrk.isGL = yes.

  /* 02.04.2004 nadejda провизии по выданным гарантиям */
  suma = 0.
  for each txb.crc no-lock.
      find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < dat no-lock no-error.
      find last txb.glday where txb.glday.gl = 287400 and txb.glday.crc = txb.crc.crc and txb.glday.gdt < dat no-lock no-error.
      if avail txb.glday then suma = suma + txb.glday.bal * txb.crchis.rate[1].
  end.

  create wrk.
  assign wrk.datot = dat
         wrk.cif = "287400"
         wrk.amoun = suma
         wrk.isGL = yes.

  suma = 0.
  for each txb.crc no-lock.
      find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < dat no-lock no-error.
      find last txb.glday where txb.glday.gl = 287500 and txb.glday.crc = txb.crc.crc and txb.glday.gdt < dat no-lock no-error.
      if avail txb.glday then suma = suma + txb.glday.bal * txb.crchis.rate[1].
  end.

  create wrk.
  assign wrk.datot = dat
         wrk.cif = "287500"
         wrk.amoun = suma
         wrk.isGL = yes.


end. /* do i = 1 to 6 */
