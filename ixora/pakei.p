/* pakei.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Экспорт-импорт пакета/пользователя
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
        16.07.07 marinav
 * CHANGES
*/

def var v-ofc as char.
def var v-txt as char.
def var coun as integer.

def stream rep.

def var v-sel as char init '0'.    
run sel2 ("Выбор :", " 1. Экспорт пакета доступа | 2. Импорт пакета доступа ", output v-sel).
if v-sel = '0' then return.

if v-sel = '1' then do:
  
  form skip(1)
       v-ofc label " Пакет для экспорта " validate(can-find(ofc where ofc.ofc = v-ofc), " неверное имя пакета ") format "x(10)" skip
       skip(1)
       with side-label centered row 7 frame fr.
  
     update v-ofc with frame fr.
  
     hide frame fr.

     output to value(v-ofc).
     for each bank.sec where ofc = v-ofc .
         put unformatted bank.sec.sts ";" bank.sec.fname skip .
     end.
     output close.

     output to value(v-ofc + ".1").
     for each bank.ujosec where lookup(v-ofc,bank.ujosec.officers) > 0  no-lock .
         put unformatted bank.ujosec.template skip .
     end.
     output close.


     output to value(v-ofc + ".2").
     for each bank.pssec where lookup(v-ofc,bank.pssec.ofcs) > 0 no-lock .
         put unformatted bank.pssec.proc skip .
     end.
     output close.


     output to value(v-ofc + ".3").
     for each bank.optitsec where lookup(v-ofc,bank.optitsec.ofcs) > 0  no-lock .
         put unformatted bank.optitsec.proc skip .
     end.
     output close.

     output to value(v-ofc + ".d").
     	for each bank.ofc where bank.ofc.ofc = v-ofc no-lock.
     		export bank.ofc.
     	end.
     output close.

end.

if v-sel = '2' then do:

  form skip(1)
       v-ofc label " Пакет для экспорта " validate(can-find(ofc where ofc.ofc = v-ofc), " неверное имя пакета ") format "x(10)" skip
       skip(1)
       with side-label centered row 7 frame fr.
  
     update v-ofc with frame fr.
  
     hide frame fr.

         define temp-table t-sec
            field sts as character 
            field fname like sec.fname.
         define temp-table t-sec1
            field tmpl like ujosec.template .
         define temp-table t-sec2
            field tmpl like pssec.proc .
         define temp-table t-sec3
            field tmpl like optitsec.proc .

         output to errload.sec.
         input from value(v-ofc).
         repeat:
            create t-sec.
            import delimiter ";" t-sec .
         end.
         input close.


         for each t-sec no-lock .
            find last sec where sec.ofc = v-ofc and sec.fname = t-sec.fname no-lock no-error.
            if not available sec then do:
                create sec.
                assign
                sec.sts = integer (t-sec.sts)
                sec.fname = t-sec.fname 
                sec.ofc = v-ofc .
            end.
         end.


         input from value(v-ofc + ".1").
         repeat:
            create t-sec1.
            import t-sec1 .
         end.
         input close.


         for each t-sec1 . display t-sec1 . pause 0. end.
         for each t-sec1 no-lock .
            find last ujosec where ujosec.template = t-sec1.tmpl no-error.
            if available ujosec then do:
                if lookup (v-ofc,ujosec.officers) > 0 then next.
                else
                ujosec.officers = ujosec.officers + "," + v-ofc .
            end.
            else do:
                display "Внимание! Шаблон " t-sec1.tmpl " не найден!" .  pause 0.
            end.
         end.



         input from value(v-ofc + ".2").
         repeat:
            create t-sec2.
            import t-sec2 .
         end.
         input close.


         for each t-sec2 . display t-sec2 . pause 0. end.

         for each t-sec2 no-lock .
            find last pssec where pssec.proc = t-sec2.tmpl no-error.
            if available pssec then do:
                if lookup (v-ofc,pssec.ofcs) > 0 then next.
                else
                pssec.ofcs = pssec.ofcs + "," + v-ofc .
            end.
            else do:
                display "Внимание! Процесс " t-sec2.tmpl " не найден!" . pause 0.
            end.
         end.



         input from value(v-ofc + ".3").

         repeat:
            create t-sec3.
            import t-sec3 .
         end.

         input close.


         for each t-sec3 . display t-sec3. pause 0 . end.

         for each t-sec3 no-lock .
            find last optitsec where optitsec.proc = t-sec3.tmpl no-error.
            if available optitsec then do:
                if lookup (v-ofc,optitsec.ofcs) > 0 then next.
                else
                optitsec.ofcs = optitsec.ofcs + "," + v-ofc .
            end.
            else do:
                display "Внимание! Пункт " t-sec3.tmpl " не найден!" . pause 0.
            end.
         end.


         input from value(v-ofc + ".d").
         repeat:
                create ofc.
                import ofc.

                create ofchis.
                assign ofchis.ofc = ofc.ofc
                       ofchis.point = 1
                       ofchis.dep = 1
                       ofchis.regdt = today.

                create ofcprofit.
                assign ofcprofit.ofc = ofc.ofc
                       ofcprofit.profit = '100'
                       ofcprofit.regdt = today
                	ofcprofit.tim = time
                	ofcprofit.who = 'bankadm'.
         end.

         input close.

end.

