/* 2ltrx_out.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Для валютных платежей на очереди 2L :
           - по ранее определенным данным после проводки выдается уведомление
           - если это была проводка на счет клиента, то накладывается специнструкция на счет до акцепта платежа
 * RUN
        
 * CALLER
        2ltrx.i
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-9-3
 * AUTHOR
        01.11.2002 kanat - stdoc_out.i
 * CHANGES
        02.10.2003 nadejda  - изменены уведомления при блокировке суммы
                              если проводка пошла на ARP - не запрашивать накладывание специнструкции
        08.10.2003 nadejda  - файл stdoc_out разбит на 2 части, выдача уведомлений перенесена в 2ltrx_out.i
        09.10.2003 nadejda  - при блокировании суммы на транзитном счете создается запись в таблице vcblock - список блокированных сумм
        02.07.2004 sasco    - добавил new shared для s-contrstat
        15.07.2004 saltanat - добавлена переменная valuta для того, чтобы при тенгов.суммах печаталось "Нац.валюта"
                              а в ост.-х случаях "иностранная валюта"  
        29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
        09/01/2006 nataly -  вынесла v-dep за цикл
	    28.02.2006 u00121  - добавил last во все find + no-undo
	    26.08.2009 galina - изменила форму письма для уведомления клиента
*/

def new shared var s-contrstat as char initial 'all'.
def var valuta as char init "иностран" no-undo.
def var  v-dep as char no-undo.

s-vcourbank = seltown.

vc_cifname = trim(remtrz.bn[1]).

find first ncrc where ncrc.crc = remtrz.tcrc no-lock no-error.        
if avail ncrc then do: 
  vc_crcdes = ncrc.des.
  vc_crccod = ncrc.code.
end.

if remtrz.tcrc = 1 then valuta = "Националь".

  find first aaa where aaa.aaa = trim(remtrz.ba) no-lock no-error. 
  if avail aaa then do:
    s-cif = aaa.cif.
    find cif where cif.cif = s-cif no-lock no-error.
    v-dep = string(int(cif.jame) - 1000) .
   end.
remtrz_usd = remtrz.amt. 
run Sm-vrd(remtrz_usd, output s_remtrz_usd) no-error.

if return_choice then do:
  find first aaa where aaa.aaa = v-racc no-lock no-error. 

  if avail aaa then do:
    s-cif = aaa.cif.

    run h-contract.

    find first vccontrs where vccontrs.contract = s-contract no-lock no-error.
    if avail vccontrs then do:

      update    vc_dnnum label "Введите номер документа"
                with centered overlay row 5 side-label title "Номер документа" frame dn_number_ask.  
      hide frame dn_number_ask.

      update    vc_remknp label "Введите код назначения платежа"
                with centered overlay row 5 side-label title "КНП" frame knp_ask.    
      hide frame knp_ask.

      run crosscurs(remtrz.tcrc, vccontrs.ncrc, g-today, output vc_kross).

      do transaction:
        vc_docs = NEXT-VALUE(vc-docs).
        
        CREATE vcdocs.
               ASSIGN  
                       vcdocs.docs = vc_docs 
                       vcdocs.contract = s-contract
                       vcdocs.dntype = "02"
                       vcdocs.dnnum = vc_dnnum
                       vcdocs.remtrz = remtrz.remtrz
                       vcdocs.dndate = g-today
                       vcdocs.pcrc = remtrz.tcrc
                       vcdocs.sum = remtrz.amt
                       vcdocs.knp = vc_remknp
                       vcdocs.payret = YES
                       vcdocs.cursdoc-con = vc_kross
                       vcdocs.kod14 = ""
                       vcdocs.info[1] = ""
                       vcdocs.rdt = g-today
                       vcdocs.rwho = g-ofc
                       vcdocs.udt = today
                       vcdocs.uwho = g-ofc
                       vcdocs.origin = no.

        run vc2hisdocs(vcdocs.docs, "Документ зарегистрирован " + string(vcdocs.dnnum) + " " + string(vcdocs.dndate)).
      end.
    end. 
    else do:
      message " Введенный номер контракта отсутствует!". 
      pause. 
    end.
  end. /*avail aaa*/

  MESSAGE skip " Сформировать уведомление на сумму" remtrz.amt "?" skip(1)
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
      TITLE " ВАЛЮТНЫЙ КОНТРОЛЬ - УВЕДОМЛЕНИЕ "
      UPDATE state_choice.

  if state_choice then do:
    out = "statnmb.html".

    OUTPUT STREAM s1 TO value(out).

    {html-title.i &stream = " stream s1 " &size-add="x-"} 

    run putheader ("&nbsp;").

    put stream s1 unformatted  
      "на Ваш счет зачислена " valuta "ная валюта в сумме: " replace(string(remtrz_usd, ">>>,>>>,>>>,>>>,>>9.99"), ",", "&nbsp;") "&nbsp;" vc_crccod " (" + vc_crcdes + ")<br>" skip
      "____________________________________________________________________________ <br>" skip
      "которая была возвращена из-за невыполнения нерезидентом своих обязательств перед " skip
      "Вами или по причине указания Вами ошибочных реквизитов в платежном поручении " skip
      "(нужное подчеркнуть)." skip
      "<br><br><br><br>" skip
      "Просим принять к сведению, что согласно правилам НацБанка РК эту " valuta "ную " skip
      "валюту Вы вправе использовать в течение 10 календарных дней со дня ее зачисления " skip
      "на Ваш счет при наличии документов, требуемых валютным законодательством. " skip
      "По истечении 10 календарных дней Банк обязан произвести обязательную продажу " skip
      "этой валюты на внутреннем валютном рынке." skip.

    run putsign (no).

    {html-end.i " stream s1 "} 

    OUTPUT STREAM s1 CLOSE.
    unix silent cptwin value(out) iexplore.
    unix silent rm -f value(out).
  end.
end.

if block_choice then do:
  /* записать платеж в список блокированных сумм */
  do transaction:
    find last vcblock where vcblock.bank = s-vcourbank and vcblock.remtrz = remtrz.remtrz no-lock no-error. /*u00121 28.02.2006 добавил last */
    if not avail vcblock then do:
      create vcblock.
      assign vcblock.bank = s-vcourbank 
             vcblock.remtrz = remtrz.remtrz.
    end.
    else find current vcblock exclusive-lock.

    find last sub-cod where sub-cod.sub = "arp" and sub-cod.acc = v-arp and sub-cod.d-cod = "sproftcn" no-lock no-error. /*u00121 28.02.2006 добавил last */
    
    assign vcblock.remracc = remtrz.racc
           vcblock.remname = vc_cifname
           vcblock.remdetails = trim(remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4])
           vcblock.amt = remtrz.amt
           vcblock.crc = remtrz.tcrc
           vcblock.arp = v-arp
           vcblock.depart = if avail sub-cod and sub-cod.ccode <> "msc" then sub-cod.ccode else "506"
           vcblock.sts = "B"
           vcblock.jh1 = remtrz.jh2
           vcblock.jh2 = 0
           vcblock.acc = ""
           vcblock.rdt = g-today
           vcblock.rwho = g-ofc
           vcblock.retremtrz = ""
           vcblock.deldt = ?
           vcblock.delwho = "".
    release vcblock.
    if num-entries(vc_cifname,'/') > 1 then vc_cifname = entry(1,vc_cifname,'/').

    run vcletter(4,'','',vc_cifname, remtrz.remtrz).
    
  end.
  
  /* если это не возврат, то нужны уведомления о блокировке */
/*  if not return_choice then do:
    MESSAGE " Сумма подлежит лицензированию или регистрации в НацБанке?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
        TITLE " ВАЛЮТНЫЙ КОНТРОЛЬ - ЗАЧИСЛЕНИЕ НА ТРАНЗИТНЫЙ СЧЕТ "
        UPDATE cbreg_choice.

    if cbreg_choice then do:
      out = "statnmb1.html".

      OUTPUT STREAM s1 TO value(out).

      {html-title.i &stream = " stream s1 " &size-add="x-"} 

      run putheader ("041202.171 ДВК").
        
      put stream s1 unformatted  
        "поступившая в Ваш адрес " valuta "ная валюта в сумме: " replace(string(remtrz_usd, ">>>,>>>,>>>,>>>,>>9.99"), ",", "&nbsp;") "&nbsp;" vc_crccod " (" + vc_crcdes + ")<br>" skip
        "___________________________________________________________________________ <br>" skip
        "по контракту _____________________________________________________________ и по паспорту сделки _________________________________________________________<br>" skip
        "согласно статьи 38 Закона Республики Казахстан ""О платежах и переводах денег на территории Республики Казахстан"" заблокирована на транзитном счете до предоставления в Банк лицензии " skip
        "и/или регистрационного свидетельства Национального Банка Республики Казахстан (нужное подчеркнуть), т.к. данная операция связана с движением капитала.<br>" skip
        "<br><br>" skip
        "Просим принять к сведению, что в случае непредоставления Вами лицензии и/или регистрационного свидетельства (нужное подчеркнуть) по " skip
        "истечении 30 календарных дней с даты поступления денег, Банк обязан сообщить об этом факте Национальному Банку Республики Казахстан." skip.

      run putsign (no).

      {html-end.i " stream s1 "}
      
      OUTPUT STREAM s1 CLOSE.

      unix silent cptwin value(out) iexplore.
      unix silent rm -f value(out).

    end.     
    else do:
      out = "statnmb2.html".

      OUTPUT STREAM s1 TO value(out).

      {html-title.i &stream = " stream s1 " &size-add="x-"} 

      run putheader ("041202.170 ДВК").

      put stream s1 unformatted  
        "на счет вашей фирмы поступила " valuta "ная валюта в сумме: " replace(string(remtrz_usd, ">>>,>>>,>>>,>>>,>>9.99"), ",", "&nbsp;") "&nbsp;" vc_crccod " (" + vc_crcdes + ")<br>" skip
        "___________________________________________________________________________. <br>" skip
        "Согласно статьи 38 Закона Республики Казахстан ""О платежах и переводах денег на территории Республики Казахстан"" данная сумма заблокирована на транзитном счете. " skip
        "Вам необходимо предоставить в АО ""TEXAKABANK"" документы для дальнейшего валютного контроля: <br>"  skip 
        "<B>- контракт, паспорта сделок, инвойсы и официальное письмо с указанием характера поступивших денег." skip.

      run putsign (yes).
      
      {html-end.i  " stream s1 "} 

      OUTPUT STREAM s1 CLOSE.

      unix silent cptwin value(out) iexplore. 
      unix silent rm -f value(out).
    end.*/
    
  /*end.*/
end.
else do:
  if blockvc_choice then do:
    /* наложить специнструкцию и снять ее при акцепте платежа */
    find first jl where jl.jh = remtrz.jh2 and jl.sub = "cif" and jl.dc = "c" no-lock no-error.
    if avail jl then run jou-aasnew (jl.acc, remtrz.amt, remtrz.jh2).
  end.
end.


procedure putheader.
  def input parameter v-number as char.
  put stream s1 unformatted
    "<P align=""center""><TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<tr><td colspan=""3""><img src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR></td></tr>" skip
    "<tr><td colspan=""3"">&nbsp;</td></tr>" skip
    "<tr><td colspan=""3"">" v-number "</td></tr>" skip
    "<tr><td colspan=""3"">&nbsp;</td></tr>" skip
    "<tr><td colspan=""3"" align=""center"" style=""font-size:small;font:bold""><P>УВЕДОМЛЕНИЕ</P></td></tr>" skip
    "<tr><td colspan=""3""><P>&nbsp;</P></td></tr>" skip
    "<tr><td width=""25%"" align=""right""><U>" string(g-today, "99/99/9999") "</U></td><TD width=""40%"">&nbsp;</TD><TD>" vc_cifname "</TD></tr>" skip
    "<TR><TD colspan=""3"">" skip
    "<P>&nbsp;</P><P>&nbsp;</P>" skip
    "<P align=""justify"">УВАЖАЕМЫЙ КЛИЕНТ: " vc_cifname "<BR><BR>АО ""TEXAKABANK"" уведомляет, что " skip.
end.

procedure putsign.
  def input parameter v-sign as logical.
  def var v-depname as char no-undo.
  def var v-deppos as char no-undo.
  def var v-tel as char no-undo.

 if v-dep = "" then do:
  find last sysc where sysc.sysc = "vc-dep" no-lock no-error. /*u00121 28.02.2006 добавил last */
  if avail sysc and sysc.chval <> "" then do:
    v-depname = entry(1, trim(sysc.chval)).
    if num-entries(sysc.chval) > 1 then 
      v-deppos = entry(2, trim(sysc.chval)). 
    else 
      v-deppos = "/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/".
    if num-entries(sysc.chval) > 2 then v-tel = entry(3, trim(sysc.chval)). else v-tel = "".
  end.
  else do:
    message " Нет сведений об ответственном лице валютного контроля!". pause 3 no-message.
    v-deppos = "/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/".
    v-depname = "/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/".
    v-tel = "".
  end. 
end. 
else do:
  find first codfr where codfr = 'vchead' and codfr.code = v-dep no-lock no-error .
  if avail codfr and codfr.name[1] <> "" then do:
     v-depname = entry(2, trim(codfr.name[1])).
  if num-entries(codfr.name[1]) > 1 then
     v-deppos = entry(1, trim(codfr.name[1])).
    else 
      v-deppos = "/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/".
    if num-entries(codfr.name[1]) > 2 then v-tel = entry(3, trim(codfr.name[1])). else v-tel = "".
  end.
  else do:
    message " Нет сведений об ответственном лице валютного контроля!". pause 3 no-message.
    v-deppos = "/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/".
    v-depname = "/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/".
    v-tel = "".
  end. 
end.  /*v-dep <> ""*/ 
  put stream s1 unformatted
    "</P><P>&nbsp;</P>" skip
    "<P align=""center"">" skip
    "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
      "<TR valign=""bottom"">"
          "<TD width=""30%"">" v-deppos if v-tel = "" then "" else "<BR>тел.&nbsp;" + v-tel "</TD>" skip
          "<TD width=""35%"" align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD>"
          "<TD>" v-depname "</TD>" skip
      "</TR>" skip.

  if v-sign then 
    put stream s1 unformatted
        "<TR><TD colspan=""3""><P>&nbsp;</P></TD></TR>" skip
        "<TR><TD colspan=""3"">""&nbsp;<U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U>&nbsp;""&nbsp;&nbsp;<U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U>&nbsp;&nbsp;20&nbsp;<U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U>&nbsp;г.</TD></TR>" skip
        "<TR valign=""top""><TD>Дата вручения</TD>" skip
            "<TD align=""center""><U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U></TD>" skip
            "<TD>Ф.И.О., должность и подпись лица, получившего Уведомление</TD>" skip
        "</TR>" skip.

  put stream s1 unformatted
    "</TABLE></P></TABLE></P>" skip.
end.



