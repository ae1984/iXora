/* rep10CB1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        25/10/2012 Luiza
 * BASES
        BANK COMM TXB
 * CHANGES

*/

def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.
def shared var v-ful as logic format "да/нет" no-undo.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.
def var v-txb as int no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
v-txb = int(substring(trim(txb.sysc.chval),4,2)) + 1.

define shared temp-table wrk1 no-undo
    field num1 as char
    field vid1 as char
    field sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field cassp1 as char
    field num2 as char
    field vid2 as char
    field sum2 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field sumtxb1 as decim extent 17 format ">>>,>>>,>>>,>>>,>>9.99"
    field sumtxb2 as decim extent 17 format ">>>,>>>,>>>,>>>,>>9.99"
    field cassp2 as char.

def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.
def var v-cassp as char.
def buffer bglday for txb.glday.

for each txb.jl  no-lock where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2  and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and txb.jl.dc = "D" and txb.jl.crc = 1.
    /* поиск кассплана */
    v-cassp = "".
    find first txb.jlsach where txb.jlsach.jh = txb.jl.jh and txb.jlsach.ln = txb.jl.ln no-lock no-error.
    if available txb.jlsach then v-cassp = string(txb.jlsach.sim).
    find first wrk1 where wrk1.cassp1 = v-cassp no-error.
    if available wrk1 then do:
        wrk1.sum1 = wrk1.sum1 + txb.jl.dam.
        wrk1.sumtxb1[v-txb] = wrk1.sumtxb1[v-txb] + txb.jl.dam.
    end.
end.
for each txb.jl  no-lock where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2  and (txb.jl.gl = 100100 or txb.jl.gl = 100500) and txb.jl.dc = "C" and txb.jl.crc = 1.
    /* поиск кассплана */
    v-cassp = "".
    find first txb.jlsach where txb.jlsach.jh = txb.jl.jh and txb.jlsach.ln = txb.jl.ln no-lock no-error.
    if available txb.jlsach then v-cassp = string(txb.jlsach.sim).
    find first wrk1 where wrk1.cassp2 = v-cassp no-error.
    if available wrk1 then do:
        wrk1.sum2 = wrk1.sum2 + txb.jl.cam.
        wrk1.sumtxb2[v-txb] = wrk1.sumtxb2[v-txb] + txb.jl.cam.
    end.
end.

/* собираем остатки на начало  */
find first wrk1 where wrk1.num1 = "11" no-error.

find last bglday where bglday.gl = 100100 and bglday.gdt < dt1 and bglday.crc = 1 no-lock no-error.
if avail bglday then do:
    wrk1.sum1 = wrk1.sum1 + bglday.bal.
    wrk1.sumtxb1[v-txb] = wrk1.sumtxb1[v-txb] + bglday.bal.
end.

find last bglday where bglday.gl = 100500 and bglday.gdt < dt1 and bglday.crc = 1 no-lock no-error.
if avail bglday then do:
    wrk1.sum1 = wrk1.sum1 + bglday.bal.
    wrk1.sumtxb1[v-txb] = wrk1.sumtxb1[v-txb] + bglday.bal.
end.

find last bglday where bglday.gl = 100110 and bglday.gdt < dt1 and bglday.crc = 1 no-lock no-error.
if avail bglday then do:
    wrk1.sum1 = wrk1.sum1 + bglday.bal.
    wrk1.sumtxb1[v-txb] = wrk1.sumtxb1[v-txb] + bglday.bal.
end.

/* собираем остатки на конец  */
find first wrk1 where wrk1.num2 = "31" no-error.

find last bglday where bglday.gl = 100100 and bglday.gdt <= dt2 and bglday.crc = 1 no-lock no-error.
if avail bglday then do:
    wrk1.sum2 = wrk1.sum2 + bglday.bal.
    wrk1.sumtxb2[v-txb] = wrk1.sumtxb2[v-txb] + bglday.bal.
end.

find last bglday where bglday.gl = 100500 and bglday.gdt <= dt2 and bglday.crc = 1 no-lock no-error.
if avail bglday then do:
    wrk1.sum2 = wrk1.sum2 + bglday.bal.
    wrk1.sumtxb2[v-txb] = wrk1.sumtxb2[v-txb] + bglday.bal.
end.

find last bglday where bglday.gl = 100110 and bglday.gdt <= dt2 and bglday.crc = 1 no-lock no-error.
if avail bglday then do:
    wrk1.sum2 = wrk1.sum2 + bglday.bal.
    wrk1.sumtxb2[v-txb] = wrk1.sumtxb2[v-txb] + bglday.bal.
end.



/* для расширенного отчета */

if v-ful then do:

    def shared var v-from as date .
    def shared var v-to as date .
    def shared var v-valuta as int .
    def shared var v-valuta_code as char .
    def shared var v-list as char .
    def shared var v-glacc as int format ">>>>>>".
    def shared var v-dt as dec format "->>>,>>>,>>>,>>9.99".
    def shared var v-ct like v-dt.

    def var v-name as char.

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

    def shared temp-table ttt no-undo
      field bank as char
      field name as char.

    def var s-ourbank as char no-undo.
    find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
    if not avail txb.sysc or txb.sysc.chval = "" then do:
       display " There is no record OURBNK in bank.sysc file !!".
       pause.
       return.
    end.
    s-ourbank = trim(txb.sysc.chval).
    find first ttt where ttt.bank  = s-ourbank no-lock no-error.
    v-name = ttt.name.

    def var kod as char.
    def var kbe as char.
    def var knp as char.
    def var v-chgk as char init "1001,1002,1003,1004,1005,1006,1007,1008,1009".

    do i = 1 to num-entries(v-list):
        v-tmpgl = int(entry(i, v-list)).
        v-glacc = v-tmpgl.

        for each txb.crc where txb.crc.crc = 1 no-lock:
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
end.


