/* hilist.i
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
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/


{jabro.i

&start     =	"
                find first stgenhi where stgenhi.cif = in_cif and
                         stgenhi.account = in_account no-lock no-error.
		if not available stgenhi then do:
   		   message 'Нет ни одной записи в истории выписок '.
   		   pause 5.
   		   return.
		end.

                "
&head      = 	"stgenhi"
&headkey   = 	"stgenhi"
&index     = 	"common_idx"
&formname  = 	"f_sthe"
&framename = 	"f_sthe"
&where     = 	" stgenhi.cif = in_cif and
                  stgenhi.account = in_account
                "
&addcon    = 	"false"
&deletecon = 	"false"
&predelete = 	"
                 define variable bseq as integer.
                 find b-st where recid(b-st) = crec no-lock no-error.
                 if b-st.sts = 'ORG' then do:
                  bseq = b-st.seq.
                  for each b-st where b-st.cif = in_cif and
                  	        	b-st.account = in_account and
                  			b-st.active = yes and
                                        b-st.seq = bseq and
                  			b-st.sts = 'CPY'.
                   b-st.active = no.
                 end.
                end.
                "
&precreate = 	" "
&postadd    = 	" "
&prechoose = 	" "
&predisplay = 	" "
&display   = 	"
                 stgenhi.seq 	 format '>>>>>9'          label 'Номер'
                 stgenhi.d_from  format '99/99/99'        label 'Начало п.'
                 stgenhi.d_to    format '99/99/99'        label 'Конец п.'
                 stgenhi.who     format 'x(8)'            label 'Исполн.'
                 string(stgenhi.tm,'HH:MM') @ stgenhi.tm  label 'Время'
                 stgenhi.gen_date format '99/99/99'       label 'Дата вып.'
                 stgenhi.sts     format 'x(3)'            label 'СТС'
                 stgenhi.active  format 'да/нет'          label 'Акт'
                 stgenhi.mode    format 'x(8)'            label 'Режим'

                "
&highlight = 	"stgenhi.seq"
&postkey   = 	"  "
&end = 		" hide frame f_sthe."
}
