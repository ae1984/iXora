/* h-prefix.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        HELP к стране инопартнера
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-6-4, 15-7-1
 * AUTHOR
        26.08.2003 nadejda
 * CHANGES
   15.07.05 nataly добавила  return frame-value    
*/


{global.i}
{itemlist.i 
       &file = "codfr"
       &frame = "  row 5 centered scroll 1 10 down overlay title ' СПРАВОЧНИК СТРАН ' "
       &where = " codfr.codfr = 'iso3166' and codfr.code <> 'msc' "
       &flddisp = "codfr.code FORMAT 'x(3)' LABEL 'КОД'
                   codfr.name[2] FORMAT 'x(30)' LABEL 'РУССКОЕ НАИМЕНОВАНИЕ СТРАНЫ'
                   codfr.name[1] FORMAT 'x(30)' LABEL 'МЕЖДУНАРОД. НАИМЕНОВАНИЕ'
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "main" }
return frame-value.




