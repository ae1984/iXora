/* KIS_ps.p
 * MODULE
        Монитор        
 * DESCRIPTION
        монитор
 RUN
 * CALLER
        стандартные для процессов
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        5.1
 * AUTHOR
        24.01.2005 tsoy
 * CHANGES
        23.02.05 tsoy заменил на новую последовательность
        25.02.05 tsoy незначительные доработки
        09.03.05 tsoy ожидаемый дебет
        10.03.05 tsoy дата валютирования для автоматически созданных платежей
        30.03.05 tsoy добавил расчет обязательств на дату и за период, раз в день
        05.04.05 tsoy исправил ошибку при удалении
        07.04.05 tsoy расширил формат мт102
        16.01.06 tsoy не работаем всю ночь до 8-30 утра.
        20.03.06 tsoy если суббота и воск. то выходим 
        07.04.06 tsoy Добавил автоматический расчет МРТ и уменьшил время расчета на 30 минут
        31.08.06 tsoy Чистка mt100 mt102 только ночью
        16.10.06 ten  теперь парсит по блокам
        17.10.06 ten  парсить 950 выписку на случай если НБ не пришлет 980.
	19/10/06 u00121 добавил no-undo, no-lock  в поиски по таблицам, убрал global.i вместо явно прописал необходимые глобальные переменные.
			и вообще, массовое использование глобальных переменных введет к нецелесообразному использованию памяти, в global.i иx "тучи", здесь используется одна,
			а память выделяется под все. ДОЛОЙ global.i!!!
       26/10/06  ten  - в поле 20 записывать референс для 910 
       16/11/06  tsoy - все переделал, разделил парсер на 3 отдельные п-шки  

*/


run savelog ("mt100", "KIS_ps BEGIN").

if time < 7 * 3600 then do:

run savelog ("mt100","Начало удаления старых mt100  ").

    do transaction:

	    for each mt100 where mt100.rdt < today - 10 exclusive-lock.
            	
            	for each mt102 where mt102.mtid = mt100.id exclusive-lock.
			delete  mt102.
      		end.

                delete  mt100.
            end.

    end. /*transaction*/ 

run savelog ("mt100","Окончание удаления старых mt100  ").
    return.
end.

if weekday( today ) = 1 or weekday( today ) = 7 then return.

define shared var g-today  as date.

def var v-100host   as char	no-undo. 
def var v-100path   as char	no-undo.
def var v-100path1  as char	no-undo.
def var v-ref as char	no-undo. 
def var v-i as integer	no-undo. 
def var v-delete-id as integer	no-undo. 
def var v-amt as decimal	no-undo. 
def var v-delete as logi	no-undo. 
def var v-was-21 as logi	no-undo. 
def var v-vex as char	no-undo.

def var v-parsfile as char no-undo init "kistmp.txt".

def buffer bmt100 for mt100.

define stream m-cpfl.
define stream m-infl.


run savelog ("mt100","Начало обработки sysc`а  OBTOD ").

find sysc where sysc.sysc = "OBTOD" no-lock no-error .
if avail sysc then 
do:
   if sysc.daval <> g-today then 
   do:
       run reserv_a (input g-today).
       find last cls no-lock no-error.
       if avail cls then  
          run reserv_a (input cls.whn).

   end.
end.

find sysc where sysc.sysc = "OBTOD" exclusive-lock no-error .
       sysc.daval = g-today.
release sysc.

run savelog ("mt100","Окончание обработки sysc`а  OBTOD ").

run savelog ("mt100","Начало формирования путей " ).

   find sysc where sysc.sysc = "lbHST" no-lock no-error .

   if not avail sysc then v-100host = "NTMAIN".
                     else v-100host = sysc.chval.

   find sysc where sysc.sysc = "lbeks" no-lock no-error.
   do v-i = 1 to num-entries (sysc.chval,"/"):
      v-100path = v-100path + ENTRY (v-i, sysc.chval, "/") + "\\" + "\\" .
   end.


   v-100path  = substring (v-100path, 1, length (v-100path) - 2).
   v-100path  = v-100path + "TRANSIT\\\\"+ substr(string(year(g-today)),3,2) + "-" + string(month(g-today),"99") + "-" +  string(day(g-today),"99").
   v-100path1 = v-100path.

run savelog ("mt100","Окончание формирования путей  ").

def var v-s        as char extent 20 no-undo.
def var v-fname    as char no-undo.
def var v-time     as char no-undo.
def var v-str      as char no-undo.
def var v-result   as char no-undo.
def var v-direct   as integer no-undo.
def var v-id       as integer no-undo.
def var j          as integer no-undo.
def var v-curfld   as char no-undo.
def var v-curtype  as char no-undo.
def var v-21f      as char no-undo.
def temp-table ftmp no-undo
         field vfield as char
         field vtime as char
         index idx is primary vfield.

   run pars_out.

   run savelog ("mt100","Начало движения по каталогам ").

   do v-i = 1 to 4.

          if v-i = 1 then v-100path = v-100path1 + "\\\\EXP\\\\".

/*        if v-i = 2 then v-100path = v-100path1 + "\\\\OUT\\\\". */

          if v-i = 2 then v-100path = v-100path1 + "\\\\998\\\\".
          if v-i = 3 then v-100path = v-100path1 + "\\\\970\\\\".
          if v-i = 4 then v-100path = v-100path1 + "\\\\950\\\\".

          for each ftmp.
              delete ftmp.
          end.

	  run savelog ("mt100","Формирование списка файлов  " + v-100path ).

          input through value("rsh " + v-100host + " ""dir " + v-100path + """") no-echo.
          repeat:
                import v-s.
                       if index(upper(v-s[4]), ".EKS") = 0 and index(upper(v-s[4]), ".EXP") = 0   then next.

                       v-fname = upper(v-s[4]).
                       v-time  = upper(v-s[2]).
                            
                       v-fname = trim(v-fname).

                       find first mt100 where mt100.fname = v-fname and mt100.rdt = g-today no-lock no-error.
                       if avail mt100 then next.

                       find first ftmp where ftmp.vfield eq v-fname no-error.

                       if not avail ftmp then 
                       do:
                          create ftmp.
                          assign
                                 ftmp.vfield = v-fname
                                 ftmp.vtime  = v-time.
                       end.

                       input stream m-cpfl through  value ("rcp " + v-100host + ":" + replace(v-100path,"\\","\\\\") + v-fname + " " + v-fname + "; echo $?").
                       repeat:

                             import stream m-cpfl unformatted v-vex.
                             if v-vex <> "0" then run savelog ("mt100"," ERROR:rcp " + v-fname + " FAILED"). 

                       end.
          end.

          input close.

	  run savelog ("mt100","Формирование списка файлов  " + v-100path + " завершено ").

	  run savelog ("mt100","Обработка содержимого каталога  " + v-100path ).

          for each ftmp no-lock.

              input through value("if [ -f " + ftmp.vfield + " ]; then echo 1; else echo 2; fi").
              repeat:
                    import unformatted v-vex.
                    if v-vex = "2" then run savelog ("mt100","ERROR: " + ftmp.vfield + " NOT FOUND"). 
              end.

              unix silent dos-un value(ftmp.vfield) kistmp.txt " && rm " value(ftmp.vfield). 
              unix silent cp kistmp.txt value(ftmp.vfield). 
              

	      run savelog ("mt100","Обработка файла  " + ftmp.vfield ).

	      v-parsfile = ftmp.vfield.

	      if v-i = 3 then 
	         run pars_mt970 (input v-parsfile).
	      else
     	         run pars_exp.r (input v-parsfile).

              run savelog ("mt100","Обработка файла  " + ftmp.vfield + " завершена "  ).

              unix silent rm kistmp.txt. 
              unix silent rm value(ftmp.vfield). 

          end. /*for each ftmp*/

	  run savelog ("mt100","Обработка содержимого каталога  " + v-100path + " завершена " ).

   end. /*do v-i = 1 to 5*/

run savelog ("mt100","Окончание движения по каталогам ").

run savelog ("mt100","KIS_ps END").
