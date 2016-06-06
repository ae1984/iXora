/* kdsysc2.f
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Формы для мониторинга
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.11
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
*/
 
form skip
    kdaffilh.name format "x(50)" label "НАИМЕНОВАНИЕ БАНКА"
    with row 5 centered scroll 1 10 down title " ОБОРОТЫ ПО СЧЕТАМ С " + string(d1) + " ПО " + string(kdcifhis.regdt)
    frame kdaffil9 .


 
