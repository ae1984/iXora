/* array-data.p
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
       09.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        09.04.2012 aigul - в соответсвиис прогой  700h_disc.p
        12.04.2012 aigul - вывод процентов
        04.05.2012 aigul - исправила вывод даты
        02/11/2012 Luiza - добавила вывод счета ГК и 7знаков балансового счета
        27.02.2013 damir - Внедрено Т.З. № 1607.
        24/04/2013 Luiza - ТЗ № 1587 добавление счетов 6 класса
*/


{mainhead.i}


def new shared var v-gldate as date.
def new shared var v-gl1 as int no-undo.
def new shared var v-gl2 as int no-undo.
def new shared var v-gl-cl as int no-undo.
def new shared var v-rate   as deci no-undo extent 3.
def var v-name as char no-undo extent 3.
def new shared var v-dat    as date no-undo.

def new shared  temp-table temp
     field txb       as character
     field filial    as   char
     field cif       as   char
     field cname      as   char
     field acc       as   char
     field opf       as   char
     field vidusl    as   char
     field ecdivis   as   char
     field rez       as   char
     field ins       as   char
     field ref       as   char
     field regdt     as   date
     field expdt     as   date
     field code      as   char
     field nps       as   char
     field npsbal    as   char
     field sumtreb   as   deci
     field sumtval   as   deci
     field sumzalog  as   deci
     field zalog     as   char
     field classif   as   char
     field bal1      as   deci
     field bal2      as   deci
     field bal3      as   deci
     field bal4      as   deci
     field naim      as   char
     field sumkom    as   deci .

def  temp-table temp1
     field txb       as character
     field filial    as   char
     field cif       as   char
     field cname      as   char
     field acc       as   char
     field opf       as   char
     field vidusl    as   char
     field ecdivis   as   char
     field rez       as   char
     field ins       as   char
     field ref       as   char
     field regdt     as   date
     field expdt     as   date
     field code      as   char
     field nps       as   char
     field npsbal    as   char
     field sumtreb   as   deci
     field sumtval   as   deci
     field sumzalog  as   deci
     field zalog     as   char
     field classif   as   char
     field bal1      as   deci
     field bal2      as   deci
     field bal3      as   deci
     field bal4      as   deci
     field naim      as   char
     field sumkom    as   deci .


define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
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
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .


def var r-type as char.
def var vs-sum as deci.
def var list-pos as int.
def var list-summ as deci extent 17.
def var all-list-summ as deci.

def var RepName as char.
def var RepPath as char init "/data/reports/array/".
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
    r-type = "В тенге".
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
    'Отчетная дата должна быть меньше даты текущего ОД') skip
     v-gl1 label "Счет ГК c" format "999999" skip
     v-gl2 label "Счет ГК по" format "999999" skip
     v-gl-cl label "Класс ГК" format "9" validate(int(substr(string(v-gl-cl),1,1)) < 4,'Допустимо вводить балансовые счета 1, 2, 3 класса')
    with row 8 centered  side-label frame opt.
hide frame opt.

RepName = "array" + string(v-gl1) + string(v-gl2) + string(v-gl-cl) + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
 run array-create.
end.

/*run sel1("Отчет за " + GetDate(v-gldate) , "В тенге|В тиынах|В тыс.тенге").
r-type = return-value.
if r-type = "" then return.*/


r-type = "В тенге".

display '   Ждите...   '  with row 5 frame ww centered .


run ImportData.

 display '   Ждите...   '  with row 5 frame ww centered .

 for each bank.crc where bank.crc.crc > 1 and bank.crc.crc <= 4 no-lock:
    find last bank.crchis where bank.crchis.crc = bank.crc.crc and bank.crchis.rdt < v-gldate + 1 no-lock no-error.
    if avail bank.crchis then assign v-rate[bank.crchis.crc - 1] =  bank.crchis.rate[1]
                                     v-name[bank.crchis.crc - 1] =  bank.crc.code.
 end.
v-dat = v-gldate + 1.
{r-branch.i &proc = "array_txbgar"}

for each temp no-lock.
    create temp1.
    buffer-copy temp to temp1.
end.
for each temp1.
    create temp.
      temp.txb       = temp1.txb.
      temp.filial    = temp1.filial.
      temp.cif       = temp1.cif.
      temp.cname     = temp1.cname.
      temp.acc       = temp1.acc.
      temp.opf       = temp1.opf.
      temp.vidusl    = temp1.vidusl.
      temp.ecdivis   = temp1.ecdivis.
      temp.rez       = temp1.rez.
      temp.ins       = temp1.ins.
      temp.ref       = temp1.ref.
      temp.regdt     = temp1.regdt.
      temp.expdt     = temp1.expdt.
      temp.code      = temp1.code.
      temp.nps       = temp1.nps.
      temp.npsbal    = substring(temp1.npsbal,1,1) + "0"  + substring(temp1.npsbal,3,5).
      temp.sumtreb   = temp1.sumtreb.
      temp.sumtval   = temp1.sumtval.
      temp.sumzalog  = temp1.sumzalog.
      temp.zalog     = temp1.zalog.
      temp.classif   = temp1.classif.
      temp.bal1      = temp1.bal1.
      temp.bal2      = temp1.bal2.
      temp.bal3      = temp1.bal2.
      temp.bal4      = temp1.bal4.
      temp.naim      = temp1.naim.
      temp.sumkom    = temp1.sumkom .
end.

display "  массив данных " no-label format "x(20)"  with row 8 frame ww2 centered title "Формирование отчета".
def stream rep_br.
def stream m-out.

/*******************************************************************************************************************/
output stream rep_br to array.htm.
    put stream rep_br unformatted "<html><head><title>FORTEBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


    put stream rep_br unformatted "<h3>Отчет об остатках на балансовых и внебалансовых счетах банков второго уровня АО ""ForteBank"" за " GetDate(v-gldate) "</h3>" skip.

    put stream rep_br unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.


    put stream rep_br unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Счет ГК</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Наимен счета ГК</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Балансовый счет</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Лицевой счет</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Наименование счета</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Остаток в тенге</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Остаток в валюте</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Код валюты</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">% ставка</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Дата открытия</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Дата закрытия</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Код продукта</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Код резидентства</td>" skip.
    /*
    put stream rep_br unformatted "<td style=""font:bold"">Код валюты</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Наименование филиала</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Лицевой счет</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Наименование счета</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Наименование счета по Главной книге</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Тип счета</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Тип суб счета</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Уровень</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Код</td>" skip.
    put stream rep_br unformatted "<td style=""font:bold"">Группа</td>" skip.*/
    put stream rep_br unformatted "</tr>" skip.


    for each tgl break by substr(trim(string(tgl.gl7)),1,1)
        by substr(trim(string(tgl.gl7)),1,2)
        by substr(trim(string(tgl.gl7)),1,3)
        by substr(trim(string(tgl.gl7)),1,4)
        by substr(trim(string(tgl.gl7)),1,5)
        by substr(trim(string(tgl.gl7)),1,6):
        if v-gl1 <> 0 and v-gl2 <> 0 then do:
            if not ( (substr(string(tgl.gl7),1,4) >= substr(string(v-gl1),1,4)
            and substr(string(tgl.gl7),1,4) <= substr(string(v-gl2),1,4)) or
            (tgl.gl7 >= v-gl1 and tgl.gl7 <= v-gl2) ) then next.
        end.

        if v-gl1 <> 0 and v-gl2 = 0 then do:
            if not ( (substr(string(tgl.gl7),1,4) = substr(string(v-gl1),1,4))
            or (tgl.gl7 = v-gl1) ) then next.
        end.
        if v-gl1 = 0 and v-gl2 <> 0 then do:
            if not ( (substr(string(tgl.gl7),1,4) = substr(string(v-gl2),1,4))
            or (tgl.gl7 = v-gl2) ) then next.
        end.
        if v-gl-cl <> 0 then do:
            if not ( substr(string(tgl.gl7),1,1) = string(v-gl-cl) )then next.
        end.
        put stream rep_br unformatted "<tr>" skip.
        put stream rep_br unformatted "<td>" string(tgl.gl) "</td>" skip.
        put stream rep_br unformatted "<td height='20' width='150'>" tgl.gl-des "</td>" skip.
        put stream rep_br unformatted "<td>" /*substr(string(tgl.gl7), 1, 6) */ string(tgl.gl7) "</td>" skip.
         put stream rep_br unformatted "<td>&nbsp;" tgl.acc "</td>" skip.
         put stream rep_br unformatted "<td>" tgl.acc-des "</td>" skip.
        put stream rep_br unformatted "<td>" GetNormSumm(tgl.sum) "</td>" skip.
        put stream rep_br unformatted "<td>" GetNormSumm(tgl.sum-val) "</td>" skip.
        put stream rep_br unformatted "<td>" GetCRC(tgl.crc) "</td>" skip.
        put stream rep_br unformatted "<td>" replace(string(tgl.perc),".",",") "</td>" skip.
        put stream rep_br unformatted "<td>" string(tgl.odt, "99/99/9999") "</td>" skip.
        put stream rep_br unformatted "<td>" string(tgl.cdt, "99/99/9999") "</td>" skip.
        put stream rep_br unformatted "<td>" tgl.prod "</td>" skip.
        if tgl.geo = "021" then put stream rep_br unformatted "<td>&nbsp; резидент </td>" skip.
        if tgl.geo <> "021" then put stream rep_br unformatted "<td>&nbsp; нерезидент </td>" skip.
        /*put stream rep_br unformatted "<td>" tgl.sub-type "</td>" skip.
        put stream rep_br unformatted "<td>" tgl.txb "</td>" skip. */
        /*put stream rep_br unformatted "<td>" GetFilName(tgl.txb) "</td>" skip.
        put stream rep_br unformatted "<td>&nbsp;" tgl.acc "</td>" skip.
        put stream rep_br unformatted "<td>" tgl.acc-des "</td>" skip.
        put stream rep_br unformatted "<td>" tgl.gl-des "</td>" skip.
        put stream rep_br unformatted "<td>" CAPS(tgl.type) "</td>" skip.
        put stream rep_br unformatted "<td>" CAPS(tgl.sub-type) "</td>" skip.
        put stream rep_br unformatted "<td>&nbsp;" tgl.level format "99" "</td>" skip.
        put stream rep_br unformatted "<td>" CAPS(tgl.code) "</td>" skip.
        put stream rep_br unformatted "<td>&nbsp;" tgl.grp format "99" "</td>" skip.*/

        put stream rep_br unformatted "</tr>" skip.


     end. /* for each tgl*/



put stream rep_br unformatted "</table></body></html>" skip.
output stream rep_br close.
hide frame ww no-pause.
hide frame ww2 no-pause.
/*******************************************************************************************************************/

  unix silent cptwin array.htm excel.
/***************************************************************************************************************/

output stream m-out to array1.htm.
    put stream m-out unformatted "<html><head><title>FORTEBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted "<h3>Отчет об остатках по гарантиям за " GetDate(v-gldate) "</h3>" skip.

    put stream m-out unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.


    put stream m-out unformatted "<tr bgcolor=""#CCCCCC"">" skip.
    /*put stream m-out unformatted "<td style=""font:bold"">Счет ГК</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Наимен счета ГК</td>" skip.*/
    put stream m-out unformatted "<td style=""font:bold"">Балансовый счет</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Номер гарантии/аккредитива</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Наименование счета</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Остаток в тенге</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Остаток в валюте</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Код валюты</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">% ставка</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Дата открытия</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Дата закрытия</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Код продукта</td>" skip.
    put stream m-out unformatted "<td style=""font:bold"">Код резидентства</td>" skip.
    put stream m-out unformatted "</tr>" skip.


    for each temp no-lock.
        put stream m-out unformatted "<tr>" skip.
        /*put stream m-out unformatted "<td>" string(tgl.gl) "</td>" skip.
        put stream m-out unformatted "<td height='20' width='150'>" tgl.gl-des "</td>" skip.*/
        put stream m-out unformatted "<td>" string(temp.npsbal) "</td>" skip.
         put stream m-out unformatted "<td>&nbsp;" temp.ref /*temp.acc*/ "</td>" skip.
         put stream m-out unformatted "<td>" temp.cname "</td>" skip.
        put stream m-out unformatted "<td>" GetNormSumm(temp.sumtreb) "</td>" skip.
        put stream m-out unformatted "<td>" GetNormSumm(temp.sumtval) "</td>" skip.
        put stream m-out unformatted "<td>" temp.code "</td>" skip.
        put stream m-out unformatted "<td>" /*replace(string(temp.perc),".",",")*/ "</td>" skip.
        put stream m-out unformatted "<td>" string(temp.regdt, "99/99/9999") "</td>" skip.
        put stream m-out unformatted "<td>" string(temp.expdt, "99/99/9999") "</td>" skip.
        put stream m-out unformatted "<td>" /*temp.prod */ "</td>" skip.
        put stream m-out unformatted "<td>" temp.rez "</td>" skip.

        put stream m-out unformatted "</tr>" skip.


     end. /* for each temp*/



put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.
/*******************************************************************************************************************/

  unix silent cptwin array1.htm excel.



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
            tgl.sum-val
            tgl.type
            tgl.sub-type
            tgl.totlev
            tgl.totgl
            tgl.level
            tgl.code
            tgl.grp
            tgl.acc
            tgl.acc-des
            tgl.geo
            tgl.odt
            tgl.cdt
            tgl.perc
            tgl.prod.
        END. /*REPEAT*/
    END. /*TRANSACTION*/
    input close.
end procedure.
/***************************************************************************************************************/



