/* intpay1.p
 * MODULE
          Платежная система
 * DESCRIPTION
          Отчет по внутренним платежам по всем подразделениям
 * RUN
          Способ вызова программы, описание параметров, примеры вызова
 * CALLER
          Список процедур, вызывающих этот файл 
 * SCRIPT
          Список скриптов, вызывающих этот файл
 * INHERIT
          
 * MENU
          6-12-14
 * AUTHOR
          26.06.06 ten
 * CHANGES
*/

def input parameter v-start as date.
def input parameter v-end as date.
def input parameter v-bank as char.
def var v-dep as int no-undo.
def var v-point as int no-undo.

def shared temp-table temp no-undo
         field code as char
         field urkol as int
         field uramt as dec
         field fizkol as int
         field fizamt as dec
         field inetkol as int
         field inetamt as dec
         field scankol as int
         field scanamt as dec
         field filkol as int
         field filamt as dec
         field joukol as int
         field jouamt as dec
         index cd is primary code.

for each txb.joudoc where txb.joudoc.whn >= v-start and txb.joudoc.whn <= v-end no-lock.
    if txb.joudoc.who = ? or txb.joudoc.jh = ? or txb.joudoc.crcur <> 1 then next. 
    find txb.jh  where txb.jh.jh = joudoc.jh no-lock no-error.
    if txb.jh.sub <> "jou" then next.
    find txb.aaa where txb.aaa.aaa eq txb.joudoc.dracc no-lock no-error.
    find txb.cif of txb.aaa no-lock no-error.
    if avail txb.aaa and avail txb.cif then do:
       v-point = integer(cif.jame) / 1000 - 0.5.
       v-dep = integer(cif.jame) - v-point * 1000. 
        if v-bank = "TXB00" and v-dep = 1 then do:
          find first temp where temp.code = "cent" no-error.
          if not avail temp then do:
             create temp.
                    temp.code = "cent".
          end.
/*
          if txb.cif.type = "B" then do:
             temp.urkol = temp.urkol + 1.
             temp.uramt = temp.uramt + txb.joudoc.dramt.
          end.
          else
          if txb.cif.type = "P" then do:
             temp.fizkol = temp.fizkol + 1.
             temp.fizamt = temp.fizamt + txb.joudoc.dramt.
          end.
*/
          temp.joukol = temp.joukol + 1.
          temp.jouamt = temp.jouamt + joudoc.dramt.
       end.
       else 
        if v-bank = "TXB00" and v-dep <> 1 then do:
          find first temp where temp.code = "spo" no-error.
          if not avail temp then do:
             create temp.
                    temp.code = "spo".
          end.
/*
          if txb.cif.type = "B" then do:
             temp.urkol = temp.urkol + 1.
             temp.uramt = temp.uramt + txb.joudoc.dramt.
          end.
          else
          if txb.cif.type = "P" then do:
             temp.fizkol = temp.fizkol + 1.
             temp.fizamt = temp.fizamt + txb.joudoc.dramt.
          end.
*/
          temp.joukol = temp.joukol + 1.
          temp.jouamt = temp.jouamt + joudoc.dramt.

       end.
       else 
       if v-bank <> "TXB00" then do:
          find first temp where temp.code = "fil" no-error.
          if not avail temp then do:
             create temp.
                    temp.code = "fil".
          end.
/*
          if txb.cif.type = "B" then do:
             temp.urkol = temp.urkol + 1.
             temp.uramt = temp.uramt + txb.joudoc.dramt.
          end.
          else
          if txb.cif.type = "P" then do:
             temp.fizkol = temp.fizkol + 1.
             temp.fizamt = temp.fizamt + txb.joudoc.dramt.
          end.
*/
          temp.joukol = temp.joukol + 1.
          temp.jouamt = temp.jouamt + joudoc.dramt.

       end.
    end.
    else do:
         find txb.arp where txb.arp.arp eq txb.joudoc.dracc no-lock no-error.
         if avail txb.arp then  do:
            find last txb.ofchis where txb.ofchis.ofc eq txb.joudoc.who no-lock no-error.
            if avail txb.ofchis then do:
               if txb.ofchis.depart = 1 and v-bank = "TXB00" then do:
                  find first temp where temp.code = "cent" no-error.
                  if not avail temp then do:
                     create temp.
                            temp.code = "cent".
                  end.
                  temp.joukol = temp.joukol + 1.
                  temp.jouamt = temp.jouamt + txb.joudoc.dramt.
               end.
               else 
               if ofchis.depart <> 1 and v-bank = "TXB00" then do:
                  find first temp where temp.code = "spo" no-error.
                  if not avail temp then do:
                     create temp.
                            temp.code = "spo".
                  end.
                  temp.joukol = temp.joukol + 1.
                  temp.jouamt = temp.jouamt + txb.joudoc.dramt.
               end.
               else
               if v-bank <> "TXB00" then do:
                  find first temp where temp.code = "fil" no-error.
                  if not avail temp then do:
                     create temp.
                            temp.code = "fil".
                  end.
                  temp.joukol = temp.joukol + 1.
                  temp.jouamt = temp.jouamt + txb.joudoc.dramt.
               end.
            end.
         end.
    end.
end.