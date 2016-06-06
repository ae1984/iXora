/* pkcifnew.i
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Расчет сумм и проставление исключений клиенту при выдаче кредита
 * RUN
      
 * CALLER
        pkcifnew.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.x.1
 * AUTHOR
        01.02.2003 sasco
 * CHANGES
        28.04.2003 nadejda - в поле офицера теперь пишется признак 'установлено вручную или по временным льготным тарифам' - "M"
        07.08.2003 nadejda - изменила вызов процедуры проставления исключений по тарифам, теперь cif передается как параметр
        15.01.2004 nadejda - при проставлении исключений не менять офицера и дату по уже существующим исключениям
        08.12.2004 saltanat - берутся тарифы со статусом "r" - рабочий.
        13/05/2005 madiyar  - комиссия за ведение тек.счета по БД - из справочника
        23/08/2005 madiyar  - код комиссии поменялся с 141 на 230
        25.08.2005 saltanat - Выборка льгот по счетам.
        03/10/2005 madiyar  - (филиалы) комиссия за ведение тек.счета по БД - из справочника
        05/12/2005 madiyar  - исправил ошибку: при наклыдывании льгот, не править сумму в льготе на клиента
        14/04/2006 madiyar  - новые льготы 180, 181, 193
        15/01/07 marinav - тариф за ведение кредита в %% от суммы кредита
        04.06.2008 madiyar - валютный контроль 
        19.09.2008 galina - проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. комиссию за ведение счета из справочника      
        02.06.2009 galina - по рефининсированию не подтягиваем спец.условия
*/

/* сумма комиссии в зависимости от запрошенной суммы */
function pk-tarif returns decimal ( sum as decimal ).
define var sumresult as deci.

  sumresult = 0.
  run value("pk-tarif-" + s-credtype) (0, sum, output sumresult).
  return sumresult.
end.

/* сумма комиссии в зависимости от окончательной суммы кредита */
function pk-tariffin returns decimal ( sum as decimal ).
define var sumresult as deci.

  sumresult = 0.
  run value("pk-tarif-" + s-credtype) (1, sum, output sumresult).
  return sumresult.
end.

/* сумма страховки */
function pk-strsum returns decimal ( sum as decimal ).
    return 0.0.
end function.

/* полная сумма */
function pk-fullsum returns decimal ( sum as decimal ).
    return sum + pk-tarif (sum) + pk-strsum (sum).
end.

procedure add-excl.
  def input parameter p-aaa as char.
  def input parameter p-cif as char.
  def input parameter p-kod as char.

  find tarif2 where tarif2.str5 = p-kod and tarif2.stat = 'r' no-lock no-error.
  if avail tarif2 then do:

    find tarifex where tarifex.cif  = p-cif and tarifex.str5 = p-kod
                   and tarifex.stat = 'r' exclusive-lock no-error.
    if not avail tarifex then do:
      create tarifex.
      assign tarifex.cif    = p-cif
             tarifex.kont   = tarif2.kont
             tarifex.pakalp = "Временно - потреб кредит"
             tarifex.str5   = p-kod
             tarifex.crc    = 1
             tarifex.who    = "M" + g-ofc /* признак 'установлено вручную или по временным льготным тарифам' 28.04.2003 nadejda */
             tarifex.whn    = g-today
             tarifex.stat   = 'r'
             tarifex.wtim   = time
             tarifex.ost  = tarif2.ost
             tarifex.proc = tarif2.proc
             tarifex.max1 = tarif2.max1
             tarifex.min1 = tarif2.min1.
      run tarifexhis_update.
    end.
    /*
    assign tarifex.ost  = tarif2.ost
           tarifex.proc = tarif2.proc
           tarifex.max1 = tarif2.max1
           tarifex.min1 = tarif2.min1.
    */
    find tarifex2 where tarifex2.aaa = p-aaa
                   and tarifex2.cif  = p-cif and tarifex2.str5 = p-kod
                   and tarifex2.stat = 'r' exclusive-lock no-error.
    if not avail tarifex2 then do:
      create tarifex2.
      assign tarifex2.aaa    = p-aaa
             tarifex2.cif    = p-cif
             tarifex2.kont   = tarif2.kont
             tarifex2.pakalp = "Временно - потреб кредит"
             tarifex2.str5   = p-kod
             tarifex2.crc    = 1
             tarifex2.who    = "M" + g-ofc /* признак 'установлено вручную или по временным льготным тарифам' 28.04.2003 nadejda */
             tarifex2.whn    = g-today
             tarifex2.stat   = 'r'
             tarifex2.wtim   = time.
      run tarifex2his_update.
    end.
    assign tarifex2.ost  = 0
           tarifex2.proc = 0
           tarifex2.max1 = 0
           tarifex2.min1 = 0.
    
    /* по БД - комиссия за ведение ссудного счета из справочника */
    if p-kod = "195" then do:
      
      find first aaa where aaa.aaa = p-aaa no-lock no-error.
      if not avail aaa then do:
          message " Не найден счет " p-aaa "! В исключения по 195 тарифу не проставлена валюта! " view-as alert-box error.
      end.
      else assign tarifex.crc = aaa.crc tarifex2.crc = aaa.crc.
      
      find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
      if avail pksysc then tarifex2.ost = pkanketa.summa * pksysc.deval / 100.
      
      /*02.09.2008 galina проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. комиссию за ведение счета из справочника*/      
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
      if not avail pkanketh or pkanketh.rescha[1] = '' or pkanketh.resdec[1] = 0 then do:
          find last lnpriv where lnpriv.credtype = s-credtype and lnpriv.bank = s-ourbank and (g-today >= lnpriv.dtb and lnpriv.dte > g-today) and lnpriv.rnn = trim(pkanketa.jobrnn) no-lock no-error.
          if avail lnpriv then tarifex2.ost = pkanketa.summa * lnpriv.comacc / 100.
      end.    
     
    end.
            
    release tarifex.
  end.
end procedure.


/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
create tarifexhis.
buffer-copy tarifex to tarifexhis.
end procedure.

procedure tarifex2his_update.
create tarifex2his.
buffer-copy tarifex2 to tarifex2his.
end procedure.

procedure pk-tarif-ex.
   def input parameter v-aaa as char no-undo.
   def input parameter v-cif as char no-undo.
   def input parameter v-loan_comiss as logical no-undo.

/* исключения по ТЕНГЕ по внутренним проводкам ставим всегда */
   if v-loan_comiss then run add-excl(v-aaa, v-cif, "195").
   run add-excl(v-aaa, v-cif, "230").
   run add-excl(v-aaa, v-cif, "141").
   run add-excl(v-aaa, v-cif, "142").
   
   run add-excl(v-aaa, v-cif, "180").
   run add-excl(v-aaa, v-cif, "193").
   
/* если выбрано предприятие-партнер ВНЕШНЕЕ, то ставим внешние дебетовые тенговые исключения - сумма 0! */
   find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
   if avail codfr and codfr.name[4] <> "" and num-entries(codfr.name[4], "|") >= 6 then do:
     run add-excl(v-aaa, v-cif, "214").
     run add-excl(v-aaa, v-cif, "163").
  /* ВНЕШНИЕ кредитовые не ставим!
     run add-excl(v-cif, "164").
  */
   end.

/* если валюта кредита не тенге - ставим валютные исключения */
   if pkanketa.crc <> 1 then do:
     run add-excl(v-aaa, v-cif, "105").
     run add-excl(v-aaa, v-cif, "165").
     run add-excl(v-aaa, v-cif, "166").
     run add-excl(v-aaa, v-cif, "181").
  /* ВНЕШНИЕ валютные не ставим!
     run add-excl(v-cif, "167").
     run add-excl(v-cif, "168").
  */
   end.
end procedure.
