/* h-cancel.p
 * MODULE
        Переводы
 * DESCRIPTION
        Возврат переводов
 * RUN
        s_return.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл        
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        22/06/05 Ilchuk
 * CHANGES
        20/07/05 nataly  - добавлен отбор переводов по дате и статусу
        27.07.05 nataly добавлена обработка банка по коду nmbr

*/


{mainhead.i}
{opr-stat.i}

def var v-choise as int format '9' init '1'.

/*message '1.ВСЕ 2.ЗА СЕГОДНЯ' update v-choise.*/
find nmbr where nmbr.code = 'translat' no-lock no-error.

{itemlist.i     
    &where = "(if translat.date = g-today  then (translat.stat = 2 or translat.stat = 3 or translat.stat = 7 or translat.stat = 8) and translat.nomer begins nmbr.prefix else (translat.stat = 2 or translat.stat = 3 or translat.stat = 7) and translat.nomer begins nmbr.prefix)"
    &file = "translat"
    &frame = "width 106 row 6 centered scroll 1 28 down overlay "
    &flddisp = "
        translat.nomer column-label 'N перевода'
        translat.date  column-label '  Дата'
        translat.fam   format 'x(15)' column-label 'Фамилия Отправ.'
        translat.name  format 'x(13)' column-label '    Имя Отправ.'
        translat.summa format 'zz,zzz,zz9.99' column-label ' Сумма '
        opr-crc(translat.crc)   format 'x(3)' column-label 'Код'
        opr-stat(translat.stat) format 'x(10)' column-label '  Статус'
    " 

    &chkey = "nomer"
    &chtype = "string"
    &index  = "i-date"
}
return frame-value.

