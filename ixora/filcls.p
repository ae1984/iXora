/* filcla.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Закрытие счета в другом филиале
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        COMM TXB
 * AUTHOR
        15.07.2010 marinav
 * CHANGES
*/



def var v-ja as logi no-undo format "Да/Нет" init no.
def var v-cod as char.

       def shared var v-id as char.
       find first filpayment   where filpayment.id = v-id no-lock no-error.
       if avail filpayment then do:
          find first txb.aaa where txb.aaa.aaa = filpayment.iik .
          if txb.aaa.cbal = 0 then do:
              message "Остаток на счету 0 ! Закрыть счет?" view-as alert-box question buttons yes-no UPDATE v-ja.
              if v-ja then do:

                  {itemlist.i 
                         &file = "txb.codfr"
                         &frame = "row 6 centered scroll 1 16 down overlay "
                         &where = " txb.codfr.codfr = 'clsa' "
                         &flddisp = " txb.codfr.code    label 'КОД ' format 'x(6)'
                                      txb.codfr.name[1] label 'ЗНАЧЕНИЕ' format 'x(50)'
                                     " 
                         &chkey = "code"
                         &chtype = "string"
                         &index  = "main" 
                  }

                  v-cod = frame-value.
                      
                  if v-cod ne '' and v-cod ne 'msc' then do:
                       find txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-error.
                        
                       if not avail txb.sub-cod then do:
                            create txb.sub-cod.
                            txb.sub-cod.sub = 'cif'.
                            txb.sub-cod.acc = txb.aaa.aaa.
                            txb.sub-cod.d-cod = 'clsa'.
                        end.
                        txb.sub-cod.ccode = v-cod.
                        txb.sub-cod.rdt = today.
                        txb.aaa.sta = 'C'.
                        txb.aaa.cltdt = today.

                        filpayment.sts = 'C'.
                        message "Счет закрыт !" view-as alert-box .
                   end.
                   else  message "Не верно выбрана причина закрытия! Счет не закрыт !" view-as alert-box. 

             end. 
          end.
       end.
                        