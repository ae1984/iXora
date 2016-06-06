/* pksbvyd.p
 * MODULE
        Быстрые Деньги
 * DESCRIPTION
        Отчет по выданным в субботу кредитам
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
        24/08/2005 madiar
 * BASES
        bank, comm
 * CHANGES
        25/08/2005 madiar - изменил поиск СПФ
        27/08/2005 madiar - в отчет попадали кредиты, выданные в пятницу
*/

{global.i}
def var s-ourbank as char init "".
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
end.
else s-ourbank = trim(sysc.chval).

def temp-table wrk
   field depart as int
   field departn as char
   field issued as int
   field issued_sum as deci
   field rejected as int
   field other as int
   index idx is primary depart.


def var dat as date.
def var usrnm as char.
def var itog as integer extent 3.
def var itog_sum as deci.
def var v-dep as integer.
def var v-in as logical.

dat = g-today - weekday(g-today). /* находим дату последней субботы */

update dat label ' Укажите дату ' format '99/99/9999' validate(weekday(dat) = 7,"Не суббота!") skip
  with side-label row 5 centered frame dat.

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and (pkanketa.rdt = dat or pkanketa.docdt = dat - 1) no-lock:
    
    if pkanketa.rwho = "i-net" then next.
    
    /* отсев анкет, выданных фактически dat -1 (в пятницу) */
    if pkanketa.rdt <> dat then do:
      v-in = no.
      if pkanketa.lon <> '' then do:
        find first lnscg where lnscg.lng = pkanketa.lon and lnscg.flp > 0 no-lock no-error.
        if avail lnscg then do:
          find first jh where jh.jh = lnscg.jh no-lock no-error.
          if avail jh and jh.whn = dat then v-in = yes.
        end.
      end.
    end.
    if not v-in then next.
    
    find last ofchis where ofchis.ofc = pkanketa.rwho and ofchis.regdt <= dat use-index ofchis no-lock no-error.
    if avail ofchis then v-dep = ofchis.depart. else v-dep = 1. /* ЦО */
    
    find first wrk where wrk.depart = v-dep no-lock no-error.
    if not avail wrk then do:
      create wrk.
      wrk.depart = v-dep.
      find first ppoint where ppoint.depart = v-dep no-lock no-error.
      if avail ppoint then wrk.departn = ppoint.name.
    end.
    
    if pkanketa.lon <> '' then do:
       wrk.issued = wrk.issued + 1.
       wrk.issued_sum = wrk.issued_sum + pkanketa.summa.
    end.
    else do:
      if pkanketa.sts = '00' then wrk.rejected = wrk.rejected + 1.
      else wrk.other = wrk.other + 1.
    end.
    
end. /* for each pkanketa */


def stream rep.
output stream rep to pksbvyd.htm.

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
    "<center><b>Анализ заявок клиентов по программе ""Быстрые деньги""<BR>за " dat format "99/99/9999" "</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>СПФ</td>" skip
    "<td>Выдано</td>" skip
    "<td>Выдано - сумма</td>" skip
    "<td>Отказано</td>" skip
    "<td>Другие</td>" skip
    "</tr>" skip.

itog = 0. itog_sum = 0.
for each wrk no-lock:
  
  put stream rep unformatted
      "<tr>" skip
      "<td>" wrk.departn "</td>" skip
      "<td>" wrk.issued "</td>" skip
      "<td>" replace(trim(string(wrk.issued_sum, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" wrk.rejected "</td>" skip
      "<td>" wrk.other "</td>" skip
      "</tr>" skip.
  
  itog[1] = itog[1] + wrk.issued.
  itog[2] = itog[2] + wrk.rejected.
  itog[3] = itog[3] + wrk.other.
  itog_sum = itog_sum + wrk.issued_sum.
  
end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td>ИТОГО</td>" skip
    "<td>" itog[1] "</td>" skip
    "<td>" replace(trim(string(itog_sum, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" itog[2] "</td>" skip
    "<td>" itog[3] "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin pksbvyd.htm excel.

