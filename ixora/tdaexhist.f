/* tdaexhist.f
 * MODULE
        Депозиты
 * DESCRIPTION
        Просмотр истории утсановки счету признака исключения по % ставки - форма для просмотра
 * RUN
        
 * CALLER
        tdainfo.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.1, 1.2, 10.7.3
 * AUTHOR
        20.05.2004 nadejda
 * CHANGES
*/

form t-excl.whn  label "ДАТА" format "99/99/99"
     t-excl.who  label "КТО УСТАНОВИЛ" format "x(28)"
     t-excl.rate label "%СТАВКА" format "zz9.99"
     t-excl.oper label "ИСКЛ" format "да/нет"
     t-excl.des  label "РАСПОРЯЖЕНИЕ" format "x(27)"
with row 6 5 down centered title " История признака исключения " overlay frame f-dat.
