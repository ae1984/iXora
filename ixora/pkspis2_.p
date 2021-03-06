﻿/* pkspis2_.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Сбор данных во временную таблицу по всем филиалам для кредитного портфеля быстрые деньги со спец.условиями кредитования
 * RUN
        вызов из pkspis_
 * CALLER
        pkspis_
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        
 * BASES
       BANK COMM       
       
 * AUTHOR
        19/09/2008 galina
 * CHANGES

*/

def input parameter d1 as date no-undo.

def shared var s-ourbank as char.
define shared var s-credtype as char.
define shared var g-today  as date.

{pk0.i}

def var rat as decimal no-undo.
def var long as int no-undo init 0.
def new shared var bilance as decimal format '->,>>>,>>>,>>9.99'.
def new shared var bilance7 as decimal format '->,>>>,>>>,>>9.99'.
def var dlong as date no-undo.
def var srok as deci no-undo.
def var dat1 as date no-undo.
def var dat2 as date no-undo.
def var dat3 as date no-undo.
def var dat4 as date no-undo.
def var otrasl as char no-undo.
def var v-obes as char no-undo.
def var v-prolon as integer no-undo init 0.
def var v-rate as decimal no-undo.
def var v-dolg as decimal no-undo.
def var v-sum as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var v-sumt as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var tempgrp as int no-undo.
define var bal% as decimal no-undo.
define var bal%9 as decimal no-undo.
define var dn1 as integer no-undo.
define var dn2 as decimal no-undo.
def var v-dt as date no-undo.
def var v-grsum as deci no-undo.

def var v-aaa as char no-undo.
def var nnomer as inte no-undo init 0.

def shared temp-table wrk no-undo
    field bank   as char
    field credtype as char
    field lon    like txb.lon.lon
    field grp   like  txb.lon.grp
    field name   like txb.cif.name
    field gua    like txb.lon.gua
    field amoun  like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field bal% like txb.lon.opnamt
    field balans7 like txb.lon.opnamt
    field bal%9 like txb.lon.opnamt
    field bal%10 like txb.lon.opnamt
    field balanst like txb.lon.opnamt
    field akkr like txb.lon.opnamt
    field garan like txb.lon.opnamt
    field crc    like txb.lon.crc
    field prem   like txb.lon.prem
    field pen_prem as deci
    field dt1    like txb.lon.rdt
    field dt2    like txb.lon.rdt
    field dt3    like txb.lon.rdt
    field dt4    like txb.lon.rdt
    field grsum as deci
    field grsum% as deci
    field duedt  like txb.lon.rdt
    field rez    like txb.lonstat.prc
    field srez   like txb.lon.opnamt
    field zalog  like txb.lon.opnamt
    field srok   as deci
    field gl     like txb.gl.gl
    index main is primary crc desc balans desc.

find first txb.cmp no-lock no-error.

for each txb.lon where txb.lon.grp = 90 or txb.lon.grp = 92 no-lock.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if s-ourbank ne 'TXB00' and s-ourbank ne trim(txb.sysc.chval) then return.

  find first pkanketa where pkanketa.bank = trim(txb.sysc.chval) and pkanketa.lon = txb.lon.lon no-lock no-error.
  if not avail pkanketa then next.
  
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dogorg" no-lock no-error. 
  if not avail pkanketh then next.
  
  run lonbalcrc_txb('lon',txb.lon.lon,d1,"1",yes,txb.lon.crc,output bilance).
  
  run lonbalcrc_txb('lon',txb.lon.lon,d1,"7,8",yes,txb.lon.crc,output bilance7).
  
  v-prolon = 0.
  if bilance + bilance7 > 0 then do:
        
           dat1 = ?.
           dat2 = ?.
           dat3 = ?.
        
           find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        
           create wrk.
           assign wrk.lon   = txb.lon.lon
                  wrk.grp   = txb.lon.grp
                  wrk.name  = txb.cif.name
                  wrk.gua   = txb.lon.gua
                  wrk.amoun = txb.lon.opnamt
                  wrk.gl = txb.lon.gl.
           
           if pkanketa.id_org = '' then wrk.bank = txb.cmp.name.
           else do:
             find first extuser where extuser.login = pkanketa.rwho no-lock no-error.
             if avail extuser then wrk.bank = extuser.id_org + ' - ' + extuser.id_dept.
           end.
           
           dlong = txb.lon.duedt.
           if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
           if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].
        
           if txb.lon.ddt[5] <> ? then v-prolon = v-prolon + 1.
           if txb.lon.cdt[5] <> ? then v-prolon = v-prolon + 1.
        
          /*выдача займа*/
           dat1 = txb.lon.rdt.
           
           /* последнее погашение */
           find last txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 = 0 no-lock no-error.
           if avail txb.lnsch then dat2 = txb.lnsch.stdat.
                              else dat2 = ?.
        
           find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 = 0 no-lock no-error.
           if avail txb.lnsci and (txb.lnsci.idat > dat2 or dat2 = ?) then dat2 = txb.lnsci.idat.
        
           /* следующее погашение по графику */
           find first txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > d1 no-lock no-error.
           if avail txb.lnsch then do: dat3 = txb.lnsch.stdat. wrk.grsum = txb.lnsch.stval. end.
                              else dat3 = ?.
           
           find first txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat > d1 no-lock no-error.
           if avail txb.lnsci then do: dat4 = txb.lnsci.idat. wrk.grsum% = txb.lnsci.iv-sc. end.
                              else dat4 = ?.
           
           
           find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
           find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            
           v-sum = pkanketa.billsum.
           
           
           /* Сумма на текущем счете для погашения кредита */
           if pkanketa.crc = 1 then v-aaa = pkanketa.aaa. 
                               else v-aaa = pkanketa.aaaval.
        
           if d1 = g-today then do:
              find last txb.aaa where txb.aaa.aaa = v-aaa no-lock no-error.
              if avail txb.aaa then wrk.balanst = txb.aaa.cr[1] - txb.aaa.dr[1].
           end.
           else do:
              find last txb.aab where txb.aab.aaa = v-aaa and txb.aab.fdt <= d1 no-lock no-error.
              if avail txb.aab then wrk.balanst = txb.aab.bal.
           end. 
        
         bal% = 0. bal%9 = 0.
         if lookup(string(txb.lon.plan), "0,1,2") <> 0 then do:
             for each txb.acr where txb.acr.lon = txb.lon.lon and txb.acr.fdt <= d1 no-lock:
                 if txb.acr.tdt > d1 then v-dt = d1.
                                     else v-dt = txb.acr.tdt.
                 run day-360(txb.acr.fdt, v-dt, txb.lon.basedy, output dn1, output dn2).
                 bal% = bal% + round(txb.acr.rate * dn1 * txb.acr.prn / 100 / txb.lon.basedy,2).
             end.
         end.
         if txb.lon.plan = 5 or txb.lon.plan = 4 then do:
            run lonbalcrc_txb('lon',txb.lon.lon,d1,"2",yes,txb.lon.crc,output bal%).
            run lonbalcrc_txb('lon',txb.lon.lon,d1,"9",yes,txb.lon.crc,output bal%9).
            run lonbalcrc_txb('lon',txb.lon.lon,d1,"10",yes,txb.lon.crc,output bal%10).
         end.
         /*  09/04/07 marinav
            for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 = 0 and txb.lnsci.idat <= d1 no-lock:
                bal% = bal% - txb.lnsci.paid-iv.
            end.
          */
        
            find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
            assign wrk.balans = bilance + wrk.akkr + wrk.garan
                   wrk.bal% = bal% 
                   wrk.balans7 = bilance7
                   wrk.bal%9 = bal%9
                   wrk.bal%10 = bal%10
                   wrk.crc = txb.lon.crc
                   wrk.prem = txb.lon.prem
                   wrk.pen_prem = txb.loncon.sods1
                   wrk.dt1 =  dat1
                   wrk.dt2 = dat2
                   wrk.dt3 = dat3
                   wrk.dt4 = dat4
                   wrk.duedt = dlong
                   wrk.zalog = v-sum
                   wrk.srok  = dlong - d1.
             
           find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "tarfnd" no-lock no-error.
           assign  wrk.rez = pksysc.deval
                   wrk.srez = pkanketa.sumcom.

           find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
           wrk.credtype = bookcod.name.

  end.   /* bilance + bilance7 > 0 */
end.  /* txb.lon */                      


