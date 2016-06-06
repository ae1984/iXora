/* fs_rv.p
 * MODULE
        Название модуля - Внутрибанковские операции
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.2.13
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{mainhead.i}
{nbankBik.i}
def var v-date   as date.
def var v-case   as char format "x(13)" view-as combo-box list-items "В тыс. тенге","В тенге, тиынах".
def var v-balacc as char init "1052,1251,1252,1253,1254,1255,1256,1257,1264".
def var v-file   as char init "FSRV.htm".
def var v-file2  as char init "ERROR.htm".
def var i        as inte.
def var v-rate   as deci.
def var v-temp   as logi init no.
def var d_sum    as deci.
def var v-stn    as char.
def var v-name   as char.
def var v-sum    as deci.
def var v-frbno  as char.
def var k        as inte.
def var v-sel    as inte.

def stream rep.
output stream rep to value(v-file).

def stream m-err.
output stream m-err to value(v-file2).

def temp-table t-kor
field gl like gl.gl
index kor is unique gl.

def workfile wf
    field wfun  like fun.fun
    field wdfb  like dfb.dfb
    field wname like bankl.bank
    field wsum  as deci format "z,zzz,zzz,zz9.99-"
    field wkod  as char
    field wcrc  like crc.crc.

v-date = g-today.

form
    v-date label "Укажите дату отчета" format "99/99/9999" validate (v-date <= g-today, "Дата не может быть больше текущей !!!") skip
with side-labels row 5 centered title "Введите параметры отчета" frame fs_rv.

update v-date with frame fs_rv.
displ  v-date with frame fs_rv.

run sel ("Выберите тип отчета", "1. В тыс. тенге |" + " 2. В тенге ").
case return-value:
    when "1" then v-sel = 1.
    when "2" then v-sel = 2.
end.

do i = 1 to num-entries(v-balacc):
    find first t-kor where t-kor.gl = integer(trim(entry(i,v-balacc))) no-lock no-error.
    if not avail t-kor then do:
        create t-kor.
        assign
        t-kor.gl = integer(trim(entry(i,v-balacc))).
    end.
end.

for each t-kor no-lock:
    for each fun where trim(string(fun.gl)) begins trim(string(t-kor.gl)) no-lock:
        assign v-name = "" v-rate = 0 d_sum = 0.
        find last histrxbal where  histrxbal.sub = 'fun' and histrxbal.acc = fun.fun and histrxbal.lev = 1 and histrxbal.dt <= v-date
        no-lock no-error.
        if avail histrxbal and histrxbal.dam ne histrxbal.cam then do:
            find first bankl where bankl.bank = fun.bank  no-lock no-error .
            if not available bankl then do:
                v-temp = yes.
                put stream m-err " Для " fun.fun " нет описания банка " skip.
                v-name = "".
                v-frbno = "".
            end.
            else do:
                v-name = bankl.name.
                v-frbno = bankl.frbno.
            end.
            find last crchis where crchis.crc = fun.crc and crchis.rdt <= v-date no-lock no-error.
            if not available crchis then do:
               v-temp = yes.
               put stream m-err " Для " fun.fun " нет описания валюты " skip.
            end.
            else v-rate = crchis.rate[1] / crchis.rate[9].

            d_sum = histrxbal.dam - histrxbal.cam.
            if d_sum <> 0 then do:
               find first wf where wf.wfun eq fun.fun and wf.wcrc eq fun.crc no-lock no-error.
               if not available wf then do:
                   create wf.
                   assign
                   wf.wfun  = fun.fun
                   wf.wname = v-name
                   wf.wkod  = v-frbno
                   wf.wcrc  = fun.crc.
               end.
               if fun.crc eq 1 then wf.wsum = wf.wsum + d_sum .
               else wf.wsum = wf.wsum + d_sum * v-rate.
            end.
        end.
    end.
    for each dfb where trim(string(dfb.gl)) begins trim(string(t-kor.gl)) no-lock:
        assign v-name = "" v-rate = 0 d_sum = 0.
        find last hisdfb where  hisdfb.dfb = dfb.dfb and hisdfb.fdt <= v-date use-index hisdfb no-lock no-error.
        if avail hisdfb and hisdfb.dam[1] ne hisdfb.cam[1] then do:
            find bankl where bankl.bank = dfb.bank no-lock no-error.
            if not available bankl then do:
                v-temp = yes.
                put stream m-err " Для " dfb.dfb " нет описания банка " skip.
                v-name = "".
                v-frbno = "".
            end.
            else do:
                v-name = bankl.name.
                v-frbno = bankl.frbno.
            end.
            find last crchis where crchis.crc = dfb.crc and crchis.rdt <= v-date no-lock no-error.
            if not available crchis then do:
                v-temp = yes.
                put stream m-err " Для " dfb.dfb " нет описания валюты " skip.
            end.
            else v-rate = crchis.rate[1] / crchis.rate[9].

            d_sum = hisdfb.dam[1] - hisdfb.cam[1].
            if d_sum <> 0 then do:
                find first wf where wf.wdfb eq dfb.dfb and wf.wcrc eq dfb.crc no-lock no-error.
                if not available wf then do:
                    create wf.
                    assign
                    wf.wdfb  = dfb.dfb
                    wf.wname = v-name
                    wf.wkod  = v-frbno
                    wf.wcrc  = dfb.crc.
                end.
                if dfb.crc eq 1 then wf.wsum = wf.wsum + d_sum .
                else wf.wsum = wf.wsum + d_sum * v-rate.
            end.
        end.
    end.
end.

output stream m-err close.

if v-temp then unix silent cptwin value(v-file2) winword.

{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put stream rep unformatted
    "<TABLE>" skip
    "<TR>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD><FONT size=2><B>Приложение 17 <br> к Правилам представления отчетности банками <br> второго уровня
    Республики Казахстан</B></FONT></TD>" skip
    "</TR>" skip
    "</TABLE>" skip
    "<P align=""center""><FONT size=2><B>Расшифровка вкладов и корреспондентских счетов, размещенных в других банках <br> " + v-nbankru +
    " (наименование банка) по состоянию на " string(v-date, "99-99-9999") "</B></FONT></P>" skip
    "<TABLE>" skip
    "<TR>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</TR>" skip
    "<TR>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD></TD>" skip
    "<TD align=""center""><FONT size=2>(в тысячах тенге)</FONT></TD>" skip
    "</TR>" skip.

put stream rep unformatted
   "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR>" "</TR>" skip
    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
    "<td><FONT size=2>N</FONT></td>" skip
    "<td><FONT size=2>Наименование банка, в котором размещены вклады</FONT></td>" skip
    "<td><FONT size=2>Сумма вкладов (в тыс.тенге)</FONT></td>" skip
    "<td><FONT size=2>Страна резидентства</FONT></td>" skip
    /*"<td>Для проверки</td>" skip*/
    "</TR>" skip
    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
    "<td></td>" skip
    "<td><FONT size=2>1</FONT></td>" skip
    "<td><FONT size=2>2</FONT></td>" skip
    "<td><FONT size=2>3</FONT></td>" skip
    /*"<td><FONT size=2>4</FONT></td>" skip*/ /*Для проверки*/
    "</TR>" skip.

assign k = 0  v-sum = 0.
for each wf where wf.wsum <> 0 no-lock:
    k = k + 1.
    if v-sel = 1 then do:
        put stream rep unformatted
            "<tr>" skip
            "<td><FONT size=2> " k format "zz9" "</FONT></td> " skip
            "<td align=""left""><FONT size=2>" wf.wname format "x(60)" "</FONT></td>" skip
            "<td align=""center""><FONT size=2>" replace(trim(string(round(wf.wsum / 1000, 0), "->>>>>>>>>>>9.99")),".",",") "</FONT></td>" skip.
        find first codfr where codfr.codfr = "iso3166" and codfr.code = trim(wf.wkod) no-lock no-error.
        if avail codfr then do:
            put stream rep unformatted
                "<td align=""center""><FONT size=2>" trim(codfr.name[1]) "</FONT></td>" skip.
        end.
        else do:
            put stream rep unformatted
                "<td align=""center""><FONT size=2>" trim(wf.wkod) "</FONT></td>" skip.
        end.
        /*if wf.wfun <> "" then do:
            put stream rep unformatted
                "<td>" wf.wfun "</td>" skip.
        end.
        else do:
            put stream rep unformatted
                "<td>" wf.wdfb "</td>" skip.
        end.*/ /*Для проверки*/
        v-sum = v-sum + round(wf.wsum / 1000, 0).
    end.
    else do:
        put stream rep unformatted
            "<tr>" skip
            "<td><FONT size=2> " k format "zz9" "</FONT></td> " skip
            "<td align=""left""><FONT size=2>" wf.wname format "x(38)" "</FONT></td>" skip
            "<td align=""center""><FONT size=2>" replace(trim(string(wf.wsum, "->>>>>>>>>>>9.999")),".",",") "</FONT></td>" skip.
        find first codfr where codfr.codfr = "iso3166" and codfr.code = trim(wf.wkod) no-lock no-error.
        if avail codfr then do:
            put stream rep unformatted
                "<td align=""center""><FONT size=2>" trim(codfr.name[1]) "</FONT></td>" skip.
        end.
        else do:
            put stream rep unformatted
                "<td align=""center""><FONT size=2>" trim(wf.wkod) "</FONT></td>" skip.
        end.
        /*if wf.wfun <> "" then do:
            put stream rep unformatted
                "<td>" wf.wfun "</td>" skip.
        end.
        else do:
            put stream rep unformatted
                "<td>" wf.wdfb "</td>" skip.
        end.*/ /*Для проверки*/
        v-sum = v-sum + wf.wsum.
    end.
end.
put stream rep unformatted
    "<tr>" skip
    "<td colspan=2><FONT size=2>Итого:</FONT></td> " skip
    "<td align=""center""><FONT size=2>" v-sum "</FONT></td> " skip
    "<td></td>" skip
    "</tr>" skip.

put stream rep unformatted
    "</table>" skip.

output stream rep close.
unix silent cptwin value(v-file) excel.

