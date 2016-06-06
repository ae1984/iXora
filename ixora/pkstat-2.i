/* pkstat-2.i
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Статистика "Портрет задолжника" (БД)
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        pkstat-2.p
        pkstat2-2.p
 * MENU
        4-13-15
 * AUTHOR
        10.11.2004 saltanat /  *  modified pkstat.i by sasco *  / 
 * CHANGES
*/

{comm-txb.i}

define variable seltxb as character.
seltxb = comm-txb().

define {1} shared temp-table tmp
                field cid as integer
                field bank as character                          
                field kritcod as character 
                field kritname as character 
                field valcod as character 
                field valdes as character 
                field loaned as logical
                field cnt as integer 
                index idx_tmp is primary kritcod bank loaned.
                .

define {1} shared temp-table tmpcln
                field bank as character 
                field ln as integer 
                field cln as logical
                field loaned as logical
                field accs as logical
                field finobrem as logical
                index idx_tmptxb as primary bank loaned
                .

define {1} shared temp-table tmpcnt
                field bank as character 
                field loaned as logical
                field cnt as integer
                .
                
/* что будем пропускать при обработке */
define variable skips as character initial "*name*,dt*,bplace,age,addrch,*apart*,*city*,*house*,*mail*,cln*,cred*,doc,*drive*,gcvp*,sik*,num*,re*,sum*,tel*,family1,krlim,info,klitxb1,almatv,alseco".

/* список кодов которые вообще выводим на экран */
define variable valouts as character initial "mf,bdt,rajon,jobp,jobs,jobt,jobpr2,family,childhas,childnum,childnum16,hasnedvizh,hasauto,finacc,txbcln,finobrem,".

/* список кодов, для которых смотрим описание в справочнике */
define variable valdefs as character initial 'mf,jobp,jobs,family,jobt,jobpr2,'.

/* наименование справочника для кодов из valdefs */
define variable valspr as character initial 'pkanksex,pkankorg,pkankkat,pkankfam,pkankwrk,pkankdoh,'.

define {1} shared variable si as integer.

define {1} shared variable v-loan as logical.

define {1} shared variable vd1 as date.
define {1} shared variable vd2 as date.
define {1} shared variable vdt as date.

define {1} shared variable s-credtype as character.

define {1} shared variable reptype as character.

define {1} shared variable rep_zaj as logical initial no. /* выводить заемщиков    */
define {1} shared variable rep_otk as logical initial no. /* выводить отказников   */
define {1} shared variable rep_con as logical initial no. /* выводить консолидацию */

define {1} shared variable cnt_zaj      as integer.
define {1} shared variable cnt_zaj_all  as integer.
define {1} shared variable cnt_otk      as integer.
define {1} shared variable cnt_otk_all  as integer.
define {1} shared variable cnt_conz     as integer.
define {1} shared variable cnt_conz_all as integer.
define {1} shared variable cnt_cono     as integer.
define {1} shared variable cnt_cono_all as integer.

define {1} shared variable tot_ank_cnt as integer.

define variable is_consolid as logical initial yes.

if "{1}" = "new" then do:
   update vd1 label "Начало периода" 
          vd2 label "Конец периода" 
          with side-labels centered frame datfr.
   hide frame datfr.

   reptype = "Задолжники|Задолжники + Консолидация".
   run sel1("Выберите вид отчета", reptype).

   reptype = return-value.

   if reptype matches "*Задолжники*" then rep_zaj = yes.
   /*if reptype matches "*Отказники*" then rep_otk = yes.*/
   if reptype matches "*Консолидация*" then rep_con = yes.

   tot_ank_cnt = 0.

   s-credtype = '6'.  

   cnt_zaj = 0.
   cnt_otk = 0.
   cnt_conz = 0.
   cnt_cono = 0.

   cnt_zaj_all = 0.
   cnt_otk_all = 0.
   cnt_conz_all = 0.
   cnt_cono_all = 0.

   message "По всем филиалам?" update is_consolid.

   if not is_consolid then do:
      
      reptype = "".
      for each txb where txb.visible and txb.consolid no-lock:
          if reptype <> "" then reptype = reptype + "|".
          reptype = reptype + txb.name.
      end.
      run sel1("Выберите филиал", reptype).
      reptype = return-value.

      find txb where txb.visible and txb.consolid and txb.name = reptype no-lock no-error.
      if not avail txb then return.

      seltxb = txb.bank.

   end.

end.

