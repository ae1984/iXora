/* trx-cods.i
 * MODULE
        Вставка кодов доходов - расходов 
 * DESCRIPTION
        Вставка кодов доходов - расходов 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        trx-cods.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        01/04/05 nataly
 * CHANGES
*/

            v-gl = gl.gl.

               v-code = "".
               v-dep = "".
                run trx-cods (input v-gl, input v-acc, output v-code, output v-dep).
               if v-code = ? or v-dep = ? or v-code = "" or not (can-find (cods where cods.gl = v-gl and cods.code = v-code))
                             then do:
                                  message "Отмена проводки!" view-as alert-box title "". 
                                 rcode = 70.
                                 rdes =  "Неверно задан код расходов/доходов для " + string(gl.gl)  .
                                 return.
                             end.

