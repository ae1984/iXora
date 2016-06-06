/* r-aststa2.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет - Состояние основных средств
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        8-1-4-2
 * BASES
        BANK TXB
 * AUTHOR
        23/04/10 marinav
 * CHANGES
        03/02/12 dmitriy - добавил столбец "Инв.номер"
*/



define shared var g-today  as date.
def input parameter vmc1 as date  .
def input parameter v-fag like txb.ast.fag .
def input parameter v-gl like txb.ast.gl.
def input parameter vib as integer format "9" .

def shared temp-table wrk no-undo
  field gl       like bank.ast.gl
  field fag      like bank.ast.fag
  field ast      like bank.ast.ast
  field inv-n    like bank.ast.addr[2]
  field qty      like bank.ast.qty
  field rdt      like bank.ast.rdt
  field noy      like bank.ast.noy
  field icost    like bank.astatl.icost
  field nol      like bank.astatl.nol
  field atl      like bank.astatl.atl
  field fatl     like bank.astatl.fatl[4]
  field name     like bank.ast.name
  field fil      as char
  field depname  as char
  field nkname   as char.


find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

for each txb.ast where (if vib=2 then txb.ast.fag = v-fag else (if vib=3 then txb.ast.gl  = v-gl else true)) no-lock :

        find first txb.codfr where txb.codfr.codfr = 'sproftcn' and txb.codfr.code = txb.ast.attn no-lock no-error.

        find last txb.hist where txb.hist.pkey = "AST" and txb.hist.skey = txb.ast.ast and txb.hist.op = "MOVEDEP" and
                             txb.hist.date <= vmc1 no-lock use-index opdate no-error.
        if not avail txb.hist then do:
           if vmc1 < g-today then do:
              find first txb.hist where txb.hist.pkey = "AST" and txb.hist.skey = txb.ast.ast and txb.hist.op = "MOVEDEP" and
                                    txb.hist.date >= vmc1 no-lock use-index opdate no-error.
           end.
        end.

	if vmc1 = g-today  then do:

		if (txb.ast.dam[1] - txb.ast.cam[1]) ne 0 or (txb.ast.dam[3] - txb.ast.cam[3] ) ne 0 then do:
                                create wrk.
                                if avail txb.codfr then wrk.nkname = txb.codfr.name[5]. else wrk.nkname = ' - '.
                                if avail txb.hist then wrk.depname = txb.hist.chval[1]. else wrk.depname = txb.ast.attn.
                                wrk.fil = trim(txb.sysc.chval).

                        	assign  wrk.gl   =  txb.ast.gl
                                 wrk.fag  = txb.ast.fag
                                 wrk.ast  = txb.ast.ast
                                 wrk.inv-n = txb.ast.addr[2]
                                 wrk.qty  = txb.ast.qty
                                 wrk.rdt  = txb.ast.rdt
                                 wrk.noy  = txb.ast.noy
                                 wrk.icost = txb.ast.dam[1] - txb.ast.cam[1]
                                 wrk.nol  = txb.ast.cam[3] - txb.ast.dam[3]
                                 wrk.atl  = txb.ast.dam[1] - txb.ast.cam[1] + txb.ast.dam[3] - txb.ast.cam[3]
                                 wrk.fatl = txb.ast.cam[4] - txb.ast.dam[4]
                                 wrk.name = txb.ast.name.
		end.
	end.
	else do:
		find last txb.astatl where txb.astatl.ast = txb.ast.ast  and txb.astatl.dt <= vmc1 use-index astdt no-lock no-error.
		if available txb.astatl and txb.astatl.icost <> 0 then do:
                                create wrk.
                                if avail txb.codfr then wrk.nkname = txb.codfr.name[5]. else wrk.nkname = ' - '.
                                if avail txb.hist then wrk.depname = txb.hist.chval[1]. else wrk.depname = txb.ast.attn.
                                wrk.fil = trim(txb.sysc.chval).

		            assign
                        	 wrk.gl   = txb.astatl.agl
                                 wrk.fag  = txb.astatl.fag
                                 wrk.ast  = txb.astatl.ast
                                 wrk.qty  = txb.astatl.qty
                                 wrk.rdt  = txb.ast.rdt
                                 wrk.noy  = txb.ast.noy
                                 wrk.icost = txb.astatl.icost
                                 wrk.nol  = txb.astatl.nol
                                 wrk.atl  = txb.astatl.atl
                                 wrk.fatl = txb.astatl.fatl[4]
                                 wrk.name = txb.ast.name.
		end.
	end.
end.
