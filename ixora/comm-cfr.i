/* comm-cfr.i
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

/* KOVAL Вызов справочника из codfr любого кодификатора 

Например:
  Вызов
  run comm-cfr("iso3166", input-output country).
  /* Передаем код справочник и input-output переменную */

  name = return-value. /* Возвращается наименоввние */

  В country (input-output) передается значение codfr.code.

*/

procedure comm-cfr.

def input parameter v-codfr-cdfr as char.
def input-output parameter v-codfr-code as char.
def var v-codfr-name as char.
def var name1 as char.
def var name2 as char.
def var tmp as char.
def var v-cnt as int.

 	def frame fcodfr
 	skip 
 	v-codfr-code  format "x(8)"  label "Код"          skip(1)  
/* 	v-codfr-name  format "x(60)" label "Наименование" skip(1) */
        name1 format "x(60)" label "Наименование" skip
        name2 format "x(60)" no-label skip(1)
 				 	   "F2 - Вызов справочника"
 	with title " Выберите значение " centered overlay.

 	on help of v-codfr-code in frame fcodfr do:
		run comm-cf2(v-codfr-cdfr, output tmp). 
		v-codfr-code:screen-value = tmp.
		apply "value-changed" to self.
 	end.

	on "end-error" of frame fcodfr
	do:
	   hide frame fcodfr.
	   hide message.
	   return ?.
	end.

 	on "value-changed" of v-codfr-code in frame fcodfr do:
 		v-codfr-code = caps(v-codfr-code:screen-value).
 		v-codfr-code:screen-value = caps(v-codfr-code:screen-value).

                select count(*) into v-cnt from codfr
                                where codfr.codfr = v-codfr-cdfr and
              		              codfr.code begins v-codfr-code.

		find first codfr no-lock where codfr.codfr = v-codfr-cdfr and 
		                               codfr.code  = v-codfr-code no-error.
		if avail codfr then do:
			v-codfr-name = trim(codfr.name[1] + codfr.name[2] + codfr.name[3] +
			               codfr.name[4] + codfr.name[5]).
			 /* v-codfr-name:screen-value = v-codfr-name. */
			name1:screen-value = substring (v-codfr-name, 1, 60).
			name2:screen-value = substring (v-codfr-name, 61).
			name1 = name1:screen-value.
			name2 = name2:screen-value.
		end.
		else do:

                        if v-cnt = 1 then do:

           		    find first codfr no-lock where codfr.codfr = v-codfr-cdfr and
		                               codfr.code begins v-codfr-code no-error.

		               v-codfr-code:screen-value = codfr.code.
		               v-codfr-code = codfr.code.
 			       v-codfr-name = trim(codfr.name[1] + codfr.name[2] + codfr.name[3] +
 			                      codfr.name[4] + codfr.name[5]).
    			       /* v-codfr-name:screen-value = v-codfr-name. */
    			        name1:screen-value = substring (v-codfr-name, 1, 60).
				name2:screen-value = substring (v-codfr-name, 61).
				name1 = name1:screen-value.
				name2 = name2:screen-value.

                        end.
                        else assign /* v-codfr-name:screen-value = "" */ v-codfr-name=""
                                    name1 = "" name2 = "" name1:screen-value = "" name2:screen-value = "".

		     end.

 	end.

 	disp v-codfr-code name1 name2 /* v-codfr-name */ with frame fcodfr.
        apply "value-changed" to v-codfr-code in frame fcodfr.

 	update v-codfr-code validate (can-find(codfr where codfr.codfr=v-codfr-cdfr and codfr.code = v-codfr-code),
		 	 	      "Ошибочный код")	
	with frame fcodfr editing:
                        readkey.
                        apply lastkey.
                        if frame-field = "v-codfr-code" then
                            apply "value-changed" to v-codfr-code in frame fcodfr.
 	end.

/*     	hide frame fcodfr.*/

	return v-codfr-name.
end.


procedure comm-cf2.
def input parameter  codfr-cdfr as char.
def output parameter codfr-code as char.

DEFINE QUERY q1 FOR codfr.

def browse b1 
    query q1 no-lock
    display 
        codfr.code    		      label "Код"  format "x(8)"
        codfr.name[1] + codfr.name[2] label "Наименование" format 'x(60)'
        with 16 down title "Справочник".

def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each codfr where codfr.codfr = codfr-cdfr.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
          TITLE "Не найдены записи".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.
hide frame fr1.

codfr-code = codfr.code.
return codfr.code.
end.
