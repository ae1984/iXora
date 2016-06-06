 /* repcred1.p
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
        14/12/05 Natalya D.
 * CHANGES
        22/02/06 Natalya D. - исправила вывод данных за заданную дату, соответствующую дате зачисления кредита на счёт
*/      

/* Отчет по кредитам, выданным за день, в разрезе менеджеров по филиалам */

def input parameter d_date as date.
def input parameter v-kurs as decimal.
def var v-numstr  as integer no-undo.
def var crlf as char no-undo.
def var return_choice as logical no-undo.
def var ttlsum_usd_kzt as decimal no-undo.
def var ttlsum as decimal no-undo.
def var v-cnt as integer no-undo.
def var col6 as decimal no-undo.
def var col7 as decimal no-undo.
def var col8 as decimal no-undo.
def var col9 as decimal no-undo.
def var col10 as decimal no-undo.
def var col11 as decimal no-undo.
def var col12 as decimal no-undo.
def var c-cred-p as character initial ["20,25,26,27,60,65,66,67,80"].
def var c-cred-b as character initial ["90,92"].
def var name-bank as char no-undo.
def var s-bank as char no-undo.
def var itog_sum as decimal no-undo.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  return.
end.
else s-bank = txb.sysc.chval.
/*display s-bank.*/

define shared temp-table tmp_t1  no-undo
       field name like txb.loncon.pase-pier
       field sum_kzt as decimal
       field sum_usd as decimal
       field ttl_sum as decimal
       field prem_kzt like txb.lon.prem
       field prem_usd like txb.lon.prem
       field srok_kzt as integer
       field srok_usd as integer
       field code_cred as integer
       field cif like txb.cif.cif
       field code_branch like txb.sysc.chval
       index indx1 code_branch
       index indx2 name.

define shared temp-table tmp_t2  no-undo
       field pp_num as integer
       field name like txb.ofc.name
       field sum_kzt as decimal
       field sum_usd as decimal
       field ttl_sum as decimal
       field part as decimal
       field cnt_cstm as integer
       field avrg_sum as integer
       field prem_kzt like txb.lon.prem
       field prem_usd like txb.lon.prem
       field srok_kzt as integer
       field srok_usd as integer
       field code_branch like txb.sysc.chval
       field name_branch as char
       index indx3 code_branch.

define shared temp-table tmp_t3  no-undo
       field vid_cred as character
       field p_kzt as decimal
       field p_usd as decimal
       field ttl_usd as decimal
       field cnt_cstm as integer
       field code_branch like txb.sysc.chval
       field name_branch as char
       index indx4 code_branch.
  name-bank = "".
find first comm.txb where comm.txb.bank = s-bank.
  name-bank = comm.txb.name.         
  v-numstr = 0.
/*заполняем временную таблицу, отфильтровав по виду кредитования*/
for each txb.loncon, each txb.lon where txb.lon.lon=txb.loncon.lon /*and txb.lon.opndt = d_date */
                          and (LOOKUP(STRING(txb.lon.grp),c-cred-p) > 0 
                               or LOOKUP(STRING(txb.lon.grp),c-cred-b) > 0)  no-lock.
   find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.stdat = d_date no-lock no-error.
  if not avail txb.lnscg then next.
  ttlsum  = txb.lon.dam[1] - txb.lon.cam[1].
  if ttlsum <> 0 then do:
  create tmp_t1.
    IF LOOKUP(STRING(txb.lon.grp),c-cred-p) > 0 
    THEN do: 
         tmp_t1.code_cred = 1.
         if txb.loncon.pase-pier ne '' then
            tmp_t1.name = txb.loncon.pase-pier.
         else tmp_t1.name = txb.lon.who.
    end.
    IF LOOKUP(STRING(txb.lon.grp),c-cred-b) > 0
    THEN do: tmp_t1.code_cred = 2.
             tmp_t1.name = ''.
    end.           
    if txb.lon.crc = 1 then do:
       
       tmp_t1.sum_kzt = ttlsum.
       tmp_t1.sum_usd = 0.
       tmp_t1.ttl_sum = ttlsum.
       tmp_t1.prem_kzt = txb.lon.prem.
       tmp_t1.prem_usd = 0.
       tmp_t1.srok_kzt = txb.lon.duedt - txb.lon.opndt.
       tmp_t1.srok_usd = 0.
       tmp_t1.cif = txb.lon.cif.
    end.
    if txb.lon.crc = 2 then do:
       ttlsum_usd_kzt = ttlsum * v-kurs.
       /*tmp_t1.name = txb.loncon.pase-pier.*/
       tmp_t1.sum_kzt = 0.
       tmp_t1.sum_usd = ttlsum.
       tmp_t1.ttl_sum = ttlsum_usd_kzt.
       tmp_t1.prem_kzt = 0.
       tmp_t1.prem_usd = txb.lon.prem.
       tmp_t1.srok_kzt = 0.
       tmp_t1.srok_usd = txb.lon.duedt - txb.lon.opndt.
      /* tmp_t1.code_cred = txb.lon.grp.*/
       tmp_t1.cif = txb.lon.cif.
    end.  
    tmp_t1.code_branch = s-bank.
  end.
end.
/*находим общую сумму по всем менеджерам*/
for each tmp_t1 where tmp_t1.code_branch = s-bank no-lock break by tmp_t1.name.
 accumulate tmp_t1.ttl_sum(total by tmp_t1.name).
end.
 itog_sum = (accum total tmp_t1.ttl_sum).
/*заполняем временную таблицу 2, расчитав все средневзвешенные суммы*/
for each tmp_t1 where tmp_t1.code_branch = s-bank no-lock break by tmp_t1.name.
  
  accumulate tmp_t1.sum_kzt(total by tmp_t1.name).
  accumulate tmp_t1.sum_usd(total by tmp_t1.name).
  accumulate tmp_t1.ttl_sum(total by tmp_t1.name).
  accumulate tmp_t1.prem_kzt(total by tmp_t1.name).
  accumulate tmp_t1.prem_usd(total by tmp_t1.name).
  accumulate tmp_t1.srok_kzt(total by tmp_t1.name).
  accumulate tmp_t1.srok_usd(total by tmp_t1.name).
  accumulate tmp_t1.cif(sub-count by tmp_t1.name).
  
  if last-of (tmp_t1.name) then do:
   find txb.ofc where txb.ofc.ofc = tmp_t1.name no-lock no-error.
   v-numstr = v-numstr + 1.
   col6 = ((accum total by tmp_t1.name tmp_t1.ttl_sum) * 100) / (itog_sum).
   col7 = (accum sub-count by tmp_t1.name tmp_t1.cif).
   col8 = (accum total by tmp_t1.name tmp_t1.ttl_sum) / col7.
   col9 = (accum total by tmp_t1.name tmp_t1.prem_kzt) / col7.
   col10 = (accum total by tmp_t1.name tmp_t1.prem_usd) / col7.
   col11 = (accum total by tmp_t1.name tmp_t1.srok_kzt) / col7.
   col12 = (accum total by tmp_t1.name tmp_t1.srok_usd) / col7.
   create tmp_t2.
           tmp_t2.pp_num = v-numstr.
           if avail txb.ofc then
           tmp_t2.name = txb.ofc.name.
           else 
           tmp_t2.name = "Быстрые деньги".
           tmp_t2.sum_kzt = (accum total by tmp_t1.name tmp_t1.sum_kzt).
           tmp_t2.sum_usd = (accum total by tmp_t1.name tmp_t1.sum_usd).
           tmp_t2.ttl_sum = (accum total by tmp_t1.name tmp_t1.ttl_sum).
           tmp_t2.part = col6.
           tmp_t2.cnt_cstm = col7.
           tmp_t2.avrg_sum = col8.
           tmp_t2.prem_kzt = col9.
           tmp_t2.prem_usd = col10.
           tmp_t2.srok_kzt = col11.
           tmp_t2.srok_usd = col12.
           tmp_t2.code_branch = tmp_t1.code_branch.
           tmp_t2.name_branch = name-bank.
  end.
  
end.

FOR EACH tmp_t1 where tmp_t1.code_branch = s-bank no-lock BREAK BY tmp_t1.code_cred.
  ACCUMULATE tmp_t1.cif(SUB-COUNT BY tmp_t1.code_cred).
  ACCUMULATE tmp_t1.sum_kzt(TOTAL BY tmp_t1.code_cred).
  ACCUMULATE tmp_t1.sum_usd(TOTAL BY tmp_t1.code_cred).
  IF LAST-OF(tmp_t1.code_cred) THEN DO:  
    IF tmp_t1.code_cred = 1 THEN DO: 
       create tmp_t3.
       ASSIGN tmp_t3.vid_cred = "Потребительское кредитование"
              tmp_t3.p_kzt = (ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_kzt)
              tmp_t3.p_usd = (ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_usd)
              tmp_t3.ttl_usd = ((ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_kzt) / v-kurs) + (ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_usd)
              tmp_t3.cnt_cstm = (ACCUM SUB-COUNT BY tmp_t1.code_cred 
                                 tmp_t1.cif)
              tmp_t3.code_branch = tmp_t1.code_branch
              .
    END.
    IF tmp_t1.code_cred = 2 THEN DO:
       create tmp_t3.
       ASSIGN tmp_t3.vid_cred = "Быстрые деньги"
              tmp_t3.p_kzt = (ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_kzt)
              tmp_t3.p_usd = (ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_usd)
              tmp_t3.ttl_usd = ((ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_kzt) / v-kurs) + (ACCUM TOTAL BY tmp_t1.code_cred tmp_t1.sum_usd)
              tmp_t3.cnt_cstm = (ACCUM SUB-COUNT BY tmp_t1.code_cred
                                 tmp_t1.cif)
              tmp_t3.code_branch = tmp_t1.code_branch
              .
    END.
    tmp_t3.name_branch = name-bank.
  END.
END.
                      
