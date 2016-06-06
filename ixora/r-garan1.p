/* r-garan1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * BASES
	    BANK COMM
 * CHANGES
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        05.09.2005 nataly   -  добавила счет 2240
        13.12.2005 nataly  - добавила обработку по переносу счетов
        10/05/2006 nataly  - добавление новых счетов ГК 213110, 213120
        01.02.10 marinav - расширение поля счета до 20 знаков
        04.03.2012 kapar ТЗ 1325
        04/02/2013 zhasulan - ТЗ 1459 (добавил новый столбец "Филиал")
        25.09.2013 damir - Внедрено Т.З. № 1869. Изменил вывод в столбец "Филиал".
*/

 /* r-garan1.p
    отчет о выданных гарантиях, срок погашения которых наступил
    26.08.2002 */

 {global.i}
 {functions-def.i}

 def stream m-out.

 def new shared var v-dat as date no-undo.
 def new shared temp-table temp
     field filial    as char
     field aaa       like  aaa.aaa
     field regdt     like  aaa.regdt
     field expdt     like  aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  cif.cif
     field name      like  cif.sname
     field crc       like  crc.code
     field ost       like  jl.dam     init 0.

 v-dat = g-today.

/* update v-dat label ' Укажите дату ' format '99/99/9999'
        validate(v-dat ge 12/19/1999 and v-dat le g-today,
        "Дата должна быть в пределах от 19.12.1999 до текущего дня")
        skip with side-label row 5 centered frame dat .
*/

{r-brfilial.i &proc = "r-garan1f"}

 display '   Ждите...   '  with row 5 frame ww centered .



 output stream m-out to rpt.img.
 put stream m-out
 FirstLine( 1, 1 ) format 'x(107)' skip(1)
 '                          '
 'Актуальные(просроченные) гарантии на '  string(v-dat)  skip(1)
 FirstLine( 2, 1 ) format 'x(107)' skip.
 put stream m-out  fill( '-', 107) format 'x(107)'  skip.
 put stream m-out
 'Филиал     Клиент                Счет           Вал.     Сумма      Дата     Срок    Конечная дата  Вид ' skip.
 put stream m-out space(44)
 '   гарантии  выдачи    погаш-я  гарантии' skip.

 put stream m-out  fill( '-', 107 ) format 'x(107)'  skip.
 def var v-logname as char.
 for each temp where temp.ost <> 0
              break by temp.cif by temp.expdt.
    if first-of(temp.cif) then do:
       v-logname = "".
       find txb where txb.bank = temp.filial no-lock no-error.
       if avail txb then v-logname = replace(txb.logname,"mkb","HQ").
       put stream m-out ' ' v-logname  format 'x(4)'  ' '
                            temp.name  format 'x(20)' ' '
                            temp.aaa   format 'x(20)' ' '
                            temp.crc   ' '
                            temp.ost   format 'zzz,zzz,zz9.99' ' '
                            temp.regdt ' '
                            temp.expdt '  '
                            temp.expdt + 30 '  '
                            space(3) temp.vid skip.
    end.
    else do:
       v-logname = "".
       find txb where txb.bank = temp.filial no-lock no-error.
       if avail txb then v-logname = replace(txb.logname,"mkb","HQ").
       put stream m-out ' ' v-logname format 'x(4)'  ' '
                         space(21)
                         temp.aaa    format 'x(20)' ' '
                         temp.crc   ' '
                         temp.ost    format 'zzz,zzz,zz9.99' ' '
                         temp.regdt ' '
                         temp.expdt '  '
                         temp.expdt + 30 '  '
                         space(3) temp.vid skip.
    end.
 end.
 put stream m-out  fill( '-', 107 ) format 'x(107)'  skip.
 put stream m-out  space(33) 'ИТОГО:' skip.
 for each temp where temp.ost <> 0
               break by temp.crc.
     accum temp.ost (total by temp.crc).
     if last-of(temp.crc) then
         put stream m-out space(48)
                          temp.crc   ' '
                          accum total by temp.crc temp.ost
                          format 'zzz,zzz,zz9.99' skip.
 end.
 output stream m-out close.
 if  not g-batch then do:
     pause 0 before-hide .
     run menu-prt( 'rpt.img' ).
     pause before-hide.
 end.
 {functions-end.i}
 return.
