/* vcmsg111.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
       Информация по паспортам сделок и дополнительным листам к паспортам сделок (МТ111 для НБ)
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
 
 * BASES
        BANK COMM             
 * AUTHOR
       11.04.2008 galina 
 * CHANGES
      23.04.2008 galina - явно указала ширину фреймов
      24.04.2008 galina - не выбирать конракты под типом 5
      30.04.2008 galina - дата отчета = дата оформления ПС/ДпЛ
      11.07.2008 galina - выводим значение поля PFORM
      20.08.2008 galina - переделала для консолидированой выгрузки из ЦО
       */


{mainhead.i}
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if sysc.chval = 'TXB00' then run vcrep5 ("all", 0, "msg").
else run vcrep5 ("this", 0, "msg").