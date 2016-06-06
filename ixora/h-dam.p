/* h-dam.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{mainhead.i "F/X TAB"}

def var v-crc like crc.crc label "CRC-FROM".
def var fcode like crc.code.
def var tcode like crc.code.
def var s-crc like crc.crc label "CRC-TO".
def var famt like fex.amt.
def var tamt /* like  fex.payment. */
 as dec format "z,zzz,zzz,zzz,zz9.99-".
def var kamt /* like  fex.payment. */   as dec.
def var samt /* like  fex.payment. */   as dec.
def var trxby like fex.trxby.
def var comm  like fex.comm.
def var somm  like fex.comm.
def var ccode like crc.code.
def buffer acrc for crc.
def buffer bcrc for crc.
def buffer tcrc for crc.
def var xuna as int.
def var xunb as int.

 form trxby ccode comm skip
      v-crc fcode famt
      s-crc tcode tamt label "PAYMENT"
      with frame crc 6 col centered row 3.

       tamt = 0.
       comm = 0.
       famt = 0.
       somm = 0.

       view frame crc.

        form crc.crc crc.des   format "x(23)"
          crc.rate[9] label "UNIT" format "zzzzz9"
          crc.rate[1] label "MID-RATE"
          crc.rate[2] label "CASH-BUY"
          crc.rate[3] label "CASH-SELL"  skip
          crc.rate[4] label "T/T-BUY" at 23
          crc.rate[5] label "T/T-SELL"
          crc.rate[6] label "T/C-BUY"
          crc.rate[7] label "T/C-SELL"
          with row 8 centered 4 down overlay frame frms.

          find acrc where acrc.crc = 1.

     do on error undo,retry:
      update trxby validate(trxby ge 1 and trxby le 4 , "")
             help " 1. CASH  2. T/T  3. T/C  4. MID-RATE "
             with frame crc.
        update v-crc with frame crc.
        find crc where crc.crc = v-crc no-error.
        if not available crc then do:
          bell.
          undo,retry.
        end.

        xuna = integer(crc.rate[9]).

        disp crc.crc crc.des
          crc.rate[9]
          crc.rate[1]
          crc.rate[2]
          crc.rate[3]
          crc.rate[4]
          crc.rate[5]
          crc.rate[6]
          crc.rate[7]  with frame frms.
          down 2 with frame frms.
         fcode = crc.code.
         disp fcode with frame crc.
         update famt with frame crc.
        end.

     do on error undo,retry:
        update s-crc validate(s-crc ne v-crc , "") with frame crc.
        find crc where crc.crc = s-crc no-error.
        if not available crc then do:
          bell.
          undo,retry.
        end.
        find bcrc where bcrc.crc = s-crc.
        disp crc.crc crc.des
          crc.rate[9]
          crc.rate[1]
          crc.rate[2]
          crc.rate[3]
          crc.rate[4]
          crc.rate[5]
          crc.rate[6]
          crc.rate[7]  with frame frms.
         tcode = crc.code.
         disp tcode with frame crc.
         xunb = integer(crc.rate[9]).

         if famt  = 0 then
          update tamt validate ( tamt ne 0 ,"" )
         with frame crc.


            if true /*v-crc ne  1*/  then do:

               find crc where crc.crc = v-crc.
               find tcrc where tcrc.crc = s-crc.

               if trxby = 1 then do:
        if famt = 0 then famt = tamt * tcrc.rate[3] * xuna / crc.rate[2] / xunb.
        kamt = famt *  crc.rate[2] / xuna .   /* BUY FIRST */
        comm = round((famt *  crc.rate[1] / xuna) -
                 (famt *  crc.rate[2] / xuna ),acrc.decpnt).
               end.

         else  if trxby = 2 then do:
        if famt = 0 then famt = tamt * xuna * tcrc.rate[5] / crc.rate[4] / xunb.
        kamt = famt *  crc.rate[4] / xuna .   /* BUY FIRST */

        comm = round((famt *  crc.rate[1] / xuna )
        - (famt * crc.rate[4] / xuna ),acrc.decpnt).
               end.

         else  if trxby = 3 then do:
        if famt = 0 then famt = tamt * xuna * tcrc.rate[7] / crc.rate[6] / xunb.
               kamt = famt *  crc.rate[6] / xuna .   /* BUY FIRST */
        comm = round((famt * crc.rate[1] / xuna )
        - (famt *  crc.rate[6] / xuna ),acrc.decpnt).
               end.
         else if trxby = 4 then do:
        if famt = 0 then famt = tamt * xuna * tcrc.rate[1] / crc.rate[1] / xunb.
        kamt =  famt / xuna  *  crc.rate[1].   /* MID-RATE */
                       end.
            end.             /*

          else do:
           kamt =  round(famt / xuna , acrc.decpnt). comm = 0. end.
                                 */
           display famt with frame crc.

          if tamt = 0 then
             tamt = kamt.

          if s-crc ne 1 then do:
               find crc where crc.crc = s-crc.
               if trxby = 1 then do:
               somm =
   round(( kamt * xunb /  crc.rate[1] - kamt / crc.rate[3] * xunb )
   *  crc.rate[1] / xunb,bcrc.decpnt).
               tamt = round( kamt / crc.rate[3] * xunb,bcrc.decpnt).
               /* SELL */
               end.

         else  if trxby = 2 then do:
               somm =
   round(( kamt / crc.rate[1] * xunb
   - kamt / crc.rate[5] * xunb )
   *  crc.rate[1] / xunb,bcrc.decpnt).

               tamt = round( kamt / crc.rate[5] * xunb , bcrc.decpnt).
               /* SELL */
              end.

         else  if trxby = 3 then do:
               somm =
   round(( kamt / crc.rate[1] * xunb
   - kamt / crc.rate[7] * xunb )
   * crc.rate[1] / xunb,bcrc.decpnt).
               tamt = round(kamt / crc.rate[7] * xunb,bcrc.decpnt).
               /* SELL */
              end.
         else if trxby = 4 then do:
               somm = 0.
               tamt = round(kamt / crc.rate[1] * xunb,bcrc.decpnt).
               end.
            end.

         find crc where crc.crc = 1 . ccode = crc.code.
         comm =  comm + somm.
         disp   ccode comm tamt
                with frame crc.
        end.
   /*
   v-crc = 0. s-crc = 0. comm = 0. famt = 0. tamt = 0. fcode = "". tcode = "".
   */
   hide all.
