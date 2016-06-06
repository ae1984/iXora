/* glavara1.p
 * MODULE
        Внутренние отчеты
 * DESCRIPTION
        Средние остатки за период
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
        11.08.2005 marinav
 * CHANGES
        03/10/2005 marinav - добавились средние остатки по кредитам депозитам
        19/04/06 marinav - для унификации - дата начала периода передается параметром 
        03/07/06 u00121 - добавил индекс и no-undo во временную таблицу t-gl
        05/07/06 marinav - добавление новых филиалов...  убрала индекс из временной таблицы, он не нужен
        25/08/06 marinav - оптимизация
        04.10.06 nataly - добавила талтырогран
*/


def shared temp-table t-gl
    field gl  as char
    field gl6 as char 
    field t0  as decimal
    field t1  as deci
    field t2  as deci
    field t3  as deci
    field t4  as deci
    field t5  as deci
    field t6  as deci
    field t7  as deci.

def var v-bank as char no-undo.
def shared var d1 as date .
def shared var d0 as date .
def var v-d1 as date  no-undo.
def var i as inte.
def var j as inte.
def var m-gl as inte .


find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if avail txb.sysc then v-bank = txb.sysc.chval.
 
repeat v-d1 = d0 to d1: 
     
      for each t-gl .

           i = num-entries(t-gl.gl6).
           repeat j = 1 to i:
                m-gl = inte(entry(j,t-gl.gl6)).
                for each bank.crc no-lock:
                   find last txb.glday where txb.glday.gl = m-gl and txb.glday.crc = bank.crc.crc and txb.glday.gdt <= v-d1 no-lock no-error.
                   if avail txb.glday then do:                  
                        find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.regdt <= v-d1 no-lock no-error.
                        if avail txb.crchis then do:
                           case v-bank:
                                when 'TXB00' then t-gl.t0 = t-gl.t0 + txb.glday.bal * txb.crchis.rate[1].
                                when 'TXB01' then t-gl.t1 = t-gl.t1 + txb.glday.bal * txb.crchis.rate[1].
                                when 'TXB02' then t-gl.t2 = t-gl.t2 + txb.glday.bal * txb.crchis.rate[1].
                                when 'TXB03' then t-gl.t3 = t-gl.t3 + txb.glday.bal * txb.crchis.rate[1].
                                when 'TXB04' then t-gl.t4 = t-gl.t4 + txb.glday.bal * txb.crchis.rate[1].
                                when 'TXB05' then t-gl.t5 = t-gl.t5 + txb.glday.bal * txb.crchis.rate[1].
                                when 'TXB06' then t-gl.t6 = t-gl.t6 + txb.glday.bal * txb.crchis.rate[1].
                                otherwise         t-gl.t7 = t-gl.t7 + txb.glday.bal * txb.crchis.rate[1].
                           end case.
                        end.
                   end.
                end.
           end. 
      end.

end.
