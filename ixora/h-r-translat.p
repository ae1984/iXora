/* h-r-translat.p
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы
 * RUN
        s-r-translat.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл        
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        19/06/05 Ilchuk
 * CHANGES
        20/07/05 nataly  - добавлен отбор переводов по дате и статусу
        28.07.05 nataly - показывать только вход переводы соотв филиала или ГО
*/


{mainhead.i}
{rec-opr-stat.i}

def var v-choise as int format '9' init '1'.

/*message '1.ВСЕ 2.ЗА СЕГОДНЯ' update v-choise.*/
find nmbr where nmbr.code = 'translat' no-lock no-error.

{itemlist.i     
    &where  = "(if r-translat.date = g-today then r-translat.rec-code = nmbr.prefix else r-translat.stat <> 2 and r-translat.stat <> 3 and r-translat.stat <> 4 and r-translat.rec-code = nmbr.prefix )" 
/*    &where = "(if v-choise = 1 then true else r-translat.date = g-today)"*/
    &file = "r-translat"
    &frame = "width 104 row 6 centered scroll 1 28 down overlay "
    &flddisp = "
        r-translat.nomer column-label 'N перевода'
        r-translat.date  column-label '  Дата'
        r-translat.rec-fam   format 'x(15)' column-label 'Фамилия Получ.'
        r-translat.rec-name  format 'x(13)' column-label '    Имя Получ.'
        r-translat.summa format 'zz,zzz,zz9.99' column-label ' Сумма '
        opr-crc(r-translat.crc)   format 'x(3)' column-label 'Код'
        rec-opr-stat(r-translat.stat) format 'x(10)' column-label '  Статус'
    "     


    &chkey = "nomer"
    &chtype = "string"
    &index  = "i-date"
}
return frame-value.

