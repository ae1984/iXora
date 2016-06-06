/* sumin.p
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
        31/12/99 pragma
 * CHANGES
*/


{global.i}

def input parameter input_s_aaa as char.
def input parameter input_d_sum as decimal.
def output parameter output_choice as logical. 

def var d_init_sum as decimal init 0.
def var d_temp_sum as decimal init 0.
def var d_final_sum as decimal init 0.
def var d_send_sum as decimal init 0.

    find first sysc where sysc = 'deblim' no-lock no-error.
    if avail sysc then do:

    	find first debet_restr where debet_restr.aaa = input_s_aaa 
    	use-index aaa_index no-lock no-error.  
    	if avail debet_restr then do:   

    		find first aaa where aaa.aaa = debet_restr.aaa no-lock no-error.
    		if avail aaa then do:

    			find first cif where cif.cif = aaa.cif and cif.cgr = sysc.inval 
    			use-index cif no-lock no-error.
    			if avail cif then do:

    				if aaa.crc ne 1 then do:
    				find last crchis where crchis.crc eq aaa.crc and crchis.rdt le g-today no-lock no-error.
    				d_init_sum = debet_restr.sum * crchis.rate[1] / crchis.rate[9].
   				end.
    				else
    				d_init_sum = debet_restr.sum.


    				for each jl where jl.jdt = g-today and jl.sts = 6 and jl.acc = aaa.aaa no-lock break by jl.crc.
                        
  				if jl.crc ne 1 then do:
   				find last crchis where crchis.crc eq jl.crc and crchis.rdt le g-today no-lock no-error.
    				d_temp_sum = jl.dam * crchis.rate[1] / crchis.rate[9].
    				end.
    				else
    				d_temp_sum = jl.dam.

    				d_final_sum = d_final_sum + d_temp_sum.

    				end. /* for each jl */


  				if aaa.crc ne 1 then do:
   				find last crchis where crchis.crc eq aaa.crc and crchis.rdt le g-today no-lock no-error.
    				d_send_sum = input_d_sum * crchis.rate[1] / crchis.rate[9].
    				end.
    				else
    				d_send_sum = input_d_sum.


    if (d_final_sum + d_send_sum) > d_init_sum then 
    output_choice = TRUE.
    else
    output_choice = FALSE.


                	end. /* cif */  

    		end. /* aaa */

    	end. /* debet_restr */

    end. /* sysc */

