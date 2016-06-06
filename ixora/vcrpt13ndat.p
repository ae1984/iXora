/* vcrpt13ndat.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 13 - Отчет о движении средств по валютному контролю
        Сборка данных во временную таблицу по всем филиалам
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        10.4.1.12
 * AUTHOR
        10.02.2006 u00600
 * CHANGES
        06/06/2006 u00600 - добавила поле rmztmp_ncrcK в таблицу rmztmp
        
*/


{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.
def var v-partnername as char no-undo.
def var v-name as char no-undo.
def var v-sum as deci no-undo.
def var v-dnum as char no-undo.

def shared temp-table rmztmp
    field rmztmp_name   as char    /* отправитель */
    field rmztmp_bn     as char    /* бенефициар */
    field rmztmp_dt     as date format "99/99/9999"   /* дата платежа */
    field rmztmp_ncrc   as char    /* валюта платежа */
    field rmztmp_ncrcK  as integer /* код валюты платежа */
    field rmztmp_summ   as deci    /* сумма платежа */
    field rmztmp_knp    as char    /* назначение платежа */
    field rmztmp_rnn    as char
    field rmztmp_str    as char
    field rmztmp_pr1    as char    /* примечание */
    field rmztmp_pr2    as char
    field rmztmp_pr3    as char
    field rmztmp_pr4    as char
    field rmztmp_pr5    as char.
  
 /* Контракты с типом 13 с платежом/поступлением в отчетном периоде */
  for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = '13' no-lock:
    
    for each vcdocs where vcdocs.contract = vccontrs.contract
                      and (vcdocs.dntype  = "02" or vcdocs.dntype = "03")
                      and vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte
                      no-lock:
    
    /* Наименование клиента */
    find first txb.cif where txb.cif.cif = vccontrs.cif no-lock  no-error.
    v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).

    /* Наименование инопартнера */
    find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
    if avail vcpartner then do:
       v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
    end.
    else do: 
      v-partnername = "". 
    end.

    /* Наименование страны */
    find first txb.codfr where txb.codfr.codfr = 'iso3166'
                     and txb.codfr.code = vcpartner.country no-lock no-error.

    /* Номер свидетельства об уведомлении */
    find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "64" no-lock no-error.
    if avail vcrslc then v-dnum = vcrslc.dnnum.
    else v-dnum = ''.

    /* Валюта платежа */
    find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error. 
  
    create  rmztmp.
    assign rmztmp.rmztmp_name  =  v-name.
           rmztmp.rmztmp_bn    =  v-partnername.
           rmztmp.rmztmp_dt    =  vcdocs.dndate.
           rmztmp.rmztmp_ncrc  =  txb.ncrc.code.          /*валюта*/
           rmztmp.rmztmp_ncrcK =  txb.ncrc.stn.          /*код валюты*/
           rmztmp.rmztmp_summ  =  (vcdocs.sum / 1000).
           rmztmp.rmztmp_knp   =  vcdocs.knp.                                  
           rmztmp.rmztmp_pr1   =  vccontrs.ctnum + "  от  " + string(vccontrs.ctdate) + " г.".  /* номер и дата*/
           if txb.cif.ssn = "000000000" or txb.cif.ssn = "" then do:   /* ОКПО, РНН */
              rmztmp.rmztmp_rnn = "РНН: " + txb.cif.jss.
           end.
           else do:
              rmztmp.rmztmp_rnn = "ОКПО: " + txb.cif.ssn + " РНН: " + txb.cif.jss.
           end.           
           rmztmp.rmztmp_pr2   =  txb.cif.addr[1] + " " + txb.cif.addr[2]. /* адрес */
           rmztmp.rmztmp_pr3   =  txb.codfr.name[1]. /* страна клиента-нерезидента */
           rmztmp.rmztmp_str   =  vcpartners.address. /* адрес нерезидента */
           rmztmp.rmztmp_pr4   =  vcpartner.bankdata.  /* реквизиты банка */
           if v-dnum = "" then do:
              rmztmp.rmztmp_pr5  = v-dnum. /* номер свидетельства об уведомлении */
           end.
           else do:
              rmztmp.rmztmp_pr5  =  "8) Номер свидетельства об уведомлении " + v-dnum. /* номер свидетельства об уведомлении */
           end.

  end.
  end.
