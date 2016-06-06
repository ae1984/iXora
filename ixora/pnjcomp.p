/* pnjcomp.p
 * MODULE
        Платежная система
 * DESCRIPTION
	Сверка созданных RMZ на всех очередях по указанному транзитному пенсионному счету с реестром.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        13.8
 * AUTHOR
        17.01.2006 u00121
 * BASES
	BANK
	COMM
 * CHANGES
 	04/07/2006 u00121 - пенсионные платежи теперь берутся не из p_f_payment, а из commonpl по полю commonpl.abk = 1
 	04/08/2006 u00121 - no-undo в описание переменных и таблиц
*/

{get-dep.i}
{deparp_pmp.i}
{comm-txb.i}

def var seltxb as int no-undo.
seltxb = comm-cod().

def var v-dtf as date no-undo .
def var v-dtf1 as date no-undo .
def var v-dtf2 as date no-undo .
def var v-dtf3 as date no-undo .
def var v-arp as cha format "x(9)" view-as combo-box. /*Arp счет для поиска RMZ*/
def var v-arpstr as cha no-undo.
def var v-arpent as cha no-undo.
def var v-pen as int init 0 no-undo.

def var v-totpens as int label "Всего пенсионных платежей по реестру" no-undo.
def var v-totsoc as int label "Всего социальных платежей по реестру" no-undo.
def var v-cmppen as int label "Сверилось пенсионных платежей" no-undo.
def var v-nocmppen as int label "Не сверилось пенсионных платежей" no-undo.
def var v-cmpsoc as int label "Сверилось социальных платежей" no-undo.
def var v-nocmpsoc as int label "Не сверилось социальных платежей" no-undo.
def var v-normz as int label "Не найдено платежей для RMZ" no-undo.

/**********************************************************************************************************************************************************************************************************************************/
def temp-table t-rko no-undo
	field name as char format "x(50)"
	index idx-t-rko name.

def query q-rko for t-rko.

def browse b-rko query q-rko no-lock
	displ t-rko with  14 down centered no-label overlay no-box no-row-markers.

form    v-dtf label "Дата создания RMZ для сверки " v-dtf1 label " по " skip
        v-arp label "по транзитному счету" skip
        v-dtf2 label "Дата создания платежей в реестре c " v-dtf3 label " по "
	skip(1)
	b-rko
        WITH FRAME fnd row 1 OVERLAY SIDE-LABELS CENTERED TITLE "Параметры сверки".

find last pmpaccnt no-lock no-error.
if avail pmpaccnt then
do:
	v-arpstr = pmpaccnt.accnt.

	for each pmpaccnt where pmpaccnt.accnt = v-arpstr no-lock.
		create t-rko.
	   	t-rko.name = pmpaccnt.rem.
	end.
	open query q-rko for each t-rko.

	assign v-arp:list-items in frame fnd = v-arpstr.
end.

for each pmpaccnt where pmpaccnt.accnt <> v-arp no-lock break by pmpaccnt.accnt.
   if last-of(pmpaccnt.accnt) then
        v-arpstr = v-arpstr + "," + pmpaccnt.accnt.
end.

on value-changed of v-arp
do:
	for each t-rko : delete t-rko. end.
        find last pmpaccnt where pmpaccnt.accnt = SELF:SCREEN-VALUE no-lock no-error.
        v-arpent = pmpaccnt.accnt.
	for each pmpaccnt where pmpaccnt.accnt = SELF:SCREEN-VALUE no-lock.
		create t-rko.
	   	t-rko.name = pmpaccnt.rem.
	end.
	open query q-rko for each t-rko.
end.
on return of v-arp 
do:
    apply "go".
end.

ASSIGN v-arp:LIST-ITEMS IN FRAME fnd = v-arpstr.
/**********************************************************************************************************************************************************************************************************************************/


/**********************************************************************************************************************************************************************************************************************************/
        update v-dtf v-dtf1 v-arp with frame fnd. 
        update v-dtf2 v-dtf3 with frame fnd.
/**********************************************************************************************************************************************************************************************************************************/


/**********************************************************************************************************************************************************************************************************************************/
def var v-totrmz as int label "Всего RMZ в ПС" no-undo.

def temp-table t-rem  no-undo like remtrz.

for each remtrz where remtrz.valdt1 >= v-dtf and remtrz.valdt1 <= v-dtf1 and remtrz.sacc = v-arpent no-lock.
        displ remtrz.amt remtrz.remtrz with 1 down 2 col row 7 centered no-label overlay . pause 0.
        create t-rem.
        buffer-copy remtrz to t-rem.
        v-totrmz = v-totrmz + 1.
end.
/**********************************************************************************************************************************************************************************************************************************/



/**********************************************************************************************************************************************************************************************************************************/
/* 04/07/2006 u00121
define temp-table payment like p_f_payment
   field dep like ppoint.depart.
*/
        output to compare2.csv. 
                put unformatted "Департамент;Дата платежа реестра;Сумма по реестру;РНН по реестру;->;Регистрация в ПС;Код платежа ПС;РНН в ПС;Сумма платежа в ПС" skip.
        output close.

define temp-table tcommonplpen no-undo like commonpl
       field dep as integer
       field account as char.

/* 04/07/2006 u00121
        for each p_f_payment where txb = seltxb and (date >= v-dtf2 and date <= v-dtf3) and p_f_payment.deluid = ? and (p_f_payment.cod = 100 or p_f_payment.cod = 200 or p_f_payment.cod = 300) no-lock:
            if deparp_pmp(get-dep(p_f_payment.uid, p_f_payment.date)) = v-arpent  then
            do:
                    create payment.
                    buffer-copy p_f_payment to payment.
                    payment.dep = get-dep(p_f_payment.uid, p_f_payment.date).

                   displ "Пенсионные " p_f_payment.rnn p_f_payment.amt skip (1) with  1 down 3 col row 9 centered no-label overlay . pause 0.

                   v-totpens = v-totpens + 1.

                   find first t-rem where entry(3,t-rem.ord,"/") = payment.rnn and t-rem.amt = payment.amt no-error.
                   if avail t-rem  then
                   do:
                        output to compare2.csv append.          
                                put unformatted get-dep(payment.uid, payment.date) ";"  payment.date ";" payment.amt ";`" payment.rnn "; -> ;" t-rem.rdt ";" t-rem.remtrz ";`" entry(3,t-rem.ord,"/") ";" t-rem.amt ";+"skip.  
                        output close.

                        displ "RMZ " entry(3,t-rem.ord,"/") format "x(12)" t-rem.amt with 1 down 3 col row 12 centered no-label overlay. pause 0.
                        v-cmppen = v-cmppen + 1.
                        delete t-rem.   
                        delete payment.         
                        v-pen = v-pen + 1.
                   end.

            end.
        end.
*/
for each commonpl where commonpl.txb = seltxb and commonpl.grp = 15 and (commonpl.date >= v-dtf2 and commonpl.date <= v-dtf3) and commonpl.deluid = ? and commonpl.abk = 1 no-lock.
        if deparp_pmp(get-dep(commonpl.uid, commonpl.date))  = v-arpent then
        do:
                create tcommonplpen.
                buffer-copy commonpl to tcommonplpen.
                assign tcommonplpen.dep = get-dep(commonpl.uid, commonpl.date)
                tcommonplpen.account = deparp_pmp(tcommonplpen.dep). 

                displ "Пенсионные " commonpl.rnn commonpl.sum skip (1) with  1 down 3 col row 9 centered no-label overlay . pause 0.

                v-totpens = v-totpens + 1.
        
                find first t-rem where entry(3,t-rem.ord,"/") = tcommonplpen.rnn and t-rem.amt = tcommonplpen.sum no-error.
                if avail t-rem  then
                do:
                        output to compare2.csv append.          
                                put unformatted get-dep(tcommonplpen.uid, tcommonplpen.date) ";" tcommonplpen.date ";" tcommonplpen.sum ";`" tcommonplpen.rnn "; -> ;" t-rem.rdt ";" t-rem.remtrz ";`" entry(3,t-rem.ord,"/") ";" t-rem.amt ";-"skip.  
                        output close.
                        displ "RMZ " entry(3,t-rem.ord,"/") format "x(12)" t-rem.amt with  1 down 3 col row 12 centered no-label overlay . pause 0.
                        v-cmppen = v-cmppen + 1.
                        delete t-rem.                   
                        delete tcommonplpen.
                        v-pen = v-pen + 1.
                end.

        end.
end.
/* 04/07/2006 u00121
output to normzforpens.csv.
for each payment no-lock break by payment.dep.
        v-nocmppen = v-nocmppen + 1.
        put unformatted payment.dnum ";" get-dep(payment.uid, payment.date) ";" payment.date ";" payment.amt ";`" payment.rnn ";" payment.name ";" payment.cod skip.
      
end.
*/
output to normzforpens.csv.
for each tcommonplpen no-lock break by tcommonplpen.dep.
        put unformatted get-dep(tcommonplpen.uid, tcommonplpen.date) ";" tcommonplpen.dnum ";" tcommonplpen.date ";" tcommonplpen.sum ";`" tcommonplpen.rnn ";" tcommonplpen.fio skip.
       v-nocmppen = v-nocmppen + 1.
end.

output close.
/**********************************************************************************************************************************************************************************************************************************/

/**********************************************************************************************************************************************************************************************************************************/
define temp-table tcommonpl no-undo like commonpl
       field dep as integer
       field account as char.

v-pen = 0.

for each commonpl where commonpl.txb = seltxb and commonpl.grp = 15 and (commonpl.date >= v-dtf2 and commonpl.date <= v-dtf3) and commonpl.deluid = ? and commonpl.abk = 0 no-lock.
        if deparp_pmp(get-dep(commonpl.uid, commonpl.date))  = v-arpent then
        do:
                create tcommonpl.
                buffer-copy commonpl to tcommonpl.
                assign tcommonpl.dep = get-dep(commonpl.uid, commonpl.date)
                tcommonpl.account = deparp_pmp(tcommonpl.dep). 

                displ "Социальные " commonpl.rnn commonpl.sum skip (1) with  1 down 3 col row 9 centered no-label overlay . pause 0.

                v-totsoc = v-totsoc + 1.
        
                find first t-rem where entry(3,t-rem.ord,"/") = tcommonpl.rnn and t-rem.amt = tcommonpl.sum no-error.
                if avail t-rem  then
                do:
                        output to compare2.csv append.          
                                put unformatted get-dep(tcommonpl.uid, tcommonpl.date) ";" tcommonpl.date ";" tcommonpl.sum ";`" tcommonpl.rnn "; -> ;" t-rem.rdt ";" t-rem.remtrz ";`" entry(3,t-rem.ord,"/") ";" t-rem.amt ";-"skip.  
                        output close.
                        displ "RMZ " entry(3,t-rem.ord,"/") format "x(12)" t-rem.amt with  1 down 3 col row 12 centered no-label overlay . pause 0.
                        v-cmpsoc = v-cmpsoc + 1.
                        delete t-rem.                   
                        delete tcommonpl.
                        v-pen = v-pen + 1.
                end.

        end.
end.





output to normzforsoc.csv.
for each tcommonpl no-lock break by tcommonpl.dep.
        put unformatted get-dep(tcommonpl.uid, tcommonpl.date) ";" tcommonpl.dnum ";" tcommonpl.date ";" tcommonpl.sum ";`" tcommonpl.rnn ";" tcommonpl.fio skip.
        v-nocmpsoc = v-nocmpsoc + 1.
end.
output close.
/**********************************************************************************************************************************************************************************************************************************/

/**********************************************************************************************************************************************************************************************************************************/
output to rmz.csv.
for each t-rem no-lock.
        find last que where que.rem = t-rem.remtrz no-lock no-error.
        if avail que then
                put unformatted t-rem.remtrz ";`" entry(3,t-rem.ord,"/") ";" entry(1,t-rem.ord,"/") ";" t-rem.amt ";" t-rem.sqn ";" que.pid skip.
        else
                put unformatted t-rem.remtrz ";`" entry(3,t-rem.ord,"/") ";" entry(1,t-rem.ord,"/") ";" t-rem.amt ";" t-rem.sqn ";Нет очереди!!!" skip.  
        v-normz = v-normz + 1.
end.
output close.
/**********************************************************************************************************************************************************************************************************************************/


/**********************************************************************************************************************************************************************************************************************************/
output to value("total-send.txt").
displ  v-totpens skip
         v-totsoc skip
         v-totrmz  skip
         v-cmppen  skip 
         v-nocmppen skip 
         v-cmpsoc skip
         v-nocmpsoc  skip 
         v-normz with side-labels.
output close.
unix silent cptwin value('total-send.txt') winword.
/**********************************************************************************************************************************************************************************************************************************/


/**********************************************************************************************************************************************************************************************************************************/ 
if v-nocmppen > 0 then
	unix silent cptwin value('normzforpens.csv') excel.
if v-cmpsoc > 0 then
	unix silent cptwin value('compare2.csv') excel.
if v-nocmpsoc > 0 then
	unix silent cptwin value('normzforsoc.csv') excel.
if v-normz > 0 then
	unix silent cptwin value('rmz.csv') excel.
/**********************************************************************************************************************************************************************************************************************************/