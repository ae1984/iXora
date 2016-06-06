/* r-ost0.p
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        
 * CHANGES
*/



{functions-def.i}

define shared variable v-dt as date.

def shared stream m-out.

find first txb.cmp no-lock no-error.

put stream m-out /*FirstLine( 1, 1 ) format 'x(80)'*/ skip(1)
txb.cmp.name format "x(80)" skip
'                          '
'ТЕКУЩИЕ СЧЕТА КЛИЕНТОВ '  skip
'                      '
'(с нулевыми остатками на '  string(v-dt) ')' skip(1)
FirstLine( 2, 1 ) format 'x(80)' skip.

put stream m-out  fill( '-', 80 ) format 'x(80)'  skip.
put stream m-out  '  Счет                  Дата      Код      Наименование     ' skip.
put stream m-out  '                    регистрации  клиента   клиента       ' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip.

for each txb.crc where txb.crc.sts ne 9 break by txb.crc.crc:
    if first-of(txb.crc.crc) then do:
         put stream m-out  " ВАЛЮТА   - "  + txb.crc.des  format "x(45)" skip.
    end.  
    find first txb.aaa where txb.aaa.crc = txb.crc.crc and (txb.aaa.gl = 220310 or txb.aaa.gl = 220420) no-lock no-error.
    if not available aaa then next.
    for each txb.aaa where txb.aaa.crc = txb.crc.crc and (txb.aaa.gl = 220310 or txb.aaa.gl = 220420) no-lock :
       
        find txb.sub-cod where txb.sub-cod.sub = "CIF" and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = "CLSA" no-lock no-error.
        if avail txb.sub-cod then 
           if txb.sub-cod.ccode <> "MSC" and txb.sub-cod.rdt < v-dt then next.
         
        find last  txb.histrxbal where txb.histrxbal.sub = 'cif' and txb.histrxbal.lev = 1 and txb.histrxbal.acc = txb.aaa.aaa  and txb.histrxbal.dt <= v-dt no-lock no-error.
        if avail  txb.histrxbal and txb.histrxbal.cam - txb.histrxbal.dam <= 0 then do:
           find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
           put stream  m-out ' ' txb.aaa.aaa ' ' txb.aaa.regdt '  '  txb.aaa.cif    '  '  trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)) format 'x(50)' skip.
        end.
        if not avail txb.histrxbal and txb.aaa.regdt <= v-dt and txb.aaa.cr[1] - txb.aaa.dr[1] eq 0  and txb.aaa.sta ne 'C' then do:
           find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
           put stream  m-out ' ' txb.aaa.aaa ' ' txb.aaa.regdt '  '  txb.aaa.cif    '  '  trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)) format 'x(50)' skip.
        end.           
           
    end.


end.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip(2).



