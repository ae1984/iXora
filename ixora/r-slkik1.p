 /* repslkik.p
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
        4-4-8-4-5
 * AUTHOR
        14/12/05 Natalya D.
 * CHANGES
        01/03/2006 Natalya D. - добавила период для формирования отчёта за период.
        06/03/2006 Natalya D. - поправила формат даты
        10/04/2006 Natalya D. - переделала под новые требования
*/

/* Отчет по продажам в КИК на дату */

def input parameter dt1 as date.
/*def input parameter dt2 as date.*/
def var name-bank as char no-undo .
def var s-bank    as char no-undo .
def var v-bal1    as deci no-undo .
def var v-bal26   as deci no-undo .
def var v-bal17   as deci no-undo .
def var v-kdkik   as char no-undo .
def var v-clsarep as char no-undo .
def var v-sumz    as deci no-undo .
def var v-zalog   as char no-undo .

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  return.
end.
else s-bank = txb.sysc.chval.

define shared temp-table t_t3 no-undo
       field lon like txb.lon.lon
       field name like txb.cif.name
       field cif like txb.lon.cif
       field vid_p as char       
       field opnamt like txb.lon.opnamt
       field opndt like txb.lon.opndt
       field jdt like txb.lonres.jdt
       field prc_first as deci
       field prc_last as deci
       field zero_1lev as date
       field quar as char
       field sumqua as deci
       field insur as date
       field sum26 as deci
       field prim as char
       field code_branch like txb.sysc.chval
       field name_branch as char
       index indx2 code_branch
       index indx3 lon
       index indx4 cif.

name-bank = "".
find first comm.txb where comm.txb.bank = s-bank.
  name-bank = comm.txb.name.

for each txb.lon where txb.lon.grp = 67 or txb.lon.grp = 27 no-lock.

  assign v-sumz = 0 v-zalog = '' v-bal1 = 0 v-bal26 = 0 v-bal17 = 0 v-kdkik = '' v-clsarep = '' . 
  find first txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 1 
                          and txb.lonres.dc = 'd' no-lock no-error.
  if avail txb.lonres then do:        
    find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon 
                                                   and txb.sub-cod.d-cod = 'lntreb' 
                                                   and txb.sub-cod.ccode = '1' 
                                                   no-lock no-error.           
    if avail txb.sub-cod then do:
      find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon 
                                                 and txb.sub-cod.d-cod = 'kdkik' 
                                                 no-lock no-error.
      if not avail txb.sub-cod then v-kdkik = 'msc'.  
      else
      v-kdkik = txb.sub-cod.ccode.
      find txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon 
                                                 and txb.sub-cod.d-cod = 'clsarep' no-lock no-error.  
      if not avail txb.sub-cod then v-clsarep = 'msc'.
      else v-clsarep = txb.sub-cod.ccode.
      create t_t3.
             t_t3.lon = txb.lon.lon.
             t_t3.cif = txb.lon.cif.
             t_t3.opnamt = txb.lon.opnamt.      
             t_t3.opndt = txb.lon.opndt.
             t_t3.jdt = txb.lonres.jdt.    /*дата выдачи кредита*/
             t_t3.code_branch = s-bank.
             t_t3.name_branch = name-bank.      
      find first txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.intrate <> 0 no-lock no-error.
      if not avail txb.ln%his then next.
      else  
             t_t3.prc_first = txb.ln%his.intrate.
      find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.intrate <> 0 no-lock no-error.
      if not avail txb.ln%his then next.
      else  
             t_t3.prc_last = txb.ln%his.intrate .
      find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
      if avail txb.cif then
             t_t3.name = txb.cif.name.     
      else   t_t3.name = txb.lon.cif.
      find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.      
      if substring(txb.loncon.lcnt, length(entry(1,caps(txb.loncon.lcnt),'ИП')) + 1,2) = 'ИП' then
             t_t3.vid_p = 'рыночная программа'.
      if substring(txb.loncon.lcnt, length(entry(1,caps(txb.loncon.lcnt),'ГП')) + 1,2) = 'ГП' then
             t_t3.vid_p = 'государственная программа'.            
      
      for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock.      
             v-sumz = v-sumz + txb.lonsec1.secamt.
             v-zalog = v-zalog + entry(1,txb.lonsec1.vieta,'&') + ' ; ' .             
      end.
      t_t3.quar = v-zalog.
      t_t3.sumqua = v-sumz.        
      find first txb.lnmoncln where txb.lnmoncln.lon = txb.lon.lon and txb.lnmoncln.code = 'insur' and txb.lnmoncln.edt = ?
                                   no-lock no-error /*by txb.lnmoncln.pwho descending*/ .

      if avail txb.lnmoncln then
                t_t3.insur = txb.lnmoncln.pdt.

      /*run lonbalcrc('lon',txb.lon.lon,dt1,"26",yes,lon.crc,output v-bal26).
                t_t3.sum26 = v-bal26.  
      run lonbalcrc('lon',txb.lon.lon,dt1,"1,7",yes,lon.crc,output v-bal17).*/
      find txb.trxbal where txb.trxbal.subled = 'LON' and txb.trxbal.acc = txb.lon.lon and txb.trxbal.level = 1 no-lock no-error.
      v-bal17 = txb.trxbal.dam - txb.trxbal.cam.
      if v-bal17 = 0 then do:
         for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 1 and txb.lonres.dc = 'c' no-lock by txb.lonres.jdt .
            run lonresbal('lon',txb.lon.lon,txb.lonres.jdt,"1,7",yes,lon.crc,output v-bal1).
            if v-bal1 = 0 then do:
             t_t3.zero_1lev = txb.lonres.jdt. 
             leave.
            end.         
         end. 
      end.
      find txb.trxbal where txb.trxbal.subled = 'LON' and txb.trxbal.acc = txb.lon.lon and txb.trxbal.level = 26 no-lock no-error.
      if avail txb.trxbal then v-bal26 = txb.trxbal.dam - txb.trxbal.cam.
      else v-bal26 = 0.
                t_t3.sum26 = v-bal26.
      if v-bal17 ne 0 and v-kdkik ne '01' then
                t_t3.prim = 'невыкупленный'.
      if (v-bal26 ne 0 and v-kdkik = '01') or v-kdkik = '01' then      
                t_t3.prim = 'выкупленный'.
      if v-kdkik = '01' and v-clsarep = '01' then
                t_t3.prim = 'досрочно погашенный'.
/*displ txb.lon.cif dt1 v-bal17 v-kdkik v-clsarep skip.*/
    end.
  end.
end.
