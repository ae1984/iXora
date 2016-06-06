/* 700H_cp12.p
 * MODULE
        Название модуля - 8 Внутрибанковские операции
 * DESCRIPTION
        Описание - Сводный отчет "700Н-приложение новое"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.3.2
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        12.06.2012 damir - аналогично п.м. 8.8.3.12, просто вывод данных в другом виде. Старая программа п.м. 8.8.3.2 ( 700h.p ).
*/

{mainhead.i}

def new shared var v-gldate as date.

define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    index tgl-id1 is primary gl7 .

def temp-table wrk
    field gl as int
    field des as char
    field crc as int.


def var r-type as char.
def var vs-sum as deci.
def var list-pos as int.
def var list-summ as deci extent 17.
def var all-list-summ as deci.
def var v-bankname as char.

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
function GetNormSumm returns char (input summ as deci ):
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
    def var sum as deci init 0.
    def buffer b-tgl for tgl.
    if v-txb = "" then
    do:
        for each b-tgl where b-tgl.gl7 = v-gl no-lock:
            sum = sum + b-tgl.sum.
        end.
    end.
    else
    do:
        for each b-tgl where b-tgl.txb = v-txb and b-tgl.gl7 = v-gl no-lock:
            sum = sum + b-tgl.sum.
        end.
    end.
    return sum.
end function.
/************************************************************************************************/
function GetBalTxb4 returns deci (input v-txb as char, input v-gl as int).
    def var sum as deci init 0.
    def buffer b-tgl for tgl.
    if v-txb = "" then
    do:
        for each b-tgl where b-tgl.gl4 = v-gl no-lock:
            sum = sum + b-tgl.sum.
        end.
    end.
    else
    do:
        for each b-tgl where b-tgl.txb = v-txb and b-tgl.gl4 = v-gl no-lock:
            sum = sum + b-tgl.sum.
        end.
    end.
    return sum.
end function.
/************************************************************************************************/
function GetDate returns char ( input dt as date):
    return replace(string(dt,"99/99/9999"),"/",".").
end function.
/************************************************************************************************/
function Get700hPril_Head returns char (input glno as int).
    find first comm.rep_caption where comm.rep_caption.gl = glno and comm.rep_caption.rep = "700h_pril" no-lock no-error.
    if avail comm.rep_caption then return comm.rep_caption.des.
    else return "".
end function.
/*****************************************************************************************************/

find last bank.cls.
v-gldate = bank.cls.whn.


update v-gldate label 'Введите отчетную дату' validate((v-gldate < g-today ), 'Отчетная дата должна быть меньше даты текущего ОД')
with row 8 centered  side-label frame opt.
hide frame opt.

RepName = "pril700_" + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
    run create700pril.
end.

run sel1("Отчет за " + GetDate(v-gldate) , "В тенге|В тиынах|В тыс.тенге").
r-type = return-value.
if r-type = "" then return.


display '   Ждите...   '  with row 5 frame ww centered .


run ImportData.

for each tgl break by tgl.gl7:
    if first-of(tgl.gl7) then
    do:
        if LOOKUP(substr(trim(string(tgl.gl)),1,4),"1351,1352,2151,2152,1858,1859,2858,2859") = 0 then
        do:
            create wrk.
            wrk.gl = tgl.gl7.
            wrk.des = Get700hPril_Head(tgl.gl7).
            if wrk.des = "" then wrk.des = tgl.gl-des.
            wrk.crc = tgl.crc.
        end.
    end.
end.

find first sysc where sysc.sysc = "bankname" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.
else v-bankname = "".

display "  Ждите ...  " no-label format "x(20)"  with row 8 frame ww2 centered title "Формирование отчета".

def stream rep_br.
output stream rep_br to value("700H_pril.htm").

/*******************************************************************************************************************/

{html-title.i
 &stream = " stream rep_br "
 &title = " "
 &size-add = "xx-"}

put stream rep_br unformatted
    "<b>АО&nbsp;" v-bankname " Приложение к форме ежедневного баланса банков второго уровня (700H) за " + string(v-gldate) + " (в тыс.тенге) </b>" skip.

put stream rep_br unformatted
    "<TABLE width=""45%"" border=""1"" cellspacing=""0"" cellpadding=""1"">" skip.

put stream rep_br unformatted
    "<TR>" skip
    "<TD><FONT size=""1""><p align=""center""><B>Счет ГК</B></p></FONT></TD>" skip
    "<TD><FONT size=""1""><p align=""center""><B>Сумма</B></p></FONT></TD>" skip
    "</TR>" skip.

for each wrk no-lock break by substr(trim(string(wrk.gl)),1,1)
by substr(trim(string(wrk.gl)),1,2)
by substr(trim(string(wrk.gl)),1,3)
by substr(trim(string(wrk.gl)),1,4)
by substr(trim(string(wrk.gl)),1,5)
by substr(trim(string(wrk.gl)),1,6):

    put stream rep_br unformatted
        "<TR valign=""top"" align=left>" skip
        "<TD>" string(wrk.gl) "</TD>" skip
        "<TD>" replace(string(GetNormSumm(GetBalTxb("",wrk.gl))),'.',',') "</TD>" skip
        "</TR>" skip.
end.

put stream rep_br unformatted
    "</TABLE>" skip.

{html-end.i " stream rep_br "}

output stream rep_br close.

/*******************************************************************************************************************/

input through cptwin value("700H_pril.htm") excel.

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
            tgl.gl4
            tgl.gl7
            tgl.gl-des
            tgl.crc
            tgl.sum
            tgl.type
            tgl.sub-type
            tgl.totlev
            tgl.totgl
            tgl.level
            tgl.code
            tgl.grp
            tgl.acc
            tgl.acc-des
            tgl.geo.
        END. /*REPEAT*/
    END. /*TRANSACTION*/
    input close.
end procedure.
/***************************************************************************************************************/