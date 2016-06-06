/* fiztxb.p
 * MODULE
        Счета
 * DESCRIPTION
        Отчет по текущим счетам физических лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-7-1-16-4-2
 * AUTHOR
        28.04.06 dpuchkov
 * CHANGES
        03.05.2006 dpuchkov - исправил ошибки при суммировании итоговых сумм.
        28.08.2006 dpuchkov - оптимизация
*/

/* Connect - comm, txb */


{get-dep.i} 

def shared var d_date as date.

def shared temp-table dn 
     field num      as integer
     field ind      as char
     field tn_kzt   as integer
     field tnul_kzt as integer
     field bn_kzt   as integer
     field bnul_kzt as integer
     field tn_usd   as integer
     field tnul_usd as integer
     field tn_eur   as integer
     field tnul_eur as integer.

  def shared var d-ix as integer.

  find last txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
  if avail txb.sysc then do:
     if txb.sysc.chval = "TXB00" then do: /*Алматы*/
     find last comm.txb where comm.txb.bank = txb.sysc.chval and comm.txb.consolid = True no-lock no-error.

       find txb.sysc where txb.sysc.sysc = 'depart' no-lock no-error.
       for each txb.ppoint where lookup(string(txb.ppoint.depart), txb.sysc.chval) <> 0 no-lock:
           create dn. dn.ind = ppoint.name.
                      dn.num = ppoint.depart.


           for each txb.aaa where lookup(txb.aaa.lgr,"237,236,151,152,153,154,155,156,157,158,171,172,204,202,208,222,232,242") <> 0 and txb.aaa.whn < d_date no-lock:
               find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
               if avail txb.cif and txb.cif.type = "B" then next.
               if txb.aaa.sta = "C" then next.
               if txb.aaa.crc = 1 and get-dep(txb.aaa.who, txb.aaa.whn) = ppoint.depart then do:
                  find last txb.lon where txb.lon.aaa = txb.aaa.aaa  and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
                  if avail txb.lon then do: /*быстрые*/
                     if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.bnul_kzt = bnul_kzt + 1. else dn.bn_kzt = bn_kzt + 1.
                  end.
                  else 
                  do: /*обычные*/
                      if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.tnul_kzt = dn.tnul_kzt + 1. else dn.tn_kzt = dn.tn_kzt + 1.
                  end.
               end.
               if txb.aaa.crc = 2 and get-dep(txb.aaa.who, txb.aaa.whn) = ppoint.depart then do:
                  find last txb.lon where txb.lon.aaa = txb.aaa.aaa  and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
                  if avail txb.lon then do: /*быстрые*/

                  end.
                  else 
                  do: /*обычные*/
                      if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.tnul_usd = dn.tnul_usd + 1. else dn.tn_usd = dn.tn_usd + 1.
                  end.
               end.

               if txb.aaa.crc = 11 and get-dep(txb.aaa.who, txb.aaa.whn) = ppoint.depart then do:
                  find last txb.lon where txb.lon.aaa = txb.aaa.aaa  and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
                  if avail txb.lon then do: /*быстрые*/

                  end.
                  else 
                  do: /*обычные*/
                      if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.tnul_eur = dn.tnul_eur + 1. else dn.tn_eur = dn.tn_eur + 1.
                  end.
               end.
           end.
       end.
     end.  
     else
     do: /*Филиалы*/
         create dn. 
         d-ix = d-ix + 1.

           find last sysc where sysc.sysc = "ourbnk" no-lock no-error.
           find last comm.txb where comm.txb.bank = sysc.chval and comm.txb.consolid = True no-lock no-error.	
           if avail comm.txb then do:
              dn.ind = comm.txb.info. 
           end.
           dn.num = d-ix.

           for each txb.aaa where lookup(txb.aaa.lgr,"237,236,151,152,153,154,155,156,157,158,171,172,204,202,208,222,232,242") <> 0 and txb.aaa.whn < d_date no-lock:
               find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
               if avail txb.cif and txb.cif.type = "B" then next.
               if txb.aaa.sta = "C" then next.
               if txb.aaa.crc = 1  then do:
                  find last txb.lon where txb.lon.aaa = txb.aaa.aaa  and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
                  if avail txb.lon then do: /*быстрые*/
                     if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.bnul_kzt = bnul_kzt + 1. else dn.bn_kzt = bn_kzt + 1.
                  end.
                  else
                  do: /*обычные*/
                      if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.tnul_kzt = dn.tnul_kzt + 1. else dn.tn_kzt = dn.tn_kzt + 1.
                  end.
               end.
               if txb.aaa.crc = 2 then do:
                  find last txb.lon where txb.lon.aaa = txb.aaa.aaa  and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
                  if avail txb.lon then do: /*быстрые*/

                  end.
                  else 
                  do: /*обычные*/
                      if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.tnul_usd = dn.tnul_usd + 1. else dn.tn_usd = dn.tn_usd + 1.
                  end.
               end.

               if txb.aaa.crc = 11 then do:
                  find last txb.lon where txb.lon.aaa = txb.aaa.aaa  and (txb.lon.grp = 90 or txb.lon.grp = 92) no-lock no-error.
                  if avail txb.lon then do:  /*быстрые*/

                  end.
                  else
                  do: /* обычные */
                      if txb.aaa.cr[1] - txb.aaa.dr[1] <= 0 then dn.tnul_eur = dn.tnul_eur + 1. else dn.tn_eur = dn.tn_eur + 1.
                  end.
               end.
           end.
     end.
  end.


















