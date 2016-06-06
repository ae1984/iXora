/* r_mop2.p
 * MODULE
        Кредитный модуль 
 * DESCRIPTION
        Выгрузка данных по кредитам в состему Налоговой отчетности
        d1 надо указать дату последнего дня месяца
        Все данные по кредитам переведены в тенге по курсу даты отчета 
 * RUN
        
 * CALLER
        r-mop
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        13.10.03  marinav
 * CHANGES
	   21.01.04 valery полностью заменен алгоритм нахождения суммы начисления для поля "Начисленная сумма вознаграждения"
			а также сделан пересчет сумм полей "Начисленная сумма вознаграждения" и "Полученная сумма вознаграждения"
			валютных счетов на тенге, причем на дату каждого поступления и начисления.
	   12.02.04 valery в поле "Пролонгация ..." теперь не выводятся вопросики.
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
	24/05/2004 valery раскомментарина строка, где сохраняется валюта договора, затем она выводится в поле Примечание (23)
       31/05/2004 madiar - добавил обработку схемы 4
       24/10/2006 Natalya D. - добавлены данные по физ.лицам
*/

def input parameter d1 as date.
def shared var g-ofc as char.
def shared var g-today as date.
def shared var coun as int.
def var long as int init 0 no-undo.
def var bilance   as decimal format '->,>>>,>>>,>>9.99' no-undo.
def var dlong as date no-undo.
def var v-fiz as char no-undo.
def var v-dt as date no-undo.
define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.

define variable sm1 as decimal no-undo.

def var d2 as date no-undo.
def var vcu like txb.lon.opnamt extent 3 decimals 2.
define shared stream m-out.

def shared temp-table wrk no-undo
    field nn     as inte
    field name   like txb.cif.name
    field cif    like txb.cif.cif
    field lon    like txb.lon.lon 
    field grp    like txb.lon.grp
    field fiz    as   char
    field rnn    like txb.cif.jss
    field dog    as   char
    field dogdt  as   date
    field crc    as  char    
    field rdt    as   date
    field duedt  as   date
    field balans like txb.lon.opnamt
    field balans1 like txb.lon.opnamt
    field balans2 like txb.lon.opnamt
    field prem   like txb.lon.prem
    field prem1  like txb.lon.opnamt
    field prem2  like txb.lon.opnamt
    field balans3 like txb.lon.opnamt
    field dlong  as   date
    field garant as   char
    field balgar like txb.lon.opnamt 
    field proviz like txb.lon.opnamt
    field nulls as   char
    index idx1 fiz
    index idx2 grp.

define temp-table w-acr no-undo
       field  nr       as integer
       field  fdt      as date
       field  tdt      as date
       field  prn      as decimal
       field  rate     as decimal
       field  amt      as decimal.



d2 = date('01' + substring(string(d1),3)) - 1.

displ "Подождите. Идет формирование отчета." skip. pause 0.

for each txb.longrp, each txb.lon where txb.longrp.longrp = txb.lon.grp no-lock /*by txb.lon.cif*/ .


  /*find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'clnsts' no-lock no-error.
  if avail txb.sub-cod then v-fiz = txb.sub-cod.ccode.*/ 
  v-fiz = substr(string(txb.longrp.stn),1,1).  

  run lon_txb (txb.lon.lon,d2,output bilance). /* остаток  ОД*/                        


  if bilance > 0 or (txb.lon.rdt >= d2 and txb.lon.rdt <= d1 ) then do:

/*
     run txb-prcl.p (input txb.lon.lon, input d1,                                      
                     output vcu[1], output vcu[2], output vcu[3]).                                   
*/
/**********************************************************************************************/
     vcu[2] = 0 .
     for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 2 
              and txb.lonres.dc = 'C' and txb.lonres.jdt <= d1 no-lock.
	/****************************находим курс для кнвертации в тенге***************************/
    	find last txb.crchis where txb.crchis.crc = txb.lonres.crc and txb.crchis.regdt <= txb.lonres.jdt use-index crcrdt no-lock no-error.
	if avail txb.crchis then 
	 if txb.lonres.crc > 1 then 
	         vcu[2] = vcu[2] + txb.lonres.amt * txb.crchis.rate[1].
	 else 
	         vcu[2] = vcu[2] + txb.lonres.amt.		 

/*        vcu[2] = vcu[2] + txb.lonres.amt.		 */
     end.

     vcu[3] = 0 .
     for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 2 
              and txb.lonres.dc = 'D' and txb.lonres.jdt <= d1 no-lock.
	/****************************находим курс для кнвертации в тенге***************************/
    	find last txb.crchis where txb.crchis.crc = txb.lonres.crc and txb.crchis.regdt <= txb.lonres.jdt use-index crcrdt no-lock no-error.
	if avail txb.crchis then 
	 if txb.lonres.crc > 1 then 
	         vcu[3] = vcu[3] + txb.lonres.amt * txb.crchis.rate[1].
	 else 
	         vcu[3] = vcu[3] + txb.lonres.amt.		 

/*        vcu[3] = vcu[3] + txb.lonres.amt.		 */
     end.
                                                               	 
/**********************************************************************************************/


for each w-acr:
	delete w-acr.
end.

/***Начисленная сумма вознаграждения**/
/*message "Поднимаем начисленные суммы вознаграждения по счету " txb.lon.lon.*/
v-dt = txb.lon.rdt + 1.
for each txb.acr where txb.acr.lon = txb.lon.lon and txb.acr.tdt <= d1 no-lock:
    if txb.acr.fdt < v-dt 
    			then v-dt = txb.acr.fdt.
    run day-360(txb.acr.fdt,txb.acr.tdt,txb.lon.basedy,output dn1,output dn2).
    create w-acr.
    w-acr.fdt = txb.acr.fdt.
    w-acr.tdt = txb.acr.tdt.
    w-acr.prn = txb.acr.prn.
    w-acr.rate = txb.acr.rate.

  if txb.lon.plan = 3 or txb.lon.plan = 4 then 
    w-acr.amt = round(txb.lon.opnamt * txb.acr.rate * dn1 / txb.lon.basedy / 100,0).
  else
    w-acr.amt = round(txb.acr.prn * txb.acr.rate * dn1 / txb.lon.basedy / 100,3).


/*конвертим на дату начисления в тенге если это не тенге :) :)*/        
	if txb.lon.crc > 1 then do:
	  find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= w-acr.fdt use-index crcrdt no-lock no-error.
	    w-acr.amt = w-acr.amt * txb.crchis.rate[1].
	end.
	
    if acr.sts = 9
    then sm1 = sm1 + w-acr.amt.

end.

vcu[1] = 0.

if sm1 < txb.lon.dam[2]
then do:
     create w-acr.
     w-acr.nr = 1.
     w-acr.fdt = v-dt - 1.
     w-acr.tdt = v-dt - 1.
     w-acr.prn = 0.
     w-acr.rate = 0.
     w-acr.amt = lon.dam[2] - sm1.
end.

for each w-acr:
   vcu[1] = vcu[1] + w-acr.amt.
end.
   vcu[1] = vcu[1] + vcu[3].
     
/*	vcu[1] = vcu[1] + vcu[2]. */

     create wrk.
     /*wrk.nn = coun.*/
     wrk.lon = txb.lon.lon. 
     wrk.grp = txb.lon.grp.
     wrk.fiz = v-fiz.
   /* Ставка %% */
     wrk.prem = txb.lon.prem.
   /**/
     wrk.prem1 = vcu[1].
   /**/
     wrk.prem2 = vcu[2].

     find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
     if not avail txb.crc then next.
     find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
     if not avail txb.cif then next.
     find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error. 
     if not avail txb.loncon then next.
   /**/
     wrk.name = txb.cif.name.
     wrk.rnn = txb.cif.jss.
   /* Дата и номер договора */
     wrk.dog = txb.loncon.lcnt.
     wrk.dogdt = txb.lon.rdt.
     wrk.crc = txb.crc.code. /*valery 24/05/2004*/
     wrk.duedt = txb.lon.duedt.

   /* Дата первой выдачи */
     find first txb.lonres  where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 1 
                            and txb.lonres.jdt <= d1 and txb.lonres.dc = 'D' 
                            and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' no-lock no-error.
     if avail txb.lonres then wrk.rdt = txb.lonres.jdt.

   /* Сумма по договору */
     find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt le d1 no-lock no-error.
     if avail txb.crchis and txb.lon.crc > 1 then wrk.balans = txb.lon.opnamt  /* * txb.crchis.rate[1] */.
                        else wrk.balans = txb.lon.opnamt.

   /* Выданная сумма*//*
     for each txb.lonres  where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= d1
                            and txb.lonres.lev = 1  and txb.lonres.dc = 'D' 
                            and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' no-lock:
       if  avail txb.crchis and txb.lon.crc > 1 then wrk.balans1 = wrk.balans1 + lonres.amt * crchis.rate[1].
                          else wrk.balans1 = wrk.balans1 + lonres.amt.
     end.
*/
   /* Погашенная сумма *//*
     for each txb.lonres  where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= d1 
                            and (txb.lonres.lev = 1 or txb.lonres.lev = 7 or txb.lonres.lev = 8)  and txb.lonres.dc = 'C' 
                            and txb.lonres.trx ne 'lon0008' and txb.lonres.trx ne 'lon0009' no-lock:
       if  avail txb.crchis and txb.lon.crc > 1 then wrk.balans2 = wrk.balans2 + lonres.amt * crchis.rate[1].
                          else wrk.balans2 = wrk.balans2 + lonres.amt.
     end. 
*/
     for each txb.lonres  where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= d1 no-lock:
       if txb.lonres.lev = 1  and txb.lonres.dc = 'D' and txb.lonres.trx ne 'lon0023' and  txb.lonres.trx ne 'lon0024' then do:
          if  avail txb.crchis and txb.lon.crc > 1 then wrk.balans1 = wrk.balans1 + lonres.amt * crchis.rate[1].
                          else wrk.balans1 = wrk.balans1 + lonres.amt.
       end.
       if (txb.lonres.lev = 1 or txb.lonres.lev = 7 or txb.lonres.lev = 8)  and txb.lonres.dc = 'C' 
                            and txb.lonres.trx ne 'lon0008' and txb.lonres.trx ne 'lon0009' then do:
          if  avail txb.crchis and txb.lon.crc > 1 then wrk.balans2 = wrk.balans2 + lonres.amt * crchis.rate[1].
                          else wrk.balans2 = wrk.balans2 + lonres.amt. 
       end.
     end.

   /* Пролонгации */
     dlong = ?.
     if txb.lon.ddt[5] <> ? and txb.lon.ddt[5] > d1 then dlong = txb.lon.ddt[5].
     if txb.lon.cdt[5] <> ? and txb.lon.ddt[5] > d1 then dlong = txb.lon.cdt[5].
     wrk.dlong = dlong.
   
     if dlong ne ? then do:
        run lon_txb (txb.lon.lon,d1,output bilance). /* остаток  ОД*/                        
        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt le d1 no-lock no-error.
        if  avail txb.crchis and txb.lon.crc > 1 then wrk.balans3 = bilance * txb.crchis.rate[1].
                           else wrk.balans3 = bilance.
     end.
    
   /* Обеспечение - курс на дату договора*/
     for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock.
       find last txb.crchis where txb.crchis.crc = txb.lonsec1.crc and txb.crchis.regdt le txb.lon.rdt no-error.
        wrk.garant = wrk.garant + substr(entry(1, txb.lonsec1.prm, '&'),1,40) + ' ; ' .
/*сумма обеспечения*/ 
/*       if  avail txb.crchis and txb.lonsec1.crc > 1 then wrk.balgar = wrk.balgar + txb.lonsec1.secamt * txb.crchis.rate[1].
                               else wrk.balgar = wrk.balgar + txb.lonsec1.secamt.
*/  
   end.

   /* Провизии */
     for each txb.lonres use-index lon where txb.lonres.lon eq txb.lon.lon 
            and txb.lonres.whn le d1 and (txb.lonres.lev eq 3 or txb.lonres.lev eq 6) no-lock.
            if lonres.dc = "D"
            then wrk.proviz = wrk.proviz - lonres.amt.
            else wrk.proviz = wrk.proviz + lonres.amt.
     end.

     run lon_txb (txb.lon.lon,d1,output bilance). /* остаток  ОД*/                        
     if bilance = 0 then wrk.nulls = '1'. /*если кредит погашен ставим "*" */ /*valery 24/05/004 "*" заменена на "1"*/

   /*coun = coun + 1.*/
   end.
 
end.

