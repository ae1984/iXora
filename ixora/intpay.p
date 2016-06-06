/* intpay.p
 * MODULE
          Платежная система
 * DESCRIPTION
          Отчет по внутренним платежам по всем подразделениям
 * RUN
          Способ вызова программы, описание параметров, примеры вызова
 * CALLER
          Список процедур, вызывающих этот файл 
 * SCRIPT
          Список скриптов, вызывающих этот файл
 * INHERIT
          intpay1.p
 * MENU
          6-12-14
 * AUTHOR
          26.06.06 ten
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def new shared temp-table temp no-undo
         field code as char
         field urkol as int
         field uramt as dec
         field fizkol as int
         field fizamt as dec
         field inetkol as int
         field inetamt as dec
         field scankol as int
         field scanamt as dec
         field filkol as int
         field filamt as dec
         field joukol as int
         field jouamt as dec
   index cd is primary code.

def var is_our as log no-undo.

def var v-start as date label "C " no-undo.
def var v-end as date label "По " no-undo. 

def var v-dep as int no-undo.
def var v-point as int no-undo.

def var v-kol as int no-undo.
def var v-amt as dec no-undo.


update v-start v-end with side-labels frame dt centered.


for each remtrz where remtrz.rdt >= v-start and remtrz.rdt <= v-end no-lock.
    if remtrz.jh2 = ? or remtrz.cover <> 5 or remtrz.tcrc <> 1 then next. 
    if remtrz.rwho = "" or remtrz.rwho = "superman" then next.
    find jh  where jh.jh = remtrz.jh1 no-lock no-error.
    if not avail jh or jh.sts <> 6 then next.
    find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
    find cif of aaa no-lock no-error.
    if avail aaa and avail cif then do:
       v-point = integer(cif.jame) / 1000 - 0.5.
       v-dep = integer(cif.jame) - v-point * 1000. 
       if remtrz.sbank = "TXB00" and v-dep = 1 then do:
          find first temp where temp.code = "cent" no-error.
          if not avail temp then do:
             create temp.
                    temp.code = "cent".
          end.
          if remtrz.source = "SCN" then do:
             temp.scankol = temp.scankol + 1.
             temp.scanamt = temp.scanamt + remtrz.amt.
          end.
          else 
          if remtrz.source = "IBH" then do:
             temp.inetkol = temp.inetkol + 1.
             temp.inetamt = temp.inetamt + remtrz.amt.
          end.
          else 
          if remtrz.rcbank begins "TXB" and remtrz.rcbank <> "TXB00" then do:
             temp.filkol = temp.filkol + 1.
             temp.filamt = temp.filamt + remtrz.amt.
          end.
          else 
          if cif.type = "B" then do:
             temp.urkol = temp.urkol + 1.
             temp.uramt = temp.uramt + remtrz.amt.
          end.
          else
          if cif.type = "P" then do:
             temp.fizkol = temp.fizkol + 1.
             temp.fizamt = temp.fizamt + remtrz.amt.
          end.
       end.
       else 
       if remtrz.sbank = "TXB00" and v-dep <> 1 then do:
          find first temp where temp.code = "spo" no-error.
          if not avail temp then do:
             create temp.
                    temp.code = "spo".
          end.
          if remtrz.source = "SCN" then do:
             temp.scankol = temp.scankol + 1.
             temp.scanamt = temp.scanamt + remtrz.amt.
          end.
          else 
          if remtrz.source = "IBH" then do:
             temp.inetkol = temp.inetkol + 1.
             temp.inetamt = temp.inetamt + remtrz.amt.
          end.
          else
          if remtrz.rcbank begins "TXB" and remtrz.rcbank <> "TXB00" then do:
             temp.filkol = temp.filkol + 1.
             temp.filamt = temp.filamt + remtrz.amt.
          end.
          else 
          if cif.type = "B" then do:
             temp.urkol = temp.urkol + 1.
             temp.uramt = temp.uramt + remtrz.amt.
          end.
          else
          if cif.type = "P" then do:
             temp.fizkol = temp.fizkol + 1.
             temp.fizamt = temp.fizamt + remtrz.amt.
          end.
       end.
       else
       if remtrz.sbank begins "TXB" and remtrz.sbank <> "TXB00" then do:
          find first temp where temp.code = "fil" no-error.
          if not avail temp then do:
             create temp.
                    temp.code = "fil".
          end.
          if remtrz.source = "SCN" then do:
             temp.scankol = temp.scankol + 1.
             temp.scanamt = temp.scanamt + remtrz.amt.
          end.
          else 
          if remtrz.source = "IBH" then do:
             temp.inetkol = temp.inetkol + 1.
             temp.inetamt = temp.inetamt + remtrz.amt.
          end.
          else 
          if remtrz.rcbank = "TXB00" then do:
             temp.filkol = temp.filkol + 1.
             temp.filamt = temp.filamt + remtrz.amt.
          end.
          else 
          if cif.type = "B" then do:
             temp.urkol = temp.urkol + 1.
             temp.uramt = temp.uramt + remtrz.amt.
          end.
          else
          if cif.type = "P" then do:
             temp.fizkol = temp.fizkol + 1.
             temp.fizamt = temp.fizamt + remtrz.amt.
          end.
       end.
    end.
    else do:
        find arp where arp.arp eq remtrz.dracc no-lock no-error.
        if avail arp then do:
           find last ofchis where ofchis.ofc eq remtrz.rwho no-lock    no-error.
           if avail ofchis then do:
              if remtrz.sbank = "TXB00" and ofchis.depart = 1 then do:
                 find first temp where temp.code = "cent" no-error.
                 if not avail temp then do:
                    create temp.
                           temp.code = "cent".
                 end.
                 if remtrz.source = "SCN" then do:
                    temp.scankol = temp.scankol + 1.
                    temp.scanamt = temp.scanamt + remtrz.amt.
                 end.
                 else 
                 if remtrz.source = "IBH" then do:
                    temp.inetkol = temp.inetkol + 1.
                    temp.inetamt = temp.inetamt + remtrz.amt.
                 end.
                 else 
                 if remtrz.rcbank begins "TXB" and remtrz.rcbank <> "TXB00" then do:
                    temp.filkol = temp.filkol + 1.
                    temp.filamt = temp.filamt + remtrz.amt.
                 end.
              end.
              else 
              if remtrz.sbank = "TXB00" and ofchis.depart = 1 then do:
                 find first temp where temp.code = "spo" no-error.
                 if not avail temp then do:
                    create temp.
                           temp.code = "spo".
                 end.
                 if remtrz.source = "SCN" then do:
                    temp.scankol = temp.scankol + 1.
                    temp.scanamt = temp.scanamt + remtrz.amt.
                 end.
                 else 
                 if remtrz.source = "IBH" then do:
                    temp.inetkol = temp.inetkol + 1.
                    temp.inetamt = temp.inetamt + remtrz.amt.
                 end.
                 else
                 if remtrz.rcbank begins "TXB" and remtrz.rcbank <> "TXB00" then do:
                    temp.filkol = temp.filkol + 1.
                    temp.filamt = temp.filamt + remtrz.amt.
                 end.
              end.
              else
              if remtrz.sbank begins "TXB" and remtrz.sbank <> "TXB00" then do:
                 find first temp where temp.code = "fil" no-error.
                 if not avail temp then do:
                    create temp.
                           temp.code = "fil".
                 end.
                 if remtrz.source = "SCN" then do:
                    temp.scankol = temp.scankol + 1.
                    temp.scanamt = temp.scanamt + remtrz.amt.
                 end.
                 else 
                 if remtrz.source = "IBH" then do:
                    temp.inetkol = temp.inetkol + 1.
                    temp.inetamt = temp.inetamt + remtrz.amt.
                 end.
                 else 
                 if remtrz.rcbank = "TXB00" then do:
                    temp.filkol = temp.filkol + 1.
                    temp.filamt = temp.filamt + remtrz.amt.
                 end.
              end.
           end.
        end.
     end.
end.

for each txb where txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 	
    run intpay1 (v-start, v-end,  txb.bank).
end.
if connected ("txb")  then disconnect "txb".

output to intpay.htm.

put  unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put unformatted  "<b> Отчет по внутренним платежам </b>" skip. 
put unformatted  "<br> в тыс. тенге C " v-start  " по " v-end " ". 
put unformatted  "<br>". 

put unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"  skip
                 "<tr><td bgcolor=""#95B2D1"" align=center> Подразделение </td>" skip
                 "<td bgcolor=""#95B2D1"" align=center> Количество </td>" skip
                 "<td bgcolor=""#95B2D1"" align=center> Сумма </td></tr>" skip
                 "<tr><td align=center><b> Центральный офис </b></td>" skip
                 "<td></td>" skip
                 "<td></td></tr>" skip.

for each temp where temp.code = "cent" no-lock.
    put unformatted "<tr><td align=left> Клиентские обычные <br> платежи юр.лиц(сч <br> 700,467,609,603,715) </td>" skip
                    "<td align=right>" temp.urkol "</td>" skip
                    "<td align=right>" temp.uramt "</td></tr>" skip
                    "<tr><td align=left> Клиентские обычные <br> платежи физ.лиц(сч <br> 711,117,704) </td>" skip
                    "<td align=right>" temp.fizkol "</td>" skip
                    "<td align=right>" temp.fizamt "</td></tr>" skip
                    "<tr><td align=left> Клиентские интернет <br> платежи </td>" skip
                    "<td align=right>" temp.inetkol "</td>" skip
                    "<td align=right>" temp.inetamt "</td></tr>" skip
                    "<tr><td align=left> Клиентские сканированные <br> платежи </td>" skip
                    "<td align=right>" temp.scankol "</td>" skip
                    "<td align=right>" temp.scanamt "</td></tr>" skip
                    "<tr><td align=left> jou платежи </td>" skip
                    "<td align=right>" temp.joukol "</td>" skip
                    "<td align=right>" temp.jouamt "</td></tr>" skip
                    "<tr><td align=left> Платежи между филиалами </td>" skip
                    "<td align=right>" temp.filkol "</td>" skip
                    "<td align=right>" temp.filamt "</td></tr>" skip.
end.
put unformatted 
                 "<tr><td align=center><b> СПО АО ""TEXAKABANK"" </b></td>" skip
                 "<td></td>" skip
                 "<td></td></tr>" skip.

for each temp where temp.code = "spo" no-lock .
    put unformatted "<tr><td align=left> Клиентские обычные <br> платежи юр.лиц(сч <br> 700,467,609,603,715) </td>" skip
                    "<td align=right>" temp.urkol "</td>" skip
                    "<td align=right>" temp.uramt "</td></tr>" skip
                    "<tr><td align=left> Клиентские обычные <br> платежи физ.лиц(сч <br> 711,117,704) </td>" skip
                    "<td align=right>" temp.fizkol "</td>" skip
                    "<td align=right>" temp.fizamt "</td></tr>" skip
                    "<tr><td align=left> Клиентские интернет <br> платежи </td>" skip
                    "<td align=right>" temp.inetkol "</td>" skip
                    "<td align=right>" temp.inetamt "</td></tr>" skip
                    "<tr><td align=left> Клиентские сканированные <br> платежи </td>" skip
                    "<td align=right>" temp.scankol "</td>" skip
                    "<td align=right>" temp.scanamt "</td></tr>" skip
                    "<tr><td align=left> jou платежи </td>" skip
                    "<td align=right>" temp.joukol "</td>" skip
                    "<td align=right>" temp.jouamt "</td></tr>" skip
                    "<tr><td align=left> Платежи между филиалами </td>" skip
                    "<td align=right>" temp.filkol "</td>" skip
                    "<td align=right>" temp.filamt "</td></tr>" skip.
end.
put unformatted 
                 "<tr><td align=center><b> Филиалы АО ""TEXAKABANK"" </b></td>" skip
                 "<td></td>" skip
                 "<td></td></tr>" skip.

for each temp where temp.code = "fil" no-lock .
    put unformatted "<tr><td align=left> Клиентские обычные <br> платежи юр.лиц(сч <br> 700,467,609,603,715) </td>" skip
                    "<td align=right>" temp.urkol "</td>" skip
                    "<td align=right>" temp.uramt "</td></tr>" skip
                    "<tr><td align=left> Клиентские обычные <br> платежи физ.лиц(сч <br> 711,117,704) </td>" skip
                    "<td align=right>" temp.fizkol "</td>" skip
                    "<td align=right>" temp.fizamt "</td></tr>" skip
                    "<tr><td align=left> Клиентские интернет <br> платежи </td>" skip
                    "<td align=right>" temp.inetkol "</td>" skip
                    "<td align=right>" temp.inetamt "</td></tr>" skip
                    "<tr><td align=left> Клиентские сканированные <br> платежи </td>" skip
                    "<td align=right>" temp.scankol "</td>" skip
                    "<td align=right>" temp.scanamt "</td></tr>" skip
                    "<tr><td align=left> jou платежи </td>" skip
                    "<td align=right>" temp.joukol "</td>" skip
                    "<td align=right>" temp.jouamt "</td></tr>" skip
                    "<tr><td align=left> Платежи между филиалами </td>" skip
                    "<td align=right>" temp.filkol "</td>" skip
                    "<td align=right>" temp.filamt "</td></tr>" skip.
end.
for each temp.
    v-kol = v-kol + temp.filkol + temp.scankol + temp.inetkol + temp.fizkol + temp.urkol + temp.joukol.
    v-amt = v-amt + temp.filamt + temp.scanamt + temp.inetamt + temp.fizamt + temp.uramt + temp.jouamt.
end.
    put unformatted "<tr><td align=center bgcolor=""#95B2D1""><b> Итого по банку </b></td>" skip
                    "<td align=right bgcolor=""#95B2D1"">" v-kol "</td>" skip
                    "<td align=right bgcolor=""#95B2D1"">" v-amt "</td></tr>" skip.

put unformatted "</TABLE>" skip.             
unix silent cptwin intpay.htm excel.

