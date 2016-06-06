/* proviz-2.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Отчет о движении провизий
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.20
 * AUTHOR
        16/05/2011 dmitriy
 * BASES
        TXB BANK COMM
 * CHANGES
        01/07/2011 dmitriy - убрал ИП из списка физ.лиц
        20/07/2011 dmitriy - перенес 80 группу в МСБ ФЛ
        25/07/2011 dmitriy - прописал группы кредитов для физ.лиц и МСБ ИП.
        01/12/2011 dmitriy - добавил возможность выбора вида провизий (МСФО или АФН)
*/

def shared var v-reptype as integer no-undo.
def shared var v-prov_type as integer no-undo.
def shared var dat1 as date.
def shared var dat2 as date.
def var branch-name as char.

def shared temp-table wrk
   field cif as char
   field gl as char
   field cifname as char
   field branch as char
   field longr as char
   field crc as char
   field begin-bal as decimal
   field res_prc as decimal
   field res1-od as decimal
   field res1-begin as decimal
   field res1-shtr as decimal
   field res1-sum as decimal
   field sozd-od as decimal
   field sozd-begin as decimal
   field sozd-shtr as decimal
   field sozd-sum as decimal
   field storn-od as decimal
   field storn-begin as decimal
   field storn-shtr as decimal
   field storn-sum as decimal
   field res2-od as decimal
   field res2-begin as decimal
   field res2-shtr as decimal
   field res2-sum as decimal
   field chng-rate as decimal
   field end-bal as decimal.

   def var j as integer no-undo.
   def var lst_grp as char no-undo.
   def var v-grp as integer no-undo.
   lst_grp = ''.

   def var vcif as char.
   def var vcifname as char.
   def var vgl7-code as char.
   def var vbranch as char.
   def var vlongr as char.
   def var vcrc as char.
   def var vbegin-bal as decimal.
   def var vres_prc as decimal.
   def var vres1-od as decimal.
   def var vres1-begin as decimal.
   def var vres1-shtr as decimal.
   def var vres1-sum as decimal.
   def var vsozd-od as decimal.
   def var vsozd-begin as decimal.
   def var vsozd-shtr as decimal.
   def var vsozd-sum as decimal.
   def var vstorn-od as decimal.
   def var vstorn-begin as decimal.
   def var vstorn-shtr as decimal.
   def var vstorn-sum as decimal.
   def var vres2-od as decimal.
   def var vres2-begin as decimal.
   def var vres2-shtr as decimal.
   def var vres2-sum as decimal.
   def var vchng-rate as decimal.
   def var vend-bal as decimal.

   def var val as char.
   def var rezid as char.
   def var scode as char.
   def var gl-code as char.

  find first txb.cmp no-lock no-error.
  if avail txb.cmp then branch-name = txb.cmp.name.

    case v-reptype:
      when 1 then do:
        for each txb.longrp no-lock:
          if substr(string(txb.longrp.stn),1,1) = '2' then do:
            if lst_grp <> '' then lst_grp = lst_grp + ','.
            lst_grp = lst_grp + string(txb.longrp.longrp).
          end.
        end.
      end.
      when 2 then do:
        for each txb.longrp no-lock:
          if /*substr(string(txb.longrp.stn),1,1) = '1' and txb.longrp.des matches '*МСБ*'*/
            txb.longrp.longrp = 21 or txb.longrp.longrp = 24 or txb.longrp.longrp = 25 or txb.longrp.longrp = 26 or txb.longrp.longrp = 64 or
            txb.longrp.longrp = 65 or txb.longrp.longrp = 66 or txb.longrp.longrp = 80 then do:
            if lst_grp <> '' then lst_grp = lst_grp + ','.
            lst_grp = lst_grp + string(txb.longrp.longrp).
          end.
        end.
      end.
      when 3 then do:
        for each txb.longrp no-lock:
          if /*substr(string(txb.longrp.stn),1,1) = '1' and*/
             txb.longrp.longrp = 20 or txb.longrp.longrp = 27 or txb.longrp.longrp = 28 or txb.longrp.longrp = 60 or
             txb.longrp.longrp = 67 or txb.longrp.longrp = 68 or txb.longrp.longrp = 81 or txb.longrp.longrp = 82 or
             txb.longrp.longrp = 90 or txb.longrp.longrp = 92
          then do:
            if lst_grp <> '' then lst_grp = lst_grp + ','.
            lst_grp = lst_grp + string(txb.longrp.longrp).
          end.
        end.
      end.
      when 4 then do:
        for each txb.longrp no-lock:
          if lst_grp <> '' then lst_grp = lst_grp + ','.
          lst_grp = lst_grp + string(txb.longrp.longrp).
        end.
      end.
      otherwise lst_grp = ''.
    end case.

if v-prov_type = 1 then do: /* Провизии по МСФО */
  do j = 1 to num-entries(lst_grp):
     v-grp = integer(entry(j,lst_grp)).

     for each txb.lon where txb.lon.grp = v-grp no-lock:

     vbegin-bal = 0.
     vres_prc = 0.
     vres1-od = 0.
     vres1-begin = 0.
     vres1-shtr = 0.
     vres1-sum = 0.
     vsozd-od = 0.
     vsozd-begin = 0.
     vsozd-shtr = 0.
     vsozd-sum = 0.
     vstorn-od = 0.
     vstorn-begin = 0.
     vstorn-shtr = 0.
     vstorn-sum = 0.
     vres2-od = 0.
     vres2-begin = 0.
     vres2-shtr = 0.
     vres2-sum = 0.
     vchng-rate = 0.
     vend-bal = 0.


        /*if txb.lon.crc = 0 then next.*/
        create wrk.
        vcif = txb.lon.cif.

        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        if avail txb.cif then do:
            /* Имя клиента */
            vcifname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).

            /* 7-значный счет главной гниги */
            if txb.lon.crc = 1 then val = "1".
            else if txb.lon.crc = 2 or txb.lon.crc = 3 or txb.lon.crc = 6 then val = "2".
            else if txb.lon.crc = 4 then val = "3".
            rezid = string (txb.cif.geo).

            find first txb.gl where txb.gl.gl = txb.lon.gl no-lock no-error.
            if avail txb.gl then gl-code = string(txb.gl.gl).

            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'secek' and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
            if avail txb.sub-cod then scode = string (txb.sub-cod.ccode).

            vgl7-code = substring(string(gl-code),1,4) + substring (rezid, 3, 1) + string (scode) + string (val).
        end.


        /* Филиал */
        vbranch = branch-name.

        /* Группа кредита */
        vlongr = string(txb.lon.grp).

        /* Вид валюты*/
        find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
        if avail txb.crc then vcrc = txb.crc.code.

        /* Остаток ОД на начало периода */
        run lonbalcrc_txb('lon',txb.lon.lon,dat1,"1,7",no,txb.lon.crc,output vbegin-bal).

        /* РЕЗЕРВ НА НАЧАЛО ПЕРИОДА */
        run lonbalcrc_txb('lon',txb.lon.lon,dat1,"6",no,txb.lon.crc,output vres1-od).
         vres1-od = - vres1-od.

        run lonbalcrc_txb('lon',txb.lon.lon,dat1,"36",no,txb.lon.crc,output vres1-begin).
         vres1-begin = - vres1-begin.

        run lonbalcrc_txb('lon',txb.lon.lon,dat1,"37",no,1,output vres1-shtr).
         vres1-shtr = - vres1-shtr.

        /* Размер резерва в % */
        vres_prc = round((vres1-od * 100) / vbegin-bal,2).

        /* РЕЗЕРВ НА КОНЕЦ ПЕРИОДА */

        run lonbalcrc_txb('lon',txb.lon.lon,dat2,"6",yes,txb.lon.crc,output vres2-od).
         vres2-od = - vres2-od.

        run lonbalcrc_txb('lon',txb.lon.lon,dat2,"36",yes,txb.lon.crc,output vres2-begin).
         vres2-begin = - vres2-begin.

        run lonbalcrc_txb('lon',txb.lon.lon,dat2,"37",yes,1,output vres2-shtr).
         vres2-shtr = - vres2-shtr.

        /* ДОСОЗДАНО/СТОРНИРОВАНО ПРОВИЗИЙ ЗА МЕСЯЦ */
        for each txb.jl where
           txb.jl.subled = 'lon' and
           txb.jl.acc = txb.lon.lon and
           txb.jl.jdt >= dat1 and
           txb.jl.jdt <= dat2 and
           txb.jl.lev = 6
        no-lock:
           if txb.jl.crc <> 1 then do:
              find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= jl.jdt no-lock no-error.
              if avail txb.crchis then do:
                vsozd-od = vsozd-od + (txb.jl.cam * txb.crchis.rate[1]).
                vstorn-od = vstorn-od + (txb.jl.dam * txb.crchis.rate[1]).
              end.
           end.
           if txb.jl.crc = 1 then do:
              vsozd-od = vsozd-od + txb.jl.cam.
              vstorn-od = vstorn-od + txb.jl.dam.
           end.

        end.
        vstorn-od = - vstorn-od.

        for each txb.jl where
           txb.jl.subled = 'lon' and
           txb.jl.acc = txb.lon.lon and
           txb.jl.jdt >= dat1 and
           txb.jl.jdt <= dat2 and
           txb.jl.lev = 36
        no-lock:
           if txb.jl.crc <> 1 then do:
              find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= jl.jdt no-lock no-error.
              if avail txb.crchis then do:
                vsozd-begin = vsozd-begin + (txb.jl.cam * txb.crchis.rate[1]).
                vstorn-begin = vstorn-begin + (txb.jl.dam * txb.crchis.rate[1]).
              end.
           end.
           if txb.jl.crc = 1 then do:
              vsozd-begin = vsozd-begin + txb.jl.cam.
              vstorn-begin = vstorn-begin + txb.jl.dam.
           end.

        end.
        vstorn-begin = - vstorn-begin.

        for each txb.jl where
           txb.jl.subled = 'lon' and
           txb.jl.acc = txb.lon.lon and
           txb.jl.jdt >= dat1 and
           txb.jl.jdt <= dat2 and
           txb.jl.lev = 37
        no-lock:
           if txb.jl.crc <> 1 then do:
              find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= jl.jdt no-lock no-error.
              if avail txb.crchis then do:
                vsozd-shtr = vsozd-shtr + (txb.jl.cam * txb.crchis.rate[1]).
                vstorn-shtr = vstorn-shtr + (txb.jl.dam * txb.crchis.rate[1]).
              end.
           end.
           if txb.jl.crc = 1 then do:
              vsozd-shtr = vsozd-shtr + txb.jl.cam.
              vstorn-shtr = vstorn-shtr + txb.jl.dam.
           end.

        end.
        vstorn-shtr = - vstorn-shtr.

       /* Остаток ОД на конец периода */
       run lonbalcrc_txb('lon',txb.lon.lon,dat2,"1,7",yes,txb.lon.crc,output vend-bal).


       if txb.lon.crc <> 1 then do:
          find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < dat1 no-lock no-error.
          if avail txb.crchis then do:
             vbegin-bal = vbegin-bal * txb.crchis.rate[1].
             vres1-od = vres1-od * txb.crchis.rate[1].
             vres1-begin = vres1-begin * txb.crchis.rate[1].
          end.
          else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
       end.
       vres1-sum = vres1-od + vres1-begin + vres1-shtr.

       if txb.lon.crc <> 1 then do:
          find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dat2 no-lock no-error.
          if avail txb.crchis then do:
             vres2-od = vres2-od * txb.crchis.rate[1].
             vres2-begin = vres2-begin * txb.crchis.rate[1].
             vend-bal = vend-bal * txb.crchis.rate[1].
          end.
          else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
       end.

       /* Сумма досозданных провизий */
       vsozd-sum = vsozd-od + vsozd-begin + vsozd-shtr.

       /* Сумма сторнированных провизий */
       vstorn-sum = vstorn-od + vstorn-begin + vstorn-shtr.

       /* Сумма провизий на конец периода */
       vres2-sum = vres2-od + vres2-begin + vres2-shtr.

       /* Курсовые изменения */
       vchng-rate = vres1-sum + (vsozd-sum + vstorn-sum) - vres2-sum.

       /* запись в БД */
       wrk.cif = vcif.
       wrk.cifname = vcifname.
       wrk.gl = vgl7-code.
       wrk.branch = vbranch.
       wrk.longr = vlongr.
       wrk.crc = vcrc.
       wrk.begin-bal = vbegin-bal.
       wrk.res_prc = vres_prc.
       wrk.res1-od = vres1-od.
       wrk.res1-begin = vres1-begin.
       wrk.res1-shtr = vres1-shtr.
       wrk.res1-sum = vres1-sum.
       wrk.sozd-od = vsozd-od.
       wrk.sozd-begin = vsozd-begin.
       wrk.sozd-shtr = vsozd-shtr.
       wrk.sozd-sum = vsozd-sum.
       wrk.storn-od = vstorn-od.
       wrk.storn-begin = vstorn-begin.
       wrk.storn-shtr = vstorn-shtr.
       wrk.storn-sum = vstorn-sum.
       wrk.res2-od = vres2-od.
       wrk.res2-begin = vres2-begin.
       wrk.res2-shtr = vres2-shtr.
       wrk.res2-sum = vres2-sum.
       wrk.end-bal = vend-bal.
       wrk.chng-rate = vchng-rate.

     end. /* lon */
  end. /* do j = 1 */
end. /* if v-prov_type = 1 */


if v-prov_type = 2 then do:  /* Провизии по АФН */
    do j = 1 to num-entries(lst_grp):
        v-grp = integer(entry(j,lst_grp)).
        for each txb.lon where txb.lon.grp = v-grp no-lock:
            vsozd-sum = 0. vstorn-sum = 0. vbegin-bal = 0. vend-bal = 0. vres1-sum = 0. vres2-sum = 0. vchng-rate.
            /*find first txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.lev = 41 no-lock no-error.
            if avail txb.jl then do:*/

                find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                if avail txb.cif then do:
                    /* Имя клиента */
                    vcif = txb.cif.cif.
                    vcifname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).

                    /* Филиал */
                    vbranch = branch-name.

                    /* Группа кредита */
                    vlongr = string(txb.lon.grp).

                    /* Вид валюты*/
                    find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
                    if avail txb.crc then vcrc = txb.crc.code.

                    /* Остаток ОД на начало периода */
                    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"1,7",no,txb.lon.crc,output vbegin-bal).

                    /* Резерв на начало периода*/
                    run lonbalcrc_txb('lon',txb.lon.lon,dat1,"41",no,txb.lon.crc,output vres1-sum).
                    vres1-sum = - vres1-sum.

                    if txb.lon.crc <> 1 then do:
                        find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dat1 no-lock no-error.
                        if avail txb.crchis then do:
                            vbegin-bal = vbegin-bal * txb.crchis.rate[1].
                            vres1-sum = vres1-sum * txb.crchis.rate[1].
                        end.
                    end.

                    /* Досоздано/Сторнировано провизий за месяц */
                    for each txb.jl where
                       txb.jl.subled = 'lon' and
                       txb.jl.acc = txb.lon.lon and
                       txb.jl.jdt >= dat1 and
                       txb.jl.jdt <= dat2 and
                       txb.jl.lev = 41
                    no-lock:
                        find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= jl.jdt no-lock no-error.
                        if avail txb.crchis then do:
                            vsozd-sum = vsozd-sum + (txb.jl.cam * txb.crchis.rate[1]).
                            vstorn-sum = vstorn-sum + (txb.jl.dam * txb.crchis.rate[1]).
                        end.
                    end.
                    vstorn-sum = - vstorn-sum.

                    /* Резерв на конец периода*/
                    run lonbalcrc_txb('lon',txb.lon.lon,dat2,"41",yes,txb.lon.crc,output vres2-sum).
                    vres2-sum = - vres2-sum.

                    /* Остаток ОД на конец периода */
                    run lonbalcrc_txb('lon',txb.lon.lon,dat2,"1,7",yes,txb.lon.crc,output vend-bal).

                   if txb.lon.crc <> 1 then do:
                      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= dat2 no-lock no-error.
                      if avail txb.crchis then do:
                        vend-bal = vend-bal * txb.crchis.rate[1].
                        vres2-sum = vres2-sum * txb.crchis.rate[1].
                      end.
                   end.

                    /* Размер резерва в % */
                    vres_prc = round((vres1-sum * 100) / vbegin-bal,2).

                    /* Курсовые изменения */
                    vchng-rate = vres1-sum + (vsozd-sum + vstorn-sum) - vres2-sum.

                    /* запись в БД */
                    create wrk.
                    wrk.cif = vcif.
                    wrk.cifname = vcifname.
                    wrk.gl = "".
                    wrk.branch = vbranch.
                    wrk.longr = vlongr.
                    wrk.crc = vcrc.
                    wrk.begin-bal = vbegin-bal.
                    wrk.res_prc = vres_prc.
                    wrk.res1-od = 0.
                    wrk.res1-begin = 0.
                    wrk.res1-shtr = 0.
                    wrk.res1-sum = vres1-sum.
                    wrk.sozd-od = 0.
                    wrk.sozd-begin = 0.
                    wrk.sozd-shtr = 0.
                    wrk.sozd-sum = vsozd-sum.
                    wrk.storn-od = 0.
                    wrk.storn-begin = 0.
                    wrk.storn-shtr = 0.
                    wrk.storn-sum = vstorn-sum.
                    wrk.res2-od = 0.
                    wrk.res2-begin = 0.
                    wrk.res2-shtr = 0.
                    wrk.res2-sum = vres2-sum.
                    wrk.end-bal = vend-bal.
                    wrk.chng-rate = vchng-rate.


                end. /* if avail txb.cif */
            /*end.*/ /* if avail txb.jl */
        end. /* for each txb.lon */
    end. /* do j = 1 */
end. /* if v-prov_type = 2 */
