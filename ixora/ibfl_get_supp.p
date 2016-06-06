/* ibfl_get_supp.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Соник-сервис для проверки данных клиента ИБФЛ
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
        13/05/2013 madiyar
 * BASES
        COMM TXB
 * CHANGES
        23/10/2013 Zhassulan - ТЗ 2144, удалил в двух местах message
*/

define input parameter p-cif as character no-undo.
define output parameter long-replyText as longchar.
define output parameter p-err as character no-undo.

define variable p-replyText as character no-undo.

if not connected ("comm") then run conncom.

define variable s-ourbank as character no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then
do:
    message " There is no record OURBNK in bank.sysc file !!".
    return.
end.
s-ourbank = trim(txb.sysc.chval).

/*****************************************************************************************/
{ibfl.i}
/*****************************************************************************************/
p-replyText = "<Data>".
def buffer b-tarif2 for txb.tarif2.

for each comm.suppcom where /*comm.suppcom.txb = s-ourbank and*/  type = 2 and ib_display = 1 no-lock break by ap_type by  ap_code:
 if first-of( ap_code ) then do:
   p-replyText = p-replyText + "<Record>".
   p-replyText = p-replyText + "<Name>" + trim(comm.suppcom.name) + "</Name>".
   p-replyText = p-replyText + "<Caption>" + GetSuppCaption(comm.suppcom.ap_code) + "</Caption>".
   p-replyText = p-replyText + "<Supp_id>" + trim(string(comm.suppcom.supp_id)) + "</Supp_id>".
   p-replyText = p-replyText + "<Type>" + trim(string(comm.suppcom.type)) + "</Type>".
   p-replyText = p-replyText + "<Ap_check>" + trim(string(comm.suppcom.ap_check)) + "</Ap_check>".
   p-replyText = p-replyText + "<Ap_type>" + trim(string(comm.suppcom.ap_type)) + "</Ap_type>".
   p-replyText = p-replyText + "<Ap_code>" + trim(string(comm.suppcom.ap_code)) + "</Ap_code>".
   p-replyText = p-replyText + "<Ap_tc>" + trim(comm.suppcom.ap_tc) + "</Ap_tc>".
   p-replyText = p-replyText + "<Ap_minsum>" + trim(string(comm.suppcom.minsum,"->>>>>>>>>>>>>>>>9.99")) + "</Ap_minsum>".
   p-replyText = p-replyText + "<Ap_minlen>" + trim(string(comm.suppcom.minlen)) + "</Ap_minlen>".
   p-replyText = p-replyText + "<Ap_maxlen>" + trim(string(comm.suppcom.maxlen)) + "</Ap_maxlen>".
   find first b-tarif2 where b-tarif2.num + b-tarif2.kod = comm.suppcom.paycod and b-tarif2.stat = 'r' no-lock no-error no-wait.
   if avail b-tarif2 then do:
       p-replyText = p-replyText + "<Comission>" + trim(string(b-tarif2.ost,"->>>>>>>>>>>>>>>>9.99")) + "</Comission>".
   end.
    p-replyText = p-replyText + "</Record>".
    long-replyText = long-replyText + p-replyText.
    p-replyText = "".

 end.
end.
long-replyText = long-replyText + "</Data>".
