/* cramtpar.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Процесс, который обрабатывает документы Интернет Офиса - создание внешнего платежа
 * RUN
        
 * CALLER
        
 * SCRIPT
    IBHtz_ps.p        
 * INHERIT
        
 * MENU
        5-1
 * AUTHOR
        10.05.04 tsoy
 * CHANGES
*/     

     /*
      * tsoy Установка парметров для валютного контроля
      * если это физ лицо платеж > 10 000
      */

    find first ib.docext where ib.docext.docid = ib.doc.id and ib.docext.code = "DC"  no-lock no-error.
    if avail ib.docext then do:
                                     create sub-cod.
                                         sub-cod.acc      = remtrz.remtrz.       
                                         sub-cod.sub      = 'rmz'.
                                         sub-cod.d-cod    = 'zdcavail'.

                                         if docext.chval[1] = "1" then
                                         sub-cod.ccode    =   "1".

                                         if docext.chval[1] = "0" then
                                         sub-cod.ccode    =   "2".

                                         sub-cod.rdt      = g-today.
    end.


    find first ib.docext where ib.docext.docid = ib.doc.id and ib.docext.code = "SG"  no-lock no-error.
    if avail ib.docext then do:
                                     create sub-cod.
                                         sub-cod.acc      = remtrz.remtrz.       
                                         sub-cod.sub      = 'rmz'.
                                         sub-cod.d-cod    = 'zsgavail'.

                                         if docext.chval[1] = "1" then
                                         sub-cod.ccode      = "1".

                                         if docext.chval[1] = "0" then
                                         sub-cod.ccode      = "2".

                                         sub-cod.rdt      = g-today.
    end.


