/* r-garant.p
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
        BANK
 * CHANGES
       15/08/03 nataly по заявке Касимовой Т.
       1) добавлена колонка "Эквивалент в тенге" ( по курсу на дату отчета)
       2) Все гарантии разбиты  по видам залога ( с выводом итога в тенге)
       3) В ИТОГО добавлен эквивалент в тенге
       28/11/03 nataly увеличен формат итоговых сумм
       28/01/04 nataly был добавлен признак отрасли
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       28/05/2004 madiyar - в отчет теперь попадают также остатки 7-го уровня счетов "2208"
       05.09.2005 nataly   -  добавила счет 2240
       08.11.2005 nataly  - добавила обработку по переносу счетов
       10/05/2006 nataly  - добавление новых счетов ГК 213110, 213120
       02/04/2009 madiyar - подправил название отчета
        01.02.10 marinav - расширение поля счета до 20 знаков
*/

 /* r-garant.p
    отчет о выданных гарантиях
    23.02.2001 */

 {global.i new}
 {functions-def.i}

 def stream m-out.
 def var v-dat as date no-undo.
 def var ecdivis as char no-undo.

 def temp-table temp
     field aaa       like  aaa.aaa
     field ecdivis as char
     field regdt     like  aaa.regdt
     field expdt     like  aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  cif.cif
     field name      like  cif.sname
     field crc       like  crc.crc
     field code       like  crc.code
     field ost       like  jl.dam     init 0
     field ostkzt    like  jl.dam     init 0.

 find last cls no-lock no-error.
 g-today = if available cls then cls.cls + 1 else today.
 v-dat = g-today.

 update v-dat label ' Укажите дату ' format '99/99/9999'
        validate(v-dat ge 12/19/1999 and v-dat le g-today,
        "Дата должна быть в пределах от 19.12.1999 до текущего дня")
        skip with side-label row 5 centered frame dat .

 display '   Ждите...   '  with row 5 frame ww centered .

 for each cif  ,
     each aaa where aaa.cif = cif.cif
                and aaa.regdt le v-dat
                and (string(aaa.gl) begins '2223' or string(aaa.gl) begins '2208' or string(aaa.gl) begins '2240'
                     or aaa.gl =  213110 or aaa.gl =  213120   )
                no-lock.
   find sub-cod where sub-cod.sub = 'cln' and  sub-cod.acc = aaa.cif  and  sub-cod.d-cod = 'ecdivis'  no-lock no-error.
   if avail sub-cod then ecdivis = sub-cod.ccod. else ecdivis = 'N/A'.
   create temp.
     temp.cif = cif.cif.
     temp.name = trim(trim(cif.prefix) + " " + trim(cif.sname)).
     temp.aaa = aaa.aaa.
     find crc where crc.crc = aaa.crc no-lock no-error.
     temp.crc = crc.crc.
     temp.code = crc.code.
     temp.regdt = aaa.regdt.
     temp.expdt = aaa.expdt.
     temp.ecdivis = ecdivis.

     find trxlevgl where trxlevgl.gl      eq  aaa.gl
                     and trxlevgl.subled  eq  'cif'
                     and trxlevgl.level   eq  7
                     no-lock no-error.
     if avail trxlevgl then do.
        if trxlevgl.glr = 605530 then
           temp.vid = 'депозит'.
        else if trxlevgl.glr = 605540 then
                temp.vid = 'др.залог'.
             else  temp.vid = 'н/обесп.'.

        for each jl where jl.acc  =  aaa.aaa
                      and jl.jdt  le v-dat and lev = 7 and subled = 'cif'  no-lock.
/*                 message jl.jh jl.jdt jl.acc.*/
            if jl.dc = 'd' then temp.ost = temp.ost + jl.dam.
            else temp.ost = temp.ost - jl.cam.
        end.

        find last crchis where crchis.crc = temp.crc and crchis.regdt <= v-dat
         no-lock no-error.
           temp.ostkzt = temp.ost * crchis.rate[1].
    end.
 end.

 output stream m-out to rpt.img.
 put stream m-out
/* FirstLine( 1, 1 ) format 'x(78)' skip(1)*/
 '                          '
 'ВЫДАННЫЕ ГАРАНТИИ на ' string(v-dat) " (включительно)"  skip(1).
/* FirstLine( 2, 1 ) format 'x(78)' skip.*/
 put stream m-out  fill( '-', 113) format 'x(113)'  skip.
 put stream m-out
 '   Клиент              '
 ' Счет            '
 '  Вал.'
 '       Сумма    '
 '   Эквивалент   '
 '   Дата   '
 '  Срок    '
 '   Вид '
 ' Признак ' skip.
 put stream m-out
 space(45)
 '      гарантии '
 '      в тенге  '
 '    выдачи  '
 ' погаш-я '
 ' гарантии'
 ' отрасли ' skip.
 put stream m-out  fill( '-', 113 ) format 'x(113)'  skip.

 for each temp where  temp.ost <> 0
              break by temp.vid by temp.cif by temp.expdt.
     accum temp.ostkzt (total by temp.vid).

    if first-of(temp.cif) then
       put stream m-out ' ' temp.name  ' '
                            temp.aaa   ' '
                            temp.code  ' '
                            temp.ost   format 'zzz,zzz,zz9.99' ' '
                            temp.ostkzt   format 'zz,zzz,zzz,zz9.99' ' '
                            temp.regdt ' '
                            temp.expdt ' '
                            temp.vid
                            temp.ecdivis skip.
    else
       put stream m-out  space(22)
                         temp.aaa   ' '
                         temp.code  ' '
                         temp.ost   format 'zzz,zzz,zz9.99' ' '
                         temp.ostkzt   format 'zz,zzz,zzz,zz9.99' ' '
                         temp.regdt ' '
                         temp.expdt ' '
                         temp.vid  skip.
 if last-of(temp.vid)
    then do:
       put stream m-out  skip fill( '-', 113) format 'x(113)'  skip.
       put stream m-out skip  '       ИТОГО ПО ВИДУ ГАРАНТИИ: ' temp.vid
                         accum  total by temp.vid temp.ostkzt   format 'zz,zzz,zzz,zz9.99' at 63 ' ' skip(1).
    end.
 end.
   put stream m-out  fill( '-', 113 ) format 'x(113)'  skip.
   put stream m-out  space(22) 'ИТОГО:'
                         accum  total temp.ostkzt format 'zz,zzz,zzz,zz9.99' at 63 ' '  skip(1).

 for each temp where temp.ost <> 0
               break by temp.code.
     accum temp.ost (total by temp.code).
     accum temp.ostkzt (total by temp.code).
     if last-of(temp.code) then
         put stream m-out space(43)
                          temp.code   ' '
                          accum total by temp.code temp.ost
                          format 'zzz,zzz,zz9.99'
                          accum total by temp.code temp.ostkzt
                          format 'zz,zzz,zzz,zz9.99'  at 63
                          skip.
 end.
 output stream m-out close.
 if  not g-batch then do:
     pause 0 before-hide .
     run menu-prt( 'rpt.img' ).
     pause before-hide.
 end.
 {functions-end.i}
 return.
