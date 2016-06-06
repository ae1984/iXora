/* gv-konvl.p
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
        25/07/2007 madiyar - убрал упоминание удаленной таблицы e002
*/

def input parameter v-dat as date.
def shared temp-table valbs
             field gl like txb.gl.gl 
             field des like txb.gl.des
             field type like txb.gl.type
             field crc like txb.glday.crc
             field sumv like txb.glday.bal
             field sumt like txb.glday.bal
             INDEX igl gl.



define shared var g-today  as date.
def shared variable g-batch  as log initial false.

define var vbal as deci extent 4 format 'zzz,zzz,zzz,zz9.99-'.

for each txb.crc where txb.crc.crc ge 2 and txb.crc.crc lt 12 no-lock.

 find last txb.crchis where txb.crchis.crc = txb.crc.crc 
                        and txb.crchis.regdt le v-dat no-lock no-error.
    for each txb.gl no-lock break by txb.gl.type by txb.gl.gl:

        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.gdt le
              v-dat and txb.glday.crc = txb.crc.crc no-lock no-error.
        if avail txb.glday then do:

          find first valbs where  valbs.gl =  txb.gl.gl and
                          valbs.crc = txb.crc.crc
                          no-lock no-error.
          if avail valbs then do: 
             valbs.sumv = valbs.sumv + txb.glday.bal.
             valbs.sumt = valbs.sumt + txb.glday.bal * txb.crchis.rate[1]. 
          end.
          else do:
             create valbs.
             valbs.gl =  txb.gl.gl.
             valbs.des = txb.gl.des.
             valbs.crc = txb.crc.crc.
             valbs.type = txb.gl.type.
             valbs.sumv = valbs.sumv + txb.glday.bal.
             valbs.sumt = valbs.sumt + txb.glday.bal * txb.crchis.rate[1]. 
          end.

        end.

   end.
end.
