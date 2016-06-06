/* h-formasob.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        HELP к форме собственности юрлица
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-2, 15-6-4
 * AUTHOR
        01.10.2002 nadejda
 * CHANGES
        25.08.2003 nadejda - изменен индекс, поскольку теперь сортировка по русским символам идет верно
*/


{global.i}
{itemlist.i 
       &file = "codfr"
       &frame = "width 65 row 4 centered scroll 1 12 down overlay "
       &where = " codfr.codfr = 'ownform' and codfr.code <> 'msc' "
       &flddisp = "codfr.code FORMAT ""x(8)"" LABEL ""СОКРАЩЕННОЕ""
                   codfr.name[1] FORMAT ""x(50)"" LABEL ""ПОЛНОЕ НАИМЕНОВАНИЕ ФОРМЫ СОБСТВЕННОСТИ""
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "cdco_idx" }



