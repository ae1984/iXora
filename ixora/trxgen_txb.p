/* trxgen_txb.p
 * MODULE
        TRXGEN_TXB
 * DESCRIPTION
        Формирование проводок в txb
        Не запускать программу через dpragma!!!
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
        05/07/2013 k.gitalov
 * BASES
        BANK COMM 
 * CHANGES
*/
{global.i "new"}.

run setglob.
if g-ofc = "" then do:
    input through whoami.
    import g-ofc.
    g-ofc = trim(g-ofc).
end.

   

def variable txb_path as character no-undo.
def variable txb_trxcode as character no-undo.
def variable txb_vdel as character no-undo.
def variable txb_vparam as character no-undo.
def variable txb_vsub as character no-undo.
def variable txb_vref as character no-undo.
def variable txb_sts as character no-undo.
def variable txb_sjh as character no-undo.

define variable s-jh like jh.jh.
define variable rcode as integer init 0.
define variable rdes as character init "".

input through echo $txb_path.
import txb_path.
if txb_path = "" then do:
    rcode = 1000.
    rdes = "txb_path = NULL".
end.
input through echo $txb_trxcode.
import txb_trxcode.
if txb_trxcode = "" then do:
    rcode = 1.
    rdes = "txb_trxcode = NULL".
end.
input through echo $txb_vdel.
import txb_vdel.
if txb_vdel = "" then do:
    rcode = 2.
    rdes = "txb_vdel = NULL".
end.
input through echo $txb_vparam.
import txb_vparam.
if txb_vparam = "" then do:
    rcode = 3.
    rdes = "txb_vparam = NULL".
end.
input through echo $txb_vsub.
import txb_vsub.
if txb_vsub = ? then do:
    rcode = 4.
    rdes = "txb_vsub = NULL".
end.
input through echo $txb_vref.
import txb_vref.
if txb_vref = ? then do:
    rcode = 5.
    rdes = "txb_vref = NULL".
end.
input through echo $txb_sts.
import txb_sts.
if txb_sts = "" then do:
    rcode = 6.
    rdes = "txb_sts = NULL".
end.
input through echo $txb_sjh.
import txb_sjh.
if txb_sjh = "" then do:
    rcode = 7.
    rdes = "txb_sjh = NULL".
end.
else s-jh = integer(txb_sjh).

hide message no-pause.

if rcode <> 0 then do:
 message "<Rcode>" + string(rcode) + "</Rcode><Rdes>" + rdes + "</Rdes>".
 return.   
end.

txb_vparam = replace(txb_vparam,"_"," ").

            do transaction:
              
              if txb_trxcode = "9999999" then 
              do:
               run trxdel(s-jh,input false,output rcode,output rdes). 
               if rcode <> 0 then do:
                    message "<Rcode>" + string(rcode) + "</Rcode><Rdes>" + rdes + "</Rdes>".
                    return.
               end.
              end.
              else do:  
                  if txb_trxcode <> "7777777" then 
                  do:  
                    run trxgen (txb_trxcode, txb_vdel, txb_vparam, txb_vsub, txb_vref, output rcode, output rdes, input-output s-jh).
                    if rcode <> 0 then do:
                        message "<Rcode>" + string(rcode) + "</Rcode><Rdes>" + rdes + "</Rdes>".
                        return.
                    end.
                  end.  
                    if integer(txb_sts) > 0 then do:
                      run trxsts(s-jh,integer(txb_sts),output rcode, output rdes). 
                      if rcode <> 0 then do:
                        message "<Rcode>" + string(rcode) + "</Rcode><Rdes>" + rdes + "</Rdes>".
                        return.
                      end. 
                    end.
              end.  
                 
            end. /*transaction*/
 
 message "<Trx>" + string(s-jh) + "</Trx>".
        
            


