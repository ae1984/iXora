/* r-garan1f.p
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
	    BANK COMM TXB
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
    26.08.2002
*/

{comm-txb_txb.i}

 def shared var v-dat as date no-undo.
 def shared temp-table temp
     field filial    as char
     field aaa       like  txb.aaa.aaa
     field regdt     like  txb.aaa.regdt
     field expdt     like  txb.aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  txb.cif.cif
     field name      like  txb.cif.sname
     field crc       like  txb.crc.code
     field ost       like  txb.jl.dam     init 0.

 def var v-ourbnk as char.
 v-ourbnk = comm-txb().

 for each txb.cif ,
     each txb.aaa where txb.aaa.cif = txb.cif.cif
                and txb.aaa.expdt + 30 < v-dat
                and (string(txb.aaa.gl) begins '2223' or string(txb.aaa.gl) begins '2240' or txb.aaa.gl =  213110 or txb.aaa.gl =  213120  )
                no-lock.
   create temp.
     temp.filial = v-ourbnk.
     temp.cif = txb.cif.cif.
     temp.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.sname)).
     temp.aaa = txb.aaa.aaa.
     find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
     temp.crc = txb.crc.code.
     temp.regdt = txb.aaa.regdt.
     temp.expdt = txb.aaa.expdt.
     find txb.trxlevgl where txb.trxlevgl.gl      eq  txb.aaa.gl
                             and txb.trxlevgl.subled  eq  'cif'
                             and txb.trxlevgl.level   eq  7
                             no-lock no-error.
     if avail txb.trxlevgl then do.
        if txb.trxlevgl.glr = 605530 then
           temp.vid = 'депозит'.
        else if txb.trxlevgl.glr = 605540 then
                temp.vid = 'др.залог'.
             else  temp.vid = 'н/обесп.'.

        for each txb.jl where /*jl.gl   =  trxlevgl.glr and*/
                      txb.jl.acc  =  txb.aaa.aaa /* and jl.jdt le v-dat*/
                      and txb.jl.lev = 7 and txb.jl.subled = 'cif'  no-lock.
              if txb.jl.jdt  > v-dat  then next.
            if txb.jl.dc = 'd' then temp.ost = temp.ost + txb.jl.dam.
            else temp.ost = temp.ost - txb.jl.cam.
        end.
     end.
 end.

