/* sgnsysc.f
 * MODULE
        Клиентская база
 * DESCRIPTION
        Настройки просмотра карточке подписей - форма для настроек
 * RUN
        
 * CALLER
        sgnsysc.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-3
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
*/


form
     sysc.sysc label "КОД ПАР"
     sysc.des format "x(30)" label "ПАРАМЕТР"
     sysc.daval label "ДАТА"
     sysc.deval label "ЧИСЛО ВЕЩ."
     sysc.inval label "ЧИСЛО ЦЕЛ."
     sysc.loval label "ЛОГ"
with row 5 centered scroll 1 12 down width 80 frame f-dat .
