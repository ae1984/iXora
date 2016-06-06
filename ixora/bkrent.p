/* bkrent.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
         
 * AUTHOR
        03.03.2004 marinav
 * CHANGES
        05.04.2004 nadejda - запрет филиалам видеть не свои отчеты
        08.04.2004 nadejda - исправлены расчеты всех цифр с учетом разбивки по филиалам, и в bkrent филиал пишется
	03/01/2005 u00121 Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/  

{mainhead.i}
{pk0.i}

def var i as integer.
def var n as integer.
def new shared var d1 as date.
def new shared var d2 as date.
def var coun as int init 1.
def var v-cif like bank.lon.cif. 
def var sumk as decimal extent 30.
def new shared var suma as decimal .
def var suma1 as decimal .
def var suma2 as decimal .
def var suma3 as decimal .
def var suma4 as decimal .
def var suma5 as decimal .
def var suma6 as decimal .
def var svalt as decimal extent 2.
def var v-suma as decimal .
define var v-sel as char.
def var v-bank as char.

define new shared var s-ourbank as char.
/* текущий вид кредита */
define new shared var s-credtype as char init "6" . /*быстрые деньги*/
{pk-sysc.i}

def new shared temp-table  wrk
    field bank   as char
    field datot  like bank.lon.rdt
    field cif    like bank.lon.cif
    field lon    like bank.lon.lon
    field name   like bank.cif.name
    field plan   like bank.lon.plan
    field balans as decimal 
    field balans1 as decimal 
    field balans3 as decimal 
    field duedt  as date
    field rez    as decimal 
    field rez1   as decimal 
    field peni   as decimal 
    field daymax as inte
    index main is primary datot desc bank cif lon.

assign d1 = g-today - 1 d2 = g-today.

def frame dat
    skip(2) 
    d1 label " Укажите период с " format "99/99/9999"  
      validate (d1 <= g-today, " Дата начала периода должна быть не больше текущей!") skip
    d2 label "               по " format "99/99/9999"  
      validate (d1 < d2, " Дата конца периода должна быть меньше даты начала!")
    skip(1) 
  with side-label row 5 centered title "Расчет окупаемости проекта БЫСТРЫЕ ДЕНЬГИ".

update d1 with frame dat.
update d2 with frame dat.


find sysc where sysc.sysc = "ourbnk" no-lock no-error.
find txb where txb.consolid and txb.bank = sysc.chval no-lock no-error.

if not txb.is_branch then do:
  {sel-filial.i}  
end.
else do:
  v-select = txb.txb + 2.
end.

if v-select > 1 then do:
  find txb where txb.consolid and txb.txb = v-select - 2 no-lock no-error.
  v-bank = txb.bank.
end.
else 
  v-bank = "".

find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 no-lock no-error.

if avail bkrent then do:
     run sel2 ("В базе есть данные за этот период :", 
               " 1. Показать отчет | 2. Пересчитать отчет ", output v-sel).
end.
      
if not avail bkrent then do transaction:
   for each bkrentspr no-lock.
     create bkrent.
     assign bkrent.kod = bkrentspr.kod
            bkrent.type = bkrentspr.type
            bkrent.ln = bkrentspr.ln
            bkrent.date1 = d1
            bkrent.date2 = d2
            bkrent.who = g-ofc
            bkrent.whn = g-today
            bkrent.bank = v-bank.  
   end.
   v-sel = "2".
end.
        
  case v-sel:
    when "2" then do:
      
      {jabrw.i 
      &start     = " "
      &head      = "bkrent"
      &headkey   = "kod"
      &index     = "d1d2ln"
      
      &formname  = "bkrent"
      &framename = "bkrent"
      &frameparm = " "
      &where     = " bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.type = '2' "
      &predisplay = " find first bkrentspr where bkrentspr.kod = bkrent.kod no-lock no-error. "
      &addcon    = "false"
      &deletecon = "false"
      &postcreate = " "
      &postupdate   = " "
                       
      &prechoose = " hide message. message 'F4 - выход, P - печать'."
      
      &postdisplay = " "
      
      &display   = " bkrentspr.name bkrent.val[1] "
      &update    = " bkrent.val[1] "
      &highlight = " bkrent.val[1] "
      
      &postkey   = " " 
      &end = " hide message no-pause. "
      }
      
      
      /*if keyfunction(lastkey) = "end-error" then return. */
      
      
      /* 05.04.2004 nadejda 
      for each comm.txb where comm.txb.consolid no-lock:
          if connected ("txb") then disconnect "txb".
          connect value(" -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
          s-ourbank = comm.txb.bank.
          hide message no-pause.
          message " Обработка " s-ourbank.
          run bkrent1 (input d1, input d2).
          if not connected ("txb") then displ comm.txb.path.
      end.
      */
/*      
      {r-brfilial.i &proc = "bkrent1 (d1, d2, txb.bank)"}
*/

      for each txb where txb.consolid and 
               (if v-select = 1 then true else txb.txb = v-select - 2) no-lock:
          if connected ("txb") then disconnect "txb".
          connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
          run bkrent1 (d1, d2, txb.bank).
      end.
      if connected ("txb")  then disconnect "txb".


      def var v-bankname as char.

      if v-select = 1 then do:
        find first cmp no-lock no-error.
        v-bankname = "Консолидированный отчет".
      end.
      else do:
        find txb where txb.consolid and txb.txb = v-select - 2 no-lock no-error.
        v-bankname = txb.name.
      end.



      hide message no-pause.

      suma1 = 0. suma2 = 0. suma3 = 0. suma4 = 0. suma5 = 0. suma6 = 0.
      sumk[1] = 0. sumk[2] = 0. sumk[3] = 0. sumk[4] = 0. sumk[5] = 0. sumk[6] = 0. sumk[7] = 0. 

        /* суммы комиссий за период */
      for each pkanketa no-lock where pkanketa.docdt >= d1 and pkanketa.docdt < d2 and if v-bank = "" then true else pkanketa.bank = v-bank:
            if pkanketa.lon = "" then next.

            /* с 24 декабря 2003 началась комиссия 3% в фонд покрытия риска */
            if pkanketa.docdt > 12/24/03 then do: 
                 suma4 = suma4 + (pkanketa.summa * get-pksysc-dec ("tarfnd") / 100).
                 suma2 = suma2 + (pkanketa.sumcom - pkanketa.summa * get-pksysc-dec ("tarfnd") / 100).
            end.
            else do:
                 suma2 = suma2 + pkanketa.sumcom.
            end.
            suma6 = suma6 + pkanketa.summa .
      end. 

      for each wrk. 
         if wrk.datot = d1 then do:
                svalt[1] = svalt[1] + wrk.balans.
                if wrk.rez = 100 then sumk[7] = sumk[7] + wrk.balans.
                suma1 = suma1 - wrk.balans3.
                suma3 = suma3 - wrk.peni.
         end.
         if wrk.datot = d2 then do:
                svalt[2] = svalt[2] + wrk.balans.
                if wrk.rez = 5 then  sumk[1] = sumk[1] + wrk.balans.
                if wrk.rez = 10 then sumk[2] = sumk[2] + wrk.balans.
                if wrk.rez = 20 then sumk[3] = sumk[3] + wrk.balans.
                if wrk.rez = 25 then sumk[4] = sumk[4] + wrk.balans.
                if wrk.rez = 50 then sumk[5] = sumk[5] + wrk.balans.
                if wrk.rez = 100 then sumk[6] = sumk[6] + wrk.balans.
                suma1 = suma1 + wrk.balans3.
                suma3 = suma3 + wrk.peni.
         end.
      end.
      
         
      /* Занести в таблицу историй bkrent */
      
      do trans:
        assign
               sumk[1] = sumk[1] / 1000
               sumk[2] = sumk[2] / 1000 
               sumk[3] = sumk[3] / 1000
               sumk[4] = sumk[4] / 1000
               sumk[5] = sumk[5] / 1000
               sumk[6] = sumk[6] / 1000
               sumk[7] = sumk[7] / 1000
               suma1 = suma1 / 1000
               suma2 = suma2 / 1000
               suma3 = suma3 / 1000
               suma4 = suma4 / 1000
               suma6 = suma6 / 1000
               svalt[1] = svalt[1] / 1000
               svalt[2] = svalt[2] / 1000 .
        
        suma5 = sumk[1] + sumk[2] + sumk[3] + sumk[4] + sumk[5] + sumk[6].  /*вся просрочка*/
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'srok30' no-error.
        if avail bkrent then assign bkrent.val[1] = (sumk[1] + sumk[2])  
                                    bkrent.val[2] = (sumk[1] + sumk[2]) / suma5 * 100.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'srok60' no-error.
        if avail bkrent then assign bkrent.val[1] = (sumk[3] + sumk[4]) 
                                    bkrent.val[2] = (sumk[3] + sumk[4]) / suma5 * 100.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'srok90' no-error.
        if avail bkrent then assign bkrent.val[1] = sumk[5]  
                                    bkrent.val[2] = sumk[5] / suma5 * 100.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'srok360' no-error.
        if avail bkrent then assign bkrent.val[1] = sumk[6] 
                                    bkrent.val[2] = sumk[6] / suma5 * 100.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'srokall' no-error.
        if avail bkrent then assign bkrent.val[1] = suma5 bkrent.val[2] = suma5 / suma5 * 100.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'srokportf' no-error.
        if avail bkrent then assign bkrent.val[1] = svalt[2]  
                                    bkrent.val[2] = suma5 / svalt[2] * 100.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'dox%' no-error.
        if avail bkrent then assign bkrent.val[1] = suma1.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'doxcom' no-error.
        if avail bkrent then assign bkrent.val[1] = suma2.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'doxpen' no-error.
        if avail bkrent then assign bkrent.val[1] = suma3.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'doxstr' no-error.
        if avail bkrent then assign bkrent.val[1] = suma4.
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'rassrok' no-error.
        if avail bkrent then assign bkrent.val[1] = sumk[6] - sumk[7].
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'rasden%' no-error.
        if avail bkrent then assign v-suma = bkrent.val[1].
        
        find first bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod = 'rasden' no-error.
        if avail bkrent then assign bkrent.val[1] = (v-suma / 100) * suma6 * ( d2 - d1) / 360.
        
      end.
   end.
  end case.   
      


suma1 = 0. /* будем считать прибыль */
suma2 = 0.
                                                            
define stream m-out.
output stream m-out to rpt.html.
put stream m-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/
put stream m-out unformatted "<br><tr align=""center""><td><h3>" bank.cmp.name "<br>" v-bankname "</h3></td></tr>" skip.

put stream m-out unformatted "<tr align=""center""><td><h3>Расчет окупаемости проекта БЫСТРЫЕ ДЕНЬГИ за период с "
                 string(d1) " по " string(d2) "</h3></td></tr><br>"
                 skip skip.

put stream m-out unformatted "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td align=""center"">Срок просрочки</td>"
                  "<td align=""center"">Сумма остатка, тыс тенге</td>"
                  "<td align=""center"">Доля , %</td>"
                  "</tr>" skip.

for each bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod begins 'srok' no-lock.
    find first bkrentspr where bkrentspr.kod = bkrent.kod no-lock no-error.
    if avail bkrentspr then
    put stream m-out unformatted 
                 "<br><tr align=""left"">"
                 "<td >"  bkrentspr.name "</td>"
                 "<td align=""right"">"  replace(trim(string(bkrent.val[1], "->>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                 "<td align=""right"">"  replace(trim(string(bkrent.val[2], "->>9.99%")), ".", ",")  "</td>"
                 "</tr>" skip.
end.
put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td align=""center"">Доходы</td>"
                  "<td align=""center"">Сумма, тыс тенге</td>"
                  "</tr>" skip.

for each bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod begins 'dox' no-lock.
    find first bkrentspr where bkrentspr.kod = bkrent.kod no-lock no-error.
    if avail bkrentspr then
    put stream m-out unformatted 
                 "<br><tr align=""left"">"
                 "<td >"  bkrentspr.name "</td>"
                 "<td align=""right"">"  replace(trim(string(bkrent.val[1], "->>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                 "</tr>" skip.
    suma1 = suma1 + bkrent.val[1].
end.
    put stream m-out unformatted 
                 "<br><tr align=""left"">"
                 "<td > Итого</td>"
                 "<td align=""right"">"  replace(trim(string(suma1, "->>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                 "</tr>" skip.

put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td align=""center"">Расходы</td>"
                  "<td align=""center""></td>"
                  "</tr>" skip.

for each bkrent where bkrent.bank = v-bank and bkrent.date1 = d1 and bkrent.date2 = d2 and bkrent.kod begins 'ras' no-lock.
    find first bkrentspr where bkrentspr.kod = bkrent.kod no-lock no-error.
    if avail bkrentspr then
    put stream m-out unformatted 
                 "<br><tr align=""left"">"
                 "<td >"  bkrentspr.name "</td>"
                 "<td align=""right"">"  replace(trim(string(bkrent.val[1], "->>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                 "</tr>" skip.
    if bkrent.kod ne 'rasden%' then suma2 = suma2 + bkrent.val[1].
end.
    put stream m-out unformatted 
                 "<br><tr align=""left"">"
                 "<td > Итого</td>"
                 "<td align=""right"">"  replace(trim(string(suma2, "->>>>>>>>>>>>>>9.99")), ".", ",")  "</td>"
                 "</tr>" skip.

put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td align=""center"">Прибыль, тыс. тенге</td>"
                  "<td align=""center"">" replace(trim(string(suma1 - suma2, "->>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
                  "</tr></table>" skip.

put stream m-out "<br><tr></tr><tr align=""left""><td colspan=2>
 * Заработная плата сотрудников , осуществляющих выдачу и контороль кредитов, выдаваемых
   по программе Быстрые деньги (7 человек) </td></tr>" skip.
put stream m-out "<br><tr></tr><tr align=""left""><td colspan=2>
 ** Сумма кредитов, перешедших из группы с просрочкой менее 90 дней в группу с просрочкой более 90 дней за период </td></tr><br><br>" skip.

put stream m-out "</body></html>" .
output stream m-out close.

unix silent cptwin rpt.html excel.

