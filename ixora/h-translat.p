/* h-translat.p  
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы
 * RUN
        s-translat.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл        
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        16/06/05 Ilchuk
 * CHANGES
        20/07/05 nataly  - добавлен отбор переводов по дате и статусу
        27.07.05 nataly добавлена обработка банка по коду nmbr
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav



*/


{mainhead.i}
{opr-stat.i}
{comm-txb.i}

def var v-choise as int format '9' init '1'.
find nmbr where nmbr.code = 'translat' no-lock no-error.

/*message '1.ВСЕ 2.ЗА СЕГОДНЯ' update v-choise.*/

{itemlist.i     
    &where  = "(if translat.date = g-today then translat.nomer begins nmbr.prefix else translat.stat <> 4 and translat.stat <> 6 and translat.stat <> 8 and translat.nomer begins nmbr.prefix )" 
/*    &where = "(if v-choise = 1 then true else translat.date = g-today )"*/
    &file = "translat"
    &frame = "width 84 row 6 centered scroll 1 12 down overlay "
    &flddisp = "
        translat.nomer column-label 'N перевода'
        translat.date  column-label '  Дата'
        translat.fam    format 'x(15)' column-label 'Фамилия Отпр.'
        translat.name   format 'x(13)' column-label '    Имя Отпр.'
        translat.summa format 'zz,zzz,zz9.99' column-label ' Сумма '
        opr-crc(translat.crc)   format 'x(3)' column-label 'Код'
        opr-stat(translat.stat) format 'x(10)' column-label ' Стс'
    " 

    &chkey = "nomer"
    &chtype = "string"
    &index  = " i-dat "
}
return frame-value.

