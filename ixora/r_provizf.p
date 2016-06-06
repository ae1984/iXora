/* r_provizf.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-cods.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-7-3-14
 * AUTHOR
       01/04/2011
 * BASES
	   COMM TXB
 * CHANGES
       29/11/2011 madiyar - с 5% СК сравниваем не остаток по одному кредиту, а сумму всех действующих займов клиента
       05/11/2011 kapar - дополнение к 5% СК
       05/11/2011 kapar - изменил алгоритм расчета
       06/06/2012 kapar - добавил поле "Общая<br>сумма пула</td> на выб. дату"
       18/06/2012 kapar - ТЗ N1149 Новые группы
       25/07/2012 kapar - ТЗ N1149 изменение
       29/12/2012 sayat (id01143) - исправил ошибку при расчете суммы валютных займов
*/

def shared temp-table lnpr no-undo
  field id       as   char
  field name     as   char
  field n1       as   decimal
  field n11      as   decimal
  field n2       as   decimal
  field n3       as   decimal
  field n4       as   decimal
  field n5       as   decimal
  field n6       as   decimal
  field n7       as   decimal
  field n8       as   decimal
  field n9       as   decimal.


def shared var v-dt as date no-undo.
def shared var r-dt as date no-undo.
def shared var v-pool as char no-undo extent 10.
def shared var v-poolName as char no-undo extent 10.
def shared var v-poolId as char no-undo extent 10.
def shared var v-sum_msb as deci no-undo.
def shared var t-sum_msb as deci no-undo.
def shared var f-sum_msb as deci no-undo.
def var poolIndex as integer no-undo.
def var poolDes as char no-undo.
def var j as integer no-undo.

def buffer b-lon for txb.lon.
def buffer c-lon for txb.lon.

def var e-dt    as date no-undo.
def var v-bal as deci no-undo.
def var v-bal_all as deci no-undo.
def var v-od    as deci no-undo.
def var v-prc   as deci no-undo.
def var v-pen   as deci no-undo.
def var v-clmain as char.

def var rates as deci extent 3.

/*Общая<br>сумма пула</td> на тек. дату*/
rates[1] = 1.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < v-dt no-lock no-error.
if avail txb.crchis then rates[2] = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < v-dt no-lock no-error.
if avail txb.crchis then rates[3] = txb.crchis.rate[1].

for each txb.lon no-lock:

  run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"1,7",no,txb.lon.crc,output v-od).
  v-od = v-od * rates[txb.lon.crc].
  run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"2,9",no,txb.lon.crc,output v-prc).
  v-prc = v-prc * rates[txb.lon.crc].
  run lonbalcrc_txb('lon',txb.lon.lon,v-dt,"16",no,1,output v-pen).

  if  v-od <= 0 and v-prc <= 0 and v-pen <= 0 then next.

      poolIndex = 0.
      do j = 1 to 10:
          if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
      end.

      if (poolIndex < 1) or (poolIndex > 10) then poolDes = ''.
      else
      if (poolIndex = 7) or (poolIndex = 8) then do:
          v-bal_all = 0. v-clmain = ''.
          if v-dt >= date('01.07.2012') then do:
                for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                    run lonbalcrc_txb('lon',b-lon.lon,v-dt,"1,7",no,b-lon.crc,output v-bal).
                    if v-bal > 0 then do:
                        if b-lon.clmain <> '' then do:
                            if lookup(b-lon.clmain,v-clmain) = 0 then do:
                                v-clmain = v-clmain + string(b-lon.clmain) + ','.
                                find last c-lon where c-lon.lon = b-lon.clmain no-lock no-error.
                                if c-lon.opnamt > 0 then do:
                                    v-bal = c-lon.opnamt.
                                    if c-lon.crc <> 1 then v-bal = v-bal * rates[c-lon.crc].
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                        end.
                        else do:
                            if b-lon.gua <> 'CL' then do:
                                if b-lon.opnamt > 0 then do:
                                    v-bal = b-lon.opnamt.
                                    if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                                    v-bal_all = v-bal_all + v-bal.
                                end.
                            end.
                        end.
                    end.
                end.
                if v-bal_all < v-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
          end.
          else do:
              if v-dt >= date('01.01.2012') then do:
                  for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                    run lonbalcrc_txb('lon',b-lon.lon,v-dt,"1,7",no,b-lon.crc,output v-bal).
                    if v-bal > 0 then do:
                        if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                        v-bal_all = v-bal_all + v-bal.
                    end.
                  end.
              end.
              else do:
                 run lonbalcrc_txb('lon',lon.lon,v-dt,"1,7,13",no,lon.crc,output v-bal).
                 if v-bal > 0 then do:
                    if lon.crc <> 1 then v-bal = v-bal * rates[lon.crc].
                    v-bal_all = v-bal_all + v-bal.
                 end.
              end.
          end.
          if v-bal_all < v-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
      end.
      else poolDes = v-poolId[poolIndex].

  find first lnpr where lnpr.id = poolDes no-lock no-error.
  if avail lnpr then do:
    lnpr.n1 = lnpr.n1 + v-od + v-prc + v-pen.
  end.

end. /* for each txb.lon */

/*Общая<br>сумма пула</td> на выб. дату*/
rates[1] = 1.
find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < r-dt no-lock no-error.
if avail txb.crchis then rates[2] = txb.crchis.rate[1].
find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < r-dt no-lock no-error.
if avail txb.crchis then rates[3] = txb.crchis.rate[1].

for each txb.lon no-lock:

  run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"1,7",no,txb.lon.crc,output v-od).
  v-od = v-od * rates[txb.lon.crc].
  run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"2,9",no,txb.lon.crc,output v-prc).
  v-prc = v-prc * rates[txb.lon.crc].
  run lonbalcrc_txb('lon',txb.lon.lon,r-dt,"16",no,1,output v-pen).

  if  v-od <= 0 and v-prc <= 0 and v-pen <= 0 then next.

    if r-dt < date('02/01/2012') then do: /* история привязки к пулам начинается с 01.02.2012 */
      poolIndex = 0.
      do j = 1 to 10:
          if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
      end.

      if (poolIndex < 1) or (poolIndex > 10) then poolDes = ''.
      else
      if (poolIndex = 7) or (poolIndex = 8) then do:
          v-bal_all = 0.
          if r-dt >= date('01.01.2012') then do:
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                run lonbalcrc_txb('lon',b-lon.lon,r-dt,"1,7",no,b-lon.crc,output v-bal).
                if v-bal > 0 then do:
                    if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                    v-bal_all = v-bal_all + v-bal.
                end.
              end.
          end.
          else do:
             run lonbalcrc_txb('lon',lon.lon,r-dt,"1,7",no,lon.crc,output v-bal).
             if v-bal > 0 then do:
                if lon.crc <> 1 then v-bal = v-bal * rates[lon.crc].
                v-bal_all = v-bal_all + v-bal.
             end.
          end.
          if v-bal_all < v-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
      end.
      else poolDes = v-poolId[poolIndex].
    end.
    else do:
        poolDes = ''.
        find last txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= r-dt no-lock no-error.
        if avail txb.lonpool then poolDes = txb.lonpool.poolId.
    end.

  find first lnpr where lnpr.id = poolDes no-lock no-error.
  if avail lnpr then do:
    lnpr.n11 = lnpr.n11 + v-od + v-prc + v-pen.
  end.

end. /* for each txb.lon */


if v-dt >= r-dt then do:
    e-dt = date(month(r-dt),1,year(r-dt)).
    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < e-dt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < e-dt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].

    for each txb.lon no-lock:

      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"6",no,txb.lon.crc,output v-od).
      v-od = - v-od * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"36",no,txb.lon.crc,output v-prc).
      v-prc = - v-prc * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"37",no,1,output v-pen).
      v-pen =  - v-pen.

      if (v-od + v-prc + v-pen ) <= 0 then next.


    if e-dt < date('02/01/2012') then do: /* история привязки к пулам начинается с 01.02.2012 */
      poolIndex = 0.
      do j = 1 to 10:
          if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
      end.

      if (poolIndex < 1) or (poolIndex > 10) then poolDes = ''.
      else
      if (poolIndex = 7) or (poolIndex = 8) then do:
          v-bal_all = 0.
          if e-dt >= date('01.01.2012') then do:
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                run lonbalcrc_txb('lon',b-lon.lon,e-dt,"1,7",no,b-lon.crc,output v-bal).
                if v-bal > 0 then do:
                    if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                    v-bal_all = v-bal_all + v-bal.
                end.
              end.
          end.
          else do:
             if v-bal > 0 then do:
             run lonbalcrc_txb('lon',lon.lon,v-dt,"1,7",no,lon.crc,output v-bal).
                if lon.crc <> 1 then v-bal = v-bal * rates[lon.crc].
                v-bal_all = v-bal_all + v-bal.
             end.
          end.
          if v-bal_all < f-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
      end.
      else poolDes = v-poolId[poolIndex].
    end.
    else do:
        poolDes = ''.
        find last txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= e-dt no-lock no-error.
        if avail txb.lonpool then poolDes = txb.lonpool.poolId.
    end.

      find first lnpr where lnpr.id = poolDes no-lock no-error.
      if avail lnpr then do:
        lnpr.n4 = lnpr.n4 + v-od + v-prc + v-pen.
      end.

    end. /* for each txb.lon */

    if month(r-dt) = 1 then e-dt = date(12,1,year(r-dt - 1)). else e-dt = date(month(r-dt - 1),1,year(r-dt)).
    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < e-dt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < e-dt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].

    for each txb.lon no-lock:

      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"6",no,txb.lon.crc,output v-od).
      v-od = - v-od * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"36",no,txb.lon.crc,output v-prc).
      v-prc = - v-prc * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"37",no,1,output v-pen).
      v-pen =  - v-pen.

      if (v-od + v-prc + v-pen ) <= 0 then next.


    if e-dt < date('02/01/2012') then do: /* история привязки к пулам начинается с 01.02.2012 */
      poolIndex = 0.
      do j = 1 to 10:
          if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
      end.

      if (poolIndex < 1) or (poolIndex > 10) then poolDes = ''.
      else
      if (poolIndex = 7) or (poolIndex = 8) then do:
          v-bal_all = 0.
          if e-dt >= date('01.01.2012') then do:
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                run lonbalcrc_txb('lon',b-lon.lon,e-dt,"1,7",no,b-lon.crc,output v-bal).
                if v-bal > 0 then do:
                    if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                    v-bal_all = v-bal_all + v-bal.
                end.
              end.
          end.
          else do:
             run lonbalcrc_txb('lon',lon.lon,v-dt,"1,7",no,lon.crc,output v-bal).
             if v-bal > 0 then do:
                if lon.crc <> 1 then v-bal = v-bal * rates[lon.crc].
                v-bal_all = v-bal_all + v-bal.
             end.
          end.
          if v-bal_all < t-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
      end.
      else poolDes = v-poolId[poolIndex].
    end.
    else do:
        poolDes = ''.
        find last txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= e-dt no-lock no-error.
        if avail txb.lonpool then poolDes = txb.lonpool.poolId.
    end.

      find first lnpr where lnpr.id = poolDes no-lock no-error.
      if avail lnpr then do:
        lnpr.n3 = lnpr.n3 + v-od + v-prc + v-pen.
      end.

    end. /* for each txb.lon */
end. else do:
    if month(r-dt) = 1 then e-dt = date(12,1,year(r-dt - 1)). else e-dt = date(month(r-dt - 1),1,year(r-dt)).
    rates[1] = 1.
    find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt < e-dt no-lock no-error.
    if avail txb.crchis then rates[2] = txb.crchis.rate[1].
    find last txb.crchis where txb.crchis.crc = 3 and txb.crchis.rdt < e-dt no-lock no-error.
    if avail txb.crchis then rates[3] = txb.crchis.rate[1].

    for each txb.lon no-lock:

      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"6",no,txb.lon.crc,output v-od).
      v-od = - v-od * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"36",no,txb.lon.crc,output v-prc).
      v-prc = - v-prc * rates[txb.lon.crc].
      run lonbalcrc_txb('lon',txb.lon.lon,e-dt,"37",no,1,output v-pen).
      v-pen =  - v-pen.

      if (v-od + v-prc + v-pen ) <= 0 then next.


    if e-dt < date('02/01/2012') then do: /* история привязки к пулам начинается с 01.02.2012 */
      poolIndex = 0.
      do j = 1 to 10:
          if lookup(string(txb.lon.grp),v-pool[j]) > 0 then poolIndex = j.
      end.

      if (poolIndex < 1) or (poolIndex > 10) then poolDes = ''.
      else
      if (poolIndex = 7) or (poolIndex = 8) then do:
          v-bal_all = 0.
          if e-dt >= date('01.01.2012') then do:
              for each b-lon where b-lon.cif = txb.lon.cif no-lock:
                run lonbalcrc_txb('lon',b-lon.lon,e-dt,"1,7",no,b-lon.crc,output v-bal).
                if v-bal > 0 then do:
                    if b-lon.crc <> 1 then v-bal = v-bal * rates[b-lon.crc].
                    v-bal_all = v-bal_all + v-bal.
                end.
              end.
          end.
          else do:
             run lonbalcrc_txb('lon',lon.lon,v-dt,"1,7",no,lon.crc,output v-bal).
             if v-bal > 0 then do:
                if lon.crc <> 1 then v-bal = v-bal * rates[lon.crc].
                v-bal_all = v-bal_all + v-bal.
             end.
          end.
          if v-bal_all < t-sum_msb then poolDes = v-poolId[7]. else poolDes = v-poolId[8].
      end.
      else poolDes = v-poolId[poolIndex].
    end.
    else do:
        poolDes = ''.
        find last txb.lonpool where txb.lonpool.cif = txb.lon.cif and txb.lonpool.lon = txb.lon.lon and txb.lonpool.rdt <= e-dt no-lock no-error.
        if avail txb.lonpool then poolDes = txb.lonpool.poolId.
    end.

      find first lnpr where lnpr.id = poolDes no-lock no-error.
      if avail lnpr then do:
        lnpr.n3 = lnpr.n3 + v-od + v-prc + v-pen.
      end.

    end. /* for each txb.lon */
end.


