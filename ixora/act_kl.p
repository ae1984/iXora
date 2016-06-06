/* act_kl.p
 * MODULE
        Операционка - отчет по активным клиентам
 * DESCRIPTION
        Создание и отправка платежей
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
        29/06/2006 u00600
 * CHANGES
        06/07/2006 u00600 - данные клиентов и ИО и со штрих-кодом, графы iosh, iosh_act по ТЗ ї391 от 04.07.06
	04/09/2006 u00121 - добавил вывод на экран код клиента, обрабатываемую дату, и количество найденных проводок. 
			  - Ускорить отчет не удалось - работает долго из-за большого количества клиентов
*/

def var v-pr as integer init 0 no-undo.
def var i as integer init 0 no-undo.
def var vdt as date no-undo.

def var vpoint as int no-undo.
def var vdep as int no-undo.
def var vrko as char no-undo.

def temp-table t-act no-undo
    field filial as char
    field type as char
    field RKO as integer
    field RKO1 as char
    field cif like txb.aaa.cif
    field aaa like txb.aaa.aaa
    field cif_kl as deci
    field cif_act as deci
    field io as deci
    field io_act as deci
    field sh as deci
    field sh_act as deci
    field iosh as deci
    field iosh_act as deci
    index ftR filial type RKO.

def shared temp-table t-tabl no-undo
    field filial as char
    field type as char
    field RKO as integer
    field RKO1 as char
    field cif_kl as integer
    field cif_act as integer
    field io as integer
    field io_act as integer
    field sh as integer
    field sh_act as integer
    field iosh as integer
    field iosh_act as integer.

def shared temp-table t-vsego no-undo
    field filial as char
    field type as char
    field RKO1 as char
    field cif_kl as integer
    field cif_act as integer
    field io as integer
    field io_act as integer
    field sh as integer
    field sh_act as integer
    field iosh as integer
    field iosh_act as integer.

def shared var vdt1 as date format "99/99/9999" no-undo.
def shared var vdt2 as date format "99/99/9999" no-undo.
def shared var koltxb as int no-undo.

def shared var vtxb as char no-undo.

def buffer b-jl for txb.jl.
  
find txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
vtxb = caps (txb.sysc.chval).
for each txb.cif fields (txb.cif.regdt txb.cif.type txb.cif.cif txb.cif.jame txb.cif.who) no-lock.
	if txb.cif.regdt > vdt2 then next.
	displ cif.cif vdt i with overlay no-labels centered row 15 1 down. pause 0.
	if txb.cif.type <> "B" and txb.cif.type <> "P" then next.
	find first txb.aaa where txb.aaa.cif  = txb.cif.cif and txb.aaa.sta <> 'C' no-lock no-error.
	if not avail txb.aaa then next.

	/* определение подразделения */
	vpoint = 1.  vdep = 1.
	if txb.cif.jame <> '' then 
	do :
		vpoint = integer(txb.cif.jame) / 1000 - 0.5.
		vdep = integer(txb.cif.jame) - vpoint * 1000.
	end.
	else 
	do:
		find last txb.ofchis where txb.ofchis.ofc = txb.cif.who no-lock no-error.
		if avail txb.ofchis then 
		do: 
			vpoint = txb.ofchis.point. 
			vdep = txb.ofchis.dep. 
		end.
		else 
		do: 
			vpoint = 0. 
			vdep = 0. 
		end.
	end.

	find last txb.ppoint where txb.ppoint.point = 1 and txb.ppoint.depart = vdep no-lock no-error.
	if not avail txb.ppoint then next.
	vrko = txb.ppoint.name.

	create t-act.
	assign 
		t-act.filial =  vtxb
		t-act.cif    =  txb.cif.cif
		t-act.type   =  txb.cif.type
		t-act.RKO    =  vdep   
		t-act.RKO1   =  vrko
		t-act.cif_kl =  1.

	for each txb.aaa fields (txb.aaa.aaa) 
		where txb.aaa.cif = txb.cif.cif and txb.aaa.sta ne 'C' no-lock use-index aaa-idx1.  /*все клиенты ,у одного клиента могут быть несколько счетов!!!*/ 
		i = 0.
		do vdt = vdt1 to vdt2.
	        	displ cif.cif vdt i with overlay no-labels centered row 15 1 down. pause 0.
			for each txb.jl fields (txb.jl.jh txb.jl.dc txb.jl.ln)  
				where txb.jl.jdt = vdt and txb.jl.acc = txb.aaa.aaa no-lock .
				find first b-jl where 	b-jl.jh = txb.jl.jh  and 
							b-jl.dc <> txb.jl.dc and 
							substr(string(b-jl.gl), 1, 1) <> '4' and 
							b-jl.ln <> txb.jl.ln and 
							b-jl.jdt = vdt no-lock no-error.
				if avail b-jl then 
					i = i + 1.       
				else 
					next.
		        	displ cif.cif vdt i with overlay no-labels centered row 15 1 down. pause 0.
			end.
		end.

		if i >= koltxb then 
			t-act.cif_act = 1.
	end.

	/*интернет-клиенты ib*/
	find first ib.usr where ib.usr.cif = txb.cif.cif no-lock no-error.
	if avail ib.usr then 
		t-act.io = 1.
	if avail ib.usr and t-act.cif_act = 1 then 
		t-act.io_act = 1.

	/*клиенты со штрих-кодом*/
	find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'scann' no-lock no-error.
	if avail txb.sub-cod and txb.sub-cod.ccode = "t" then 
	do: 
		if  t-act.io = 0 then 
			t-act.sh = 1.    /*если клиент с ИО, то штрих код не учитываем*/
		if  t-act.cif_act = 1 and t-act.io_act = 0 then 
			t-act.sh_act = 1.

		if t-act.io = 1 then 
			t-act.iosh = 1.   /*если и ИО и штрих-код, то в графу iosh*/

		if t-act.cif_act = 1 and t-act.io_act = 1 then 
			t-act.iosh_act = 1.  /*если клиент активный и ИО, то в графу t-act.iosh_act*/

		if t-act.io = 1 then 
			t-act.io = 0.  /*если клиент ИО и штрих-код, то обнуляем. нужны клиенты чисто ИО*/
		if t-act.io_act = 1 then 
			t-act.io_act = 0. 
	end.
end.

/*-------------------------------------------------------------------------------------------------------------------------*/

for each t-act no-lock break by t-act.filial by t-act.type by t-act.RKO .

	accumulate t-act.cif_kl (total by t-act.filial by t-act.type by t-act.RKO ).
	accumulate t-act.cif_act (total by t-act.filial by t-act.type by t-act.RKO).
	accumulate t-act.io (total by t-act.filial by t-act.type by t-act.RKO).
	accumulate t-act.io_act (total by t-act.filial by t-act.type by t-act.RKO).
	accumulate t-act.sh (total by t-act.filial by t-act.type by t-act.RKO).
	accumulate t-act.sh_act (total by t-act.filial by t-act.type by t-act.RKO).
	accumulate t-act.iosh (total by t-act.filial by t-act.type by t-act.RKO).
	accumulate t-act.iosh_act (total by t-act.filial by t-act.type by t-act.RKO).

	accumulate t-act.cif_kl (total by t-act.filial by t-act.type).
	accumulate t-act.cif_act (total by t-act.filial by t-act.type).
	accumulate t-act.io (total by t-act.filial by t-act.type).
	accumulate t-act.io_act (total by t-act.filial by t-act.type).
	accumulate t-act.sh (total by t-act.filial by t-act.type).
	accumulate t-act.sh_act (total by t-act.filial by t-act.type).
	accumulate t-act.iosh (total by t-act.filial by t-act.type).
	accumulate t-act.iosh_act (total by t-act.filial by t-act.type).

	if last-of(t-act.type) then 
	do:
		create t-vsego.
		assign 
			t-vsego.filial  = t-act.filial
			t-vsego.type    = t-act.type
			t-vsego.RKO1    = "Всего"
			t-vsego.cif_kl  = accum total by (t-act.type) t-act.cif_kl
			t-vsego.cif_act = accum total by (t-act.type) t-act.cif_act
			t-vsego.io      = accum total by (t-act.type) t-act.io
			t-vsego.io_act  = accum total by (t-act.type) t-act.io_act
			t-vsego.sh      = accum total by (t-act.type) t-act.sh
			t-vsego.sh_act  = accum total by (t-act.type) t-act.sh_act
			t-vsego.iosh    = accum total by (t-act.type) t-act.iosh
			t-vsego.iosh_act  = accum total by (t-act.type) t-act.iosh_act.
	end.

	if last-of(t-act.RKO) then 
	do:
		create t-tabl.
		assign 
			t-tabl.filial    = t-act.filial
			t-tabl.type      = t-act.type
			t-tabl.RKO       = t-act.RKO
			t-tabl.RKO1      = t-act.RKO1
			t-tabl.cif_kl    = accum total by (t-act.RKO) t-act.cif_kl
			t-tabl.cif_act   = accum total by (t-act.RKO) t-act.cif_act
			t-tabl.io        = accum total by (t-act.RKO) t-act.io
			t-tabl.io_act    = accum total by (t-act.RKO) t-act.io_act
			t-tabl.sh        = accum total by (t-act.RKO) t-act.sh
			t-tabl.sh_act    = accum total by (t-act.RKO) t-act.sh_act
			t-tabl.iosh      = accum total by (t-act.RKO) t-act.iosh
			t-tabl.iosh_act  = accum total by (t-act.RKO) t-act.iosh_act.     
	end.
end.

