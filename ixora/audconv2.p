
/* audconv2.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по счетам сейфовых ячеек.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * BASES
        TXB COMM
 * AUTHOR
        28/03/09 id00004
 * CHANGES
*/


def  shared var v-txbcode as char.
def  shared var v-dbeg as date.

def  buffer bsysc for txb.sysc.

if  v-txbcode <> "ALL" then do:
    find last bsysc where bsysc.sysc = "OURBNK" no-lock no-error.
    if bsysc.chval <> v-txbcode then return. 
end.

    find last bsysc where bsysc.sysc = "OURBNK" no-lock no-error.

find last txb.sysc where txb.sysc.sysc = "citi" no-lock no-error.


    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Конвертации по депозитам (" + if bsysc.chval = 'txb16' then 'Алматинский филиал)' else txb.sysc.chval + ")   </P>" skip
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>Транзакция</TD>" skip
        "<TD>С счета</TD>" skip
        "<TD>На счет</TD>" skip
        "<TD>Описание транзакции/Курс</TD>" skip
        "<TD>Филиал</TD>" skip
        "<TD>Дата проводки</TD>" skip
        "<TD>Время проводки</TD>" skip
        "<TD>ФИО Клиента</TD>" skip
        "<TD>ФИО Менеджера</TD>" skip
        "<TD>Логин менеджера</TD>" skip
        "</TR>" skip.



def buffer k1 for txb.jl .
def buffer kk for txb.jl .
for each txb.lgr where txb.lgr.led = "TDA" no-lock:
    for each txb.aaa where txb.aaa.lgr = txb.lgr.lgr no-lock:
/*        if length(txb.aaa.aaa) < 20 then next.          */

         for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and jl.jdt < v-dbeg  no-lock use-index acc :
             if txb.jl.dc <> "D" then do:
                if txb.jl.rem[1] begins "Зачисление на" then do:  


         find last k1 where k1.jh = txb.jl.jh and k1.ln = 1 no-lock.
         find last kk where kk.jh = txb.jl.jh and kk.ln = 4 no-lock no-error.

if not avail kk then next.

/*
if not avail kk then do:
   message txb.aaa.aaa txb.jl.jh .
   pause 4545.
end. */



       put unformatted "<TR align=""center"" style=""font-size:x-small;background:white "">" skip.

/*         displ txb.jl.jh k1.acc kk.acc txb.jl.rem[1] txb.sysc.chval. */
find last txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
find last txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
       put unformatted
           "<td>" txb.jl.jh format 'zzzzzzzzzz' "</td>" skip
           "<td>" k1.acc  "</td>" skip 
           "<td>" kk.acc   "</td>" skip
           "<td>" txb.jl.rem[1] "</td>" skip
           "<td>" txb.sysc.chval "</td>" skip
           "<td>" txb.jl.jdt "</td>" skip
           "<td>" string(txb.jh.tim,"hh:mm:ss") "</td>" skip
           "<td>" txb.cif.name "</td>" skip
           "<td>" txb.ofc.name "</td>" skip
           "<td>" txb.ofc.ofc "</td>" skip.
                  put unformatted "</tr>" .


                end.
             end.
         end.
    end.
end.




    put unformatted "</TABLE>" skip.
