/* raspr_lon.p
 * MODULE
        Название модуля
 * DESCRIPTION
        РАСПОРЯЖЕНИЕ НА ВЫДАЧУ КРЕДИТА
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
        14.02.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        11.03.2011 ruslan подправил заголовок
        14.03.2011 ruslan они уже сами не знают, что еще придумать.
        15.03.2011 ruslan
        18.03.2011 ruslan изменил прописание текущей даты, подвязал доступный остаток для траншей из основной кредитной линии
        12.04.2011 ruslan подправил проверку loncon.lcnt в случае если в строке один пробел.
        26.05.2011 ruslan выровнял по центру заголовок
        26/09/2011 dmitriy - изменил алгорим вытягивания номера овердрафта из loncon.lcnt
        07.06.2013 yerganat добавление шаблоны отчетов распоряжений, и выборку по ним
*/

{global.i}

def stream rep.
def var coun as int no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-itogo as deci no-undo extent 3.
def var v-name like ofc.name.
def var t-prnmos as int format "9".
def var i as int.
def var v-ofile as char no-undo.
def var v-sel-reptype as int no-undo.
def var mm as char no-undo extent 12 init ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'].
def var v-lon-cntr like loncon.lcnt.


define variable cl-voz as deci no-undo format ">>>,>>>,>>>,>>9.99".
define variable cl-nevoz as deci no-undo format ">>>,>>>,>>>,>>9.99".

def shared var s-lon like lon.lon.


find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " Ссудный счет не найден " view-as alert-box error.
  return.
end.

find first cif where cif.cif = lon.cif no-lock no-error.
if not avail cif then do:
  message " Клиент не найден " view-as alert-box error.
  return.
end.
else do:
    if lon.gua = "LO" and lon.clmain <> '' then do:
        run lonbalcrc('lon',lon.clmain,g-today,'15',yes,lon.crc,output cl-voz). cl-voz = - cl-voz.
        run lonbalcrc('lon',lon.clmain,g-today,'35',yes,lon.crc,output cl-nevoz). cl-nevoz = - cl-nevoz.
    end.
    else do:
        run lonbalcrc('lon',lon.lon,g-today,'15',yes,lon.crc,output cl-voz). cl-voz = - cl-voz.
        run lonbalcrc('lon',lon.lon,g-today,'35',yes,lon.crc,output cl-nevoz). cl-nevoz = - cl-nevoz.
    end.
end.


def var num_dog as char.

find first loncon where loncon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " № контракта не найден " view-as alert-box info.
  return.
end.
else do:
    v-lon-cntr=loncon.lcnt.
    num_dog = entry(1, loncon.lcnt, "  ").
    num_dog = substr(loncon.lcnt, length(num_dog) + 2).
    if substr(num_dog,1,1) = " " then num_dog = substr(num_dog,2).
    if num_dog = "" or num_dog = " " then num_dog = "0".
    /*if substring(loncon.lcnt,1,1) = "C" and index(loncon.lcnt," ") <> 0 then
        do i = 1 to length(loncon.lcnt):
            if substring(loncon.lcnt,i,1) = " " and substring(loncon.lcnt,i + 1,1) = " " then
                num_dog = entry(2,replace(loncon.lcnt,"  ",","),",").
            else do:
                num_dog = entry(2,replace(loncon.lcnt," ",","),",").
            end.
        end.
    else do:
        num_dog = loncon.lcnt.
    end.*/
end.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
v-ofile = "rep.htm".

find first ofc where ofc.ofc = loncon.who no-lock no-error.
if not avail ofc then
  assign v-name = "__________________".
  else
  assign v-name = entry(1,ofc.name," ") + " " + substring(entry(2,ofc.name," "),1,1) + ".".

def var v-crc like crc.des.

find first lon where lon.lon = s-lon no-lock no-error.
if avail lon then do:
    assign t-prnmos = lon.prnmos.
    find first crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then v-crc = crc.des.
end.

def var v-city as char no-undo.
find first cmp no-lock no-error.
v-city = entry(2, cmp.addr[1],",").
/*if s-ourbank = "txb00" then v-city = "ЦО".
else do:
    find first cmp no-lock no-error.
    if avail cmp then do:
     if (int(cmp.code) = 0) or (int(cmp.code) = 8) then
       v-city = entry(2, cmp.addr[1],",").
     else
       v-city = entry(3, cmp.addr[1],",").
    end.
end.*/


def var v-rep-date as char no-undo.
def var v-prnmos as char no-undo.
def var v-lon-plan as char no-undo.
def var v-contr-num as char no-undo.
def var v-balance as char no-undo.
def var v-lon-sum as char no-undo.
def var v-lon-date as char no-undo.
def var v-city2 as char no-undo.

v-rep-date = '«' + string(day(g-today), "99") + '» ' + mm[month(g-today)] + ' ' + string(year(g-today), "9999") + '  '.
case t-prnmos:
     when 1 then  v-prnmos = "Овердрафт".
     when 2 then  v-prnmos = "Кредит".
     when 3 then  v-prnmos = "Факторинг".
end case.

case lon.plan:
     when 1 then v-lon-plan="равными долями".
     when 2 then v-lon-plan="аннуитет".
end case.

v-contr-num = num_dog + " от " + string(lon.rdt, "99/99/9999").
v-balance = "Ост.ВозКЛ...:" + replace(replace(string(cl-voz, ">>>,>>>,>>>,>>9.99"),","," "),".",",") + " " + v-crc + "; Ост.НевозКЛ.:" + replace(replace(string(cl-nevoz, ">>>,>>>,>>>,>>9.99"),","," "),".",",") + " " + v-crc.
v-lon-sum = replace(replace(string(lon.opnamt, ">>>,>>>,>>>,>>9.99"),","," "),".",",") + " " + v-crc.
if lon.duedt <> ? then v-lon-date = " по " + string(lon.duedt, "99/99/9999") + " ".
else v-lon-date= " по ".

find sysc where sysc.sysc = "ourbnk".
if avail sysc then do:
     if not connected ("comm") then run comm-con.
     find txb where txb.bank = sysc.chval.
     if avail txb then v-city2=txb.info.
end.


run sel2(" Выберите тип распоряжения "," Распоряжение 1 – выдача кредита | Распоряжение 3 – созд./корр-ка дост.ост. | Распоряжение 4 – погаш. ком./штрафа | Распоряжение 5 – изм. стоим. залога | Распоряжение 6 – прих./спис. залога | Распоряжение 7 – прих./спис. гарантии ", output v-sel-reptype).

def var v-infile as char.
def var v-str as char.

output stream rep to value(v-ofile).

case v-sel-reptype:
    when 1 then do:
        {raspr1.i}
    end.
    when 2 then do:
        {raspr3.i}
    end.
    when 3 then do:
        {raspr4.i}
    end.
    when 4 then do:
        {raspr5.i}
    end.
    when 5 then do:
        {raspr6.i}
    end.
    when 6 then do:
        {raspr7.i}
    end.
end case.

output stream rep close.

unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -r " + v-ofile).