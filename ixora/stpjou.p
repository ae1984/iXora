/* stpjou.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Отчет по своду внутренних документов.
 * RUN
        rmzmon -> stpjou.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур 
 * MENU
        5-3-13
 * AUTHOR
        05.08.2003 tsoy
 * CHANGES
        29.11.2004 suchkov - Переделал список офицеров контроля, теперь берется из sysc.
        17.05.2006 ten - тоже для филиалов.
*/

{global.i}

def temp-table t-data
  field n_por      as integer
  field jh         like jh.jh
  field amt        as deci
  field ofc        as char
  field sub        as char.

def var i as integer init 0.

def var v-total as decimal.

def var is_our as logi.
def var v-klist as char init "abulhair,chigr,krikunov,u00083,u00087,u00085".


find sysc where sysc.sysc = "klist" no-lock no-error .
if not available sysc then do:
        message "Внимание! Не найдена настройка офицеров-контролеров!" view-as alert-box.
        quit.
end.
v-klist = sysc.chval .

def stream v-out.
output stream v-out to stpjou.html.

define var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

for each remtrz where remtrz.rdt = g-today no-lock.

      if remtrz.jh2 = ?  then next. 

      find jh  where jh.jh = remtrz.jh1 no-lock no-error.
      if jh.sts <> 6 then next.

      if remtrz.cover <> 5  then next.
      if remtrz.sbank <> remtrz.sbank then next.

      if remtrz.sbank <> s-ourbank then next.
      is_our = false.

      for each jl where jl.jh = jh.jh no-lock.
        if lookup(jl.teller, v-klist)  > 0 then is_our = true.
      end.
      if not is_our then  next.
      i = i + 1.

      create t-data.
        t-data.n_por  = i.
        t-data.jh     = remtrz.jh1.
        t-data.amt    = remtrz.amt.
        t-data.sub    = jh.sub.
        if avail jh then
             t-data.ofc = jh.who.

end.

for each joudoc where joudoc.whn = g-today no-lock. 
     is_our = false.

     if joudoc.jh = ?  then next.            
     find jh where jh.jh = joudoc.jh no-lock no-error.
     
     if jh.sub <> 'jou' then next.


     for each jl where jl.jh = joudoc.jh no-lock.
            if jh.sts <> 6 then leave.
            if lookup(jl.teller, v-klist)  = 0 then leave .
            is_our = true.
     end.


      if is_our then do: 
           i = i + 1.

           create t-data.
               t-data.n_por  = i.
               t-data.jh     = jh.jh.
               t-data.amt    = joudoc.dramt.
               t-data.sub    = jh.sub.
               
               if avail jh then
                    t-data.ofc = jh.who.
       end.
end.

put stream v-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<b>Свод внутренних документов</b>" skip. 
put stream v-out unformatted  "<br>" string(today, "99.99.9999")  " " string (time, "HH:MM") " " g-ofc. 
put stream v-out unformatted  "<br>". 

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip. 

       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>N п/п </td>"
                         "<td>Транзакция</td>"
                         "<td>Сумма</td>"
                         "<td>Исполнитель</td>"
                         "</tr>"
                          skip.



for each t-data.
       v-total = v-total + t-data.amt. 
       put stream v-out unformatted "<tr>"
                         "<td>" t-data.n_por "</td>"
                         "<td>" t-data.jh "</td>"
                         "<td>" replace(trim(string(t-data.amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")   "</td>"
                         "<td>" t-data.ofc  "</td>"
                         "</tr>"
                          skip.

end.

put stream v-out unformatted
"</table>". 

put stream v-out unformatted  "<br>". 
put stream v-out unformatted  "<br>Всего документов: "  string(i)  " Общая сумма: " replace(trim(string(v-total, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") . 

output close.
output stream v-out close.
unix silent value("cptwin stpjou.html excel").





