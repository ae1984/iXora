/* lgrtofil.p
 * MODULE
        Программа общего назначения
 * DESCRIPTION
        Перенос групп на филиалы
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
        21/04/2010 marinav
 * BASES
        BANK TXB
 * CHANGES
*/



find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if trim(txb.sysc.chval) = "txb00" then return.


  find bank.sysc where bank.sysc.sysc = "GLTD" no-lock no-error.
  if avail bank.sysc and bank.sysc.chval ne "" then do:
      do transaction:
        find first txb.lgr where txb.lgr.lgr = bank.sysc.chval exclusive-lock no-error.

           find first bank.lgr where bank.lgr.lgr = bank.sysc.chval no-lock no-error.  
           if avail bank.lgr then do:
              if avail txb.lgr then delete txb.lgr.
              create txb.lgr. 
              buffer-copy bank.lgr to txb.lgr.
           
              for each txb.aax where txb.aax.lgr = txb.lgr.lgr .
                  delete txb.aax.
              end.
              for each bank.aax where bank.aax.lgr = bank.lgr.lgr no-lock.
                  create txb.aax.
                  buffer-copy bank.aax to txb.aax.       
              end.
           end.
           else do:
              if avail txb.lgr then do:
                 find txb.aax where txb.aax.lgr eq txb.lgr.lgr no-error.
                 if avail txb.aax then delete txb.aax. 
                 delete txb.lgr.
              end.
           end.
      end.
  end.

