/* monch.p
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
 * CONNECT
        bank
 * AUTHOR
        03/09/05 dpuchkov
 * CHANGES
*/


   {global.i}
   def var v-dep as integer.
   def var v-men as char init "".
   def var v-men1 as char init "".
   def buffer bf1-jl for jl.
   def buffer bf1-aaa for aaa.
   def var ocas as integer.
   def var obmGL2 as integer.
   def var xin1  as dec decimals 2 label "ПРИХОД ".
   def var xout1 as dec decimals 2 label "РАСХОД  ".
   def var sxin1  like xin1.
   def var sxout1 like xout1.
   def var v-tit as char.
   def temp-table t-chk like acheck
       field cif like aaa.cif
       field sum like aaa.opnamt
       field val as char .

   find sysc where sysc.sysc = "904kas" no-lock no-error.
   if avail sysc then obmGL2 = sysc.inval. else obmGL2 = 100200.
   find sysc where sysc.sysc = "CASHGL" no-lock no-error.
   if avail sysc then ocas = sysc.inval.



   for each cashier where cashier.kasnum begins "МЕНЕДЖЕР" and (cashier.prim = "1" or cashier.prim = "2") no-lock:
      if cashier.prim = "1" then do: /* юр лица */
          if v-men <> "" then  v-men = v-men + "," + cashier.ofc. else  v-men = cashier.ofc.
      end.
      else
      if cashier.prim = "2" then do: /* физ лица*/
          if v-men1 <> "" then v-men1 = v-men1 + "," + cashier.ofc. else v-men1 = cashier.ofc.
      end.
   end.

   v-tit = "Реестр очередей Юр.лиц".
   run sel2 (" РЕЕСТРЫ ОЧЕРЕДЕЙ ", " Реестр Физ. лиц | Реестр Юр. лиц", output v-dep).


      if v-dep = 1 then do:
         v-tit = "Реестр очередей Физ.лиц".
         v-men = v-men1.
      end.


      for each acheck where acheck.dt = g-today no-lock:
          find last jh where jh.jh = integer(acheck.jh) and jh.sts = 5 and lookup(jh.who, v-men) <> 0 no-lock no-error.
          if avail jh then do:
if time - jh.tim < 60 then next.

find last joudoc where joudoc.whn = g-today and joudoc.jh = jh.jh no-lock no-error.

                  find ofc where ofc.ofc = jh.who no-lock no-error.
                  if ofc.regno mod 1000 = 1 then do:

                      find last bf1-jl where bf1-jl.jh = jh.jh and bf1-jl.acc ne "" no-lock no-error.
                      if avail bf1-jl then do:
                         find last bf1-aaa where bf1-jl.acc = bf1-aaa.aaa no-lock no-error.
                      end.

                      create t-chk.
                      t-chk.jh  = acheck.jh.
                      t-chk.num = acheck.num.
                      t-chk.dt  = acheck.dt.
                      t-chk.n1  = acheck.n1.

   if avail joudoc and joudoc.chk <> 0 then 
   t-chk.num = t-chk.num + " ЧЕК".

    if avail bf1-aaa then 
       t-chk.cif  = bf1-aaa.cif.
                  end.
          end.
      end.


/*      for each joudoc where joudoc.whn = g-today and joudoc.chk <> 0 and lookup(joudoc.who, v-men) <> 0 no-lock:
          find last jh where jh.jh = joudoc.jh no-lock no-error.
          find ofc where ofc.ofc = joudoc.who no-lock no-error.
          if avail jh and jh.sts = 5 and avail ofc and ofc.regno mod 1000 = 1 then do:

if time - jh.tim < 60 then next.

             find last bf1-jl where bf1-jl.jh = jh.jh and bf1-jl.acc ne "" no-lock no-error.
             if avail bf1-jl then do:
                find last bf1-aaa where bf1-jl.acc = bf1-aaa.aaa no-lock no-error.
             end.

             create t-chk.
             t-chk.jh  = string(jh.jh).
             t-chk.num = "ЧЕК".
             t-chk.dt  = jh.whn.
             t-chk.n1  = "    ".
             if avail bf1-aaa then 
             t-chk.cif  = bf1-aaa.cif.
          end.
      end.*/


      for each t-chk no-lock:
        find last jh where jh.jh = integer(t-chk.jh) no-lock no-error.
        for each jl of jh use-index jhln where jl.gl = ocas or (jl.gl = obmGL2  and ((jl.trx begins "opk") 
                                                      or (substring(jl.rem[1],1,5) = "Обмен")
                                                      or (can-find (sub-cod where sub-cod.sub = "arp" 
                                                                              and sub-cod.acc = jl.acc 
                                                                              and sub-cod.d-cod = "arptype" 
                                                                              and sub-cod.ccode = "obmen1002" no-lock)))) no-lock break by jl.crc by jl.dc:
          if jl.dam gt 0 then do:
              xin1 = jl.dam. 
              xout1 = 0. 
          end.
          else do:
               xin1 = 0. 
               xout1 = jl.cam.  
          end.
          sxin1 = sxin1 + xin1.
          sxout1 = sxout1 + xout1.     
          if last-of(jl.dc) then do:
             if jl.dc eq "C"  then do:
                find last crc where crc.crc = jl.crc no-lock no-error.
                if avail crc then do:
                   t-chk.sum = sxout1.
                   t-chk.val = crc.code.
                end.
             end.
             sxin1 = 0. sxout1 = 0.
          end.
        end.
      end.














  DEFINE QUERY q1 FOR t-chk.
  def browse b1
      query q1
      displ
      t-chk.jh  label "N проводки"
      t-chk.num format "x(19)" label "N корешка "
      t-chk.dt label " Дата	"
      t-chk.cif label "CIF" format "x(6)"
      t-chk.sum format "->>>,>>>,>>>,>>9.99" label "Сумма"
      t-chk.val format "x(3)" label "Вал"
  with 6 down title v-tit overlay.

  DEFINE BUTTON bexit LABEL "Выход".
  def frame fr1 b1 skip  bexit  with centered overlay row 9 top-only.

  ON CHOOSE OF bexit IN FRAME fr1
  do:
     hide frame fr1.
     APPLY "WINDOW-CLOSE" TO BROWSE b1.
       view frame qqq.
  end.

   open query q1 for each t-chk no-lock by integer(t-chk.jh) by t-chk.cif /*by integer(substr(t-chk.cif,2,5)) */ . 
   b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
   ENABLE all with frame fr1 centered overlay top-only.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR WINDOW-CLOSE of frame fr1.











