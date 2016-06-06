/* f-repmng_ho.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Управленческая отчетность
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.18
 * AUTHOR
        14/12/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        11/03/2011 k.gitalov расчет по факту, период месяц
        27/08/2011 k.gitalov перекомпиляция
        29/06/2012 id01143 перекомпиляция из-за изменений в dates.i
        13.08.2013 damir - Внедрено Т.З. № 1182,1258,1257,1650. Добавил расчет по CHF,AUD.
*/

{mainhead.i}

def new shared temp-table t-period no-undo
  field pid as integer
  field dtb as date
  field dte as date
  index idx is primary dtb.

def new shared temp-table t-krit no-undo
  field kid as integer
  field kcode as char
  field bold_code as log
  field color_code as log
  field des_en as char
  field des_ru as char
  field level as integer
  index idx is primary kid
  index idx2 kcode.

def new shared temp-table t-kritval no-undo
  field bank as char
  field kid as integer
  field pid as integer
  field sum as deci
  index idx is primary bank kid pid.

def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var v-dt as date no-undo.
def var i as integer.
def var v-result as char no-undo.
def var repname as char no-undo.


{dates.i}


if month(g-today) = 1 then dt1 = date( 12 , 1 , year(g-today) - 1 ).
else dt1 = date( month(g-today) - 1 , 1 , year(g-today) ).
dt2 = date( month(dt1) , DaysInMonth(dt1) , year(dt1) ).
displ dt1 label " С " format "99/99/9999" validate(day(dt1) = 1 and dt1 < g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate(LastDay(dt2) and dt2 < g-today and dt1 < dt2, "Некорректная дата!") skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.

v-dt = dt1.
i = 0.
repeat:
    if v-dt < dt2 then do:
        i = i + 1.
        create t-period.
               t-period.pid = i.
               t-period.dtb = v-dt.
               t-period.dte = v-dt + DaysInMonth(v-dt) - 1.
    end.
    else leave.
    v-dt = v-dt + DaysInMonth(v-dt).
end.


/*
dt2 = g-today - (weekday(g-today) - 1).
dt1 = dt2 - 6.

displ dt1 label " С " format "99/99/9999" validate(weekday(dt1) = 2 and dt1 < g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate(weekday(dt2) = 1 and dt2 < g-today and dt1 < dt2, "Некорректная дата!") skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.

v-dt = dt1.
i = 0.
repeat:
    if v-dt < dt2 then do:
        i = i + 1.
        create t-period.
        assign t-period.pid = i
               t-period.dtb = v-dt
               t-period.dte = v-dt + 6.
    end.
    else leave.
    v-dt = v-dt + 7.
end.
*/

{repmng_ho.i}

/* Сохранить значение для использования в других отчетах */

procedure setStoredKritVal.
    def input parameter p-bank as char no-undo.
    def input parameter p-kcode as char no-undo.
    def input parameter p-dtb as date no-undo.
    def input parameter p-sum as deci no-undo.
    do transaction:
        find first uprdata where uprdata.bank = p-bank and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb exclusive-lock no-error.
        if not avail uprdata then do:
            create uprdata.
            assign uprdata.bank = p-bank
                   uprdata.kcode = "fact_" + p-kcode
                   uprdata.dtb = p-dtb.
        end.
        uprdata.kvalue = p-sum.
        find current uprdata no-lock.
    end. /* transaction */
end procedure.

/* Получить сумму сохраненных ранее значений */
function getStoredKritVals returns deci (input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.
    for each uprdata where uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
     v-res = v-res + uprdata.kvalue.
    end.
    return v-res.
end function.


for each comm.txb where comm.txb.consolid no-lock:
 if connected ("txb") then disconnect "txb".
 connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
 run comexp_ho("month").
 run getgl_txb("month").
 run f-paycost.
 if connected ("txb") then disconnect "txb".
end.

/*определение стоимости платежей*/

def var tmp_count as int.
def var tmp_summ as deci.
for each t-period no-lock:

  tmp_count = getStoredKritVals("payCostKZT_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_KZT",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostKZT" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostKZT" , t-period.dtb , tmp_summ / tmp_count  ).

  tmp_count = getStoredKritVals("payCostRUB_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_RUB",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostRUB" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostRUB" , t-period.dtb , tmp_summ / tmp_count  ).


  tmp_count = getStoredKritVals("payCostUSD_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_USD",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostUSD" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostUSD" , t-period.dtb , tmp_summ / tmp_count  ).


  tmp_count = getStoredKritVals("payCostEUR_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_EUR",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostEUR" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostEUR" , t-period.dtb , tmp_summ / tmp_count  ).


  tmp_count = getStoredKritVals("payCostGBP_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_GBP",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostGBP" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostGBP" , t-period.dtb , tmp_summ / tmp_count  ).

  tmp_count = getStoredKritVals("payCostAUD_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_AUD",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostAUD" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostAUD" , t-period.dtb , tmp_summ / tmp_count  ).

  tmp_count = getStoredKritVals("payCostCHF_Count",t-period.dtb).
  tmp_summ  = getStoredKritVals("com_exp_CHF",t-period.dtb).
  if tmp_count = 0 then run setStoredKritVal( '' , "payCostCHF" , t-period.dtb , 0  ).
  else run setStoredKritVal( '' , "payCostCHF" , t-period.dtb , tmp_summ / tmp_count  ).


end.


/*Загрузка отчетов по филиалам*/
run repmngall("month",dt1,dt2).


find first comm.txb where comm.txb.bank = "txb00" and comm.txb.consolid no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
run f-repmng_ho1.
/*---------------------------------------------------------------------------------------------*/
def var s-ourbank as char.
if avail comm.txb then s-ourbank = comm.txb.bank.
function getKID returns integer (input p-kcode as char).
    find first t-krit where t-krit.kcode = p-kcode no-lock no-error.
    if avail t-krit then return t-krit.kid.
    else return 0.
end function.

function getStoredKritVal returns deci (input p-bank as char, input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.

   case p-bank:
       when "txb00" then do:
          find first uprdata where uprdata.bank = "txb00" and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock no-error.
          if avail uprdata then v-res = uprdata.kvalue.
       end.
       when "txb" then do:
          for each uprdata where uprdata.bank <> "txb00" and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
       when "all" then do:
          for each uprdata where uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
       OTHERWISE do:
          for each uprdata where uprdata.bank = p-bank and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock:
            v-res = v-res + uprdata.kvalue.
          end.
       end.
   end case.

   return v-res.
end function.

procedure setKritVal.
    def input parameter p-kcode as char no-undo.
    def input parameter p-pid as integer no-undo.
    def input parameter p-sum as deci no-undo.

    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-error.
        if not avail t-kritval then do:
            create t-kritval.
            assign t-kritval.bank = s-ourbank
                   t-kritval.kid = v-kid
                   t-kritval.pid = p-pid.
        end.
        t-kritval.sum = t-kritval.sum + p-sum.
    end.
end procedure.

for each t-period no-lock:
    run setKritVal("SO_Adjust_provision_account",t-period.pid, getStoredKritVal("txb","SO_Adjust_provision_account", t-period.dtb)  ).
end.
/*---------------------------------------------------------------------------------------------*/

def stream rep.

 repname = "rpt_fact_" + replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".
 output stream rep to value(repname).

/*output stream rep to rpt.htm.*/

put stream rep "<html><head><title>Управленческая отчетность факт - ЦО</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>" comm.txb.info "</b><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td width=700></td>" skip.

for each t-period no-lock:
   /* put stream rep unformatted "<td>" string(t-period.dtb,"99/99/9999") "</td>" skip.*/
    put stream rep unformatted "<td>" replace(string(t-period.dtb,"99/99/9999"),'/','.') "-" replace(string(t-period.dte,"99/99/9999"),'/','.') "</td>" skip.
end.

put stream rep unformatted "</tr>" skip.

for each t-krit no-lock:
    put stream rep unformatted "<tr>" skip.
    if t-krit.kcode = "-" then do:
      if t-krit.color_code then put stream rep unformatted "<td style=""font:bold"" bgcolor=""#C0C0C0"">" t-krit.des_en "</td>" skip.
      else put stream rep unformatted "<td style=""font:bold"">" t-krit.des_en "</td>" skip.
    end.
    else do:
        put stream rep unformatted "<td".
        if t-krit.bold_code  = yes then put stream rep unformatted " style=""font:bold"" ".
        if t-krit.color_code = yes then put stream rep unformatted " bgcolor=""#C0C0C0"" ".
        put stream rep unformatted ">" fill("&nbsp;&nbsp;&nbsp;&nbsp;",t-krit.level - 1) replace(trim(t-krit.des_en),' ',"&nbsp;") "</td>" skip.

        for each t-period no-lock:
            find first t-kritval where t-kritval.bank = comm.txb.bank and t-kritval.kid = t-krit.kid and t-kritval.pid = t-period.pid no-lock no-error.
            if avail t-kritval then put stream rep unformatted "<td>" replace(trim(string( t-kritval.sum / 1000 ,"->>>>>>>>>>>9.99")),'.',',') "</td>" skip.
            else put stream rep unformatted "<td></td>" skip.
        end.
    end.
    put stream rep unformatted "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.

/*unix silent cptwin rpt.htm excel.*/

unix silent value("cptwin " + repname + " excel").

         v-result = "".
         input through value ("mv " + repname + " /data/reports/uprav/" + repname ).
         repeat:
           import unformatted v-result.
         end.

         if v-result <> "" then do:
           message " Произошла ошибка при копировании отчета - " v-result.
         end.

