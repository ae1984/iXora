/* autosale.p
 * MODULE
        . 
 * DESCRIPTION
        Автоматизация обязательных продаж в течение 10 календарных дней со дня возврата и в течение 30 календарных дней со дня конвертации.
 * RUN
        v-stat2.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        v-stat2.p
 * AUTHOR
        21.07.2006 Natalya D.
 * CHANGES
        24.07.2006 Natalya D. - убрала рассылку на e-mail
        27.07.2006 Natalya D. - добавила входящий параметр(процедура будет отрабатывать за дату).
        28.07.2006 Natalya D. - добавила сохранение в лог.
        01.08.2006 Natalya D. - временно закоментарена продажа до выяснения вопросов по спец. инструкциям.
        02.08.2006 Natalya D. - если у счёта есть спец.инструкция, то пропускаем, по остальным попадают под продажу,
                                то продаем.
        22.08.2006 Natalya D. - необходимо учитывать случай, если транзакция была удалена менеджером:
                                добавила проверку и удаление записи из curctrl, если такой транзакции нет в jl.
        21.09.2006 Natalya D. - исправила ошибку с остатком.
        22.09.2006 Natalya D. - оказывается не то исправила
*/      
 
{global.i}
/*
Значения статусов таблицы curctrl.
1 - возвраты (счёт ГК = 223730 или 255110, код назн.платежа = 780 или 880).
2 - конвертация (счёт ГК = 220310)
3 - другие платежи
8 - сумма была продана (реконвертация)
9 - сумма была перекрыта дебетовой суммой в опер.день)
*/
def input parameter p-dt as date.
def var v-ost as deci no-undo.
def var sum-dr as deci no-undo.
def var v-jh like jl.jh no-undo.
def var v-sum as deci no-undo.
def var p-sts like curctrl.sts no-undo.
def buffer baa for aaa.
def buffer bcurctrl for curctrl.
def buffer bjl for jl.

def stream ss-str.
output stream ss-str to autosale.log append.
put stream ss-str " " skip.
put stream ss-str today skip.
put stream ss-str "Ном.док-та" " | " "Про-ка начисления" " | " "Про-ка продажи" skip.
output stream ss-str close.

def stream s-str.
output stream s-str to value("testautosl" + string(year(today), "9999") + string(month(today), "99") + 
                        string(day(today),"99") + ".log").
put stream s-str " " skip.
put stream s-str p-dt skip.

define stream m-out.
output stream m-out to test64-1.html.
{html-title.i &stream = " stream m-out "}

put stream m-out unformatted "<table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td align=center>Ном.счета</td>"
                    "<td align=center>Счет ГК</td>"
                    "<td align=center>Код<br>валюты</td>"
                    "<td align=center>Сумма<br>поступления<br>на счет</td>"
                    "<td align=center>ном.проводки</td>"
                    "<td align=center>Дата<br>проаводки</td>"
                    "<td align=center>Код<br>назначения<br>платежа</td>"
                    "<td align=center>Номер<br>документа</td>"
                    "<td align=center>Статус</td>"
                    "<td align=center>Сумма<br>продажи</td>" 
                    "<td align=center>Ном.проводки(рек)</td>" 
                    "<td align=center>Дата реконвертации</td>" 
                    "<td align=center>Ном.документа<br>реконвертации</td>" 
                  "</tr></table>" skip.
for each curctrl no-lock break by curctrl.jdt by curctrl.sts .

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr align=""right"">"
                 "<td>&nbsp;" string(curctrl.aaa, "x(10)") "</td>"
                 "<td>" curctrl.gl "</td>"
                 "<td>" curctrl.crc "</td>"
                 "<td>" replace(string(curctrl.pamt, ">>>>>>>>>>>9.99"),'.',',') " </td>"
                 "<td>" curctrl.jh "</td>"               
                 "<td>" string(curctrl.jdt, "99.99.9999") "</td>"               
                 "<td>" curctrl.kpn "</td>"
                 "<td>" curctrl.pdocnum format "x(10)" "</td>" 
                 "<td>" curctrl.sts "</td>"
                 "<td>" replace(string(curctrl.rpamt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
                 "<td>" curctrl.rpjh "</td>"               
                 "<td>" string(curctrl.rpjdt, "99.99.9999") "</td>"               
                 "<td>" curctrl.rpnumdoc format "x(10)" "</td>" 
               "</tr></table>" skip.  
END.
  put stream m-out unformatted "</body></html>" skip.
output stream m-out close.
hide message no-pause.
/*unix silent cptwin test64-1.html excel.exe.*/
unix silent value("rcp test64-1.html " + replace("ntmain:L:\\Users\\Departments\\DIT\\","\\","\\\\")).

define temp-table t-acc no-undo
       field acc  like aaa.aaa
       field cif  like cif.cif.                              
/*-----------------------------------------------------------------------*/
/*Находим теньговые счета, по которым были последний раз движения средств*/
for each baa where baa.crc = 1 and baa.sta = 'A' and substring(baa.lgr,1,1) = '1' no-lock.
 find last jl where jl.acc = baa.aaa no-lock no-error.
 if not avail jl then next.
 create t-acc.
        t-acc.acc = baa.aaa.
        t-acc.cif = baa.cif.
end.
/*На случай, если транзакция была удалена менеджером, делаем проверку и удаляем её из curctrl.*/
for each curctrl where curctrl.jdt = p-dt exclusive-lock.
 find first jl where jl.jdt = curctrl.jdt and jl.jh = curctrl.jh no-lock no-error.
 if not avail jl then delete curctrl. 
end.
release curctrl.

for each aaa where (substring(aaa.aaa,4,3) = '070') or (substring(aaa.aaa,4,3) = '160') /*lookup(aaa.aaa,'009070543,018070657') > 0*/	  
               and substring(aaa.lgr,1,1) = '1' and aaa.sta = 'A' no-lock:
assign v-ost = 0 sum-dr = 0 p-sts = 0 v-sum = 0 .
put stream s-str "---------------------------------------------------------------------------------- " skip.
put stream s-str "ACC: " aaa.aaa skip.
  find last aas where aas.aaa = aaa.aaa no-lock no-error.
  if avail aas then do: 
    /*if (aas.payee matches '*k-2*') or (aas.payee matches '*предписание*') then*/ 
     next. 
  end.
  v-ost = absolute(aaa.dr[1] - aaa.cr[1]).  
    for each jl where jl.jdt = p-dt and jl.acc = aaa.aaa and jl.dc = 'd' and jl.lev = 1 no-lock .        
        find first bjl where bjl.jh = jl.jh and bjl.dc = 'c' and bjl.crc = jl.crc and bjl.cam = jl.dam  no-lock no-error.
         if avail bjl then do:
          if bjl.gl = 460410 then next.
         end.
        sum-dr = sum-dr + jl.dam.
    end.
put stream s-str "SUM-DR: " sum-dr format ">>>,>>>,>>9.99" skip.
    if sum-dr > 0 then do:

       do while sum-dr > 0:
       find first curctrl where curctrl.aaa = aaa.aaa and lookup(string(curctrl.sts),'8,9') = 0 
                            and curctrl.jdt <= p-dt no-lock no-error.
       if not avail curctrl then leave.       
          for each bcurctrl where bcurctrl.aaa = aaa.aaa and (bcurctrl.sts = 1 or bcurctrl.sts = 2) 
                            and bcurctrl.jdt <= p-dt no-lock by bcurctrl.jdt by bcurctrl.sts.            
            run verupd(input-output sum-dr,bcurctrl.aaa,bcurctrl.sts,bcurctrl.jh,bcurctrl.pamt,no,output p-sts).
put stream s-str "SUM-DR: " sum-dr format "->>>,>>>,>>9.99" " AMT "  bcurctrl.pamt format ">>>,>>>,>>9.99" " STS: " p-sts skip.
            if sum-dr = 0 then leave.
          end.
          for each bcurctrl where bcurctrl.aaa = aaa.aaa and bcurctrl.sts = 3 
                            and bcurctrl.jdt <= p-dt no-lock by bcurctrl.jdt.            
            run verupd(input-output sum-dr,bcurctrl.aaa,bcurctrl.sts,bcurctrl.jh,bcurctrl.pamt,no,output p-sts).
put stream s-str "SUM-DR: " sum-dr format "->>>,>>>,>>9.99" " AMT "  bcurctrl.pamt format ">>>,>>>,>>9.99" " STS: " p-sts skip.
            if sum-dr = 0 then leave.          
          end.
       end.
    end.


    if v-ost > 0 then do:
put stream s-str "V-OST: " v-ost format ">>>,>>>,>>9.99" skip.
      find first t-acc where t-acc.cif = aaa.cif no-lock no-error.
      if not avail t-acc then next. 
choose:
       do while v-ost > 0:

         find first curctrl where curctrl.aaa = aaa.aaa and lookup(string(curctrl.sts), '1,2') > 0 no-lock no-error.
         if not avail curctrl then leave choose.       
          for each bcurctrl where bcurctrl.aaa = aaa.aaa and lookup(string(bcurctrl.sts),'1,2') > 0 
                            no-lock by bcurctrl.jdt by bcurctrl.sts.                      
            case bcurctrl.sts :
              when 2 then do: if (g-today - bcurctrl.jdt) >= 30 then do:                       
              do transaction:
                       run verupd(input-output v-ost,bcurctrl.aaa,bcurctrl.sts,bcurctrl.jh,bcurctrl.pamt,yes,output p-sts).
put stream s-str "V-OST: " v-ost format "->>>,>>>,>>9.99" " AMT "  bcurctrl.pamt format ">>>,>>>,>>9.99" " STS: " p-sts skip.
                       
                       if v-ost >= bcurctrl.pamt or v-ost >= 0 then v-sum = bcurctrl.pamt. 
                       else v-sum = bcurctrl.pamt + v-ost.
                       run conv_trx(aaa.aaa, t-acc.acc, v-sum, curctrl.jh, p-sts).                       
             end. 

                       if v-ost <= 0 then leave choose.
                      end.
                      else leave choose.
              end.
              when 1 then do: if (g-today - bcurctrl.jdt) >= 10 then do:
              do transaction: 
                       run verupd(input-output v-ost,bcurctrl.aaa,bcurctrl.sts,bcurctrl.jh,bcurctrl.pamt,yes,output p-sts).
put stream s-str "V-OST: " v-ost format "->>>,>>>,>>9.99" " AMT "  bcurctrl.pamt format ">>>,>>>,>>9.99" " STS: " p-sts skip.
                       if v-ost >= bcurctrl.pamt or v-ost >= 0 then v-sum = bcurctrl.pamt.
                       else v-sum = bcurctrl.pamt + v-ost.
                       run conv_trx(aaa.aaa, t-acc.acc, v-sum, curctrl.jh, p-sts).                       
              end.

                       if v-ost <= 0 then leave choose.                                                                           
                      end.
                      else leave choose.
              end.
              OTHERWISE leave choose.
            end.            
          end.  
       end.    
  end.

end.

output stream s-str close.
unix silent value("rcp testautosl" + string(year(today), "9999") + string(month(today), "99") + 
                        string(day(today),"99") + ".log " + replace("ntmain:L:\\Users\\Departments\\DIT\\","\\","\\\\")).

define stream m-out1.
output stream m-out1 to test64-2.html.
{html-title.i &stream = " stream m-out1 "}

put stream m-out1 unformatted "<table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td align=center>Ном.счета</td>"
                    "<td align=center>Счет ГК</td>"
                    "<td align=center>Код<br>валюты</td>"
                    "<td align=center>Сумма<br>поступления<br>на счет</td>"
                    "<td align=center>ном.проводки</td>"
                    "<td align=center>Дата<br>проаводки</td>"
                    "<td align=center>Код<br>назначения<br>платежа</td>"
                    "<td align=center>Номер<br>документа</td>"
                    "<td align=center>Статус</td>"
                    "<td align=center>Сумма<br>продажи</td>" 
                    "<td align=center>Ном.проводки(рек)</td>" 
                    "<td align=center>Дата реконвертации</td>" 
                    "<td align=center>Ном.документа<br>реконвертации</td>" 
                  "</tr></table>" skip.
for each curctrl no-lock break by curctrl.jdt by curctrl.sts .

put stream m-out1 unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
               "<tr align=""right"">"
                 "<td>&nbsp;" string(curctrl.aaa, "x(10)") "</td>"
                 "<td>" curctrl.gl "</td>"
                 "<td>" curctrl.crc "</td>"
                 "<td>" replace(string(curctrl.pamt, ">>>>>>>>>>>9.99"),'.',',') " </td>"
                 "<td>" curctrl.jh "</td>"               
                 "<td>" string(curctrl.jdt, "99.99.9999") "</td>"               
                 "<td>" curctrl.kpn "</td>"
                 "<td>" curctrl.pdocnum format "x(10)" "</td>" 
                 "<td>" curctrl.sts "</td>"
                 "<td>" replace(string(curctrl.rpamt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
                 "<td>" curctrl.rpjh "</td>"               
                 "<td>" string(curctrl.rpjdt, "99.99.9999") "</td>"               
                 "<td>" curctrl.rpnumdoc format "x(10)" "</td>" 
               "</tr></table>" skip.  
END.
  put stream m-out1 unformatted "</body></html>" skip.
output stream m-out1 close.
hide message no-pause.
/*unix silent cptwin test64-2.html excel.exe.*/
unix silent value("rcp test64-2.html " + replace("ntmain:L:\\Users\\Departments\\DIT\\","\\","\\\\")).
/*run mail("andrey@elexnet.kz", "TEXAKABANK <abpk@elexnet.kz>", "Авоматическая продажа валюты", "", "1", "", "test64-1.html; test64-2.html").*/

if ERROR-STATUS:error then
return "0".
else return "1".

procedure verupd.
def input-output parameter v-sum  as deci.
def input parameter v-aaa  like aaa.aaa.
def input parameter v-sts  like curctrl.sts.
def input parameter v-jh   like curctrl.jh.
def input parameter v-pamt like curctrl.pamt.
def input parameter v-tr   as logi.
def output parameter p-sts like curctrl.sts.
def var v-jdt as date no-undo.
def var v-crgl like curctrl.gl no-undo.
def var v-crc  like curctrl.crc no-undo.
def var v-pdocnum like curctrl.pdocnum no-undo.
def var v-kpn like curctrl.kpn no-undo.

if v-sum <= 0 then return.
if v-sum >= v-pamt then do:              
   find curctrl where curctrl.aaa = v-aaa and curctrl.sts = v-sts
                  and curctrl.jh = v-jh and curctrl.pamt = v-pamt no-error.
   if not avail curctrl then return. 
   if v-tr then p-sts = 8.      
   else p-sts = 9.
   curctrl.sts = p-sts.
   curctrl.rpamt = v-pamt.
   v-sum = v-sum - v-pamt.
end. else do:              
   find curctrl where curctrl.aaa = v-aaa and curctrl.sts = v-sts
                  and curctrl.jh = v-jh and curctrl.pamt = v-pamt no-error.
   if not avail curctrl then return. 
   v-jdt = curctrl.jdt.
   v-crgl = curctrl.gl.
   v-crc = curctrl.crc.
   v-kpn = curctrl.kpn.
   v-pdocnum = curctrl.pdocnum.
   curctrl.rpamt = v-sum.
   if v-tr then p-sts = 8.      
   else p-sts = 9.
   curctrl.sts = p-sts.
   create curctrl.
          curctrl.aaa     = v-aaa.
          curctrl.sts     = v-sts.
          curctrl.pamt    = v-pamt - v-sum.
          curctrl.jdt     = v-jdt.
          curctrl.gl      = v-crgl.
          curctrl.crc     = v-crc.
          curctrl.jh      = v-jh.
          curctrl.pdocnum = v-pdocnum.                                   
          curctrl.kpn     = v-kpn.
          v-sum = v-sum - v-pamt.              
end.          

end procedure.
