/* s-lonnda1.i
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


/*-------------------------------
  #3.NodroЅin–juma p–rvёrtёЅana
-------------------------------*/
if v-atl > 0
then do:
     s2 = s1 / v-atl * 100.
end.
else do:
     s2 = 0.
end.
display w-sec.lonsec
        w-sec.des
        w-sec.secamt0
        w-sec.secamt
        w-sec.pietiek
with frame sec1.
display s4
        s1
        s2
        w-sec.who
        w-sec.whn
with frame br.
pause 0.
if ja-ne
then do:
     s1 = s1 - w-sec.secamt.
     update w-sec.secamt
            w-sec.pietiek
            go-on("PF1" "U8" "F10" "CURSOR-UP" "CURSOR-DOWN") with frame sec1.
     s1 = s1 + w-sec.secamt.
end.
else pause.
