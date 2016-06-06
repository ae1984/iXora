/* astnal.f
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


FORM

astnal.nrst format "zz9" label "Ст." 
astnal.grup format "x(2)" label "Гр."
astnal.ast  format "x(10)" label "Карточка" 
astnal.amn format "zz9.99-" label "% аморт."
astnal.ston format "zzz,zzz,zzz,zz9.99-" label "Cт.баланс на нач.г."
astnal.stok format "zzz,zzz,zzz,zz9.99-" label "Cт.баланс на конец г."

 WITH FRAME astnal row 5 centered 
 title "Ввод и редактирование налоговой амортизации за " + string(v-god)
    scroll 1 10 down overlay.  



