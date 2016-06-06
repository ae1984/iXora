/* r-dopmax.p
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
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*
    12.01.2000
    r-dopusk.p 
    Отчет по счетам с остатком больше crc.max-report...
    Пропер С.В.

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
   21/05/03 nataly - были добавлены Итоги по валютам в разрезе каждого филиала
*/

/*{global.i new}*/

def input parameter v-dat as date.

define shared var g-today  as date.
def shared variable g-batch  as log initial false.
def            var amt1       as deci.
def new shared var its        as deci decimals 2.
def new shared var oldcrc     as deci initial 0.
def new shared var ii         as deci initial 0.
def new shared var oldval     as char.
def new shared temp-table temp
    field aaa  like txb.aaa.aaa
    field cif  like txb.cif.cif
    field crc  like txb.crc.crc
    field code like txb.crc.code
    field amt1 as deci decimals 2 format '-zzzz,zzz,zzz,zzz,zz9.99'.

find last  txb.cls no-lock no-error.
find first txb.cmp no-lock no-error.

/*display '   Ждите...   '  with row 5 frame ww centered .*/

output to rpt.img append.
put skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( txb.cmp.name )                               format 'x(79)' at 02 skip(1)
'СПИСОК СЧЕТОВ КЛИЕНТОВ'                       format 'x(22)' at 29 skip
' на ' + string( v-dat, '99/99/9999' ) + ' г.' format 'x(17)' at 31 skip(1).
put ' ' fill( '-', 77 )           format 'x(77)'       skip.
put  
'п/п'          at 02
'Счет'         at 07
'Наименование' at 18
'Валюта'       at 51
'Сумма'        at 70
skip.  
put ' ' fill( '-', 77 ) format 'x(77)' skip(1).

    oldcrc = 0.
    for each txb.aaa where 
    txb.aaa.sta <> 'C' and 
    txb.aaa.regdt <> v-dat and
    txb.aaa.gl = 220310 no-lock
    break by txb.aaa.crc by txb.aaa.cr[1] - txb.aaa.dr[1] descend:

    /* выберем юридические... */
    find first txb.sub-cod where 
    txb.sub-cod.d-cod = 'clnsts' and
    txb.sub-cod.ccode = '0'      and 
    txb.sub-cod.sub   = 'cln'    and
    txb.sub-cod.acc   = string( txb.aaa.cif ) 
    no-lock no-error.
    if not avail txb.sub-cod then next.
    
    /* пропустим исключения... */
    find first txb.sub-cod where
    txb.sub-cod.d-cod = 'clndop' and
    txb.sub-cod.sub   = 'cln'    and
    txb.sub-cod.acc   = string( txb.aaa.cif )
    no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode = '1' then next.
    
    find txb.crc where txb.crc.crc eq txb.aaa.crc no-lock no-error.
    find txb.crc-new where txb.crc-new.crc eq txb.aaa.crc no-lock no-error.
    if v-dat = g-today then amt1 = txb.aaa.cr[1] - txb.aaa.dr[1].
    else do:
        find last txb.aab where txb.aab.aaa eq txb.aaa.aaa and 
        txb.aab.fdt <= v-dat - 1
        no-lock no-error.
        if not available txb.aab then next.    
        amt1 = txb.aab.bal. 
    end.

    if amt1 < txb.crc-new.max-report then next.
    create temp.
    temp.aaa  = txb.aaa.aaa.
    temp.cif  = txb.aaa.cif.
    temp.crc  = txb.crc.crc.
    temp.code = txb.crc.code.
    temp.amt1 = amt1.
end.

    for each temp break by temp.crc by temp.amt1 descend:
    if temp.crc <> oldcrc and oldcrc <> 0 then run itogo.
        oldcrc = temp.crc.
        oldval = temp.code.
        ii     = ii + 1.
        its    = its + temp.amt1.
        find txb.cif where txb.cif.cif eq temp.cif no-lock no-error.
        put ii format '>>>9' '. '
        temp.aaa  ' ' 
        trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)) format "x(30)" '   '  
        temp.code ' ' 
        temp.amt1
        skip.
    end.        

run itogo.
put ' ' fill( '-', 77 ) format 'x(77)' skip(2).
put chr(12).
output close.

return.
/**/
procedure itogo.
    
    put  skip
    fill( ' ', 41 ) format 'x(41)' 'Итого по ' oldval format 'xxxx'
    its format '-zzzz,zzz,zzz,zzz,zz9.99' 
    skip(1).
    ii  = 0.
    its = 0.
                                                  
end procedure.
/***/
