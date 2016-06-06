/* lgrpribranch.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Копирование на филиалы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-branch.i
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/06/2008 alex
 * BASES
        BANK COMM TXB
 * CHANGES
        01/07/2008 alex - добавил синхронизацию таблицы prih, проверка tdalgr или tdaint.
        
*/

def input parameter lgr as logical.

def var s-ourbank as char no-undo.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

s-ourbank = trim(txb.sysc.chval).
if s-ourbank = "txb00" then return.

do transaction:
    
    if lgr then do:
        /**************************LGR****************************************************************************************/
        
        for each txb.lgr where txb.lgr.led = "TDA" exclusive-lock:
            delete txb.lgr.
        end.
        
        for each bank.lgr where bank.lgr.led = "TDA" no-lock:
            create txb.lgr.
            buffer-copy bank.lgr to txb.lgr.
        end.
    end.
    else do:
        /**************************PRI****************************************************************************************/
        for each txb.pri exclusive-lock:
            delete txb.pri.
        end.
             
        for each bank.pri no-lock:
            create txb.pri.
            buffer-copy bank.pri to txb.pri.
        end.
        
        /**************************PRIH*****************************/
        for each txb.prih exclusive-lock:
            delete txb.prih.
        end.
        
        for each bank.prih no-lock:
            create txb.prih.
            buffer-copy bank.prih to txb.prih.
        end.
    end.
    
end. /*transaction*/