/* storno-txb.p
 * MODULE
          Внутрибанковские операции
 * DESCRIPTION
          Подготовка временной таблицы для отчета по сторно-документам
 * BASES
          BANK COMM TXB
 * RUN
  
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
          8.8.5.21
 * AUTHOR
          31.03.09 id00363
 * CHANGES
*/
{get-dep-txb.i}
def var v-dep like bank.ofchis.depart no-undo.

def var ofc-name like bank.ofc.name no-undo.
def var ofc-name2 like bank.ofc.name no-undo.

def buffer b-jl for txb.jl.
def buffer b-jh for txb.jh.

def shared var dt1	as date no-undo.
def shared var dt2	as date no-undo.

def shared temp-table st no-undo
    
    field depar like bank.ppoint.name
    field num like bank.jh.jh
    field dam like bank.jl.gl
    field cam like bank.jl.gl
    field damcam like bank.jl.dam
    field party like bank.jh.party
    field crc like bank.crc.code
    field who1 like bank.ofc.name
    field who2 like bank.ofc.name
    field jdt like bank.jh.jdt
    field tim like bank.jh.tim.

/*empty temp-table st.*/


for each txb.jh where txb.jh.jdt >= dt1 AND txb.jh.jdt <= dt2 AND  txb.jh.party matches '*Storno*' no-lock :

	/*test*/
	find first txb.cmp no-lock no-error.

	/*... .......*/
	if substring ( txb.jh.who, 1, 2) = 'id' then do:
		find first txb.ofc where txb.ofc.ofc = txb.jh.who no-lock no-error.
		ofc-name = txb.ofc.name.
	end.	
	else do:
		ofc-name = txb.jh.who.
	end.
	
	
	/*... .........*/
	find first b-jh where b-jh.jh = INTEGER(entry(1, substring ( txb.jh.party , 8) ,")")) no-lock no-error.
	
	if substring ( b-jh.who, 1, 2) = 'id' then do:
		find first txb.ofc where txb.ofc.ofc = b-jh.who no-lock no-error.
		ofc-name2 = txb.ofc.name.
	end.	
	else do:
		ofc-name2 = b-jh.who.
	end.
	
	/*...........*/
	v-dep = get-dep(txb.jh.who,txb.jh.jdt).
	find first txb.ppoint where txb.ppoint.depart = v-dep no-lock no-error.
	if not avail txb.ppoint then do:
		/*message txb.cmp.name txb.jh.jh v-dep view-as alert-box.*/
		find first txb.ppoint where txb.ppoint.depart = 1 no-lock no-error.
	end.
		
	for each txb.jl where txb.jl.jh = txb.jh.jh and txb.jl.dc = 'C' no-lock:

		find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
			
		if avail b-jl then do:

			/*......*/
			find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
			if not avail txb.crc then message txb.jl.jh txb.jl.crc view-as alert-box.
			
			create st.
  			assign	st.depar = txb.ppoint.name
	  				st.num = txb.jh.jh
	  				st.dam = b-jl.gl
	  				st.cam = txb.jl.gl
	  				st.damcam = txb.jl.cam
	  				st.party =  txb.jh.party
	  				st.crc = txb.crc.code
	  				st.who1 = ofc-name
	  				st.who2 = ofc-name2
	  				st.jdt = txb.jh.jdt
	  				st.tim = txb.jh.tim.

		end.	  				

	end.

end.
