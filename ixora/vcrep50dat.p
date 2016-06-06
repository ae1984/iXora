/* vcrep50dat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по физ. лицам для НБ РК
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        17.01.2006 u00600 - переделала в консолидированный отчет и в соответствии с новыми требованиями НБ
 * CHANGES
        05.04.2006 u00600 - изменения соглано ТЗ ї297 от 30.03.06 (Нац.Банк)
        12.05.2006 u00600 - добавила проверку на блокировку по входящим платежам и разблокированных платежей
        05.05.2008 galina - изменения в согласно Правил ОВК от 11.12.2006 на состояние 25.06.2007
        08.05.2008 galina - перекомпеляция
        13.05.2008 galina - выводим в отчет описание КНП
        13.08.08 galina - выводим в отчет платежи типа 4 (наш банк -> участник) с банком получателем VALOUT
        08.01.2009 galina - выводим в отчет платежи типа 3 (участник -> наш банк), где банк отправитель НЕ Участник или страна отправителя/получателя не KZ
        09.01.2009 galina - страна отправителя/получателя проверяется в начале, убрала повторную проверку
                            не проверяем банк отправителя/получателя
        18.03.2009 galina - выводим в отчет платежи типа 2 (участник -> неучастник)
        02/11/2009 galina - выводим платежи физ.лиц без открытия в эквиваленте более 10 тыс.долларов
                            и с открытием в эквиваленте 50 тыс.долларов
                            добавила ИИН
        27/05/2010 galina - выводим кнп в файл для статистики
        19/11/2010 aigul - исправила crchis.regdt на crchis.rdt
        6/12/2010 aigul - исправила crchis на ncrchis для подтягивания курса с пм 2-5-3-2 1-го значения (тоесть курс на начало опер дня)

*/


define shared var g-ofc    like ofc.ofc.
def  shared var v-god as integer format "9999".
def  shared var v-month as integer format "99".
def shared var v-dtb as date format "99/99/9999".
def shared var v-dte as date format "99/99/9999".
def shared var v-pay as integer.
def var v-rnn as char no-undo.
def var v-rnnd as deci no-undo.
def var v-knp as char no-undo.
def var v-knpK as char no-undo.
def var v-bn as char no-undo.

def shared temp-table rmztmp
    field rmz       as char
    field rmztmp_aaa       as char
    field rmztmp_cif       as char
    field rmztmp_fio       as char
    field rmztmp_rez1      as char
    field rmztmp_rnn       as char
    field rmztmp_tranz     as char
    field rmztmp_tranzK    as char
    field rmztmp_knp       as char
    field rmztmp_knpK       as char /*КНП*/
    field rmztmp_dt        as date
    field rmztmp_bc        as char /*ї банковского счета*/
    field rmztmp_st        as char /*страна получения/отправления*/
    field rmztmp_stch      as char /*буквенный код страны*/
    field rmztmp_stK       as char /*код страны получения/отправления*/
    field rmztmp_rez2      as char
    field rmztmp_sec       as char /*сектор экономики*/
    field rmztmp_secK      as char /*код сектор экономики*/
    field rmztmp_bn        as char /*наименование отправителя/получателя 28.02.2006*/
    field rmztmp_crc       like ncrc.code  /*валюта*/
    field rmztmp_crcK      like ncrc.stn   /*код валюты*/
    field rmztmp_camt      as deci
    field rmztmp_uamt      as deci
    field rmztmp_bin       as char
    field rmztmp_bank       as char.

def var v-amtusd as deci no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-fio    as char no-undo.
def var v-bank   as char no-undo.
def var v-rez1 as char no-undo. def var v-rez2 as char no-undo.
def var v-tranz as char no-undo. def var v-tranzK as char no-undo.
def var v-dt as date format "99/99/9999" no-undo.
def var v-ncrc as char  no-undo.  def var v-ncrcK as integer no-undo.   /*char*/
def var v-sec as char no-undo. def var v-secK as char no-undo.
def var v-amt as deci no-undo. def var v-stK as char no-undo.
def var rep_f as logi initial false no-undo.
def var v-bin as char no-undo.

/*по всем платежам*/
for each remtrz where remtrz.valdt2 >= v-dtb and remtrz.valdt2 <= v-dte and
         ((v-pay = 2 and string(remtrz.drgl) begins '1052') or (v-pay = 1 and string(remtrz.crgl) begins '1052') or
          (v-pay = 2 and string(remtrz.drgl) begins '1351') or (v-pay = 1 and string(remtrz.crgl) begins '1351')) no-lock.

 run rep50-remtrz(remtrz.remtrz).

end.

/*по разблокированным в текущем месяце*/
  for each vcblock where vcblock.sts = 'C' and vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte no-lock.

  find first rmztmp where rmztmp.rmz = vcblock.remtrz no-lock no-error.
  if avail rmztmp then next.

    find first remtrz where remtrz.remtrz = vcblock.remtrz  and
    ((v-pay = 2 and string(remtrz.drgl) begins '1052') or (v-pay = 1 and string(remtrz.crgl) begins '1052') or
    (v-pay = 2 and string(remtrz.drgl) begins '1351') or (v-pay = 1 and string(remtrz.crgl) begins '1351')) no-lock no-error.

    if avail remtrz then do: rep_f = true. run rep50-remtrz(remtrz.remtrz). end.

  end.

procedure rep50-remtrz.
def input parameter v-remtrz like remtrz.remtrz.

v-rnn = ''. v-rnn = ''. v-bn = ''. v-tranz = ''. v-tranzK = ''. v-rez1 = ''. v-rez2 = ''. v-ncrc = ''. v-ncrcK = 0.
v-sec = ''. v-secK = ''. v-stK = ''.

find first remtrz where remtrz.remtrz =  v-remtrz no-lock no-error.
if avail remtrz then do:
/*валютному контролю подлежат не только операции в валюте, но и в тенге*/
/*if remtrz.fcrc = 1 then next. */

   find first sub-cod where sub-cod.sub   = 'rmz'
                       and sub-cod.acc   = remtrz.remtrz
                       and sub-cod.d-cod = 'zsgavail' no-lock  no-error.
   if avail sub-cod then do:
       if sub-cod.ccode <> "1" then next.
   end. else next.

   /*если страна бенефициара и отправителя казахстан то next*/
   find first sub-cod where sub-cod.sub = 'rmz'
			   and sub-cod.acc        = remtrz.remtrz
			   and sub-cod.d-cod      = 'iso3166'  no-lock no-error.
   if (sub-cod.ccode = 'KZ' or sub-cod.ccode = 'msc') then next.

  /* Если не физ лицо то next */
  find first sub-cod where sub-cod.sub   = 'rmz'
                           and sub-cod.acc   = remtrz.remtrz
                           and sub-cod.d-cod = 'eknp' no-lock  no-error.

   if avail sub-cod and
   (((remtrz.ptype = '6' or remtrz.ptype = '2' or (remtrz.ptype = '4' and remtrz.rbank = "VALOUT")) and substr(sub-cod.rcode,2,1) = "9" and v-pay = 1) or
     ((remtrz.ptype = '7'or (remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and substr(sub-cod.rcode,5,1) = "9" and v-pay = 2 ))
   then do:

         v-knpK = substr(sub-cod.rcode,7,3).
         /*исключить преводы между собственными счетами*/
         if trim(v-knpK) = '321' then next.

         find codfr where codfr.codfr = 'spnpl' and codfr.code = substr(sub-cod.rcode,7,3) no-lock no-error.
         v-knp = trim(codfr.name[1]). /*кнп*/

         if (remtrz.ptype = '6' or remtrz.ptype = '2' or (remtrz.ptype = '4' and remtrz.rbank = "VALOUT")) and v-pay = 1 then do:    /*30.03.2006 u00600*/
             v-tranz = "отправленный". v-dt = remtrz.valdt2.    /*"исходящий"*/
             v-tranzK = '1'.
             v-rez1 = substr(sub-cod.rcode,1,1).   /*резидентство клиента банка*/
             v-rez2 = substr(sub-cod.rcode,4,1).   /*резидентсво инопартнера*/
             v-secK = substr(sub-cod.rcode,5,1).  /*сектор экономики в кодовом значении*/

             find first codfr where codfr.codfr = 'secek'      /*исходящий - получатель 2-я пара, 5.1*/
                                  and   codfr.code  = substr(sub-cod.rcode,5,1) no-lock no-error.
                  if avail codfr then v-sec = codfr.name[1].   /*сектор экономики*/
                  else v-sec = ''.
         end.

         if (remtrz.ptype = '7'or (remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and v-pay = 2 then do: /*входящий*/

         /*если платеж блокирован, то пропускаем*/
         if rep_f = false then do:
         if remtrz.rsub = 'arp' then do:
           find first vcblock where vcblock.remtrz = remtrz.remtrz no-lock no-error.
              if avail vcblock then do:
                if vcblock.sts <> 'C' then next.
                if vcblock.sts = 'C' and (vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte) then v-dt = vcblock.deldt.
                /*else next.*/
              end.
         end.
         else v-dt = remtrz.valdt2.
         end.
         else do:
           find first vcblock where vcblock.remtrz = remtrz.remtrz no-lock no-error.
              if avail vcblock then do:
                if vcblock.sts = 'C' and (vcblock.deldt >= v-dtb and vcblock.deldt <= v-dte) then v-dt = vcblock.deldt.
                else next.
              end.
         end.

             v-tranz = "полученный". v-tranzK = '2'.
             v-rez1 = substr(sub-cod.rcode,4,1).    /*резидентство клиента банка*/
             v-rez2 = substr(sub-cod.rcode,1,1).    /*резидентсво инопартнера*/
             v-secK = substr(sub-cod.rcode,2,1).  /*сектор экономики в кодовом значении*/

             find first codfr where codfr.codfr = 'secek'     /*входящий - отправитель 1-я пара, 2.1*/
                                  and   codfr.code  = substr(sub-cod.rcode,2,1) no-lock no-error.
                  if avail codfr then v-sec = codfr.name[1].   /*сектор экономики*/
                  else v-sec = ''.
         end.

         if remtrz.fcrc = 2 then
             v-amtusd = remtrz.amt.
         else do:  /*перевод суммы платежа по курсу в доллары*/
                 find last ncrchis where ncrchis.crc = remtrz.fcrc and ncrchis.rdt <= remtrz.rdt - 1 no-lock no-error.
                    if avail ncrchis then
                       v-amtusd = remtrz.amt * ncrchis.rate[1].

                 find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= remtrz.rdt - 1 no-lock no-error.
                    if avail ncrchis then
                       v-amtusd = v-amtusd / ncrchis.rate[1].
         end.

         v-amt =  remtrz.amt. /*сумма в валюте платежа*/

 	 find first sub-cod where sub-cod.sub = 'rmz'
			   and sub-cod.acc        = remtrz.remtrz
			   and sub-cod.d-cod      = 'iso3166'  no-lock no-error.

	 find first codfr where codfr.codfr = sub-cod.d-cod
			 and  codfr.code        = sub-cod.ccode no-lock no-error.

	 find first code-st where code-st.code = codfr.code no-lock no-error.
	   if avail code-st then v-stK = code-st.cod-ch.
	      else v-stK = ''.


         if (remtrz.ptype = '6' or remtrz.ptype = '2' or (remtrz.ptype = '4' and remtrz.rbank = "VALOUT")) and v-pay = 1 then do:
               if index(remtrz.ord,"/RNN/") > 0 then do:
                    v-rnn = substr(remtrz.ord, index(remtrz.ord,"/RNN/") + 5, 12).
                    v-fio = substr(remtrz.ord, 1 , index(remtrz.ord,"/RNN/") - 1).
                    if index(v-fio,"ALMATY") > 0 then substr(v-fio, index(v-fio,'ALMATY'), 6) = " ".
                    if index(v-fio,"URALSK") > 0 then substr(v-fio, index(v-fio,"URALSK"), 6) = " " .
                    if index(v-fio,"ASTANA") > 0 then substr(v-fio, index(v-fio,"ASTANA"), 6) = " " .
                    if index(v-fio,"ATYRAU") > 0 then substr(v-fio, index(v-fio,"ATYRAU"), 6) = " " .
                    if index(v-fio,"KAZAKHSTAN") > 0 then substr(v-fio, index(v-fio,"KAZAKHSTAN"), 10) = " " .

                    v-rnnd = deci(v-rnn) no-error.
                    IF ERROR-STATUS:ERROR then assign v-rnn = remtrz.ord v-fio = remtrz.ord.
               end.
               IF trim(v-rnn) = '' then assign v-rnn = remtrz.ord v-fio = remtrz.ord.

             v-bn = remtrz.bn[1] + " " + remtrz.bn[2] + " " + remtrz.bn[3].  /*получатель 28.02.2006*/

         end.
         if (remtrz.ptype = '7'or (remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and v-pay = 2 then do:
                    find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
                    if avail aaa then do:
                       find first cif where cif.cif = aaa.cif no-lock no-error.
                       if avail cif then  assign v-rnn = cif.jss v-fio = cif.name v-bin = cif.bin.
                    end.
                    if v-rnn = '' then assign v-rnn = remtrz.bn[1] v-fio = remtrz.bn[1] .

                    v-bn = remtrz.ord. /*отправитель 28.02.2006*/
         end.

        /* Валюта платежа */
        find first ncrc where ncrc.crc = remtrz.fcrc no-lock no-error.
        if avail ncrc then do:
            v-ncrc = ncrc.code.
            v-ncrcK = ncrc.stn.
        end.

        create  rmztmp.
        assign  rmztmp.rmztmp_fio   =  v-fio
                rmztmp.rmz = remtrz.remtrz
                rmztmp.rmztmp_rez1  =  v-rez1
                rmztmp.rmztmp_rez2  =  v-rez2
                rmztmp.rmztmp_rnn   =  v-rnn
                rmztmp.rmztmp_tranz =  v-tranz
                rmztmp.rmztmp_tranzK =  v-tranzK
                rmztmp.rmztmp_knp = v-knp
                rmztmp.rmztmp_knpK = v-knpK
                rmztmp.rmztmp_dt    =  v-dt
                rmztmp.rmztmp_sec   =  v-secK        /*v-sec*/
                rmztmp.rmztmp_bn    =  v-bn
                rmztmp.rmztmp_crc   =  v-ncrc            /*валюта платежа*/
                rmztmp.rmztmp_crcK  =  v-ncrcK           /*код валюты платежа*/
                rmztmp.rmztmp_camt  =  v-amt / 1000      /*сумма в валюте платежа*/
                rmztmp.rmztmp_uamt  =  v-amtusd / 1000          /*сумма в долларах*/
                rmztmp.rmztmp_st    =  codfr.name[1] /*наименование страны*/
                rmztmp.rmztmp_stch  =  codfr.code /*буквенный код страны*/
        	    rmztmp.rmztmp_stK   =  v-stK.            /*код страны для статистики*/

        	    /*разобраться с входящими*/
        	    if v-pay = 1 then rmztmp.rmztmp_bank = remtrz.sbank.
        	    if v-pay = 2 then rmztmp.rmztmp_bank = remtrz.rbank.
        	    rmztmp.rmztmp_bin = v-bin.

		if (remtrz.ptype = '6' or remtrz.ptype = '2' or (remtrz.ptype = '4' and remtrz.rbank = "VALOUT")) and v-pay = 1 then rmztmp.rmztmp_bc  = remtrz.sacc.   /* исходящий */
		if (remtrz.ptype = '7' or (remtrz.ptype = '3' /*and not remtrz.sbank begins "TXB"*/)) and v-pay = 2 then rmztmp.rmztmp_bc  = remtrz.racc.   /* входящий */
    end.
end.
end.
