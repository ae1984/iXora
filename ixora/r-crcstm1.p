 /* r-crcstm1.p
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
   4-4-2-16-16-7
 * AUTHOR
        14/12/05 Natalya D.
 * CHANGES
        06/03/2006 Natalya D. - поправила шрифт и курс валюты.
        22/08/2006 Natalya D. - изменила прохождение курсора по lon:убрала объединение с таблицеё cif, 
                                вывела в отдельный запрос и добавила цикл по переменной v_cred, чтобы
                                цеплялся индекс по grp.  
*/

/* Кредитный портфель по клиентам*/

def input parameter d_date as date.
def input parameter v-kurs as decimal.
def var v-numstr  as integer.
def var day_kurs as decimal.
def var v_short as character initial ["20,25,26,27"].
def var v_medium as character initial ["40,45"].
def var v_long as character initial ["60,65,66,67"].
def var v_express as character initial ["90,92"].
def var v_overdraft as character initial ["80"].
def var v_cred as character initial ["20,25,26,27,40,45,60,65,66,67,80,90,92"].
def var pr_kurs as decimal.
def var v_ost_kzt as decimal.
def var v_ost_usd as decimal.
def var v_stat as integer.
def var name-bank as char.
def var s-bank as char.
def var itog_sum as decimal.
def var i as inte.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  return.
end.
else s-bank = txb.sysc.chval.

define shared temp-table tmp_t1
       field code_cstm like txb.lon.cif
       field name_cstm as char /*like txb.cif.name*/
       field vid_p as char
       field srok_p as int
       field opnamt like txb.lon.opnamt
       field num_doc as char
       field ost_kzt as decimal
       field ost_usd as decimal
       field curr as char format "x(3)" 
       field prem like txb.lon.prem 
       field opndt like txb.lon.opndt
       field duedt like txb.lon.duedt
       field protec as char
       field protec_usd as decimal
       field reserv as decimal
       field reserv_amt as decimal
       field srok as int format "->>>>>9"
       field manager as char
       field code_branch like sysc.chval
       field name_branch as char
       index indx1 curr
       index indx2 code_branch.

define shared temp-table tmp_t2
       field manager as char
       field code_manager as char
       field sum_usd as decimal
       field cnt_cstm as integer
       field part as decimal
       field code_branch like txb.sysc.chval
       field name_branch as char
       index indx3 code_branch.

  name-bank = "".
find first comm.txb where comm.txb.bank = s-bank.
  name-bank = comm.txb.name.         
  
/*заполняем временную таблицу, отфильтровав по виду кредитования*/


/*FOR EACH txb.lon, EACH txb.cif WHERE txb.cif.cif=txb.lon.cif AND txb.lon.opndt <= d_date 
                         AND (LOOKUP(STRING(txb.lon.grp),v_cred) > 0) 
                         AND ((txb.lon.dam[1] - txb.lon.cam[1]) > 0) 
                         NO-LOCK. */
do i = 1 to num-entries(v_cred) :
FOR EACH txb.lon WHERE txb.lon.opndt <= d_date  
                         AND txb.lon.grp = integer(entry(i, v_cred)) 
                         AND ((txb.lon.dam[1] - txb.lon.cam[1]) > 0) 
                         NO-LOCK.
    find last txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.

    FIND FIRST txb.loncon WHERE txb.loncon.lon = txb.lon.lon NO-LOCK NO-ERROR.
    FIND FIRST txb.crc WHERE txb.crc.crc = txb.lon.crc NO-LOCK NO-ERROR. 
    
    FIND FIRST txb.lonsec1 WHERE txb.lonsec1.lon = txb.lon.lon NO-LOCK NO-ERROR.
    FIND FIRST txb.longrp WHERE txb.longrp.longrp = txb.lon.grp NO-LOCK NO-ERROR.       
             
    IF  (avail txb.loncon)
      AND (avail txb.crc)  AND (avail txb.lonsec1) 
      AND (avail txb.longrp)  THEN DO:
      
      day_kurs = txb.crc.rate[1].
      
      CREATE tmp_t1.
      ASSIGN tmp_t1.code_cstm = txb.lon.cif
             tmp_t1.name_cstm = txb.cif.name  
             tmp_t1.vid_p = txb.longrp.des.
      
             tmp_t1.srok_p = round(((txb.lon.duedt - txb.lon.opndt) / 30), 0).
             tmp_t1.opnamt = txb.lon.opnamt.
             tmp_t1.num_doc = txb.loncon.lcnt.  
      IF txb.lon.crc = 1  THEN v_ost_kzt = txb.lon.dam[1] - txb.lon.cam[1].               
      IF txb.lon.crc <> 1 THEN v_ost_kzt = (txb.lon.dam[1] - txb.lon.cam[1]) * day_kurs.  /*если сумма в не KZT, то переводим в KZT*/
             v_ost_usd = v_ost_kzt / v-kurs.                                              /*затем в USD*/
             tmp_t1.ost_kzt = v_ost_kzt.
             tmp_t1.ost_usd = v_ost_usd. 
             tmp_t1.curr = txb.crc.code.   
             tmp_t1.prem = txb.lon.prem.
             tmp_t1.opndt = txb.lon.opndt.
             tmp_t1.duedt = txb.lon.duedt.
             tmp_t1.protec = entry(1,txb.lonsec1.prm).
        IF txb.lonsec1.crc = 2 THEN
             tmp_t1.protec_usd = txb.lonsec1.secamt.
        IF txb.lonsec1.crc <> 2 THEN DO:             
             FIND LAST txb.crchis WHERE txb.crchis.rdt = d_date AND txb.crchis.crc = txb.lonsec1.crc NO-LOCK NO-ERROR.
             IF avail txb.crchis THEN DO:
               pr_kurs = txb.crchis.rate[1].
               tmp_t1.protec_usd = (txb.lonsec1.secamt * pr_kurs) / v-kurs.
               tmp_t1.protec_usd = txb.lonsec1.crc.
             END.
      END.
       
      FIND LAST txb.lonhar WHERE txb.lonhar.lon = txb.lon.lon AND txb.lonhar.fdt < d_date NO-LOCK NO-ERROR.
        IF avail txb.lonhar THEN DO:
          v_stat = txb.lonhar.lonstat.
          FIND FIRST txb.lonstat WHERE txb.lonstat.lonstat = txb.lonhar.lonstat NO-LOCK.
          IF avail txb.lonstat THEN 
            tmp_t1.reserv = txb.lonstat.prc.
            tmp_t1.reserv_amt = (ost_kzt * txb.lonstat.prc) / 100.
        END. 
            
             tmp_t1.srok = txb.lon.duedt - d_date.
             tmp_t1.manager = txb.loncon.pase-pier.
        FIND txb.ofc WHERE txb.ofc.ofc = txb.loncon.pase-pier NO-LOCK NO-ERROR.
          IF avail ofc THEN
             tmp_t1.manager = txb.ofc.name.
          ELSE 
             tmp_t1.manager = tmp_t1.manager.   
             tmp_t1.code_branch = s-bank.
             tmp_t1.name_branch = name-bank.

    END.                    
END.
end.
/*находим общую сумму остатков по кредиту в USD*/
for each tmp_t1 where tmp_t1.code_branch = s-bank no-lock break by tmp_t1.manager.
 accumulate tmp_t1.ost_usd(total by tmp_t1.manager).
end.
 itog_sum = (accum total tmp_t1.ost_usd).
/*заполняем temp таблицу данными сгруппировав по менеджерам*/
FOR EACH tmp_t1 WHERE tmp_t1.code_branch = s-bank NO-LOCK GROUP BY tmp_t1.manager.
  ACCUMULATE tmp_t1.code_cstm(COUNT BY tmp_t1.manager).
  ACCUMULATE tmp_t1.ost_usd(TOTAL BY tmp_t1.manager).
  IF LAST-OF (tmp_t1.manager) THEN DO:
  CREATE tmp_t2.
         if tmp_t1.manager = '' then tmp_t2.manager = 'Быстрые деньги' .
         else tmp_t2.manager = tmp_t1.manager. 
         tmp_t2.code_manager = tmp_t1.manager.
         tmp_t2.sum_usd = ACCUM TOTAL BY tmp_t1.manager tmp_t1.ost_usd.
         tmp_t2.cnt_cstm = ACCUM COUNT BY tmp_t1.manager tmp_t1.code_cstm.
         tmp_t2.part = ((ACCUM TOTAL BY tmp_t1.manager tmp_t1.ost_usd) * 100) / (itog_sum).    /*расчитываем долю на каждого менеджера*/
         tmp_t2.code_branch = tmp_t1.code_branch.
         tmp_t2.name_branch = tmp_t1.name_branch. 
  END.
END.
