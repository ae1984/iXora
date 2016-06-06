/* 700-H-kons.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        03/10/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        30.11.2012 Lyubov - добавлена проверка по счетам 1858,2858,1859,2859

*/


{mainhead.i}


def new shared var v-dt as date.
def new shared temp-table tgl
    field txb as char
    field des as char
    field tgl as int format ">>>>"
    field gl as int
    field tcrc as integer
    field tsum1 as dec format "->>>>>>>>>>>>>>9.99"
    field tsum2 as dec format "->>>>>>>>>>>>>>9.99"
    field totlev as int
    field totgl as int.

def temp-table wrk
    field gl as integer
    field des as char
    field crc as int.

def var r-type as char.
def var vs-sum as decimal format "->>>>>>>>>>>>>>9.99".
def var list-pos as int.
def var list-summ as decimal format "->>>>>>>>>>>>>>9.99" extent 17.
def var list-summ2 as decimal format "->>>>>>>>>>>>>>9.99" extent 17.
def var all-list-summ as decimal format "->>>>>>>>>>>>>>9.99".
def var all-list-summ2 as decimal format "->>>>>>>>>>>>>>9.99".
def var Activ as decimal format "->>>>>>>>>>>>>>9.99" extent 17.
def var Obyaz as decimal format "->>>>>>>>>>>>>>9.99" extent 17.
def var Kapital as decimal format "->>>>>>>>>>>>>>9.99" extent 17.
def var Doxod as decimal format "->>>>>>>>>>>>>>9.99" extent 17.
def var Rashod as decimal format "->>>>>>>>>>>>>>9.99" extent 17.

def var RepName as char.
def var RepPath as char init "/data/reports/700h/".

/************************************************************************************************/
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
/************************************************************************************************/
function GetNormSumm returns char (input summ as decimal  ):
    def var ss1 as deci.
    def var ret as char.

    if summ >= 0 then ss1 = summ.
    else ss1 = - summ.
    case r-type:
        when "В тенге" then
            do:
                ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
            end.
        when "В тиынах" then
            do:
                ret = string(ss1 * 100,"->>>>>>>>>>>>>>>>>>9").
            end.
        when "В тыс.тенге" then
            do:
               /* ret = string(ss1 / 1000,"->>>>>>>>>>>>>>>>9.99").*/
                ret = string(round(ss1 / 1000,0)).
            end.
    end case.

    if summ < 0 then ret = "-" + ret.
    return trim(replace(ret,".",",")).
end function.
/************************************************************************************************/
function GetBalTxb returns deci (input v-txb as char, input v-gl as int).
    def var sum as decimal format "->>>>>>>>>>>>>>9.99" init 0.
    def buffer b-tgl for tgl.
    if v-txb = "" then
    do:
        for each b-tgl where b-tgl.gl = v-gl no-lock:
            sum = sum + b-tgl.tsum2.
        end.
    end.
    else
    do:
        for each b-tgl where b-tgl.txb = v-txb and b-tgl.gl = v-gl no-lock:
            sum = sum + b-tgl.tsum2.
        end.
    end.
    return sum.
end function.
/************************************************************************************************/
function GetBalTxb4 returns deci (input v-txb as char, input v-gl as int).
    def var sum as decimal format "->>>>>>>>>>>>>>9.99" init 0.
    def buffer b-tgl for tgl.
    if v-txb = "" then
    do:
        for each b-tgl where b-tgl.tgl = v-gl no-lock:
            sum = sum + b-tgl.tsum2.
        end.
    end.
    else
    do:
        for each b-tgl where b-tgl.txb = v-txb and b-tgl.tgl = v-gl no-lock:
            sum = sum + b-tgl.tsum2.
        end.
    end.
    return sum.
end function.
/************************************************************************************************/
function GetDate returns char ( input dt as date):
    return replace(string(dt,"99/99/9999"),"/",".").
end function.
/************************************************************************************************/
function Get700h_Head returns char (input glno as int).
  find first comm.rep_caption where comm.rep_caption.gl = glno and comm.rep_caption.rep = "700h" no-lock no-error.
  if avail comm.rep_caption then return comm.rep_caption.des.
  else return "".
end function.
/*****************************************************************************************************/


find last bank.cls.
v-dt = bank.cls.whn.


update v-dt label 'Введите отчетную дату'
    validate((v-dt < g-today ),
    'Отчетная дата должна быть меньше даты текущего ОД')
    with row 8 centered  side-label frame opt.
hide frame opt.

RepName = "700h_" + replace(string(v-dt,"99/99/9999"),"/","-") + ".rep".

if not FileExist(RepPath + RepName) then do:
 run create700h.
end.

run sel1("Отчет за " + GetDate(v-dt) , "В тенге|В тиынах|В тыс.тенге").
r-type = return-value.
if r-type = "" then return.

display '   Ждите...   '  with row 5 frame ww centered .

run ImportData.



for each tgl break by substr(trim(string(tgl.gl)),1,4) :
    if first-of(substr(trim(string(tgl.gl)),1,4) ) then
    do:
        if LOOKUP(string(tgl.tgl),"1351,1352,2151,2152,1858,1859,2858,2859") = 0 then
        do:
            create wrk.
            wrk.gl = tgl.tgl.
            wrk.des = Get700h_Head(integer(tgl.tgl /*substr(trim(string(tgl.gl)),1,4)*/ )).
            if wrk.des = "" then wrk.des = tgl.des.
            wrk.crc = tgl.tcrc.
        end.
    end.
end.

display "      700-H...    " no-label format "x(20)"  with row 8 frame ww1 centered title "Формирование отчета".
def stream rep_br.
/*******************************************************************************************************************/
output stream rep_br to value("700-H.htm").
put stream rep_br "<html><head><title>Отчет об остатках на балансовых и внебалансовых счетах банков второго уровня АО ""Метрокомбанк"" за " GetDate(v-dt) "</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep_br unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.

put stream rep_br unformatted "<tr><td>&nbsp;</td>".
put stream rep_br unformatted "<td style=""font:bold"">Отчет об остатках на балансовых и внебалансовых счетах банков второго уровня АО ""Метрокомбанк"" за " GetDate(v-dt) " " LC(r-type) "</td>".
put stream rep_br unformatted "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>".
put stream rep_br unformatted "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>".
put stream rep_br unformatted "<td>&nbsp;</td><td>&nbsp;</td></tr>".

put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
put stream rep_br unformatted "<td style=""font:bold"">Счет</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Наименование</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Свод</td>" skip.


for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
    put stream rep_br unformatted "<td style=""font:bold"">" comm.txb.name "</td>" skip.
end. /*for each comm.txb*/
put stream rep_br unformatted "</tr>" skip.



for each wrk break by substr(trim(string(wrk.gl)),1,1)
    by substr(trim(string(wrk.gl)),1,2)
    by substr(trim(string(wrk.gl)),1,3) :

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>" substr(string(wrk.gl), 1, 4) "</td>" skip.
    put stream rep_br unformatted "<td>" wrk.des "</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",wrk.gl)) "</td>" skip.


    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,wrk.gl).
        list-summ[comm.txb.txb + 1 ] = list-summ[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.

    put stream rep_br unformatted "</tr>" skip.

    if last-of(substr(trim(string(wrk.gl)),1,1)) then
    do:
        put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
        if substr(trim(string(wrk.gl)),1,1) eq "1" then
        do:
            put stream rep_br unformatted "<td>1</td><td style=""font:bold"">АКТИВЫ</td>" skip.
            list-pos = 1.
            do while list-pos <= 17:
                Activ[list-pos] = list-summ[list-pos].
                list-pos = list-pos + 1.
            end.
        end.
        else if substr(trim(string(wrk.gl)),1,1) eq "2" then
            do:
                put stream rep_br unformatted "<td>2</td><td style=""font:bold"">ОБЯЗАТЕЛЬСТВА</td>" skip.
                list-pos = 1.
                do while list-pos <= 17:
                    Obyaz[list-pos] = list-summ[list-pos].
                    list-pos = list-pos + 1.
                end.
            end.
            else if substr(trim(string(wrk.gl)),1,1) eq "3" then
                do:
                    put stream rep_br unformatted "<td>3</td><td style=""font:bold"">СОБСТВЕННЫЙ КАПИТАЛ</td>" skip.
                    list-pos = 1.
                    do while list-pos <= 17:
                        Kapital[list-pos] = list-summ[list-pos].
                        list-pos = list-pos + 1.
                    end.
                end.
                else if substr(trim(string(wrk.gl)),1,1) eq "4" then
                    do:
                        put stream rep_br unformatted "<td>4</td><td style=""font:bold"">ДОХОДЫ</td>" skip.
                        list-pos = 1.
                        do while list-pos <= 17:
                            Doxod[list-pos] = list-summ[list-pos].
                            list-pos = list-pos + 1.
                        end.
                    end.
                    else if substr(trim(string(wrk.gl)),1,1) eq "5" then
                        do:
                            put stream rep_br unformatted "<td>5</td><td style=""font:bold"">РАСХОДЫ</td>" skip.
                            list-pos = 1.
                            do while list-pos <= 17:
                                Rashod[list-pos] = list-summ[list-pos].
                                list-pos = list-pos + 1.
                            end.
                        end.
                        else if substr(trim(string(wrk.gl)),1,1) eq "6" then
                            do:
                                put stream rep_br unformatted "<td>6</td><td style=""font:bold"">УСЛОВНЫЕ И ВОЗМОЖНЫЕ ТРЕБОВАНИЯ И ОБЯЗАТЕЛЬСТВА</td>" skip.
                            end.
                            else if substr(trim(string(wrk.gl)),1,1) eq "7" then
                                do:
                                    put stream rep_br unformatted "<td>7</td><td style=""font:bold"">СЧЕТА МЕМОРАНДУМА К БАЛАНСУ</td>" skip.
                                end.

        list-pos = 1.
        do while list-pos <= 17:
            all-list-summ = all-list-summ + list-summ[list-pos].
            list-pos = list-pos + 1.
        end.
        put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(all-list-summ) "</td>" skip.


        list-pos = 1.
        do while list-pos <= 17:
            put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(list-summ[list-pos]) "</td>" skip.
            list-pos = list-pos + 1.
        end.
        list-pos = 1.
        do while list-pos <= 17:
            list-summ[list-pos] = 0.
            list-pos = list-pos + 1.
        end.
        all-list-summ = 0.
        put stream rep_br unformatted "</tr>" skip.
    end. /*if last-of*/

end. /*for each wrk*/


put stream rep_br unformatted "</table></body></html>" skip.
output stream rep_br close.
/*******************************************************************************************************************/

input through cptwin value("700-H.htm") excel.

/*******************************************************************************************************************/


/* формирование отчета CHECK*/

    output stream rep_br to value("700-check.htm").
    put stream rep_br "<html><head><title>CHECK за " GetDate(v-dt) "</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream rep_br unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.

    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td style=""font:bold"">&nbsp;</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Свод</td>" skip.

    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        put stream rep_br unformatted "<td style=""font:bold"">" comm.txb.name "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

   /* Start Проверка 1858 - 2859 */
    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>1858</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",1858)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,1858).
        list-summ[comm.txb.txb + 1 ] = list-summ[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>2859</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",2859)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,2859).
        list-summ2[comm.txb.txb + 1 ] = list-summ2[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    all-list-summ = 0.
    all-list-summ2 = 0.
    do while list-pos <= 17:
      all-list-summ = all-list-summ + list-summ[list-pos].
      list-pos = list-pos + 1.
    end.
    list-pos = 1.
    do while list-pos <= 17:
      all-list-summ2 = all-list-summ2 + list-summ2[list-pos].
      list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td>Проверка</td><td style=""font:bold"">" GetNormSumm(all-list-summ - all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(list-summ[list-pos] - list-summ2[list-pos] ) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       list-summ[list-pos] = 0.
       list-summ2[list-pos] = 0.
       list-pos = list-pos + 1.
    end.
    all-list-summ = 0.
    all-list-summ2 = 0.
    /* End Проверка 1858 - 2859 */

    /* Start Проверка 1859 - 2858 */
    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>1859</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",1859)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,1859).
        list-summ[comm.txb.txb + 1 ] = list-summ[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>2858</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",2858)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,2858).
        list-summ2[comm.txb.txb + 1 ] = list-summ2[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    all-list-summ = 0.
    all-list-summ2 = 0.
    do while list-pos <= 17:
      all-list-summ = all-list-summ + list-summ[list-pos].
      list-pos = list-pos + 1.
    end.
    list-pos = 1.
    do while list-pos <= 17:
      all-list-summ2 = all-list-summ2 + list-summ2[list-pos].
      list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td>Проверка</td><td style=""font:bold"">" GetNormSumm(all-list-summ - all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(list-summ[list-pos] - list-summ2[list-pos] ) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       list-summ[list-pos] = 0.
       list-summ2[list-pos] = 0.
       list-pos = list-pos + 1.
    end.
    all-list-summ = 0.
    all-list-summ2 = 0.
    /* End Проверка 1859 - 2858 */



   /* Start Проверка 1351 - 2152 */
    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>1351</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",1351)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,1351).
        list-summ[comm.txb.txb + 1 ] = list-summ[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>2152</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",2152)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,2152).
        list-summ2[comm.txb.txb + 1 ] = list-summ2[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    all-list-summ = 0.
    all-list-summ2 = 0.
    do while list-pos <= 17:
      all-list-summ = all-list-summ + list-summ[list-pos].
      list-pos = list-pos + 1.
    end.
    list-pos = 1.
    do while list-pos <= 17:
      all-list-summ2 = all-list-summ2 + list-summ2[list-pos].
      list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td>Проверка</td><td style=""font:bold"">" GetNormSumm(all-list-summ - all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(list-summ[list-pos] - list-summ2[list-pos] ) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       list-summ[list-pos] = 0.
       list-summ2[list-pos] = 0.
       list-pos = list-pos + 1.
    end.
    all-list-summ = 0.
    all-list-summ2 = 0.
    /* End Проверка 1351 - 2152 */

    /* Start Проверка 1352 - 2151 */
    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>1352</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",1352)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,1352).
        list-summ[comm.txb.txb + 1 ] = list-summ[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>2151</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(GetBalTxb4("",2151)) "</td>" skip.
    for each comm.txb  where comm.txb.consolid no-lock by comm.txb.txb:
        vs-sum = GetBalTxb4(comm.txb.bank,2151).
        list-summ2[comm.txb.txb + 1 ] = list-summ2[comm.txb.txb + 1 ] + vs-sum.
        put stream rep_br unformatted "<td>" GetNormSumm(vs-sum) "</td>" skip.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    all-list-summ = 0.
    all-list-summ2 = 0.
    do while list-pos <= 17:
      all-list-summ = all-list-summ + list-summ[list-pos].
      list-pos = list-pos + 1.
    end.
    list-pos = 1.
    do while list-pos <= 17:
      all-list-summ2 = all-list-summ2 + list-summ2[list-pos].
      list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td>Проверка</td><td style=""font:bold"">" GetNormSumm(all-list-summ - all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(list-summ[list-pos] - list-summ2[list-pos] ) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       list-summ[list-pos] = 0.
       list-summ2[list-pos] = 0.
       list-pos = list-pos + 1.
    end.
    all-list-summ = 0.
    all-list-summ2 = 0.
    /* End Проверка 1351 - 2152 */

    /* Start Проверка Активы - (обязательства+собственный капитал)*/
    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>Активы</td>" skip.
    list-pos = 1.
    do while list-pos <= 17:
       all-list-summ = all-list-summ + Activ[list-pos].
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<td>" GetNormSumm(all-list-summ) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td>" GetNormSumm(Activ[list-pos]) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>Обязательства + Собственный капитал</td>" skip.
    list-pos = 1.
    do while list-pos <= 17:
       all-list-summ2 = all-list-summ2 + ( Obyaz[list-pos] + Kapital[list-pos] ).
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<td>" GetNormSumm(all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td>" GetNormSumm(Obyaz[list-pos] + Kapital[list-pos]) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td>Проверка</td><td style=""font:bold"">" GetNormSumm(all-list-summ - all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(Activ[list-pos] - ( Obyaz[list-pos] + Kapital[list-pos] ) ) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.
    all-list-summ = 0.
    all-list-summ2 = 0.
   /* End Проверка Активы - (обязательства+собственный капитал)*/


   /* Start Проверка Доходы - Расходы*/
    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>Доходы</td>" skip.
    list-pos = 1.
    do while list-pos <= 17:
       all-list-summ = all-list-summ + Doxod[list-pos].
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<td>" GetNormSumm(all-list-summ) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td>" GetNormSumm(Doxod[list-pos]) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>Расходы</td>" skip.
    list-pos = 1.
    do while list-pos <= 17:
       all-list-summ2 = all-list-summ2 + ( Rashod[list-pos] ).
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "<td>" GetNormSumm(all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td>" GetNormSumm(Rashod[list-pos]) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.

    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td>Проверка</td><td style=""font:bold"">" GetNormSumm(all-list-summ - all-list-summ2) "</td>" skip.

    list-pos = 1.
    do while list-pos <= 17:
       put stream rep_br unformatted "<td style=""font:bold"">" GetNormSumm(Doxod[list-pos] - Rashod[list-pos]  ) "</td>" skip.
       list-pos = list-pos + 1.
    end.
    put stream rep_br unformatted "</tr>" skip.
    all-list-summ = 0.
    all-list-summ2 = 0.
   /* End Проверка Доходы - Расходы*/


put stream rep_br unformatted "</table></body></html>" skip.
output stream rep_br close.
hide frame ww1 no-pause.
/*******************************************************************************************************************/

input through cptwin value("700-check.htm") excel.

/*******************************************************************************************************************/

/***************************************************************************************************************/
procedure ImportData:
  empty temp-table tgl.
  INPUT FROM value(RepPath + RepName) NO-ECHO.
  LOOP:
  REPEAT TRANSACTION:
   REPEAT ON ENDKEY UNDO, LEAVE LOOP:
   CREATE tgl.
   IMPORT
    tgl.txb
    tgl.gl
    tgl.tgl
    tgl.des
    tgl.tcrc
    tgl.tsum1
    tgl.tsum2
    tgl.totlev
    tgl.totgl.
   END. /*REPEAT*/
  END. /*TRANSACTION*/
  input close.
end procedure.
/***************************************************************************************************************/



