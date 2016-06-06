/* pkzdfil.p
 * MODULE
        Быстрые Деньги
 * DESCRIPTION
        Задолжники по БД - по результатам работы проблемников
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
        05/09/2005 madiyar
 * CHANGES
        02/12/2005 madiyar - выводятся все платежи по просрочкам, не только последний
        07/12/2005 madiyar - по тем кто не платил - выводится запись с ? в дате оплаты
        24/02/2006 madiyar - добавил три колонки
        02/03/2006 madiyar - исправил вызов программы lndayspr
        24/05/2006 madiyar - добавил статус, списанные суммы
        12/05/2009 madiyar - внебалансовые уровни, валюта кредита
        03/08/2009 madiyar - добавил день погашения
        11/08/2009 madiyar - отчет разъехался, подправил
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define temp-table wrk no-undo
  field cif like cif.cif
  field clname as char
  field lon like lon.lon
  field crc like crc.crc
  field grp like lon.grp
  field vid as char
  field rdt as date
  field duedt as date
  field pday as integer
  field prosr_od as deci
  field prosr_prc as deci
  field pen as deci
  field comd as deci
  field dt_pay as date
  field dayc as integer
  field sum_pay as deci
  field od_end as deci
  field sts as char
  field odz as deci
  field prcz as deci
  field penz as deci
  index idx is primary cif lon dt_pay.


def var v-bal as deci no-undo extent 3.
def var v-balz as deci no-undo extent 3.
def var usrnm as char no-undo.
def var dat_wrk as date no-undo.
def var tempdt as date no-undo.
def var tempost as deci no-undo.
def var dayc1 as integer no-undo.
def var dayc2 as integer no-undo.
def var v-ch as logical no-undo.
def var v-itog as deci no-undo.

def var coun as integer no-undo.

def var dt1 as date no-undo.
def var dt2 as date no-undo.
dt2 = date(month(g-today),1,year(g-today)) - 1.
dt1 = date(month(dt2),1,year(dt2)).

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.
hide frame dat.

message " Формируется отчет... ".

coun = 0.
for each lon where (lon.grp = 90 or lon.grp = 92) /*and lon.cif = "C10765"*/ no-lock:

  if lon.opnamt <= 0 then next.

  v-ch = no.

  run lonbalcrc('lon',lon.lon,dt2,'13',yes,lon.crc,output v-balz[1]).
  run lonbalcrc('lon',lon.lon,dt2,'14',yes,lon.crc,output v-balz[2]).
  run lonbalcrc('lon',lon.lon,dt2,'30',yes,1,output v-balz[3]).

  if v-balz[1] + v-balz[2] + v-balz[3] > 0 then v-ch = yes.
  else do:

    run lonbalcrc('lon',lon.lon,dt2,'7',yes,lon.crc,output v-bal[1]).
    run lonbalcrc('lon',lon.lon,dt2,'9,4',yes,lon.crc,output v-bal[2]).
    run lonbalcrc('lon',lon.lon,dt2,'16,5',yes,1,output v-bal[3]).
    if v-bal[1] + v-bal[2] + v-bal[3] > 0 then v-ch = yes.
    else do:
      run lonbalcrc('lon',lon.lon,dt1,'7',no,lon.crc,output v-bal[1]).
      run lonbalcrc('lon',lon.lon,dt1,'9,4',no,lon.crc,output v-bal[2]).
      run lonbalcrc('lon',lon.lon,dt1,'16,5',no,1,output v-bal[3]).
      if v-bal[1] + v-bal[2] + v-bal[3] > 0 then v-ch = yes.
      else do:
        find first lonres where lonres.lon = lon.lon and lonres.jdt >= dt1 and lonres.jdt <= dt2 and (lonres.lev = 7 or lonres.lev = 9 or lonres.lev = 16 or lonres.lev = 4 or lonres.lev = 5) and lonres.dc = 'd' use-index jdt no-lock no-error.
        if avail lonres then v-ch = yes.
      end.
    end.

  end.


  if not v-ch then next.

  find first cif where cif.cif = lon.cif no-lock no-error.

  for each jl where jl.acc = lon.aaa and jl.dc = 'C' and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.lev = 1 use-index accdcjdt no-lock:

     run lonbalcrc('lon',lon.lon,jl.jdt,'7',no,lon.crc,output v-bal[1]).
     run lonbalcrc('lon',lon.lon,jl.jdt,'9,4',no,lon.crc,output v-bal[2]).
     run lonbalcrc('lon',lon.lon,jl.jdt,'16,5',no,1,output v-bal[3]).

     if v-bal[1] + v-bal[2] + v-bal[3] + v-balz[1] + v-balz[2] + v-balz[3] > 0 then do:

        create wrk.
        assign wrk.cif = lon.cif
               wrk.lon = lon.lon
               wrk.crc = lon.crc
               wrk.grp = lon.grp
               wrk.vid = "БД"
               wrk.rdt = lon.rdt
               wrk.duedt = lon.duedt
               wrk.prosr_od = v-bal[1]
               wrk.prosr_prc = v-bal[2]
               wrk.pen = v-bal[3]
               wrk.pday = lon.day.
        if avail cif then wrk.clname = trim(cif.name).

        for each bxcif where bxcif.cif = lon.cif no-lock:
          wrk.comd = wrk.comd + bxcif.amount.
        end.

        run lonbalcrc('lon',lon.lon,jl.jdt,'1,7',yes,lon.crc,output wrk.od_end).

        wrk.dt_pay = jl.jdt.
        wrk.sum_pay = jl.cam.

        find last cls where cls.whn < wrk.dt_pay and cls.del no-lock no-error.
        dat_wrk = cls.whn.

        dayc1 = 0. dayc2 = 0.
        if wrk.prosr_prc > 0 or wrk.prosr_od > 0 then do:
          run lndayspr(lon.lon,wrk.dt_pay,no,output dayc1,output dayc2).
        end.

        if dayc1 > dayc2 then wrk.dayc = dayc1. else wrk.dayc = dayc2.

        wrk.odz = v-balz[1].
        wrk.prcz = v-balz[2].
        wrk.penz = v-balz[3].

     end. /* if v-bal[1] + v-bal[2] + v-bal[3] > 0 */

  end. /* for each jl */

  find first wrk where wrk.cif = lon.cif no-lock no-error.
  if not avail wrk then do:
     create wrk.
     assign wrk.cif = lon.cif
            wrk.lon = lon.lon
            wrk.crc = lon.crc
            wrk.vid = "БД"
            wrk.rdt = lon.rdt
            wrk.duedt = lon.duedt
            wrk.prosr_od = v-bal[1]
            wrk.prosr_prc = v-bal[2]
            wrk.pen = v-bal[3].
     if avail cif then wrk.clname = trim(cif.name).

     for each bxcif where bxcif.cif = lon.cif no-lock:
       wrk.comd = wrk.comd + bxcif.amount.
     end.
     run lonbalcrc('lon',lon.lon,dt2,'1,7',yes,lon.crc,output wrk.od_end).
     wrk.dt_pay = ?.
     wrk.sum_pay = 0.
     find last cls where cls.whn < dt2 and cls.del no-lock no-error.
     dat_wrk = cls.whn.
     dayc1 = 0. dayc2 = 0.
     if wrk.prosr_prc > 0 or wrk.prosr_od > 0 then do:
        run lndayspr(lon.lon,dt2,yes,output dayc1,output dayc2).
     end.
     if dayc1 > dayc2 then wrk.dayc = dayc1. else wrk.dayc = dayc2.
     wrk.odz = v-balz[1].
     wrk.prcz = v-balz[2].
     wrk.penz = v-balz[3].
  end. /* if not avail wrk */

  if wrk.odz + wrk.prcz + wrk.penz > 0 then wrk.sts = 'Z'.
  else do:
    /* находим последнюю дату по графику */
    find last lnsch where lnsch.stdat < dt2 and lnsch.lnn = wrk.lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
    if avail lnsch then do:
       /*t-report.lgrfdt = lnsch.stdat.*/
       find first pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = wrk.lon and pkdebtdat.rdt >= (dt2 - wrk.dayc) and pkdebtdat.rdt <= dt2 use-index lonrdt no-lock no-error.
       if avail pkdebtdat then do:
            wrk.sts = "K".
            find last pkdebtdat where pkdebtdat.bank = s-ourbank
                                      and pkdebtdat.lon = wrk.lon
                                      and pkdebtdat.rdt >= (dt2 - wrk.dayc)
                                      and pkdebtdat.rdt <= dt2
                                      and (pkdebtdat.result = "part" or pkdebtdat.result = "secu" or pkdebtdat.result = "leg") use-index lonrdt no-lock no-error.
             if avail pkdebtdat then do:
                    if pkdebtdat.result = "part" then wrk.sts = "K,P".
                    else if pkdebtdat.result = "secu" then wrk.sts = "K,S".
                    else if pkdebtdat.result = "leg" then wrk.sts = "K,L".
             end.
       end.
       else wrk.sts = "N".
    end.
  end.

  coun = coun + 1.
  hide message no-pause.
  message coun.

end. /* for each lon */


def stream rep.
output stream rep to pkzdfil.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Погашение задолженности по результатам работы отдела по работе с проблемными кредитами с " dt1 format "99/99/9999" " по " dt2 format "99/99/9999" "</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>пп</td>" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td>Наименование заемщика</td>" skip
    "<td>Сс счет</td>" skip
    "<td>Группа</td>" skip
    "<td>Вид<br>кредита</td>" skip
    "<td>Валюта</td>" skip
    "<td>Дата<BR>выдачи</td>" skip
    "<td>Дата<BR>окончания</td>" skip
    "<td>День<BR>погашения</td>" skip
    "<td>Статус</td>" skip
    "<td>Задолженность по ОД<BR>на дату оплаты</td>" skip
    "<td>Задолженность по %<BR>на дату оплаты</td>" skip
    "<td>Пеня на дату оплаты</td>" skip
    "<td>Сумма просрочки<br>на дату оплаты</td>" skip
    "<td>Долг по комиссиям<br>(текущий)</td>" skip
    "<td>Дата<BR>оплаты</td>" skip
    "<td>Кол-во дней просрочки<BR>на дату оплаты</td>" skip
    "<td>ОД (спис)</td>" skip
    "<td>%% (спис)</td>" skip
    "<td>Штрафы (спис)</td>" skip
    "<td>Сумма<BR>погашения</td>" skip
    "<td>Остаток займа<BR>за дату оплаты</td>" skip
    "</tr>" skip.

v-itog = 0. coun = 0.
for each wrk no-lock break by wrk.cif by wrk.lon by wrk.dt_pay:

  if first-of(wrk.lon) then do:
    find first crc where crc.crc = wrk.crc no-lock no-error.
    coun = coun + 1.
    put stream rep unformatted
      "<tr>" skip
      "<td>" coun "</td>" skip
      "<td>" wrk.cif "</td>" skip
      "<td>" wrk.clname "</td>" skip
      "<td>&nbsp;" wrk.lon "</td>" skip
      "<td>" wrk.grp "</td>" skip
      "<td>" wrk.vid "</td>" skip
      "<td>" crc.code "</td>" skip
      "<td>" wrk.rdt "</td>" skip
      "<td>" wrk.duedt "</td>" skip
      "<td>" wrk.pday "</td>" skip
      "<td>" wrk.sts "</td>" skip.
  end.
  else do:
    put stream rep unformatted
      "<tr>" skip
      "<td></td>" skip
      "<td>" wrk.cif "</td>" skip
      "<td>" wrk.clname "</td>" skip
      "<td>&nbsp;" wrk.lon "</td>" skip
      " <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip.
  end.

  put stream rep unformatted
    "<td>" replace(trim(string(wrk.prosr_od, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prosr_prc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.pen, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prosr_od + wrk.prosr_prc + wrk.pen, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.comd, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" wrk.dt_pay "</td>" skip
    "<td>" wrk.dayc "</td>" skip
    "<td>" replace(trim(string(wrk.odz, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prcz, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.penz, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pay, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.od_end, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.

  v-itog = v-itog + wrk.sum_pay.

end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
    "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
    "<td>" replace(string(v-itog, ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td></td>" skip
    "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin pkzdfil.htm excel.

