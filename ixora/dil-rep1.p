/* dil-rep1.p
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
        27/07/2011 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
*/


def input param dt1 as date no-undo.
def input param dt2 as date no-undo.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).


def buffer b-aaa for txb.aaa.
def buffer b-cif for txb.cif.
def buffer b-jh for txb.jh.
def var clientname as char.
def var v_crc as int.
def var com_crc as int.
def var com_aaa as char.

define shared temp-table wrk
                field type as int
                field txb AS char
                field dt as date
                field tm as int
                field trx as int
                field Name as char
                field t-summ as deci
                field t-crc as int
                field v-summ as deci
                field v-crc as int
                field rate as deci
                field com_conv as deci
                field com_crc as int
                field who_cr as char.


  for each txb.dealing_doc where txb.dealing_doc.whn_cr >= dt1 and txb.dealing_doc.whn_cr <= dt2 and txb.dealing_doc.jh <> ? and txb.dealing_doc.jh <> 0 no-lock:

  find first b-jh where b-jh.jh = txb.dealing_doc.jh and b-jh.sts <> 0 and b-jh.sts <> ? no-lock no-error.
   if avail b-jh then do:
      create wrk.
      wrk.type = txb.dealing_doc.doctype.
      wrk.txb = s-ourbank.
      wrk.dt = txb.dealing_doc.whn_cr.
      wrk.tm = txb.dealing_doc.time_cr.
      wrk.trx = txb.dealing_doc.jh.
      wrk.t-summ = txb.dealing_doc.t_amount.
      wrk.v-summ = txb.dealing_doc.v_amount.
      wrk.rate = txb.dealing_doc.rate.
      wrk.who_cr = txb.dealing_doc.who_cr.

      find first b-aaa where b-aaa.aaa = txb.dealing_doc.tclientaccno no-lock no-error.
      if not available b-aaa then wrk.t-crc = -1.
      else do:
        wrk.t-crc = b-aaa.crc.
        find first b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
        if not available b-cif then clientname = "".
        else clientname = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
        wrk.Name = clientname.
        /* message "Не найден клиент " b-aaa.cif "в таблице CIF"  view-as alert-box title s-ourbank.*/
      end.
      /*message "Счет" txb.dealing_doc.tclientaccno "не найден !" view-as alert-box title s-ourbank.*/
      find first b-aaa where b-aaa.aaa = txb.dealing_doc.vclientaccno no-lock no-error.
      if not available b-aaa then wrk.v-crc = -1.
      else wrk.v-crc = b-aaa.crc.
      /*message " Счет" txb.dealing_doc.vclientaccno "не найден! ~n документ:" txb.dealing_doc.docno  view-as alert-box title s-ourbank.*/

      find first b-aaa where b-aaa.aaa = txb.dealing_doc.com_accno no-lock no-error.
      if not available b-aaa then wrk.com_crc = -1.
      else wrk.com_crc = b-aaa.crc.
      wrk.com_conv = txb.dealing_doc.com_conv.
      /*message " Счет сомиссии" txb.dealing_doc.com_accno "не найден! ~n документ:" txb.dealing_doc.docno  view-as alert-box title s-ourbank.*/
   end.

  end.