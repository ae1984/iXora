

/*BANK TXB*/


def shared temp-table t-comm
    field type as integer
    field deb1 as char 
    field deb2 as char 
    field deb3 as char 
    field cre1 as char 
    field cre2 as char 
    field cre3 as char 
    field amount as deci
    field des as char
    field data as date
    field grp as integer
    field grptype as integer
    index main type cre1.

def shared temp-table t-jl
    field type as integer
    field deb1 as char 
    field deb2 as char 
    field deb3 as char 
    field cre1 as char 
    field cre2 as char 
    field cre3 as char 
    field amount as deci
    field des as char
    field data as date
    index main type .

def shared var v-dat as date .
def shared var v-summ as deci init 0.

find first txb.cmp.

FOR EACH txb.jl  where txb.jl.jdt = v-dat NO-LOCK :

   find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt le txb.jl.jdt no-lock no-error.
   find last txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.


/* для филиалов */

  if txb.ppoint.fax = 'fil' then do:

        /* выдача кредита 100% */
              if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'D'  then do:
              find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
                  if avail txb.lon then do:
                     if txb.jl.trx = 'LON0058' then do:

                          find t-jl where t-jl.type = 17 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 17
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииФ'
                                    t-jl.cre1 = txb.cmp.addr[3]
                                    t-jl.cre2 = '00000006'
                                    t-jl.cre3 = '00000001'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за кредит-нач'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 

                          find t-jl where t-jl.type = 18 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 18
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииФ'
                                    t-jl.cre1 = '00000058'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = 'КомиссииФ'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за кредит-пог'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 
                     end.


             /* Погашение ежемесячной комиссии за ведение кредита */
                     if txb.jl.trx = 'cif0006' or txb.jl.trx = 'JOU0026' then do:

                          find t-jl where t-jl.type = 15 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 15
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииК'
                                    t-jl.cre1 = txb.cmp.addr[3]
                                    t-jl.cre2 = '00000001'
                                    t-jl.cre3 = '00000001'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за ведение кредита-нач'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 

                          find t-jl where t-jl.type = 16 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 16
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииК'
                                    t-jl.cre1 = '00000058'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = 'КомиссииК'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за ведение кредита-пог'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 

                      end.
                  end.
              end.


              if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'C' and txb.jl.trx = 'lon0052'  then do:

                          find t-jl where t-jl.type = 3 and t-jl.cre1 = txb.ppoint.tel2 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 3
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = ''
                                    t-jl.cre1 = txb.ppoint.tel2
                                    t-jl.cre2 = '00000029'
                                    t-jl.cre3 = ''
                                    t-jl.amount = 0
                                    t-jl.des = 'Выдача кредитных средств'
                                    t-jl.data = v-dat .
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.cam. 
               end.


          /*погашение кредита*/

              if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'C' and txb.jl.trx ne 'lon0052'  then do:
              find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
                  if avail txb.lon then do:
                          find t-jl where t-jl.type = 5 and t-jl.deb1 = txb.ppoint.tel2 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 5
                                    t-jl.deb1 = txb.ppoint.tel2
                                    t-jl.deb2 = '00000030'
                                    t-jl.deb3 = ''
                                    t-jl.cre1 = '00000058'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = ''
                                    t-jl.amount = 0
                                    t-jl.des = 'Поступление на авансовый счет'
                                    t-jl.data = v-dat .
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.cam. 
                     end.
              end.

              if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'D' and txb.jl.trx = 'lon0058'  then do:
              find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
                  if avail txb.lon then do:
                          find t-jl where t-jl.type = 5 and t-jl.deb1 = txb.ppoint.tel2 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 5
                                    t-jl.deb1 = txb.ppoint.tel2
                                    t-jl.deb2 = '00000030'
                                    t-jl.deb3 = ''
                                    t-jl.cre1 = '00000058'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = ''
                                    t-jl.amount = 0
                                    t-jl.des = 'Поступление на авансовый счет'
                                    t-jl.data = v-dat .
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam. 
                     end.
              end.

              if (txb.jl.lev = 1 or txb.jl.lev = 7) and txb.jl.sub = 'lon' and txb.jl.dc = 'C' and (txb.jl.trx = 'LON0062' or txb.jl.trx = 'LON0079' or txb.jl.trx = 'LON0015') then do:

                find t-jl where t-jl.type = 6 exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 6
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = ''
                          t-jl.cre1 = '00000058'
                          t-jl.cre2 = 'Договор'
                          t-jl.cre3 = ''
                          t-jl.amount = 0
                          t-jl.des = 'Возврат кредитных средств'
                          t-jl.data = v-dat.
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 
              end.


              if (txb.jl.lev = 2 or txb.jl.lev = 9) and txb.jl.sub = 'lon' and txb.jl.dc = 'C' and (txb.jl.trx = 'LON0062' or txb.jl.trx = 'LON0079' or txb.jl.trx = 'LON0015') then do:

                find t-jl where t-jl.type = 7 exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 7
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = ''
                          t-jl.cre1 = '00000058'
                          t-jl.cre2 = 'Договор'
                          t-jl.cre3 = 'ПроцентыПоКредиту'
                          t-jl.amount = 0
                          t-jl.des = 'Оплата процентов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 
              end.


              if txb.jl.lev = 16 and txb.jl.sub = 'lon' and txb.jl.dc = 'C' and (txb.jl.trx = 'LON0062' or txb.jl.trx = 'LON0079' or txb.jl.trx = 'LON0015') then do:

                find t-jl where t-jl.type = 8 exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 8
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = ''
                          t-jl.cre1 = '00000058'
                          t-jl.cre2 = 'Договор'
                          t-jl.cre3 = 'ШтрафыПоКредиту'
                          t-jl.amount = 0
                          t-jl.des = 'Оплата штрафов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 
              end.


        /*начисление %%*/

              if txb.jl.lev = 11 and txb.jl.sub = 'lon' and txb.jl.dc = 'C' then do:

                find t-jl where t-jl.type = 10 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 10
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = 'ПроцентыПоКредиту'
                          t-jl.cre1 = txb.cmp.addr[3]
                          t-jl.cre2 = '00000007'
                          t-jl.cre3 = '00000001'
                          t-jl.amount = 0
                          t-jl.des = 'Начисление процентов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 

              end.

        /*начисление штрафов*/

              if txb.jl.lev = 16 and txb.jl.sub = 'lon' and txb.jl.dc = 'D' then do:

                find t-jl where t-jl.type = 12 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 12
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = 'ШтрафПоКредиту'
                          t-jl.cre1 = txb.cmp.addr[3]
                          t-jl.cre2 = '00000008'
                          t-jl.cre3 = '00000001'
                          t-jl.amount = 0
                          t-jl.des = 'Начисление штрафов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.dam. 

              end.

        /*  комиссиия с НДС только по счету 460721 */
            if txb.jl.gl = 460721 and txb.jl.dc = 'C' then do:


                  find t-jl where t-jl.type = 5 and t-jl.deb1 = txb.ppoint.tel2 exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 5
                            t-jl.deb1 = txb.ppoint.tel2
                            t-jl.deb2 = '00000030'
                            t-jl.deb3 = ''
                            t-jl.cre1 = '00000058'
                            t-jl.cre2 = 'Договор'
                            t-jl.cre3 = ''
                            t-jl.amount = 0
                            t-jl.des = 'Поступление на авансовый счет'
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + txb.jl.cam. 

                  find t-jl where t-jl.type = 19 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 19
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = 'КомиссииПрочие'
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000001'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Начисление КомиссииПрочие без НДС'
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + (txb.jl.cam / 1.14). 

                  find t-jl where t-jl.type = 20 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 20
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = 'КомиссииПрочие'
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000001'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Погашение КомиссииПрочие '
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + txb.jl.cam . 

                  find t-jl where t-jl.type = 21 exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 21
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = 'КомиссииПрочие'
                            t-jl.cre1 = '00000013'
                            t-jl.cre2 = ''
                            t-jl.cre3 = ''
                            t-jl.amount = 0
                            t-jl.des = 'КомиссииПрочие НДС'
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + (txb.jl.cam - (txb.jl.cam / 1.14)). 

            end. 

    end. /* для филиалов */


/* для Алматы */

  if txb.ppoint.fax = 'alm' then do:
          


/* для Алматы выгрузим кредиты в РКЦ-1 */

       if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'C' and txb.jl.trx = 'lon0052'  then do:

             find t-comm where t-comm.type = 10 and t-comm.cre1 = txb.ppoint.zip exclusive-lock no-error.
             if not avail t-comm then do:
                create t-comm.
                assign t-comm.type = 10
                       t-comm.deb1 = '00000055'
                       t-comm.deb2 = 'Договор'
                       t-comm.deb3 = ''
                       t-comm.cre1 = txb.ppoint.zip
                       t-comm.cre2 = '00000032'
                       t-comm.cre3 = ''
                       t-comm.amount = 0
                       t-comm.des = 'Выдача кредитных средств'
                       t-comm.data = v-dat .
             end.
             t-comm.amount = t-comm.amount + txb.jl.cam. 
       end.


       if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'D'  and txb.jl.trx = 'LON0058' then do:

              find t-comm where t-comm.type = 11 and t-comm.deb1 = txb.ppoint.zip exclusive-lock no-error.
              if not avail t-comm then do:
                 create t-comm.
                 assign t-comm.type = 11
                        t-comm.deb1 = txb.ppoint.zip
                        t-comm.deb2 = '00000009'
                        t-comm.deb3 = ''
                        t-comm.cre1 = '00000055'
                        t-comm.cre2 = 'Договор'
                        t-comm.cre3 = ''
                        t-comm.amount = 0
                        t-comm.des = 'Комиссия за кредит-пог'
                        t-comm.data = v-dat.
              end.
              t-comm.amount = t-comm.amount + txb.jl.dam . 
              v-summ = v-summ + txb.jl.dam . 
        end.

        if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'C' and txb.jl.trx ne 'lon0052'  then do:
        find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
            if avail txb.lon then do:

               find t-comm where t-comm.type = 12 and t-comm.deb1 = txb.ppoint.zip exclusive-lock no-error.
               if not avail t-comm then do:
                  create t-comm.
                  assign t-comm.type = 12
                         t-comm.deb1 = txb.ppoint.zip
                         t-comm.deb2 = '00000009'
                         t-comm.deb3 = ''
                         t-comm.cre1 = '00000055'
                         t-comm.cre2 = 'Договор'
                         t-comm.cre3 = ''
                         t-comm.amount = 0
                         t-comm.des = 'Поступление на авансовый счет'
                         t-comm.data = v-dat .
               end.
               t-comm.amount = t-comm.amount + txb.jl.cam. 
               v-summ = v-summ + txb.jl.cam . 
            end.
        end.


        /* выдача кредита 100% */
              if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'D'  then do:
              find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
                  if avail txb.lon then do:
                     if txb.jl.trx = 'LON0058' then do:

                          find t-jl where t-jl.type = 17 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 17
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииФ'
                                    t-jl.cre1 = txb.cmp.addr[3]
                                    t-jl.cre2 = '00000006'
                                    t-jl.cre3 = '00000001'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за кредит-нач'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 

                          find t-jl where t-jl.type = 18 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 18
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииФ'
                                    t-jl.cre1 = '00000058'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = 'КомиссииФ'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за кредит-пог'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 
                     end.


             /* Погашение ежемесячной комиссии за ведение кредита */
                     if txb.jl.trx = 'cif0006' or txb.jl.trx = 'JOU0026' then do:

                          find t-jl where t-jl.type = 15 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 15
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииК'
                                    t-jl.cre1 = txb.cmp.addr[3]
                                    t-jl.cre2 = '00000001'
                                    t-jl.cre3 = '00000001'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за ведение кредита-нач'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 

                          find t-jl where t-jl.type = 16 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 16
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = 'КомиссииК'
                                    t-jl.cre1 = '00000058'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = 'КомиссииК'
                                    t-jl.amount = 0
                                    t-jl.des = 'Комиссия за ведение кредита-пог'
                                    t-jl.data = v-dat.
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.dam . 

                      end.
                  end.
              end.



              if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'C' and txb.jl.trx = 'lon0052'  then do:

                          find t-jl where t-jl.type = 13 exclusive-lock no-error.
                          if not avail t-jl then do:
                             create t-jl.
                             assign t-jl.type = 13
                                    t-jl.deb1 = '00000058'
                                    t-jl.deb2 = 'Договор'
                                    t-jl.deb3 = ''
                                    t-jl.cre1 = '00000128'
                                    t-jl.cre2 = 'Договор'
                                    t-jl.cre3 = ''
                                    t-jl.amount = 0
                                    t-jl.des = 'Выдача кредитных средств'
                                    t-jl.data = v-dat .
                          end.
                          t-jl.amount = t-jl.amount + txb.jl.cam. 
               end.

          /*погашение кредита*/


              if (txb.jl.lev = 1 or txb.jl.lev = 7) and txb.jl.sub = 'lon' and txb.jl.dc = 'C' and (txb.jl.trx = 'LON0062' or txb.jl.trx = 'LON0079' or txb.jl.trx = 'LON0015') then do:

                find t-jl where t-jl.type = 6 exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 6
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = ''
                          t-jl.cre1 = '00000058'
                          t-jl.cre2 = 'Договор'
                          t-jl.cre3 = ''
                          t-jl.amount = 0
                          t-jl.des = 'Возврат кредитных средств'
                          t-jl.data = v-dat.
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 
              end.


              if (txb.jl.lev = 2 or txb.jl.lev = 9) and txb.jl.sub = 'lon' and txb.jl.dc = 'C' and (txb.jl.trx = 'LON0062' or txb.jl.trx = 'LON0079' or txb.jl.trx = 'LON0015') then do:

                find t-jl where t-jl.type = 7 exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 7
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = ''
                          t-jl.cre1 = '00000058'
                          t-jl.cre2 = 'Договор'
                          t-jl.cre3 = 'ПроцентыПоКредиту'
                          t-jl.amount = 0
                          t-jl.des = 'Оплата процентов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 
              end.


              if txb.jl.lev = 16 and txb.jl.sub = 'lon' and txb.jl.dc = 'C' and (txb.jl.trx = 'LON0062' or txb.jl.trx = 'LON0079' or txb.jl.trx = 'LON0015') then do:

                find t-jl where t-jl.type = 8 exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 8
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = ''
                          t-jl.cre1 = '00000058'
                          t-jl.cre2 = 'Договор'
                          t-jl.cre3 = 'ШтрафыПоКредиту'
                          t-jl.amount = 0
                          t-jl.des = 'Оплата штрафов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 
              end.


        /*начисление %%*/

              if txb.jl.lev = 11 and txb.jl.sub = 'lon' and txb.jl.dc = 'C' then do:

                find t-jl where t-jl.type = 10 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 10
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = 'ПроцентыПоКредиту'
                          t-jl.cre1 = txb.cmp.addr[3]
                          t-jl.cre2 = '00000007'
                          t-jl.cre3 = '00000001'
                          t-jl.amount = 0
                          t-jl.des = 'Начисление процентов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.cam. 

              end.

        /*начисление штрафов*/

              if txb.jl.lev = 16 and txb.jl.sub = 'lon' and txb.jl.dc = 'D' then do:

                find t-jl where t-jl.type = 12 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                if not avail t-jl then do:
                   create t-jl.
                   assign t-jl.type = 12
                          t-jl.deb1 = '00000058'
                          t-jl.deb2 = 'Договор'
                          t-jl.deb3 = 'ШтрафПоКредиту'
                          t-jl.cre1 = txb.cmp.addr[3]
                          t-jl.cre2 = '00000008'
                          t-jl.cre3 = '00000001'
                          t-jl.amount = 0
                          t-jl.des = 'Начисление штрафов'
                          t-jl.data = v-dat .
                end.
                t-jl.amount = t-jl.amount + txb.jl.dam. 

              end.

        /*  комиссиия с НДС только по счету 460721 */
            if txb.jl.gl = 460721 and txb.jl.dc = 'C' then do:

                  find t-jl where t-jl.type = 19 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 19
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = 'КомиссииПрочие'
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000001'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Начисление КомиссииПрочие без НДС'
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + (txb.jl.cam / 1.14). 

                  find t-jl where t-jl.type = 20 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 20
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = 'КомиссииПрочие'
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000001'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Погашение КомиссииПрочие '
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + txb.jl.cam . 

            end. 

   end. /* для Алматы */



  end.

  if v-summ > 0 then do:
        find t-jl where t-jl.type = 14 exclusive-lock no-error.
        if not avail t-jl then do:
           create t-jl.
           assign t-jl.type = 14
                  t-jl.deb1 = '00000128'
                  t-jl.deb2 = 'Договор'
                  t-jl.deb3 = ''
                  t-jl.cre1 = '00000058'
                  t-jl.cre2 = 'Договор'
                  t-jl.cre3 = ''
                  t-jl.amount = 0
                  t-jl.des = 'Переброска средств на контрагента'
                  t-jl.data = v-dat.
        end.
        t-jl.amount = t-jl.amount + v-summ . 
  end.




