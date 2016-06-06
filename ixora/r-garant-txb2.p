/* r-garant-txb2.p
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
	30.06.2010 - id00363
    21.07.2010 - id00363 сумму обеспечения брали с поля sumzalog а надо sum
    29/12/2010 - id00810 - название филиала берется из таблицы txb
    02/09/2013 galina - ТЗ1918 перекомпиляция
*/

 /* r-garant-txb2.p
    отчет о выданных гарантиях консолид
    30.06.2010 */



 def shared stream m-out.
 def shared var v-dat as date no-undo.
 def shared var ecdivis as char no-undo.
 define shared var g-today  as date.
 define shared variable g-batch  as log initial false.
 def var i5 as integer.
 def var v-bankn as char.

def shared  temp-table temp
     field aaa       like  txb.aaa.aaa
     field ecdivis as char
     field regdt     like  txb.aaa.regdt
     field expdt     like  txb.aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  txb.cif.cif
     field name      like  txb.cif.sname
     field filial      like  txb.cmp.addr
     field crc       like  txb.crc.crc
     field code       like  txb.crc.code
     field sumzalog   like  txb.garan.sumzalog
     field ost       like  txb.jl.dam     init 0
     field ostkzt    like  txb.jl.dam     init 0.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

find first comm.txb where comm.txb.bank = trim(txb.sysc.chval) no-lock no-error.
if avail comm.txb then v-bankn = comm.txb.info.

 for each txb.cif  ,
     each txb.aaa where txb.aaa.cif = txb.cif.cif
                and txb.aaa.regdt le v-dat
                and (string(txb.aaa.gl) begins '2223' or string(txb.aaa.gl) begins '2208' or string(txb.aaa.gl) begins '2240'
                     or txb.aaa.gl =  213110 or txb.aaa.gl =  213120   )
                no-lock.
   find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = txb.aaa.cif  and  txb.sub-cod.d-cod = 'ecdivis'  no-lock no-error.
   if avail sub-cod then ecdivis = sub-cod.ccod. else ecdivis = 'N/A'.





   create temp.
     temp.cif = txb.cif.cif.
     temp.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.sname)).
     temp.aaa = txb.aaa.aaa.
     find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
     temp.crc = txb.crc.crc.
     temp.code = txb.crc.code.
     temp.regdt = txb.aaa.regdt.
     temp.expdt = txb.aaa.expdt.
     temp.ecdivis = ecdivis.
     temp.filial = v-bankn.

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

        for each txb.jl where txb.jl.acc  =  txb.aaa.aaa
                      and txb.jl.jdt  le v-dat and lev = 7 and txb.jl.subled = 'cif'  no-lock.
/*                 message jl.jh jl.jdt jl.acc.*/
            if txb.jl.dc = 'd' then temp.ost = temp.ost + txb.jl.dam.
            else temp.ost = temp.ost - txb.jl.cam.
            /*i5 = index(jl.rem[2], "Сумма").
            temp.sumzalog = decimal(trim(substr(jl.rem[2],i5 + 6))).*/
        end.


        find last txb.crchis where txb.crchis.crc = temp.crc and txb.crchis.rdt <= v-dat no-lock no-error.
           temp.ostkzt = temp.ost * txb.crchis.rate[1].

	if temp.vid = 'депозит' then do:
		find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.cif.cif no-lock no-error.
		if avail txb.garan then do.
			temp.sumzalog = txb.garan.sum.
		end.
	end.

    end.

 end.
