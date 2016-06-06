/* r-obmaud.p
 * MODULE
        Обменные операции
 * DESCRIPTION
       Печать реестра купленной и проданной валюты для аудита      
 * RUN
       Вызов из п меню без параметров 
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
         
 * BASES
        BANK 
 * AUTHOR
        17/11/08 marinav
 * CHANGES
*/


{functions-def.i}
{global.i}

unix silent value("rm rpt1.img").

/*
g-ofc = "id00261".
*/

/*define var oldg-ofc like ofc.ofc.*/
define var tg-today as date.
define var mpage-size as integer init 64.

def var fio as char.
def var pwidth as int init 128.
def var pwidth2 as int init 126.
def var fsymb as char.
define buffer b_exch_lst for exch_lst.
define variable symb1 as integer extent 5 init [21,43,65,87,109].
define variable symb2 as  integer extent 7 init [6,30,38,60,79,99,118].
define variable mycount    as integer.
define variable prevbrate  as deci .
define variable prevsrate  as deci.
define variable cur_line   as integer.
define variable cur_page   as integer.
define variable i          as integer.
define variable prev_rated as deci init 0 extent 11.
define variable prev_ratec as deci init 0 extent 11.
define variable new_rec as logical.
define buffer b-crc for crc.
define buffer bcrc for crc.
                                         
define temp-table tot_sum no-undo
  field ts_crc like crc.crc
  field ts_dam like jl.dam
  field ts_damkzt like jl.dam
  field ts_cam like jl.cam
  field ts_camkzt like jl.cam
  index icrc is primary ts_crc /*ts_dc*/.
  

define temp-table tmp_jdoc no-undo
  field tj_docnum as integer format "zzz"
  field tj_fio    like fio
  field tj_code   like crc.code
  field tj_dc     like jl.dc
  field tj_amt    like jl.dam
  field tj_amtkzt like jl.dam
  field tj_rate as deci
  field tj_time as integer
  field tj_ofc  as char
  field tj_jh   as integer
  index idocnum  is primary tj_docnum.

define temp-table tmp_rateD no-undo
  field tr_rate   as deci
  field tr_crc    like crc.crc
.

define temp-table tmp_rateC no-undo
  field tr_rate   as deci
  field tr_crc    like crc.crc
.

define temp-table tmp_rateDO no-undo
  field tr_rate   as deci
  field tr_crc    like crc.crc
.

define temp-table tmp_rateCO no-undo
  field tr_rate   as deci
  field tr_crc    like crc.crc
.


/* курсы, которые уже вывелись в шапке */
define temp-table tmpD no-undo
       field tr_rate as deci
       field tr_crc  like crc.crc.

define temp-table tmpC no-undo
       field tr_rate as deci
       field tr_crc  like crc.crc.

define var rate_cnt as integer.
define var rate_c   as integer.
define var rate_d   as integer.

define temp-table t_totsub no-undo
  field tt_crc  like crc.crc
  field tt_code like tj_code
  field tt_dc   like jl.dc
  field tt_rate as deci
  field tt_amt     like jl.dam. 

define temp-table t_ofc no-undo
  field to_ofc like g-ofc.

define buffer btmp for tmp_jdoc.

procedure get_page:

  find first b_exch_lst no-lock no-error.
    cur_page = b_exch_lst.page_num.   

end procedure.

procedure put_page:
  for each b_exch_lst :
    /*  b_exch_lst.page_num = cur_page. */
  end.    
end procedure.

procedure add_line:
define input parameter  a as integer.
   cur_line = cur_line + a.
   if cur_line = mpage-size - 3
      then 
        do: 
           put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")".       
           put skip(1) "Подпись кассира __________" "Лист N "  at 100 cur_page format "zzzzz" skip. 
           page. 
           put skip(1). 
           cur_line = 1.
           cur_page = cur_page + 1.
           run view_header(false). 
        end.
end procedure.


procedure get_fio:
define input parameter famt like jl.dam.
/* 20.10.2003 nadejda */
  if trim(joudoc.info + joudoc.passp) = "" then 
    fio = "".
  else do:
    fio = trim(joudoc.info) + ";" + trim(joudoc.passp) + " ".
    if  string(joudoc.passpdt) <> ? then
        fio = fio + string(joudoc.passpdt).
  end.
end procedure.

procedure add_to_TS:
define input param namt like jl.dam.
define input param nrate as deci.

find tot_sum where ts_crc = jl.crc  no-error.
if not avail tot_sum then do: 
	create tot_sum. 
	 ts_crc = jl.crc. 
end.
if jl.dc = "d" then 
                 do: 
                   ts_dam = ts_dam + namt.
                   ts_damkzt = ts_damkzt + namt * nrate.

                 find tmp_rateD where tmp_rateD.tr_rate = nrate no-error.
                      if not avail tmp_rateD 
                         then 
                           do:
                              create tmp_rateD.
                              tmp_rateD.tr_rate = nrate.
                              tmp_rateD.tr_crc = crc.crc.
                           end.

                 end.
               else
                 do:
                   ts_cam = ts_cam + namt.
                   ts_camkzt = ts_camkzt + namt * nrate.
                 find tmp_rateC where tmp_rateC.tr_rate = nrate no-error.
                      if not avail tmp_rateC 
                         then 
                           do:
                              create tmp_rateC.
                              tmp_rateC.tr_rate = nrate.
                              tmp_rateC.tr_crc = crc.crc.
                           end.
                 end.
end procedure.


procedure CheckAmt:
       if exch_lst.whn < tg-today 
          then 
              do:
                 output to terminal.
                 find first bcrc where bcrc.crc = exch_lst.crc.
                 find current exch_lst exclusive-lock.
                 exch_lst.whn = tg-today.
                 exch_lst.camt = exch_lst.bamt.
                 find current exch_lst no-lock.
              end.
          else 
              do:
                 output to terminal.
                 find current exch_lst exclusive-lock.
                 exch_lst.camt = exch_lst.bamt.
                 find current exch_lst no-lock.
              end.

            
end procedure.

mycount = 0.
prevbrate = 0.
prevsrate = 0.

def new shared var v-dtb as date.
def new shared var v-dte as date.

update 
  v-dtb label " Начальная дата " format "99/99/9999" skip
  v-dte label "  Конечная дата " format "99/99/9999" 
  with centered row 5 side-label frame f-dt.


do tg-today = v-dtb to v-dte:


mycount   = 0.
prevbrate = 0. 
prevsrate  = 0.
cur_line   = 0.
cur_page   = 0.
i          = 0.
prev_rated  = 0.
prev_ratec   = 0.
rate_cnt = 0.
rate_c   = 0.
rate_d   = 0.


for each tot_sum.
  delete tot_sum.
end.
for each tmp_jdoc.
delete tmp_jdoc.
end.
for each tmp_rateD.
delete tmp_rateD.
end.
for each tmp_rateC.
delete tmp_rateC.
end.

for each tmp_rateDO.
delete tmp_rateDO.
end.
for each tmp_rateCO.
delete tmp_rateCO.
end.

for each tmpD.
delete tmpD.
end.
for each tmpC.
delete tmpC.
end.
for each t_totsub.
delete t_totsub.
end.
for each t_ofc.
delete t_ofc.
end.



find first exch_lst no-lock no-error.

if not avail exch_lst then do: message "Ваш логин отсутствует в списке кассиров" skip "обменного пункта" view-as alert-box title "".  leave. end.


REPEAT i=1 TO NUM-ENTRIES(exch_lst.ofc_list):
  create t_ofc.
  t_ofc.to_ofc = ENTRY(i,exch_lst.ofc_list).
END.

mycount = 1.


for each joudoc where can-find (t_ofc no-lock where t_ofc.to_ofc = joudoc.who) and  joudoc.whn = tg-today no-lock break by joudoc.tim.
	/*по удаленным транзакциям*/
	for each jh where jh.jdt = joudoc.whn  and jh.ref = joudoc.docnum  and substr(party,12,7) = "deleted" no-lock :
		for each deljl where  deljl.jh = jh.jh and  deljl.jdt = joudoc.whn no-lock.
			if deljl.who = joudoc.who and  integer(substr(deljl.bywho, 1, 3)) <> 1 and (deljl.gl = 100100  or deljl.gl = 100200 or deljl.gl = 100300) and substring(deljl.rem[1],1,5) = "Обмен" then
			do:
				find last crc where crc.crc = integer(substr(deljl.bywho, 1, 3)) no-lock no-error.
				if deljl.dc = "d" and deljl.dam <> 0 then
				do:
					create tmp_jdoc.
					assign
						tmp_jdoc.tj_docnum =  mycount
						tmp_jdoc.tj_fio    = trim("введена ошибочно;")
						tmp_jdoc.tj_dc     = deljl.dc
						tmp_jdoc.tj_code   = crc.code
						tmp_jdoc.tj_amt    = deljl.dam
						tmp_jdoc.tj_amtkzt = deljl.dam * brate
						tmp_jdoc.tj_rate   = brate
						tmp_jdoc.tj_time   =  jh.tim
						tmp_jdoc.tj_ofc    = deljl.who
						tmp_jdoc.tj_jh     = deljl.jh.
				end.
				if deljl.dc = "c" and deljl.cam <> 0 then
				do:
					create tmp_jdoc.
					assign
						tmp_jdoc.tj_docnum =  mycount
						tmp_jdoc.tj_fio    = trim("введена ошибочно;")
						tmp_jdoc.tj_dc     = deljl.dc
						tmp_jdoc.tj_code   = crc.code
						tmp_jdoc.tj_amt    = deljl.cam
						tmp_jdoc.tj_amtkzt = deljl.cam * srate
						tmp_jdoc.tj_rate   = srate
						tmp_jdoc.tj_time   = jh.tim
						tmp_jdoc.tj_ofc    = deljl.who
						tmp_jdoc.tj_jh     = deljl.jh.
				end.
				mycount = mycount + 1.
			end.
		end.
	end.
	for each jl where   jl.jh = joudoc.jh  and jl.jdt = joudoc.whn no-lock.
		if (jl.gl = 100100  or jl.gl = 100200 or jl.gl = 100300) and substring(jl.rem[1],1,5) = "Обмен" and jl.who = joudoc.who and jl.crc <> 1 then
		do:
			find last jh where  jh.jh = jl.jh no-lock no-error.
			find last crc where crc.crc = jl.crc no-lock no-error.
			if jl.dc = "d" and jl.dam <> 0 then
			do:
				run add_to_TS(jl.dam, brate).
				run get_fio(jl.dam).
				create tmp_jdoc.
				assign
					tmp_jdoc.tj_docnum = mycount
					tmp_jdoc.tj_fio    = fio
					tmp_jdoc.tj_dc     = jl.dc
					tmp_jdoc.tj_code   = crc.code
					tmp_jdoc.tj_amt    = jl.dam
					tmp_jdoc.tj_amtkzt = jl.dam * brate
					tmp_jdoc.tj_rate   = brate
					tmp_jdoc.tj_time   =     jh.tim
					tmp_jdoc.tj_ofc    = jl.who
					tmp_jdoc.tj_jh     = jl.jh.
			end.
			if jl.dc = "c" and jl.cam <> 0 then
			do: 
				run add_to_TS(jl.cam, srate).
				run get_fio(jl.cam).
				create tmp_jdoc.
				assign
					tmp_jdoc.tj_docnum = mycount
					tmp_jdoc.tj_fio    = fio
					tmp_jdoc.tj_dc     = jl.dc
					tmp_jdoc.tj_code   = crc.code
					tmp_jdoc.tj_amt    = jl.cam
					tmp_jdoc.tj_amtkzt = jl.cam * srate
					tmp_jdoc.tj_rate   = srate
					tmp_jdoc.tj_time   =  jh.tim
					tmp_jdoc.tj_ofc    = jl.who
					tmp_jdoc.tj_jh     = jl.jh.
			end.
			mycount = mycount + 1.
		end.
	end.
end.

mycount = 1.
for each tmp_jdoc where tmp_jdoc.tj_amt > 0 break by tmp_jdoc.tj_time:
	tmp_jdoc.tj_docnum = mycount. 
	mycount = mycount + 1.
end.


  find first tot_sum where tot_sum.ts_crc = 2 no-lock no-error.
  if not avail tot_sum and can-find (exch_lst where /*exch_lst.ofc_list matches ("*" + g-ofc + "*") and*/ exch_lst.crc = 2 ) then 
  do:

             create tmp_jdoc.
             tmp_jdoc.tj_docnum = 1. 
             tmp_jdoc.tj_fio    = " ".
             tmp_jdoc.tj_dc     = "d".
             tmp_jdoc.tj_code   = "USD".
             tmp_jdoc.tj_amt    = 0.
             tmp_jdoc.tj_amtkzt = 0. 
             tmp_jdoc.tj_rate   = 0.
             create tot_sum.
             tot_sum.ts_crc = 2.
             tot_sum.ts_dam = 0.  
             tot_sum.ts_damkzt = 0.
             tot_sum.ts_cam    = 0.
             tot_sum.ts_camkzt = 0.
  end.

  find first tot_sum where tot_sum.ts_crc = 4 no-lock no-error.
  if not avail tot_sum and can-find (exch_lst where /*exch_lst.ofc_list matches ("*" + g-ofc + "*") and*/ exch_lst.crc = 4 ) then 
  do:
             create tmp_jdoc.
             tmp_jdoc.tj_docnum = 1. 
             tmp_jdoc.tj_fio    = " ".
             tmp_jdoc.tj_dc     = "d".
             tmp_jdoc.tj_code   = "RUB".
             tmp_jdoc.tj_amt    = 0.
             tmp_jdoc.tj_amtkzt = 0. 
             tmp_jdoc.tj_rate   = 0.
             create tot_sum.
             tot_sum.ts_crc = 4.
             tot_sum.ts_dam = 0.  
             tot_sum.ts_damkzt = 0.
             tot_sum.ts_cam    = 0.
             tot_sum.ts_camkzt = 0.
  end.

  find first tot_sum where tot_sum.ts_crc = 3 no-lock no-error.
  if not avail tot_sum and can-find (exch_lst where /*exch_lst.ofc_list matches ("*" + g-ofc + "*") and*/ exch_lst.crc = 3 ) then 
  do:
             create tmp_jdoc.
             tmp_jdoc.tj_docnum = 1.
             tmp_jdoc.tj_fio    = " ".
             tmp_jdoc.tj_dc     = "d".
             tmp_jdoc.tj_code   = "EUR".
             tmp_jdoc.tj_amt    = 0.
             tmp_jdoc.tj_amtkzt = 0.  
             tmp_jdoc.tj_rate   = 0.
             create tot_sum.
             tot_sum.ts_crc = 3.
             tot_sum.ts_dam = 0.  
             tot_sum.ts_damkzt = 0.
             tot_sum.ts_cam    = 0.
             tot_sum.ts_camkzt = 0.
  end. 
           

output to rpt1.img append.


procedure View_Header:

	define input parameter ct as logical.

	if ct then run get_page.

	find first cmp no-lock no-error.

	put   string(tg-today,"99/99/9999") + ", " + string( time, "HH:MM:SS" ) + ", " + trim( cmp.name ) format "x(" + string(pwidth) + ")" skip FirstLine( 2, 1 ) format "x(" + string(pwidth) + ")" skip(1).

	put   fill( "-", pwidth ) format "x(" + string(pwidth) + ")"  skip.

	put  "|" "Вид валюты" "|" at symb1[1] fill( "_", 16 ) format "x(16)"  "Остатки валюты" at 38 fill( "_", 13 ) format "x(13)"  "|" at symb1[3] fill( "_", 28 ) format "x(28)"  "Курс" at 94 fill( "_", 30 ) format "x(30)" "|" skip.
                                         
	put	  "|"  "|" at symb1[1] "На начало дня" at 22 
                  "|" at symb1[2] "На конец дня" at 44 
                  "|" at symb1[3] "Покупки" at 66 
                  "|" at symb1[4] "Продажи" at 88 
                  "|" at symb1[5] "Номер и дата" at 110 "|" at 128
                  skip.
	put  "|"  "|" at symb1[1] "|" at symb1[2] "|" at symb1[3] "|" at symb1[4] "|" at symb1[5] "распоряжения" at 110 "|" at 128 skip.
	put  "|"  "|" at symb1[1] "|" at symb1[2] "|" at symb1[3] "|" at symb1[4] "|" at symb1[5] "руководителя" at 110 "|" at 128 skip.

	put  fill( "-", pwidth ) format "x(" + string(pwidth) + ")"  skip.



	find first exch_lst where /*exch_lst.ofc_list matches ("*" + g-ofc + "*") and*/ exch_lst.crc = 1 no-lock no-error.
	if not avail exch_lst then 
		message "Вашего логина нет в списке кассиров" skip "Проверьте настройки в п.4.2.2" view-as alert-box title "Ошибка".
	run CheckAmt.
	find last b-crc where b-crc.crc = 1 no-lock no-error.
	find current exch_lst exclusive-lock.
/* убран расчет на конец дня согл ТЗ 302 от 04.04.08
	for each tot_sum no-lock:
		exch_lst.camt = exch_lst.camt - tot_sum.ts_damkzt.
		exch_lst.camt = exch_lst.camt + tot_sum.ts_camkzt.   
	end. 
*/
	find current exch_lst no-lock.
	find last b-crc where b-crc.crc = 1 no-lock no-error.
	put  	"| " b-crc.code
		"|" at symb1[1]	exch_lst.bamt  format "z,zzz,zzz,zz9.99-" at 22
		"|" at symb1[2] exch_lst.camt  format "z,zzz,zzz,zz9.99-" at 44
		"|" at symb1[3] 
		"|" at symb1[4] 
		"|" at symb1[5] exch_lst.numr at 110 tg-today at 120 "|" at 128 skip.
	cur_line = 10.

	/* sasco */
	for each tmp_rateDO: delete tmp_rateDO. end.
	for each tmp_rateCO: delete tmp_rateCO. end.

	for each tmp_rateD:
	    create tmp_rateDO.
	    buffer-copy tmp_rateD to tmp_rateDO.
	end.

	for each tmp_rateC:
	    create tmp_rateCO.
	    buffer-copy tmp_rateC to tmp_rateCO.
	end.

	for each tot_sum no-lock:
        	find last exch_lst where ( exch_lst.crc = tot_sum.ts_crc /*and exch_lst.ofc_list matches ("*" + g-ofc + "*")*/ ) no-lock no-error.
		if not avail exch_lst then message "Проверьте настройки в п.4.2.2" view-as alert-box title "Ошибка".
		find last b-crc where b-crc.crc = tot_sum.ts_crc no-lock no-error. 
		if g-today = tg-today then 
		do:   
			find last b-crc where b-crc.crc = tot_sum.ts_crc no-lock no-error. 
			prevbrate = b-crc.rate[2].
			prevsrate = b-crc.rate[3].
		end.
		else 
		do:
			find last crchis where b-crc.crc = crchis.crc and crchis.rdt <= tg-today and crchis.tim < 75600 no-lock no-error. /*u00121 09/06/06 */
			prevbrate = crchis.rate[2].
			prevsrate = crchis.rate[3].
		end.

		run CheckAmt. 
		find current exch_lst exclusive-lock.
/*   убран расчет на конец дня согл ТЗ 302 от 04.04.08
		exch_lst.camt = exch_lst.camt + tot_sum.ts_dam.
		exch_lst.camt = exch_lst.camt - tot_sum.ts_cam. 
*/
		find current exch_lst no-lock.
		put  	"| " b-crc.code
			"|" at symb1[1] exch_lst.bamt  format "z,zzz,zzz,zz9.99-" at 22
			"|" at symb1[2] exch_lst.camt  format "z,zzz,zzz,zz9.99-" at 44
			"|" at symb1[3] prevbrate format "z,zz9.99" at 66
			"|" at symb1[4] prevsrate format "z,zz9.99" at 88 
			"|" at symb1[5] exch_lst.numr at 110 tg-today at 120 "|" at 128 skip.
		run add_line(1).

		find last tmp_rateDO where tmp_rateDO.tr_rate = prevbrate and tmp_rateDO.tr_crc = b-crc.crc no-lock no-error.
		if avail tmp_rateDO then delete tmp_rateDO.

		find tmp_rateCO where tmp_rateCO.tr_rate = prevsrate and tmp_rateCO.tr_crc = b-crc.crc no-lock no-error.
		if avail tmp_rateCO then delete tmp_rateCO.

		rate_d = 0.
		rate_c = 0.

		/* количество курсов покупки и продажи */
		for each tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-lock:
			rate_d = rate_d + 1.
		end.
		for each tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc:
			rate_c = rate_c + 1.
		end.

		rate_cnt = rate_d.
		if rate_c > rate_d then rate_cnt = rate_c.

		find first tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
		find first tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.

		do rate_d = 1 to rate_cnt:
			if avail(tmp_rateDO) and avail(tmp_rateCO) then 
				if tmp_rateDO.tr_rate = ? and tmp_rateCO.tr_rate = ? then
				do:
					find next tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
					find next tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.
					next.
				end.

			put 	"|"
				"|" at symb1[1]
				"|" at symb1[2]
				"|" at symb1[3].
			if avail tmp_rateDO then
				if tmp_rateDO.tr_rate <> ? then 
					put tmp_rateDO.tr_rate format "z,zz9.99" at 66.
			put "|" at symb1[4].
			if avail tmp_rateCO then
				if tmp_rateCO.tr_rate <> ? then 
					put tmp_rateCO.tr_rate format "z,zz9.99" at 88.
			put "|" at symb1[5] tg-today at 110 "|" at 128 skip.

			run add_line(1).

			find next tmp_rateDO where tmp_rateDO.tr_crc = b-crc.crc no-error.
			find next tmp_rateCO where tmp_rateCO.tr_crc = b-crc.crc no-error.
		end.
	end.

	put   fill( "-", pwidth ) format "x(" + string(pwidth) + ")"  skip(1).
        run add_line(2).

	put 
		padc("РЕЕСТР",pwidth," ") format "x(" + string(pwidth) + ")" skip
		padc("купленной и проданой иностранной валюты",pwidth," ") format "x(" + string(pwidth) + ")" skip
		padc("за " + string(tg-today) , pwidth," ") format "x(" + string(pwidth) + ")" skip(1).

	put   fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.
	put  	"|" "|" at symb2[1]
                 "Ф.И.О. N и серия"  at symb2[1] + 1
                 "|" at symb2[2] "Наим." at symb2[2] + 1 "|" at symb2[3]
		fill( "_", 35 ) format "x(35)"                 "Сумма валюты"      at symb2[3] + 36
		fill( "_", 32 ) format "x(32)"
                "|" at symb2[7] fill("",8) "|" skip.             
	put  	"|" "N"                 at 2
                 "|" at symb2[1] 
                 "документа"         at symb2[1] + 1
                 "|" at symb2[2]
                 "валюты"            at symb2[2] + 1
                 "|" at symb2[3]
		fill( "_", 17 ) format "x(17)" "Куплено"           at symb2[3] + 18
		fill( "_", 16 ) format "x(16)"
                "|" at symb2[5]
		fill( "_", 16 ) format "x(16)" "Продано"           at symb2[5] + 17
		fill( "_", 16 ) format "x(15)"
                "|" at symb2[7] fill("",8) "|"  skip.
	put  "|" "п/п"               at 2 "|" at symb2[1] 
                 "удостоверяющего"   at symb2[1] + 1
                 "|" at symb2[2] "|" at symb2[3]
                 "в валюте"          at symb2[3] + 1 "|" at symb2[4]
                 "эквивалент"        at symb2[4] + 1 "|" at symb2[5]
                 "в валюте"          at symb2[5] + 1  "|" at symb2[6]
                 "эквивалент"        at symb2[6] + 1  "|" at symb2[7] fill("",8) "|"
                 skip.
	put  "|"  "|" at symb2[1] "личность клиента"  at symb2[1] + 1
                 "|" at symb2[2] "|" at symb2[3] "|" at symb2[4]
                 "в тенге"           at symb2[4] + 1  "|" at symb2[5] "|" at symb2[6]
                 "в тенге"           at symb2[6] + 1  "|" at symb2[7] "  Время |"  
                 skip.

	put  fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.
        run add_line(10).
end procedure.


run view_header(true).

for each crc no-lock:
	find first tmp_jdoc where tmp_jdoc.tj_dc = "d" and tmp_jdoc.tj_code = crc.code no-lock no-error.
	if avail tmp_jdoc then prev_rated[crc.crc] = tmp_jdoc.tj_rate. 
	find first tmp_jdoc where tmp_jdoc.tj_dc = "c" and tmp_jdoc.tj_code = crc.code no-lock no-error.
	if avail tmp_jdoc then prev_ratec[crc.crc] = tmp_jdoc.tj_rate.
end.


for each tmp_jdoc where tmp_jdoc.tj_amt > 0 break by tmp_jdoc.tj_time:
	find last crc where crc.code = tmp_jdoc.tj_code no-lock no-error.
	find first t_totsub where t_totsub.tt_crc = crc.crc and t_totsub.tt_dc  = tmp_jdoc.tj_dc and t_totsub.tt_rate = tmp_jdoc.tj_rate no-error.
	new_rec = false.
	if not avail t_totsub then
		if substr(tmp_jdoc.tj_fio, 1,7) <> "введена" then
		do:
			create t_totsub.
			assign
				t_totsub.tt_crc = crc.crc
				t_totsub.tt_dc  = tmp_jdoc.tj_dc
				t_totsub.tt_rate = tmp_jdoc.tj_rate
				t_totsub.tt_code = tmp_jdoc.tj_code
				t_totsub.tt_amt = tmp_jdoc.tj_amt.
			new_rec = true.
		end.
	if new_rec = false then
	do:
		if substr(tmp_jdoc.tj_fio, 1,7) <> "введена" then  
			t_totsub.tt_amt = t_totsub.tt_amt + tmp_jdoc.tj_amt.
	end.
	else
	if substr(tmp_jdoc.tj_fio, 1,7) <> "введена" then 
		do:
			if (t_totsub.tt_dc = "d" and prev_rated[crc.crc] <> t_totsub.tt_rate) then 
			do:
				put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.                               
				run add_line(1).
				find first t_totsub where t_totsub.tt_dc = "d" and prev_rated[crc.crc] = t_totsub.tt_rate and t_totsub.tt_crc = crc.crc no-error. 
				put 	"| Итого по курсу " t_totsub.tt_rate "|" at symb2[2] tt_code          format "x(4)"  at symb2[2] + 1
					"|" at symb2[3] tt_amt format "zzz,zzz,zzz,zz9.99" at symb2[3] + 1 "|" at symb2[4] tt_amt * tt_rate format "zzz,zzz,zzz,zz9.99" at symb2[4] + 1
					"|" at symb2[5] "|" at symb2[6] "|" at symb2[7] fill("",10) "|" skip.
				delete t_totsub.
				run add_line(1). 
				put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.
				run add_line(1).           
			end.
			else
				if (t_totsub.tt_dc = "c" and prev_ratec[crc.crc] <> t_totsub.tt_rate) then 
				do:
					put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.                               
					run add_line(1).
					find first t_totsub where t_totsub.tt_dc = "c" and prev_ratec[crc.crc] = t_totsub.tt_rate and t_totsub.tt_crc = crc.crc no-error.
					put 	"| Итого по курсу " t_totsub.tt_rate "|" at symb2[2] tt_code          format "x(4)"  at symb2[2] + 1
						"|" at symb2[3] "|" at symb2[4] "|" at symb2[5] tt_amt           format "zzz,zzz,zzz,zz9.99" at symb2[5] + 1
						"|" at symb2[6] tt_amt * tt_rate format "zzz,zzz,zzz,zz9.99" at symb2[6] + 1 "|" at symb2[7] fill("",10) "|" skip.
					delete t_totsub.
					run add_line(1). 
					put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.
					run add_line(1).           
				end.
		end.
	if tmp_jdoc.tj_dc = "d" then 
		prev_rated[crc.crc] = tmp_jdoc.tj_rate.
	else 
		prev_ratec[crc.crc] = tmp_jdoc.tj_rate. 

	if tmp_jdoc.tj_dc = "d" then
	do:
			put 	"|"  tj_docnum format "zzzz"  "|" at symb2[1].
			put 	entry(1,tj_fio,";") format "x(20)" at symb2[1] + 1 "|" at symb2[2] tj_code     format "x(4)"  at symb2[2] + 1
				"|" at symb2[3]  tj_amt           format "zzz,zzz,zzz,zz9.99" at symb2[3] + 1 
				"|" at symb2[4]  tj_amtkzt        format "zzz,zzz,zzz,zz9.99" at symb2[4] + 1
				"|" at symb2[5] "|" at symb2[6] "|" at symb2[7]  string(tj_time,"HH:MM:SS") "|" skip.
			if substr(tj_fio, 1, 7) <> "введена" then
			do:
				if tj_fio <> "" then
				do:
					put "|" "|" at symb2[1] entry(2,tj_fio,";") at symb2[1] + 1 format "x(20)"
						"|" at symb2[2] 
						"|" at symb2[3] 
						"|" at symb2[4]
						"|" at symb2[5]
						"|" at symb2[6] 
						"|" at symb2[7] fill("",10) "|" 
						skip.
					run add_line(1).
				end.
			end.
			run add_line(1).
	end.
	else
	do:
			put "|"  tj_docnum format "zzzz" "|" at symb2[1].
			put entry(1,tj_fio,";") format "x(20)" at symb2[1] + 1
				"|" at symb2[2] tj_code  format "x(4)"  at symb2[2] + 1
				"|" at symb2[3]  "|" at symb2[4] "|" at symb2[5] tj_amt           format "zzz,zzz,zzz,zz9.99" at symb2[5] + 1 "|" at symb2[6]
				tj_amtkzt        format "zzz,zzz,zzz,zz9.99" at symb2[6] + 1 "|" at symb2[7] 
				string(tj_time,"HH:MM:SS") "|" skip.

			if substr(tj_fio, 1, 7) <> "введена" then
			do:
				if tj_fio <> "" then 
				do:
					put "|" "|" at symb2[1] entry(2,tj_fio,";") at symb2[1] + 1 format "x(20)"
						"|" at symb2[2] 
						"|" at symb2[3] 
						"|" at symb2[4]
						"|" at symb2[5]
						"|" at symb2[6] 
						"|" at symb2[7] fill("",10) "|"
						skip. 
					run add_line(1).
				end. 
			end.
			run add_line(1).  
	end.
end.

put  fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.

          run add_line(1).


/* Вывод промежуточных остатков в конце распечатки */

for each t_totsub:
   if t_totsub.tt_dc = "d" 
      then do:
           run add_line(1).
                put "| Итого по курсу " t_totsub.tt_rate
                    "|" at symb2[2] 
                           tt_code          format "x(4)"  at symb2[2] + 1
                    "|" at symb2[3] 
                           tt_amt           format "zzz,zzz,zzz,zz9.99" at symb2[3] + 1
                    "|" at symb2[4]
                           tt_amt * tt_rate format "zzz,zzz,zzz,zz9.99" at symb2[4] + 1
                    "|" at symb2[5] "|" at symb2[6] "|" at symb2[7] fill("",10) "|"
                    skip.
                delete t_totsub.
                run add_line(1). 
            put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.
            run add_line(1).           
      end.
   else
   if t_totsub.tt_dc = "c" 
      then do:
           run add_line(1).
           put "| Итого по курсу " t_totsub.tt_rate
                          "|" at symb2[2] 
                          tt_code          format "x(4)"  at symb2[2] + 1
                          "|" at symb2[3] 
                          "|" at symb2[4]
                          "|" at symb2[5] 
                          tt_amt           format "zzz,zzz,zzz,zz9.99" at symb2[5] + 1
                          "|" at symb2[6] 
                          tt_amt * tt_rate format "zzz,zzz,zzz,zz9.99" at symb2[6] + 1
                          "|" at symb2[7] fill("",10) "|"
                          skip.
           delete t_totsub.
           run add_line(1). 
           put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.
           run add_line(1).           
       end.
end.

for each tot_sum where tot_sum.ts_dam + tot_sum.ts_cam > 0 no-lock:
    find crc where crc.crc = tot_sum.ts_crc no-lock no-error. 
    put "| " "Всего  " "|" at symb2[2] crc.code at symb2[2] + 1 "|" at symb2[3]
                                               tot_sum.ts_dam    format "zzz,zzz,zzz,zz9.99"  at symb2[3] + 1 "|" at symb2[4]
                                               tot_sum.ts_damkzt format "zzz,zzz,zzz,zz9.99"  at symb2[4] + 1 "|" at symb2[5]
                                               tot_sum.ts_cam    format "zzz,zzz,zzz,zz9.99"  at symb2[5] + 1 "|" at symb2[6]
                                               tot_sum.ts_camkzt format "zzz,zzz,zzz,zz9.99"  at symb2[6] + 1 "|" at symb2[7] 
                                        fill("",10) "|"
                                       skip.
          run add_line(1).
end.

put fill( "-", pwidth2 ) format "x(" + string(pwidth) + ")"  skip.

if cur_line < mpage-size
   then put skip(2).
put "Подпись кассира __________" "Лист N "  at 100 cur_page format "zzzzz" skip(10).
cur_page = cur_page + 1.

output  close.
end.
run put_page.

pause 0 before-hide .
/*    run menu-prt( "rpt1.img" ).*/
unix silent value("cptwin rpt1.img winword").
    pause before-hide.

{functions-end.i}
