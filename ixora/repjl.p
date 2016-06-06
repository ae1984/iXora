/* repjl.p
 * MODULE
       Кредиты
 * DESCRIPTION
         Отчет по исполнению решений КК (внутренний аудит)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        04/09/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        07/09/2009 galina - перекомпиляция
        08/09/2009 galina - перекомпиляция
*/

def input parameter p-bank as char.
def input parameter p-dt1 as date.
def input parameter p-dt2 as date.

def shared temp-table t-jl
  field bank as char
  field jlnum as integer
  field jldt as date
  field ofc as char
  field dgl as integer
  field dacc as char
  field cgl as integer
  field cacc as char
  field summ as decimal
  field rem as char
  index ind1 is primary bank dgl cgl.
  
def buffer b-jl for txb.jl.

def var v-gllist as char.
def var i as integer.

v-gllist = '186050,713014,713040,713060'.
do i  = 1 to num-entries(v-gllist):
    for each txb.jl where txb.jl.jdt >= p-dt1 and txb.jl.jdt <= p-dt2 and txb.jl.dc = 'D' and txb.jl.gl = integer(entry(i,v-gllist)) no-lock:
       if i > 1 then do:
           create t-jl.
           assign t-jl.bank = p-bank
                  t-jl.jlnum = txb.jl.jh
                  t-jl.jldt = txb.jl.jdt
                  t-jl.ofc = txb.jl.who
                  t-jl.dgl = txb.jl.gl
                  t-jl.dacc = txb.jl.sub + ' ' + txb.jl.acc
                  t-jl.summ =  txb.jl.dam
                  t-jl.rem = trim(txb.jl.rem[1]) + ' ' + trim(txb.jl.rem[2]) + ' ' + trim(txb.jl.rem[3]) + ' ' + trim(txb.jl.rem[4]) +  ' ' + trim(txb.jl.rem[5]).
       end.       
       find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
       if avail b-jl then do:
          if i = 1 and b-jl.gl <> 490000 then do:
               create t-jl.
               assign t-jl.bank = p-bank
                      t-jl.jlnum = txb.jl.jh
                      t-jl.jldt = txb.jl.jdt
                      t-jl.ofc = txb.jl.who
                      t-jl.dgl = txb.jl.gl
                      t-jl.dacc = txb.jl.sub + ' ' + txb.jl.acc
                      t-jl.summ =  txb.jl.dam
                      t-jl.rem = trim(txb.jl.rem[1]) + ' ' + trim(txb.jl.rem[2]) + ' ' + trim(txb.jl.rem[3]) + ' ' + trim(txb.jl.rem[4]) +  ' ' + trim(txb.jl.rem[5]).
          end.
          if i > 1 or (i = 1 and b-jl.gl <> 490000) then
          assign t-jl.cgl = b-jl.gl
                 t-jl.cacc = b-jl.sub + ' ' + b-jl.acc.
       end.
       
    end.
end.


v-gllist = '186050,713014,713040,713060,717000,718000'.
do i  = 1 to num-entries(v-gllist):
    for each txb.jl where txb.jl.jdt >= p-dt1 and txb.jl.jdt <= p-dt2 and txb.jl.dc = 'C' and txb.jl.gl = integer(entry(i,v-gllist)) no-lock:
       find first txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
       create t-jl.
       assign t-jl.bank = p-bank
              t-jl.jlnum = txb.jl.jh
              t-jl.jldt = txb.jl.jdt
              t-jl.ofc = txb.jl.who
              t-jl.cgl = txb.jl.gl
              t-jl.cacc = txb.jl.sub + ' ' + txb.jl.acc
              t-jl.summ =  txb.jl.cam
              t-jl.rem = trim(txb.jl.rem[1]) + ' ' + trim(txb.jl.rem[2]) + ' ' + trim(txb.jl.rem[3]) + ' ' + trim(txb.jl.rem[4]) +  ' ' + trim(txb.jl.rem[5]).
       if avail txb.ofc then t-jl.ofc = t-jl.ofc + ' ' + txb.ofc.name.
       find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
       if avail b-jl then do:
          assign t-jl.dgl = b-jl.gl
                 t-jl.dacc = b-jl.sub + ' ' + b-jl.acc.
       end.
       
    end.
end.
   


  
  