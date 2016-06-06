/* emi1.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по депозитам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.1.8.14
 * BASES
        TXB COMM
 * AUTHOR
        06/03/09 id00004
 * CHANGES
        01.06.2009 galina - исключила до 02/11/2009 20-тизначные счета из отчета
        12/07/2010 galina - убрала проверку на 20-тизначные счета
        17.01.11 evseev - добавил группы для учета счетов Недропользователь 518,519,520
        30.05.11 evseev - добавил группы для учета счетов Метролюкс A22,A23,A24
        23.11.2011 id00004 - добавил новые валюты и группы
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/

def shared var g_date as date.
def shared var v-dbeg as date.
def buffer b-aaa for txb.aaa.

def shared temp-table tom
    field  pp as char
    field  df_kzt_kol as integer
    field  df_kzt_sum as decimal
    field  df_usd_kol as integer
    field  df_usd_sum as decimal
    field  df_eur_kol as integer
    field  df_eur_sum as decimal
    field  df_rur_kol as integer
    field  df_rur_sum as decimal

    field  df_gbp_kol as integer
    field  df_gbp_sum as decimal
    field  df_aud_kol as integer
    field  df_aud_sum as decimal
    field  df_sek_kol as integer
    field  df_sek_sum as decimal
    field  df_chf_kol as integer
    field  df_chf_sum as decimal
    field  df_zar_kol as integer
    field  df_zar_sum as decimal
    field  df_cad_kol as integer
    field  df_cad_sum as decimal.

  def var sm as decimal.
  def var v-cls as integer.

  for each txb.aaa where txb.aaa.stadt  < v-dbeg and  lookup(txb.aaa.lgr,"A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36,A38,A39,A40") <> 0 no-lock :
      /*if length(txb.aaa.aaa) = 20 then next.*/
      sm = 0. v-cls = 0.
      run lonbal3('cif', txb.aaa.aaa, v-dbeg - 1, "1", yes, output sm).
      find last tom where tom.pp = "DF" exclusive-lock.

      if txb.aaa.crc = 1  then tom.df_kzt_sum = tom.df_kzt_sum + sm.
      if txb.aaa.crc = 2  then tom.df_usd_sum = tom.df_usd_sum + sm.
      if txb.aaa.crc = 3  then tom.df_eur_sum = tom.df_eur_sum + sm.
      if txb.aaa.crc = 4  then tom.df_rur_sum = tom.df_rur_sum + sm.
      if txb.aaa.crc = 6  then tom.df_gbp_sum = tom.df_gbp_sum + sm.
      if txb.aaa.crc = 7  then tom.df_sek_sum = tom.df_sek_sum + sm.
      if txb.aaa.crc = 8  then tom.df_aud_sum = tom.df_aud_sum + sm.
      if txb.aaa.crc = 9  then tom.df_chf_sum = tom.df_chf_sum + sm.
      if txb.aaa.crc = 10 then tom.df_zar_sum = tom.df_zar_sum + sm.
      if txb.aaa.crc = 11 then tom.df_cad_sum = tom.df_cad_sum + sm.

      find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
      if avail txb.aadrt then do:
         if txb.aadrt.who = "C" and txb.aadrt.whn < v-dbeg then v-cls = 1.
      end.
      if v-cls <> 1 then do:
         if txb.aaa.crc = 1  then tom.df_kzt_kol = tom.df_kzt_kol + 1.
         if txb.aaa.crc = 2  then tom.df_usd_kol = tom.df_usd_kol + 1.
         if txb.aaa.crc = 3  then tom.df_eur_kol = tom.df_eur_kol + 1.
         if txb.aaa.crc = 4  then tom.df_rur_kol = tom.df_rur_kol + 1.
         if txb.aaa.crc = 6  then tom.df_gbp_kol = tom.df_gbp_kol + 1.
         if txb.aaa.crc = 7  then tom.df_sek_kol = tom.df_sek_kol + 1.
         if txb.aaa.crc = 8  then tom.df_aud_kol = tom.df_aud_kol + 1.
         if txb.aaa.crc = 9  then tom.df_chf_kol = tom.df_chf_kol + 1.
         if txb.aaa.crc = 10 then tom.df_zar_kol = tom.df_zar_kol + 1.
         if txb.aaa.crc = 11 then tom.df_cad_kol = tom.df_cad_kol + 1.

      end.
  end.

  for each txb.aaa where txb.aaa.stadt  < v-dbeg and  lookup(txb.aaa.lgr,"484,485,486,487,488,489,478,479,480,481,482,483,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") <> 0 no-lock :
      /*if length(txb.aaa.aaa) = 20 then next.*/
      sm = 0. v-cls = 0.
      run lonbal3('cif', txb.aaa.aaa, v-dbeg - 1, "1", yes, output sm).
      find last tom where tom.pp = "DU" exclusive-lock.

      if txb.aaa.crc = 1  then tom.df_kzt_sum = tom.df_kzt_sum + sm.
      if txb.aaa.crc = 2  then tom.df_usd_sum = tom.df_usd_sum + sm.
      if txb.aaa.crc = 3  then tom.df_eur_sum = tom.df_eur_sum + sm.
      if txb.aaa.crc = 4  then tom.df_rur_sum = tom.df_rur_sum + sm.
      if txb.aaa.crc = 6  then tom.df_gbp_sum = tom.df_gbp_sum + sm.
      if txb.aaa.crc = 7  then tom.df_sek_sum = tom.df_sek_sum + sm.
      if txb.aaa.crc = 8  then tom.df_aud_sum = tom.df_aud_sum + sm.
      if txb.aaa.crc = 9  then tom.df_chf_sum = tom.df_chf_sum + sm.
      if txb.aaa.crc = 10 then tom.df_zar_sum = tom.df_zar_sum + sm.
      if txb.aaa.crc = 11 then tom.df_cad_sum = tom.df_cad_sum + sm.

      find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
      if avail txb.aadrt then do:
         if txb.aadrt.who = "C" and txb.aadrt.whn < v-dbeg then v-cls = 1.
      end.
      if v-cls <> 1 then do:
         if txb.aaa.crc = 1  then tom.df_kzt_kol = tom.df_kzt_kol + 1.
         if txb.aaa.crc = 2  then tom.df_usd_kol = tom.df_usd_kol + 1.
         if txb.aaa.crc = 3  then tom.df_eur_kol = tom.df_eur_kol + 1.
         if txb.aaa.crc = 4  then tom.df_rur_kol = tom.df_rur_kol + 1.
         if txb.aaa.crc = 6  then tom.df_gbp_kol = tom.df_gbp_kol + 1.
         if txb.aaa.crc = 7  then tom.df_sek_kol = tom.df_sek_kol + 1.
         if txb.aaa.crc = 8  then tom.df_aud_kol = tom.df_aud_kol + 1.
         if txb.aaa.crc = 9  then tom.df_chf_kol = tom.df_chf_kol + 1.
         if txb.aaa.crc = 10 then tom.df_zar_kol = tom.df_zar_kol + 1.
         if txb.aaa.crc = 11 then tom.df_cad_kol = tom.df_cad_kol + 1.

      end.
  end.

/*  for each txb.aaa where txb.aaa.stadt  < v-dbeg and  lookup(txb.aaa.lgr,"246,151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,249,250") <> 0 no-lock : */
  for each txb.aaa where txb.aaa.stadt  < v-dbeg and  lookup(txb.aaa.lgr,"246,151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,249") <> 0 no-lock :

      /*if length(txb.aaa.aaa) = 20 then next.*/
      sm = 0. v-cls = 0.

      find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
      if not avail txb.cif then next.
      find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif  and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
      if (txb.cif.type = "p" and txb.sub-cod.ccode <> "0") then do:

         run lonbal3('cif', txb.aaa.aaa, v-dbeg - 1, "1", yes, output sm).
         find last tom where tom.pp = "TF" exclusive-lock.

      if txb.aaa.crc = 1  then tom.df_kzt_sum = tom.df_kzt_sum + sm.
      if txb.aaa.crc = 2  then tom.df_usd_sum = tom.df_usd_sum + sm.
      if txb.aaa.crc = 3  then tom.df_eur_sum = tom.df_eur_sum + sm.
      if txb.aaa.crc = 4  then tom.df_rur_sum = tom.df_rur_sum + sm.
      if txb.aaa.crc = 6  then tom.df_gbp_sum = tom.df_gbp_sum + sm.
      if txb.aaa.crc = 7  then tom.df_sek_sum = tom.df_sek_sum + sm.
      if txb.aaa.crc = 8  then tom.df_aud_sum = tom.df_aud_sum + sm.
      if txb.aaa.crc = 9  then tom.df_chf_sum = tom.df_chf_sum + sm.
      if txb.aaa.crc = 10 then tom.df_zar_sum = tom.df_zar_sum + sm.
      if txb.aaa.crc = 11 then tom.df_cad_sum = tom.df_cad_sum + sm.

      find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
      if avail txb.aadrt then do:
         if txb.aadrt.who = "C" and txb.aadrt.whn < v-dbeg then v-cls = 1.
      end.
      if v-cls <> 1 then do:
         if txb.aaa.crc = 1  then tom.df_kzt_kol = tom.df_kzt_kol + 1.
         if txb.aaa.crc = 2  then tom.df_usd_kol = tom.df_usd_kol + 1.
         if txb.aaa.crc = 3  then tom.df_eur_kol = tom.df_eur_kol + 1.
         if txb.aaa.crc = 4  then tom.df_rur_kol = tom.df_rur_kol + 1.
         if txb.aaa.crc = 6  then tom.df_gbp_kol = tom.df_gbp_kol + 1.
         if txb.aaa.crc = 7  then tom.df_sek_kol = tom.df_sek_kol + 1.
         if txb.aaa.crc = 8  then tom.df_aud_kol = tom.df_aud_kol + 1.
         if txb.aaa.crc = 9  then tom.df_chf_kol = tom.df_chf_kol + 1.
         if txb.aaa.crc = 10 then tom.df_zar_kol = tom.df_zar_kol + 1.
         if txb.aaa.crc = 11 then tom.df_cad_kol = tom.df_cad_kol + 1.

         end.
      end.
  end.

/*  for each txb.aaa where txb.aaa.stadt  < v-dbeg and  lookup(txb.aaa.lgr,"151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,249,250") <> 0 no-lock :*/
    for each txb.aaa where txb.aaa.stadt  < v-dbeg and  lookup(txb.aaa.lgr,"151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,176,177,130,131,132,137,142") <> 0 no-lock :
      /*if length(txb.aaa.aaa) = 20 then next.*/
      sm = 0. v-cls = 0.

      find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
      if not avail txb.cif then next.
      find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif  and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
      if (txb.cif.type = "b" or (txb.cif.type = "p" and txb.sub-cod.ccode = "0")) then do:
         run lonbal3('cif', txb.aaa.aaa, v-dbeg - 1, "1", yes, output sm).
         find last tom where tom.pp = "TU" exclusive-lock.

         if txb.aaa.crc = 1  then tom.df_kzt_sum = tom.df_kzt_sum + sm.
         if txb.aaa.crc = 2  then tom.df_usd_sum = tom.df_usd_sum + sm.
         if txb.aaa.crc = 3  then tom.df_eur_sum = tom.df_eur_sum + sm.
         if txb.aaa.crc = 4  then tom.df_rur_sum = tom.df_rur_sum + sm.
         if txb.aaa.crc = 6  then tom.df_gbp_sum = tom.df_gbp_sum + sm.
         if txb.aaa.crc = 7  then tom.df_sek_sum = tom.df_sek_sum + sm.
         if txb.aaa.crc = 8  then tom.df_aud_sum = tom.df_aud_sum + sm.
         if txb.aaa.crc = 9  then tom.df_chf_sum = tom.df_chf_sum + sm.
         if txb.aaa.crc = 10 then tom.df_zar_sum = tom.df_zar_sum + sm.
         if txb.aaa.crc = 11 then tom.df_cad_sum = tom.df_cad_sum + sm.

         find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
         if avail txb.aadrt then do:
            if txb.aadrt.who = "C" and txb.aadrt.whn < v-dbeg then v-cls = 1.
         end.
         if v-cls <> 1 then do:
            if txb.aaa.crc = 1  then tom.df_kzt_kol = tom.df_kzt_kol + 1.
            if txb.aaa.crc = 2  then tom.df_usd_kol = tom.df_usd_kol + 1.
            if txb.aaa.crc = 3  then tom.df_eur_kol = tom.df_eur_kol + 1.
            if txb.aaa.crc = 4  then tom.df_rur_kol = tom.df_rur_kol + 1.
            if txb.aaa.crc = 6  then tom.df_gbp_kol = tom.df_gbp_kol + 1.
            if txb.aaa.crc = 7  then tom.df_sek_kol = tom.df_sek_kol + 1.
            if txb.aaa.crc = 8  then tom.df_aud_kol = tom.df_aud_kol + 1.
            if txb.aaa.crc = 9  then tom.df_chf_kol = tom.df_chf_kol + 1.
            if txb.aaa.crc = 10 then tom.df_zar_kol = tom.df_zar_kol + 1.
            if txb.aaa.crc = 11 then tom.df_cad_kol = tom.df_cad_kol + 1.

         end.
      end.
  end.

procedure lonbal3.

define input  parameter p-sub like txb.trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like txb.jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

if p-dt > g_date then p-dt = g_date. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g_date then do:
     for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
         if lookup(string(txb.trxbal.level), p-lvls) > 0 then do:

            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.trxbal.dam - txb.trxbal.cam.
	    else res = res + txb.trxbal.cam - txb.trxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
	    for each txb.jl where txb.jl.acc = p-acc
                          and txb.jl.jdt >= p-dt
                          and txb.jl.lev = 1 no-lock:
	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res - txb.jl.dam + txb.jl.cam.
            else res = res + txb.jl.dam - txb.jl.cam.
            end.

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last txb.histrxbal where txb.histrxbal.subled = p-sub
                              and txb.histrxbal.acc = p-acc
                              and txb.histrxbal.level = integer(entry(i, p-lvls))
                              and txb.histrxbal.dt <= p-dt no-lock no-error.
        if avail txb.histrxbal then do:
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
                                 and txb.histrxbal.dt < p-dt no-lock no-error.
       if avail txb.histrxbal then do:
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.

end.