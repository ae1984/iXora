/* tdajlhist.а
 * MODULE
        Депозиты
 * DESCRIPTION
        Просмотр проводок по депозиту TDA - форма вывода
 * RUN
        
 * CALLER
        tdainfo1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.1, 1.2, 10.7.3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20.06.2004 nadejda - переделала на вывод временной таблицы, а то сортировки проводок никакой не было
        02.03.2010 marinav - чуть увеличилась форма
*/


form t-jl.jh  label "Проводка" 
     t-jl.ln  label "Лн" format "zz9"
     t-jl.jdt label "Дата"
     t-jl.amt label "Сумма            " 
     t-jl.dc  label "Д/К"
     t-jl.rem[1] label "Описание      " format "x(30)"
with row 5 10 down centered title " История проводок " overlay frame jl.
