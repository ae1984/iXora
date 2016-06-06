/* remzvkb.f
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

form v-num format "zzzzzz" label "Dokumenta Nr."
     linkjl.docdate format "99/99/99" label "Dokumenta datums"
     linkjl.atr[5] format "x(15)" label "Maks–t–ja konts"
     linkjl.atr[9]  format "x(12)" label "Re¦istracijas Nr"
     linkjl.atr[12] format "x(11)" label "Nor.cntr.s/konts"
     with overlay 1 columns row 5 1 down centered
          title "VALSTS KASE - Ievadiet papilddatus"
          side-label frame entvkb.
