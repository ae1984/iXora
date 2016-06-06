/* r-gle.p
 * MODULE
        Обороты по счетам ГК
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r-gl2.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
         BANK COMM
 * AUTHOR
        10/10/03 kim
 * CHANGES
        14/10/03 nataly  добавила ввод даты отчета + счета ГК
        08.01.2003 nadejda  - переделала на работу через r-branch.i
        03.02.2004 nadejda  - убрано условие на диапазон дат
        13.04.2004 suchkov  - сделал эту p-шку на основе r-gl. Точно такая же, только вызывается r-gl2e
        29.06.2009 id00024  - Програмка клон на основе r-gl. Точно такая же, только вызывается r-gl3e
*/

{mainhead.i}

{r-gl.i "new shared"}

 
     update
              v-from label "  С" /*validate (12/15/00 <= v-from, 
                " В базе информация с  " + string(12/15/00) )*/
                help " Задайте начальную дату отчета" skip
              v-to   label " ПО"  
                help " Задайте конечную дату отчета" skip
              v-list label "СЧЕТ ГК" format "x(69)"
             /* validate( can-find(gl where gl.gl eq v-glacc),
             "Счет ГК не найден... ")*/
              help " Введите счета ГК (через запятую)"
    with row 8 centered  side-label frame opt title "Задайте период отчета и счета ГК (через запятую)".

  hide frame  opt.


def var i as int.
def var v-tmpgl as int.

output to "r-gl.html".

 put "<html>" skip.
 put "<head>" skip.
 put "<META http-equiv= Content-Type content= text\/html; charset= windows-1251>" skip.
 put "<title>Отчет<\/title>" skip.
 put "<\/head>" skip.
 put "<body>" skip.
 
do i = 1 to num-entries(v-list):
    v-tmpgl = int(entry(i, v-list)).
    v-glacc = v-tmpgl.
    
    for each crc no-lock:
        v-valuta = crc.crc.
        {r-branch.i &proc = "r-gl3e (txb.name)"}
    end.

   /* put fill("*", 145) format "x(145)" skip.*/
end.

put "<\/body>" skip.
output close.

pause 0.
unix silent cptwin r-gl.html excel.
