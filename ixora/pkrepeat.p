/* pkrepeat.p
 * MODULE
        Быстрые Деньги
 * DESCRIPTION
        Отчет по повторным кредитам
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
        25/08/2005 madiar
 * BASES
        bank, comm
 * CHANGES
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
   field accepted as int
   field issued as int
   field issued_sum as deci
   field rejected as int
   field other as int
   index idx is primary depart.

def temp-table wrkr
   field cause as char
   field cause_des as char
   field num as int
   index idx is primary cause.

def var dat1 as date.
def var dat2 as date.
def var usrnm as char.
def var itog as integer extent 4.
def var itog_sum as deci.
def var v-dep as integer.
def var v-ref as char.
def var i as integer.

dat1 = g-today.
dat2 = g-today.

update dat1 label ' Укажите дату с ' format '99/99/9999' dat2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.

for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = '6' and pkanketa.rdt >= dat1 and pkanketa.rdt <= dat2 no-lock:
    
    if pkanketa.rwho = "i-net" then next.
    
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "numpas" no-lock no-error.
    if not avail pkanketh or trim(pkanketh.rescha[3]) = '' then next.
    
    find last ofchis where ofchis.ofc = pkanketa.rwho and ofchis.regdt <= pkanketa.rdt use-index ofchis no-lock no-error.
    if avail ofchis then v-dep = ofchis.depart. else v-dep = 1. /* ЦО */
    
    find first wrk where wrk.depart = v-dep no-lock no-error.
    if not avail wrk then do:
      create wrk.
      wrk.depart = v-dep.
      find first ppoint where ppoint.depart = v-dep no-lock no-error.
      if avail ppoint then wrk.departn = ppoint.name.
    end.
    
    wrk.accepted = wrk.accepted + 1.
    if pkanketa.lon <> '' then do:
       wrk.issued = wrk.issued + 1.
       wrk.issued_sum = wrk.issued_sum + pkanketa.summa.
    end.
    else do:
      if pkanketa.sts = '00' then do:
        wrk.rejected = wrk.rejected + 1.
        v-ref = ''.
        do i = 1 to num-entries(pkanketa.refusal):
          if trim(entry(i,pkanketa.refusal)) <> '' then do:
            if v-ref <> '' then v-ref = v-ref + ','.
            v-ref = v-ref + trim(entry(i,pkanketa.refusal)).
          end.
        end.
        find first wrkr where wrkr.cause = v-ref no-error.
        if not avail wrkr then do:
          create wrkr.
          wrkr.cause = v-ref.
          wrkr.cause_des = v-ref + ' '.
          do i = 1 to num-entries(v-ref):
            if i > 1 then wrkr.cause_des = wrkr.cause_des + ','.
            find first bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(i,v-ref) no-lock no-error.
            if avail bookcod then wrkr.cause_des = wrkr.cause_des + trim(bookcod.name).
            else wrkr.cause_des = wrkr.cause_des + '-'.
          end.
        end.
        wrkr.num = wrkr.num + 1.
      end. /* if pkanketa.sts = '00' */
      else wrk.other = wrk.other + 1.
    end.
    
end. /* for each pkanketa */


def stream rep.
output stream rep to pksbvyd.htm.

find first cmp no-lock no-error.

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
    "<center><b>Отчет по повторным анкетам по программе ""Быстрые деньги""<BR>за период с " dat1 format "99/99/9999" " по " dat2 format "99/99/9999" "<br>" cmp.name "</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>СПФ</td>" skip
    "<td>Рассмотрено</td>" skip
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
      "<td>" wrk.accepted "</td>" skip
      "<td>" wrk.issued "</td>" skip
      "<td>" replace(trim(string(wrk.issued_sum, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" wrk.rejected "</td>" skip
      "<td>" wrk.other "</td>" skip
      "</tr>" skip.
  
  itog[1] = itog[1] + wrk.accepted.
  itog[2] = itog[2] + wrk.issued.
  itog[3] = itog[3] + wrk.rejected.
  itog[4] = itog[4] + wrk.other.
  itog_sum = itog_sum + wrk.issued_sum.
  
end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td>ИТОГО</td>" skip
    "<td>" itog[1] "</td>" skip
    "<td>" itog[2] "</td>" skip
    "<td>" replace(trim(string(itog_sum, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" itog[3] "</td>" skip
    "<td>" itog[4] "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table><br><br>" skip.

/* табличка - причины отказов */
put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Причина отказа</td>" skip
    "<td>Количество</td>" skip
    "</tr>" skip.

itog = 0.
for each wrkr no-lock:
  
  put stream rep unformatted
      "<tr>" skip
      "<td>" wrkr.cause_des "</td>" skip
      "<td>" wrkr.num "</td>" skip
      "</tr>" skip.
  
  itog[1] = itog[1] + wrkr.num.
  
end. /* for each wrkr */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td>ИТОГО</td>" skip
    "<td>" itog[1] "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table>" skip.

put stream rep unformatted "</body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin pksbvyd.htm excel.

