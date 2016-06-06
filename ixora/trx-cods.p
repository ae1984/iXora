/* trx-cods.p
 * MODULE
        форма ввода кодов доходов- расходов
 * DESCRIPTION
        форма ввода кодов доходов- расходов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        help-code, help-dep
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19.04.05 nataly
 * CHANGES
       26.04.05 nataly добавлена обработка проводки, когда v-code =?
       26.09.05 nataly если код начинается с 1,2 или 3  департамент ставится по g-ofc
      23/01/06 nataly добавила признак архивности справочника 
*/
{global.i}

define input parameter v-gl like gl.gl.
define input parameter v-acc like jl.acc.
define output parameter v-code as char.
define output parameter v-dep as char format 'x(3)'.


define  var v-descr like cods.des label "Наименование".
define  var v-des like cods.des label "Наименование".

define button dbut1 label "Выбрать".
define button dbut3 label "Отмена".
def  shared var v-gltrx as char.


define  frame get-debls 
             v-code label "Введите код расходов/доходов (F2 - выбор)"
             validate (can-find(cods where cods.code = v-code and cods.gl = v-gl  and cods.arc = no no-lock) or v-code = ?, "Код не найден! ")
             skip
             v-descr view-as text skip
             v-dep label "Подразделение (F2 - выбор)"
             validate (can-find( codfr where codfr.codfr = 'sdep' and codfr.code = v-dep  no-lock) or v-dep = ? , "Подразделение не найдено! ")
             v-des view-as text skip
             skip
             dbut1  dbut3
             with row 5 centered side-labels overlay.

on help of v-code in frame get-debls do: 
                                        run help-code (v-gl,v-acc).
                                       v-code:screen-value = return-value.
                                       v-code = v-code:screen-value.
                                   end.
on help of v-dep in frame get-debls do: run help-dep (input v-dep).
                                       v-dep:screen-value = return-value.
                                       v-dep = v-dep:screen-value.
                                   end.
  
on value-changed of v-code in frame get-debls do:
   find cods where cods.gl = v-gl and cods.code = v-code:screen-value and cods.arc = no no-lock no-error.
   if avail cods  then v-descr = cods.des.
                  else v-descr = "".
   if avail cods  then v-dep = cods.dep.
                  else v-dep = "".
                                  /*26/09/05*/
     if (v-code begins '1' or v-code begins '2' or v-code begins '3') and v-dep = '000' then 
     do:
       find ofc where ofc.ofc = g-ofc no-lock no-error.
       find codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd no-lock  no-error.
     if avail codfr then v-dep = codfr.name[4].
     end.                    /*26/09/05 nataly*/

   if avail  cods and cods.dep <> "000" then do:
     find codfr where codfr.codfr = 'sdep' and codfr.code = cods.dep no-lock no-error.
     if avail codfr then v-des = codfr.name[1]. else v-des = "".
   end.
   else v-des = "Подразделение не задано".
   displ v-descr v-dep v-des with frame get-debls.
end.

on value-changed of v-dep in frame get-debls do:
   find codfr where codfr.codfr = 'sdep' and codfr.code = v-dep:screen-value no-lock no-error.
   if avail codfr then v-des = codfr.name[1]. else v-des = "".
   displ  v-des with frame get-debls.
end.

v-code = ?.
v-dep = ?.
/* выбрать код */
on choose of dbut1 in frame get-debls do:
   v-code = v-code:screen-value.
   v-dep = v-dep:screen-value.
   apply "go" to frame get-debls.
end.


/* отменить и выйти из редактирования */
on choose of dbut3 in frame get-debls do:
   v-code:screen-value = ?.
   v-code = ?.
   v-dep:screen-value = ?.
   v-dep = ?.
   apply "go" to frame get-debls.
end.

/* - - - - - - - ОСНОВНАЯ ЧАСТЬ ПРОГРАММЫ - - - - - -*/

enable all with frame get-debls.
pause 0.

do transaction ON ENDKEY undo,leave:
update v-code 
       v-dep with frame get-debls
editing:
        readkey.
        apply lastkey.
        if frame-field = "v-code" then apply "value-changed" to v-code in frame get-debls.
        if frame-field = "v-dep"  then apply "value-changed" to v-dep in frame get-debls.

     if lookup(string(v-gl), v-gltrx) = 0 then
        find cods where cods.gl = v-gl and cods.code = v-code:screen-value and cods.arc = no no-lock no-error.
     else  find  cods where cods.gl =  v-gl and cods.acc = v-acc and cods.code = v-code:screen-value  and cods.arc = no no-lock no-error.
   if avail cods then do:
     if cods.dep <> '000' and cods.dep <> v-dep then do:
        message 'Неверно набран код департамента! Надо' cods.dep  '!' .
        v-dep:screen-value = ?.
        v-dep = ?.
        apply "go" to frame get-debls. /*26.04.05 nataly*/
     end.
   end. 
   else do:
   v-code:screen-value = ?.
   v-code = ?.
   v-dep:screen-value = ?.
   v-dep = ?.
    apply "go" to frame get-debls.    /*26.04.05 nataly*/
  end.
end.

end.
hide frame get-debls.

/* - - - - - - - - - - - КОНЕЦ - - - - - - - - - - -*/ 

