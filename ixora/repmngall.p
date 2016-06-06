/* repmngall.p
 * MODULE
        Управленческая отчетность
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
        Пункт меню
 * AUTHOR
        10/06/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        29/06/2012 id01143 перекомпиляция из-за изменений в dates.i
*/

/*{mainhead.i}*/

def input param v-period as char.
def input param dt1 as date.
def input param dt2 as date.


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

def var v-dt as date no-undo.
def var i as integer.
def var v-result as char no-undo.
def var repname as char no-undo.
def var proc_name as char.

{dates.i}


v-dt = dt1.
i = 0.

if v-period = "month" then do:
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

    proc_name = "f-repmng1".
end.
else do:
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

    proc_name = "repmng1".
end.

{repmng.i}



{r-branch.i &proc = value(proc_name)}

def stream rep.


for each comm.txb no-lock:

    find first t-kritval where t-kritval.bank = comm.txb.bank no-lock no-error.
    if avail t-kritval then do:

      if v-period = "month" then repname = "rpt_fact_" + comm.txb.bank + "_" + replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".
      else repname = "rpt_" + comm.txb.bank + "_" + replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".htm".


        output stream rep to value(repname).

        put stream rep "<html><head><title>Управленческая отчетность</title>" skip
                       "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                       "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream rep unformatted
            "<b>" comm.txb.info "</b><BR><BR>" skip
            "<table border=1 cellpadding=0 cellspacing=0>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
            "<td width=700></td>" skip.

        for each t-period no-lock:
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

        /*unix silent value("cptwin rpt_" + comm.txb.bank + ".htm excel").*/



       /* unix silent value("cptwin " + repname + " excel").*/

         v-result = "".
         input through value ("mv " + repname + " /data/reports/uprav/" + repname ).
         repeat:
           import unformatted v-result.
         end.

         if v-result <> "" then do:
           message " Произошла ошибка при копировании отчета - " v-result.
         end.

    end.

end.

