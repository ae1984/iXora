/* gltofil.p
 * MODULE
        Программа общего назначения
 * DESCRIPTION
        Перенос ГК на филиалы
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
        16/03/2010 marinav
 * BASES
        BANK TXB
 * CHANGES
        27.03.10 marinav - добавлено удаление счета 
*/



find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if trim(txb.sysc.chval) = "txb00" then return.


  find bank.sysc where bank.sysc.sysc = "GLTD" no-lock no-error.
  if avail bank.sysc and bank.sysc.inval ne 0 then do:
      do transaction:
        find first txb.gl where txb.gl.gl = bank.sysc.inval exclusive-lock no-error.

           find first bank.gl where bank.gl.gl = bank.sysc.inval no-lock no-error.  
           if avail bank.gl then do:
              if avail txb.gl then delete txb.gl.
              create txb.gl. 
              buffer-copy bank.gl to txb.gl.
           
              for each bank.gltot where bank.gltot.gl = bank.gl.gl and bank.gltot.crc = bank.gl.crc no-lock.
                  find txb.gltot where txb.gltot.gl eq bank.gltot.gl and txb.gltot.crc eq bank.gltot.crc no-lock no-error.
                  if not available txb.gltot then do:
                  create txb.gltot.
                         txb.gltot.gl = bank.gltot.gl.
                         txb.gltot.crc = bank.gltot.crc.
                  end.
              end.

              for each txb.trxlevgl where txb.trxlevgl.gl = txb.gl.gl .
                  delete txb.trxlevgl.
              end.
              for each bank.trxlevgl where bank.trxlevgl.gl = bank.gl.gl no-lock.
                  create txb.trxlevgl.
                  buffer-copy bank.trxlevgl to txb.trxlevgl.       
              end.

              for each txb.sub-cod where txb.sub-cod.sub = 'gld' and txb.sub-cod.acc = string(txb.gl.gl).
                  delete txb.sub-cod.
              end.
              for each bank.sub-cod where bank.sub-cod.sub = 'gld' and bank.sub-cod.acc = string(bank.gl.gl) no-lock.
                  create txb.sub-cod. 
                  buffer-copy bank.sub-cod to txb.sub-cod.       
              end.
           end.
           else do:
              if avail txb.gl then do:
                 find txb.gltot where txb.gltot.gl eq txb.gl.gl and txb.gltot.crc eq txb.gl.crc no-error.
                 if avail txb.gltot then delete txb.gltot . 
                 delete txb.gl.
              end.
           end.
      end.
  end.

