/* r-gl2.p
 * MODULE
        Обороты по счетам ГК
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        10/10/03 kim
 * CHANGES
        14/10/03 nataly  добавила ввод даты отчета + счета ГК
        21/10/03 nataly неправильно брался входящий остаток. Теперь реализовано через bglday
        08.01.2004 nadejda - не выдавать отчет для счетов без оборотов
        07/10/04 madiar - подправил поиск парной проводки (теперь по genln)
        08/10/04 madiar - поле genln при создании проводок без шаблона как правило не проставлялось, поэтому поиск парной проводки
                          при проставленном genln производится по этому полю, в противном случае - по старому
        14/03/05 sasco  - поиск корресп счета по b-jl.ln = vln
        26.10.05 marinav - добавлен счет
        17/11/05 u00121 - ограничил формат txb.jl.rem[1] до 45 символов, т.к. вся запись о проводке не помещается в одну строку, отчет становится "некрасивым" при печати :))
        06/05/06 marinav - убрала первую проверку по glbal.
        19/07/2011 madiyar - вывод в excel
        20/07/2011 id00810 -  перенесла сюда разборку счетов ГК и валюты из r-gl.p
        29/11/2011 id00810 - добавила no-error в строке 142
        05/01/2012 evseev - закомментировал "if not v-isdata then next"
        06/04/2012 Luiza   - вывод код кбе кнп
        19/07/2012 dmitriy - добавил if not avail txb.gl then next
        02/08/2012 Luiza   - вывод символа кассового плана
        21/10/2013 Luiza   - ТЗ 2137 добавила столбец признак ДПК
        06/11/2013 Luiza   - *ТЗ 2188
        12/11/2013 Luiza   - ТЗ 2196 вывод статуса проводки

*/

{r-gl.i "shared"}

def input parameter v-name as char.

def buffer bglday for txb.glday.
def buffer b-gl for txb.gl.
/*def var v-strText as char.*/
def buffer b-jl for txb.jl.
def var v-corracc as int format ">>>>>>".
def var v-corraccdes as char format "x(40)".
def var v-corr as char format "x(10)".
def var v-outsum as dec format "->>>,>>>,>>>,>>>,>>9.99".
def var v-rem as char no-undo.
def var v-doc as char no-undo.
def var v-dat as date.
def var v-isdata as logical.
def var vln like txb.jl.ln.

def var v-dam_in as deci no-undo.
def var v-dam_out as deci no-undo.
def var v-cam_in as deci no-undo.
def var v-cam_out as deci no-undo.
def var i as int.
def var v-tmpgl as int.

def shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field gl as integer
  field crc as integer
  field crc_code as char
  field jdt as date
  field jh as integer
  field glcorr as integer
  field glcorr_des as char
  field acc_corr as char
  field dam as deci
  field cam as deci
  field dam_KZT as deci
  field cam_KZT as deci
  field rem as char
  field who as char
  field glcorr2 as integer
  field glcorr_des2 as char
  field acc2 as char
  field cod as char
  field kbe as char
  field knp as char
  field rez as char
  field rez1 as char
  field cassp as char
  field DPK as char
  index idx is primary bank gl crc jdt jh.

def shared temp-table wrk_ost no-undo
  field bank as char
  field gl as integer
  field crc as integer
  field dam_in as deci
  field cam_in as deci
  field dam_out as deci
  field cam_out as deci
  field dam_in_KZT as deci
  field cam_in_KZT as deci
  field dam_out_KZT as deci
  field cam_out_KZT as deci
  index idx is primary bank gl crc.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
find first txb.cmp no-lock no-error.
if available txb.cmp then message txb.cmp.name  .
pause 1.
def var kod as char.
def var kbe as char.
def var knp as char.
def var v-cassp as char.
def var v-dpk as char.
def var v-chgk as char init "1001,1002,1003,1004,1005,1006,1007,1008,1009".
/*
find first txb.glday where txb.glday.gl = v-glacc and
          (txb.glday.gdt >= v-from and txb.glday.gdt <= v-to) and
          txb.glday.crc = v-valuta no-lock no-error.

if avail txb.glday then do:
*/

do i = 1 to num-entries(v-list):
    v-tmpgl = int(entry(i, v-list)).
    v-glacc = v-tmpgl.

    for each txb.crc no-lock:
        v-valuta = txb.crc.crc.
        v-valuta_code = txb.crc.code.

        /* 08.01.2004 nadejda */
        v-isdata = false.

        do v-dat = v-from to v-to:
          find first txb.jl where txb.jl.gl = v-glacc and
                     txb.jl.jdt = v-dat and
                     txb.jl.crc = v-valuta use-index jdt no-lock no-error.
          if avail txb.jl then do:
            v-isdata = true.
            leave.
          end.
        end.

        /*if not v-isdata then next.*/
        /*******************/

        find txb.gl where txb.gl.gl = v-glacc no-lock no-error.
        if not avail txb.gl then next.

        v-dam_in = 0. v-cam_in = 0.
        find last bglday where bglday.gl = v-glacc and bglday.gdt < v-from and bglday.crc = v-valuta no-lock no-error.
        if avail bglday then do:
            if txb.gl.type = "A" or txb.gl.type = "E" then v-dam_in = bglday.bal.
            else v-cam_in = bglday.bal.
        end.

        v-dam_out = 0. v-cam_out = 0.
        find last bglday where bglday.gl = v-glacc and bglday.gdt <= v-to and bglday.crc = v-valuta no-lock no-error.
        if avail bglday then do:
            if txb.gl.type = "A" or txb.gl.type = "E" then v-dam_out = bglday.bal.
            else v-cam_out = bglday.bal.
        end.

        create wrk_ost.
        assign wrk_ost.bank = s-ourbank
               wrk_ost.gl = v-glacc
               wrk_ost.crc = v-valuta
               wrk_ost.dam_in = v-dam_in
               wrk_ost.cam_in = v-cam_in
               wrk_ost.dam_out = v-dam_out
               wrk_ost.cam_out = v-cam_out.

        if v-valuta <> 1 then do:
            find last txb.crchis where txb.crchis.crc = v-valuta and txb.crchis.rdt < v-from no-lock no-error.
            if avail txb.crchis then assign wrk_ost.dam_in_KZT = wrk_ost.dam_in * txb.crchis.rate[1] wrk_ost.cam_in_KZT = wrk_ost.cam_in * txb.crchis.rate[1].
            find last txb.crchis where txb.crchis.crc = v-valuta and txb.crchis.rdt <= v-to no-lock no-error.
            if avail txb.crchis then assign wrk_ost.dam_out_KZT = wrk_ost.dam_out * txb.crchis.rate[1] wrk_ost.cam_out_KZT = wrk_ost.cam_out * txb.crchis.rate[1].
        end.
        else assign wrk_ost.dam_in_KZT = wrk_ost.dam_in wrk_ost.cam_in_KZT = wrk_ost.cam_in wrk_ost.dam_out_KZT = wrk_ost.dam_out wrk_ost.cam_out_KZT = wrk_ost.cam_out.

        do v-dat = v-from to v-to:
          for each txb.jl no-lock where txb.jl.gl = v-glacc and txb.jl.jdt = v-dat use-index jdt /* break by txb.jl.jh by txb.jl.crc*/:
            if txb.jl.crc <> v-valuta then next.
                vln = jl.ln.
                if vln mod 2 = 0 then vln = vln - 1.
                                 else vln = vln + 1.
                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam and b-jl.cam = txb.jl.dam and /*(b-jl.ln + 1 = txb.jl.ln or b-jl.ln - 1 = txb.jl.ln)*/
                                      b-jl.ln = vln no-lock no-error.
                if avail b-jl then do:
                    v-corracc = b-jl.gl. v-corr = b-jl.acc.
                    find first b-gl where b-gl.gl = v-corracc no-lock no-error.
                    if avail b-gl then v-corraccdes = b-gl.des. else v-corraccdes = ''.
                end.
                else do:
                    v-corracc = 0. v-corr = ''. v-corraccdes = ''.
                end.

              v-rem = trim(trim(txb.jl.rem[1]) + " " + trim(txb.jl.rem[2]) + " " + trim(txb.jl.rem[3]) + " " + trim(txb.jl.rem[4]) + " " + trim(txb.jl.rem[5])).
              find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
              if avail txb.jh then v-doc = txb.jh.party.
              if v-rem = '' and avail txb.jh then v-rem = txb.jh.party.
              kod = "".
              kbe = "".
              knp = "".
              if v-doc begins "jou" or v-doc begins "rmz" then do:
                  if v-doc begins "jou" then do:
                    find first txb.sub-cod where txb.sub-cod.sub = "jou" and txb.sub-cod.acc = substring(trim(v-doc),1,10) and txb.sub-cod.d-cod  = "eknp" no-lock no-error.
                    if available txb.sub-cod then do:
                        kod = substring(txb.sub-cod.rcode,1,2).
                        kbe = substring(txb.sub-cod.rcode,4,2).
                        knp = substring(txb.sub-cod.rcode,7,3).
                    end.
                  end.
                  if v-doc begins "rmz" then do:
                    find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = substring(trim(v-doc),1,10) and txb.sub-cod.d-cod  = "eknp" no-lock no-error.
                    if available txb.sub-cod then do:
                        kod = substring(txb.sub-cod.rcode,1,2).
                        kbe = substring(txb.sub-cod.rcode,4,2).
                        knp = substring(txb.sub-cod.rcode,7,3).
                    end.
                  end.
              end.
              if kod = "" and kbe = "" and knp = "" then do:
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 1 and txb.trxcods.codfr = "locat" no-lock no-error.
                   if available txb.trxcods then do:
                      kod = txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 1 and txb.trxcods.codfr = "secek" no-lock no-error.
                   if available txb.trxcods then do:
                      kod = kod + txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 2 and txb.trxcods.codfr = "locat" no-lock no-error.
                   if available txb.trxcods then do:
                      kbe = txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 2 and txb.trxcods.codfr = "secek" no-lock no-error.
                   if available txb.trxcods then do:
                      kbe = kbe + txb.trxcods.code.
                   end.
                   find txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = 1 and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if available txb.trxcods then knp = txb.trxcods.code.
              end.
              /* поиск кассплана */
              v-cassp = "".
              find first txb.jlsach where txb.jlsach.jh = txb.jl.jh and txb.jlsach.ln = txb.jl.ln and
                    lookup(substring(string(txb.jl.gl),1,4),v-chgk) > 0 no-lock no-error.
                    if available txb.jlsach then v-cassp = string(txb.jlsach.sim).
              /*-----------------------------------------------------------------------------*/
              /* признак дпк */
              if txb.jl.gl = 286012 then do:
                  find first comm.pcpay where comm.pcpay.bank = s-ourbank and comm.pcpay.jh  = txb.jl.jh no-lock no-error.
                  if available comm.pcpay then do:
                      v-dpk = "файл".
                      if txb.jl.sts <> 6 then v-dpk = "ФАЙЛ (проводка не отштампована статус 5)".
                  end.
                  else do:
                      v-dpk = "".
                      if txb.jl.sts <> 6 then v-dpk = "(проводка не отштампована статус 5)".
                  end.
              end.
              /*-----------------------------------------------------------------------------------*/
              create wrk.
              assign wrk.bank = s-ourbank
                     wrk.bankn = v-name
                     wrk.gl = v-glacc
                     wrk.crc = v-valuta
                     wrk.crc_code = v-valuta_code
                     wrk.jdt = v-dat
                     wrk.jh = txb.jl.jh
                     wrk.glcorr = v-corracc
                     wrk.glcorr_des = v-corraccdes
                     wrk.acc_corr = v-corr
                     wrk.dam = txb.jl.dam
                     wrk.cam = txb.jl.cam
                     wrk.rem = v-rem
                     wrk.who = txb.jl.who
                     wrk.glcorr2 = txb.jl.gl.
                     wrk.acc2 = txb.jl.acc.
                    wrk.cod = kod.
                    wrk.kbe = kbe.
                    wrk.knp = knp.
                    wrk.cassp = v-cassp.
                    wrk.DPK = v-dpk.
                find first txb.aaa where txb.aaa.aaa = txb.jl.acc no-lock no-error.

                if available txb.aaa then do:
                    wrk.glcorr_des2 = txb.aaa.name.
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if available txb.cif then if txb.cif.geo = "021" then wrk.rez1 = "1". else wrk.rez1 = "2".
                end.
                find first txb.aaa where txb.aaa.aaa = v-corr no-lock no-error.
                if available txb.aaa then do:
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if available txb.cif then if txb.cif.geo = "021" then wrk.rez = "1". else wrk.rez = "2".
                end.
                if wrk.glcorr_des2 = "" then do:
                    find first txb.arp where txb.arp.arp = txb.jl.acc no-lock no-error.
                    if available txb.arp then wrk.glcorr_des2 = txb.arp.des.
                end.
                if wrk.glcorr_des2 = "" then do:
                    find first txb.dfb where txb.dfb.dfb = txb.jl.acc no-lock no-error.
                    if available txb.dfb then wrk.glcorr_des2 = txb.dfb.name.
                end.
                if wrk.crc <> 1 then do:
                find last txb.crchis where txb.crchis.crc = wrk.crc and txb.crchis.rdt <= wrk.jdt no-lock no-error.
                if avail txb.crchis then assign wrk.dam_KZT = wrk.dam * txb.crchis.rate[1] wrk.cam_KZT = wrk.cam * txb.crchis.rate[1].
              end.
              else assign wrk.dam_KZT = wrk.dam wrk.cam_KZT = wrk.cam.
          end.
        end. /*v-dat*/
    end.
end.


