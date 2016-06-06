/* .p
 * MODULE
        Название модуля
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
        Пункт меню
 * AUTHOR
        03.05.2013 evseev tz-1810
 * BASES
        BANK COMM
 * CHANGES
        01.11.2013 evseev - tz1952
*/

{global.i}


def input parameter p-IIN as char no-undo.
def input parameter p-product as char no-undo.
def output parameter p-fcb_id as int no-undo.

run savelog("1CB_RequestReport", "29. " + p-IIN + " " + p-product ).

def var v-str as char.
def var v-str1 as char.

def var  xml_id  as int  no-undo.
def var  fcb_id  as int  no-undo.
def var choice as logi no-undo.
def var  v-dt  as char  no-undo.

fcb_id = 0.
for each fcb where fcb.bin = p-IIN and fcb.req_method = "GetReport.200017" and fcb.dt >= today - 30 use-index idx_dt no-lock:
    find first xml_det where xml_det.xml_id = fcb.xml_id and xml_det.par matches "*CigResultError Errmessage" no-lock no-error.
    if avail xml_det then next.
    find first xml_det where xml_det.xml_id = fcb.xml_id no-lock no-error.
    if avail xml_det and xml_det.par = ? then next.
    fcb_id = fcb.fcb_id.
    v-dt = string(fcb.dt) + " " + string(fcb.tm,"HH:MM").
end.

if fcb_id > 0 then do:
   choice = no.
   message "В Иксоре имеется отчет 1КБ за " + v-dt + ". Использовать его? (<No> - запросить новый в 1КБ)" view-as alert-box question buttons yes-no update choice.
   if choice then do:
      p-fcb_id = fcb_id.
      return.
   end.
end.


function GetXmlId returns integer.
    do transaction:
        find first pksysc where pksysc.sysc = "xml_id" exclusive-lock no-error.
        if avail pksysc then
           pksysc.chval = string(int(pksysc.chval) + 1).
        else do:
           create pksysc.
           pksysc.sysc = "xml_id".
           pksysc.chval = "1".
        end.
        find first pksysc where pksysc.sysc = "xml_id" no-lock no-error.
    end.
    return int(pksysc.chval).
end function.
xml_id = GetXmlId().


function GetFcbId returns integer.
    do transaction:
        find first pksysc where pksysc.sysc = "fcb_id" exclusive-lock no-error.
        if avail pksysc then
           pksysc.chval = string(int(pksysc.chval) + 1).
        else do:
           create pksysc.
           pksysc.sysc = "fcb_id".
           pksysc.chval = "1".
        end.
        find first pksysc where pksysc.sysc = "fcb_id" no-lock no-error.
    end.
    return int(pksysc.chval).
end function.
fcb_id = GetFcbId().


/*input through value ("cb1rep.pl -login=MBuser75_TST -password=MBuser75_TST -method=GetReport -rnn=" + p-IIN + " -reportid=200017 > report1cb_" + string(xml_id,"99999999") + ".xml;echo $?").*/
input through value ("cb1rep.pl -login=MBuser75 -password=MBuser76 -method=GetReport -rnn=" + p-IIN + " -reportid=200017 > report1cb_" + string(xml_id,"99999999") + ".xml;echo $?").

v-str1 = "".
repeat:
  import unformatted v-str.
  if v-str1 <> "" then v-str1 = v-str1 + " \n".
  v-str1 = v-str1 + v-str.
end.

if v-str <> "0" then do:
    message skip "Произошла ошибка при запросе отчета из ПКБ!" view-as alert-box buttons ok title " ОШИБКА ! ".
    return .
end.


run loadXML(input "report1cb_" + string(xml_id,"99999999") + ".xml", input xml_id).

do transaction:
    create fcb.
     assign
          fcb.fcb_id = fcb_id
          fcb.dt = today
          fcb.tm = time
          fcb.usr = g-ofc
          fcb.bin = p-IIN
          fcb.req_method = "GetReport.200017"
          fcb.xml_id = xml_id
          fcb.product = p-product.
end.
p-fcb_id = fcb_id.

