/* astn.f
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


form
"N Строки "   "      Группа" "    Ном.карт. Норма амортизации % "  
astnal.whn astnal.who skip  
 astnal.nrst at 3 format "zz9" astnal.grup at 16 format "x(2)"     
 astnal.dam4 at 20 format "x(4)" astnal.ast at 28 format "x(10)" " "        
"A1:" astnal.amp  format "zz9.99" 
"A2:" astnal.amn  format "zz9.99" skip(1)

"Стоимост.баланс группы на конец предыд. периода   (Б):" astnal.ston format "zzzzzz,zzz,zz9.99-" skip  
"Сумма прироста стоимости                      (В):" astnal.sper format "zzzzzz,zzz,zz9.99-" skip
"Стоимость поступивших ОС                      (Г):" astnal.sieg format "zzzzzz,zzz,zz9.99-" skip
"Kорректировка стоимости ОС                       :" astnal.damn2[1] format "zzzzzz,zzz,zz9.99-" skip
"Сумма от реализации ОС группы                 (Д):" astnal.sizs format "zzzzzz,zzz,zz9.99-" skip
"Стоимостной баланс группы на конец налогов.г.     (Е):" astnal.sbal format "zzzzzz,zzz,zz9.99-" skip
"Амортизационные отчисления отчетного налог. года  (Ж):" astnal.snam format "zzzzzz,zzz,zz9.99-" skip                   
"Фактические  расходы на ремонт ОС - всего        :" astnal.sremk format "zzzzzz,zzz,zz9.99-"  skip
"в т.ч.в пределах " astnal.damn3[1] format "zz9"
                "% стоимостного балана гр.  (З):" astnal.srem10 format "zzzzzz,zzz,zz9.99-" skip
"в т.ч.на увеличение стоимостного баланса гр.  (И):" astnal.sremos format "zzzzzz,zzz,zz9.99-" skip
"Ст.баланс гр.подлежит вычету -< 100 рас.показ.(К):" astnal.k format "zzzzzz,zzz,zz9.99-" skip  
"Ст.баланс гр.подлежит вычету - выбытие ОС гр. (Л):" astnal.l format "zzzzzz,zzz,zz9.99-" skip
"Стоим.баланс гр.на конец налог.года с учетом корр.(М):" astnal.stok format "zzzzzz,zzz,zz9.99-" skip

  with frame astn row 2 overlay centered no-labels no-hide
    title "ВВОД, ПРОСМОТР И КОРРЕКТИРОВКА АМОРТИЗАЦИИ ДЛЯ НАЛОГОВ " +     string(v-god,"9999").

