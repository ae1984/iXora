
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

find first txb.cmp.

FOR EACH txb.jl  where txb.jl.jdt = v-dat NO-LOCK :

  /* выдача кредита */
      if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'D'  then do:
      find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
          if avail txb.lon then do:
             if txb.jl.trx = 'LON0058' then do:

                  find t-jl where t-jl.type = 4 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 4
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = ''
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000006'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Комиссия за кредит'
                            t-jl.data = v-dat.
                  end.
                  t-jl.amount = t-jl.amount + txb.jl.dam . 
             end.


             if txb.jl.trx = 'LON0059' then do:

                  find t-jl where t-jl.type = 22 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 22
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = ''
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000001'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Закрытие остатков л/с при погашении кредита'
                            t-jl.data = v-dat.
                  end.
                  t-jl.amount = t-jl.amount + txb.jl.dam . 
             end.

             if txb.jl.trx = 'JOU0016'  then do:

                find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt le txb.jl.jdt no-lock no-error.
                find last txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.

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
                  t-jl.amount = t-jl.amount + txb.jl.dam. 
             end.

     /* Погашение ежемесячной комиссии за ведение кредита */
             if txb.jl.trx = 'cif0006' or txb.jl.trx = 'JOU0026' then do:

                  find t-jl where t-jl.type = 9 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 9
                            t-jl.deb1 = '00000058'
                            t-jl.deb2 = 'Договор'
                            t-jl.deb3 = ''
                            t-jl.cre1 = txb.cmp.addr[3]
                            t-jl.cre2 = '00000001'
                            t-jl.cre3 = '00000001'
                            t-jl.amount = 0
                            t-jl.des = 'Комиссия за ведение кредита'
                            t-jl.data = v-dat.
                  end.
                  t-jl.amount = t-jl.amount + txb.jl.dam . 

              end.
          end.
      end.

  /*погашение кредита*/

      if txb.jl.lev = 1 and txb.jl.sub = 'cif' and txb.jl.dc = 'C' and txb.jl.trx ne 'lon0052'  then do:
      find first txb.lon where txb.lon.aaa = txb.jl.acc no-lock no-error.
          if avail txb.lon then do:

               find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt le txb.jl.jdt no-lock no-error.
               find last txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.

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

       find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt le txb.jl.jdt no-lock no-error.
       find last txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.

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
end.       

