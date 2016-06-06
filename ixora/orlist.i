/* orlist.i
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

m: repeat:
{jabro.i

&start     =	" 
                 find first stgenhi where stgenhi.cif = in_cif and 
                         stgenhi.account = in_account and
                         stgenhi.active = yes and
                         stgenhi.sts = 'ORG' no-lock no-error.
if not available stgenhi then do:
   message 'Не доступно оригиналов.'.
   pause 5.
   return.
end.
 
                "
&head      = 	"stgenhi"
&headkey   = 	"stgenhi"
&index     = 	"common_idx"
&formname  = 	"f_sthi"
&framename = 	"f_sthi"
&where     = 	" stgenhi.cif = in_cif and 
                  stgenhi.account = in_account and
                  stgenhi.active = yes and
                  stgenhi.sts = 'ORG'
                "
&addcon    = 	"false"
&deletecon = 	"false"
&predelete = 	" " 
&precreate = 	" "
&postadd    = 	" " 
&prechoose = 	" "
&predisplay = 	" "
&display   = 	"
                 stgenhi.seq 	 format '>>>>>9'
                 stgenhi.d_from  format '99/99/99' 
                 stgenhi.d_to    format '99/99/99'
                 stgenhi.who     format 'x(8)'
                 string(stgenhi.tm,'HH:MM') @ stgenhi.tm 
                 stgenhi.gen_date format '99/99/99'  

                "
&highlight = 	"stgenhi.seq"
&postkey   = 	"
                 else 
                 if keyfunction(lastkey) = 'end-error' then do:
                    leave upper. 
                 end.
                 else   
                 if keyfunction(lastkey) = 'return' then do transaction:
                  
                  message 'Удалить оригинал ?' update vans.
                  if vans = yes then do :

                  vans = no.

                  define variable aseq as integer. 
                  find b-st where recid(b-st) = crec exclusive-lock no-error.
                  b-st.active = no.
                  
                  aseq = b-st.seq.
                  
                  for each b-st where b-st.cif = in_cif and
                  	        	b-st.account = in_account and
                  			b-st.active = yes and
                                        b-st.seq = aseq and
                  			b-st.sts = 'CPY'.
                   b-st.active = no.

                 end.
                 hide frame f_sthi. 
                 next m.  
                 run elog('ORREM','SYS', 'Remove Statement Original Nr.' + string(aseq) + ' by account ' + in_account).
                 end.
                end.
                "
&end = 		" hide frame f_sthi."
}

if keyfunction(lastkey) = 'end-error' then do:
   leave.
end.

end.
