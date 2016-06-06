/* cif-cfs.p
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

/* checked */
/* cif-cfs.p
*/

{global.i}

{line.i
&var = "  "
&start = " "
&head = "cif"
&line = "cfs"
&index = "cifln"
&form = "cfs.ln label 'Номер' 
         cfs.yr label 'Год' 
         cfs.revenue label 'Доход' 
         cfs.profit label 'Прибыль' 
         cfs.capital label 'Капитал' 
         cfs.ref label 'Справка' "
&frame = "row 3 col 1 scroll 1 10 down overlay title
          ""Финансовый статус "" "
&newline = "  "
&predisp = "  "
&flddisp = "cfs.ln cfs.yr cfs.revenue cfs.profit cfs.capital cfs.ref"
&preupdt = " "
&newpreupdt = " "
&posupdt = " "
&fldupdt = "cfs.yr cfs.revenue cfs.profit cfs.capital cfs.ref"
&postplus = " "
&postminus = " "
&end = " "
}
