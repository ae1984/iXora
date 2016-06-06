/* pkport_mko.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по динамике портфеля МКО
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
        03/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        07/12/2009 galina - немного поправила внешний вид отчета
                            еще поправила внешний вид отчета 
        10/12/2009 galina - немного поправила внешний вид отчета                            
*/

{global.i}

def var v-port_kzt as deci no-undo.
def var v-port_usd as deci no-undo.
def var v-sumdoh as deci no-undo.
def var v-sumod as deci no-undo.
def var v-sumbal as deci no-undo.
def var v-amtlon as integer no-undo.
def var v-amtcif as integer no-undo.
def var v-port_kzttot as deci no-undo.
def var v-port_usdtot as deci no-undo.
def var v-sumdohtot as deci no-undo.
def var v-sumodtot as deci no-undo.
def var v-sumbaltot as deci no-undo.
def var v-amtlontot as integer no-undo.
def var v-amtciftot as integer no-undo.
def var i as integer no-undo.

def var v-cif as char no-undo.
def var v-bankname as char no-undo.
def stream rep.

def new shared temp-table wrk no-undo
  field cif as char
  field dt as date
  field port_kzt as decimal
  field port_usd as decimal
  field sumod as decimal
  field sumdoh as decimal
  field bank as char
  field crc as integer
  field sumbal as deci.

def temp-table wrk1 no-undo
  field dt as date
  field port_kzt as decimal
  field port_usd as decimal
  field sumod as decimal
  field sumdoh as decimal
  field amtlon as integer
  field amtcif as integer
  field sumbal as decimal
  field bank as char
  index idx is primary bank dt.

def buffer b-wrk1 for wrk1.
def buffer b2-wrk1 for wrk1.
def var v-bnklist as char.
def var k as integer.
v-bnklist = 'txb99,txb16,txb01,txb04,txb02,txb06'.

def new shared var dates as date no-undo extent 7.
def var dat as date no-undo.
def var bdat as date no-undo.
dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999'
validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
with side-label row 5 centered frame dat.


bdat = dat.
dates[1] = dat.
do i = 2 to 7:
  if day(bdat) <> 1 then bdat = date(month(bdat),1,year(bdat)).
  else do:
    if month(bdat) = 1 then bdat = date(12,1,year(bdat) - 1).
    else bdat = date(month(bdat) - 1,1,year(bdat)).
  end.
  /*dates[7 - i] = bdat.*/
  dates[i] = bdat.
end.

{r-branch.i &proc = "pkport_mko1 (txb.bank)"}

v-port_kzt = 0.
v-port_usd = 0.
v-sumdoh = 0.
v-sumod = 0.
v-sumbal = 0.
v-amtlon = 0.
v-amtcif = 0.

do i = 1 to 7:

    assign v-port_kzttot = 0
           v-port_usdtot = 0
           v-sumdohtot = 0
           v-sumodtot = 0
           v-sumbaltot = 0
           v-amtlontot = 0
           v-amtciftot = 0.

   for each wrk where wrk.dt = dates[i] break by wrk.bank by wrk.cif:

     if first-of(wrk.bank) then do:
         assign v-port_kzt = 0
                v-port_usd = 0
                v-sumdoh = 0
                v-sumod = 0
                v-sumbal = 0
                v-amtlon = 0
                v-amtcif = 0.
     end.

     v-port_kzt = v-port_kzt + wrk.port_kzt.
     v-port_usd = v-port_usd + wrk.port_usd.
     v-sumdoh = v-sumdoh + wrk.sumdoh.
     v-sumod = v-sumod + wrk.sumod.
     v-sumbal = v-sumbal + wrk.sumbal.

     if wrk.port_kzt > 0 then do:
        v-amtlon = v-amtlon + 1.
        if wrk.cif <> v-cif then assign v-amtcif = v-amtcif + 1 v-cif = wrk.cif.
     end.

     if last-of(wrk.bank) then do:
         create wrk1.
         assign wrk1.bank = wrk.bank
                wrk1.port_kzt = v-port_kzt
                wrk1.port_usd = v-port_usd
                wrk1.sumod = v-sumod
                wrk1.sumdoh = v-sumdoh
                wrk1.amtcif = v-amtcif
                wrk1.amtlon = v-amtlon
                wrk1.sumbal = v-sumbal
                wrk1.dt = wrk.dt.

         v-port_kzttot = v-port_kzttot + v-port_kzt.
         v-port_usdtot = v-port_usdtot + v-port_usd.
         v-sumdohtot = v-sumdohtot + v-sumdoh.
         v-sumodtot = v-sumodtot + v-sumod.
         v-sumbaltot = v-sumbaltot + v-sumbal.
         v-amtlontot = v-amtlontot + v-amtlon.
         v-amtciftot = v-amtciftot + v-amtcif.
     end.
   end.

   create wrk1.
   assign wrk1.bank = 'txb99'
          wrk1.port_kzt = v-port_kzttot
          wrk1.port_usd = v-port_usdtot
          wrk1.sumod = v-sumodtot
          wrk1.sumdoh = v-sumdohtot
          wrk1.amtcif = v-amtciftot
          wrk1.amtlon = v-amtlontot
          wrk1.sumbal = v-sumbaltot
          wrk1.dt = dates[i].

end.


output stream rep to rep.htm.
put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

put stream rep unformatted
    "<center><b>Анализ портфеля беззалоговых экспресс-кредитов на " dat format "99/99/9999" "<br>Консолидированный МКО</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip.

put stream rep unformatted "</tr>" skip.

do k = 1 to num-entries(v-bnklist):  
    for each wrk1 where wrk1.bank = entry(k,v-bnklist) no-lock break by wrk1.bank:
          
        if first-of(wrk1.bank) then do:
    
            if wrk1.bank = "txb99" then v-bankname = "Консолидированный".
            else do:
                find first comm.txb where comm.txb.consolid and comm.txb.bank = wrk1.bank no-lock no-error.
                if avail comm.txb then v-bankname = comm.txb.info.
            end.
            put stream rep unformatted
                "<tr></tr><tr><td colspan=""8"">ДИНАМИКА КРЕДИТНОГО ПОРТФЕЛЯ " v-bankname "</td></tr>"skip.
    
            put stream rep unformatted
                "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
                "<td colspan=""2""></td>" skip.
            do i = 1 to 6:
                put stream rep unformatted "<td>" string(dates[i],"99/99/9999") "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td rowspan=""4"">Кредитный портфель</td>" skip
                "<td>Количество заемщиков</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                put stream rep unformatted "<td>" b-wrk1.amtcif "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td>Количество кредитов</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                put stream rep unformatted "<td>" b-wrk1.amtlon "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td>Сумма, KZT</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                put stream rep unformatted "<td>" replace(trim(string(b-wrk1.port_kzt,">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td>Сумма, USD</td>" skip.
            do i = 1 to 6:
                /* Истории курсов в МКО нет, поэтому выводим пустые ячейки
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                put stream rep unformatted "<td>" replace(trim(string(b-wrk1.port_usd,">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
                */
                put stream rep unformatted "<td></td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td colspan=""2"">Кредитный портфель по балансу</td>" skip
                "<td>" replace(trim(string(b-wrk1.sumbal,">>>>>>>>>>>9.99")),'.',',') "</td>" skip
                "<td colspan=""5""></td></tr><tr></tr>" skip.
    
            put stream rep unformatted "<tr allign ""left""><td colspan=""8"">ДИНАМИКА ПОСТУПЛЕНИЯ СУММ</td></tr>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center""><td colspan=""2""></td>" skip.
            do i = 1 to 6: put stream rep unformatted "<td>" string(dates[i],"99/99/9999") "</td>" skip.        end.
            put stream rep unformatted "</tr><tr>" skip
                "<td colspan=""2"">Объем поступления сумм на ОД, на дату</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                put stream rep unformatted "<td>" replace(trim(string(b-wrk1.sumod,">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td colspan=""2"">Объем поступления сумм на ОД, за период</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                find first b2-wrk1 where b2-wrk1.bank = wrk1.bank and b2-wrk1.dt = dates[i + 1] no-lock no-error.
                put stream rep unformatted "<td>" replace(trim(string(b-wrk1.sumod - b2-wrk1.sumod,"->>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td colspan=""2"">Объем поступления сумм на доходы, на дату</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                put stream rep unformatted "<td>" replace(trim(string(b-wrk1.sumdoh,">>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
    
            put stream rep unformatted
                "<tr>" skip
                "<td colspan=""2"">Объем поступления сумм на доходы, за период</td>" skip.
            do i = 1 to 6:
                find first b-wrk1 where b-wrk1.bank = wrk1.bank and b-wrk1.dt = dates[i] no-lock no-error.
                find first b2-wrk1 where b2-wrk1.bank = wrk1.bank and b2-wrk1.dt = dates[i + 1] no-lock no-error.
                put stream rep unformatted "<td>" replace(trim(string(b-wrk1.sumdoh - b2-wrk1.sumdoh,"->>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            end.
            put stream rep unformatted "</tr>" skip.
        end.
    end.
end.
put stream rep unformatted
    "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm excel.

