/* h-spr_bank.p 
 * MODULE
        Переводы 
 * DESCRIPTION
        Переводы (справочник пунктов обслуживания)
 * RUN
        h-spr_bank.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        17/06/05 Ilchuk
 * CHANGES

*/
{mainhead.i}
{itemlist.i     
    &where = "spr_bank.code begins 'МБГБ'"
    &file = "spr_bank"
    &frame = "width 60 row 15 centered scroll 1 6 down overlay "
    &flddisp = "
        spr_bank.code
        spr_bank.name
    " 

    &chkey = "code"
    &chtype = "string"
    &index  = "i-code"
}

return frame-value.
/*return frame-value.*/

