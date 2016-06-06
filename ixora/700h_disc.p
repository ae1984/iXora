/* 700h_disc.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        --/--/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
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


def var r-type as char.
def var vs-sum as deci.
def var list-pos as int.
def var list-summ as deci extent 17.
def var all-list-summ as deci.

def var RepName as char.
def var RepPath as char init "/data/reports/700h/".
/************************************************************************************************/
function GetCRC returns char (input currency as integer).
  def var code as char format "x(3)".
  def buffer b-crc for crc.
   find b-crc where b-crc.crc = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = "?".
  return code.
end function.
/************************************************************************************************/
function GetFilName returns char ( input txb_val as char ):
 def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
 def var ListBank as char format "x(25)" extent 17 init  ["ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау","Астана","Павлодар",
                                     "Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].
   if txb_val = "" then return "".
   return  ListBank[LOOKUP(txb_val , ListCod)].
end function.
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

find last bank.cls.
v-gldate = bank.cls.whn.


update v-gldate label 'Введите отчетную дату'
    validate((v-gldate < g-today ),
    'Отчетная дата должна быть меньше даты текущего ОД')
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


display "  700-H disclosure " no-label format "x(20)"  with row 8 frame ww2 centered title "Формирование отчета".
def stream rep_br.
/*******************************************************************************************************************/
output stream rep_br to value("700H_disc.htm").
put stream rep_br "<html><head><title>Отчет об остатках на балансовых и внебалансовых счетах банков второго уровня АО ""Метрокомбанк"" за " GetDate(v-gldate) "</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep_br unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.


put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
put stream rep_br unformatted "<td colspan=""4"" style=""font:bold"">Счет</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Сумма</td>" skip.

put stream rep_br unformatted "<td style=""font:bold"">Гео Код</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Код валюты</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Наименование филиала</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">IBAN-20 значный счет</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Наименование счета</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Наименование счета по Главной книге</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Тип счета</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Тип суб счета</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Уровень</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Код</td>" skip.
put stream rep_br unformatted "<td style=""font:bold"">Группа</td>" skip.
put stream rep_br unformatted "</tr>" skip.


for each tgl break by substr(trim(string(tgl.gl7)),1,1)
    by substr(trim(string(tgl.gl7)),1,2)
    by substr(trim(string(tgl.gl7)),1,3)
    by substr(trim(string(tgl.gl7)),1,4)
        by substr(trim(string(tgl.gl7)),1,5)
            by substr(trim(string(tgl.gl7)),1,6):

    put stream rep_br unformatted "<tr>" skip.
    put stream rep_br unformatted "<td>" substr(string(tgl.gl7), 1, 4) "</td>" skip.
    put stream rep_br unformatted "<td>" substr(string(tgl.gl7), 5, 1) "</td>" skip.
    put stream rep_br unformatted "<td>" substr(string(tgl.gl7), 6, 1) "</td>" skip.
    put stream rep_br unformatted "<td>" substr(string(tgl.gl7), 7, 1)"</td>" skip.
    put stream rep_br unformatted "<td>" GetNormSumm(tgl.sum) "</td>" skip.
    put stream rep_br unformatted "<td>&nbsp;" tgl.geo format "999"  "</td>" skip.
    put stream rep_br unformatted "<td>" GetCRC(tgl.crc) "</td>" skip.
    put stream rep_br unformatted "<td>" GetFilName(tgl.txb) "</td>" skip.
    put stream rep_br unformatted "<td>&nbsp;" tgl.acc "</td>" skip.
    put stream rep_br unformatted "<td>" tgl.acc-des "</td>" skip.
    put stream rep_br unformatted "<td>" tgl.gl-des "</td>" skip.
    put stream rep_br unformatted "<td>" CAPS(tgl.type) "</td>" skip.
    put stream rep_br unformatted "<td>" CAPS(tgl.sub-type) "</td>" skip.
    put stream rep_br unformatted "<td>&nbsp;" tgl.level format "99" "</td>" skip.
    put stream rep_br unformatted "<td>" CAPS(tgl.code) "</td>" skip.
    put stream rep_br unformatted "<td>&nbsp;" tgl.grp format "99" "</td>" skip.

    put stream rep_br unformatted "</tr>" skip.


 end. /* for each tgl*/



put stream rep_br unformatted "</table></body></html>" skip.
output stream rep_br close.
hide frame ww no-pause.
hide frame ww2 no-pause.
/*******************************************************************************************************************/

input through cptwin value("700H_disc.htm") excel.

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



